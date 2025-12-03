Here is the fully updated Markdown snippet using the **latest Node.js 24 (LTS)** and modern "Core" Linux images (Debian Bookworm), matching the improved Dockerfiles we created earlier.

#### Snippet of backend (Node.js) `Dockerfile`

You will find this `Dockerfile` in the `backend/` directory. This version uses **Multi-Stage Builds** to support both Development and Production from a single file.

```dockerfile
# syntax=docker/dockerfile:1.4

# ============================================================================
# BASE STAGE - Common dependencies
# ============================================================================
# Use Node.js 24 LTS on Debian Bookworm ("Core" Linux)
FROM node:24-bookworm AS base
LABEL maintainer="MERN Stack Team"

# Set working directory
WORKDIR /app

# Copy package files first (for efficient caching)
COPY package*.json ./

# ============================================================================
# DEPENDENCIES STAGE - Install all dependencies
# ============================================================================
FROM base AS dependencies
# 'npm ci' is faster and cleaner than 'npm install' for CI/Docker environments
RUN npm ci --verbose

# ============================================================================
# DEVELOPMENT STAGE - Development environment with hot reload
# ============================================================================
FROM dependencies AS development
LABEL stage="development"

# Argument passed from docker-compose
ARG NODE_PORT=5000
ENV PORT=${NODE_PORT}
ENV NODE_ENV=development

# Copy source code
COPY . .

# Install nodemon globally for hot-reloading
RUN npm install -g nodemon

# Expose the port
EXPOSE ${PORT}

# Start with nodemon for development
CMD ["nodemon", "server.js"]

# ============================================================================
# PRODUCTION STAGE - Optimized production build
# ============================================================================
FROM node:24-bookworm-slim AS production
LABEL stage="production"

ARG NODE_PORT=5000
ENV PORT=${NODE_PORT}
ENV NODE_ENV=production

# Install essential tools (dumb-init for signal handling)
RUN apt-get update && apt-get install -y --no-install-recommends dumb-init \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy production dependencies only (saves space)
COPY --from=dependencies /app/node_modules ./node_modules
# Prune devDependencies
RUN npm prune --production

# Copy application code
COPY . .

# Create non-root user for security
USER node

EXPOSE ${PORT}

# Use dumb-init as PID 1 to handle signals properly
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "server.js"]
```

##### Explanation of backend (Node.js) `Dockerfile`

- **Line 1**: Enables modern Docker syntax features.
- **Line 7**: Uses `node:24-bookworm`. This is the **latest LTS** version on standard Debian Linux ("Core"), replacing the older `stretch` image.
- **Line 14**: Copies `package*.json` first. This optimizes the build cache—if dependencies haven't changed, Docker skips the install step.
- **Line 21**: Uses `npm ci` instead of `npm install`. This is best practice for Docker builds as it installs the exact versions from `package-lock.json` faster and more reliably.
- **Line 26**: Starts the **Development Stage**. This stage includes full development tools like `nodemon`.
- **Line 30**: Captures `NODE_PORT` as a build argument and sets it as an environment variable.
- **Line 38**: Installs `nodemon` globally so we can watch files for changes during development.
- **Line 49**: Starts the **Production Stage**. Uses the `-slim` image variant to reduce size while keeping standard Linux compatibility (Debian Bookworm).
- **Line 57**: Installs `dumb-init`. This is critical for Node.js in production Docker containers to properly handle shutdown signals (SIGTERM/SIGINT).
- **Line 65**: Copies dependencies from the previous stage and runs `npm prune --production` to remove dev-only tools (like testing libraries), keeping the image small.
- **Line 71**: switches to the `node` user (UID 1000). Running as **non-root** is a mandatory security practice for production.
- **Line 76**: Uses `dumb-init` as the entrypoint to wrap the Node process.
- **Line 77**: Runs `node server.js` directly. In production, we never use `nodemon` or `npm run dev` for performance and stability.

###### :clipboard: `Note: This multi-stage setup allows you to use the same Dockerfile for both 'docker-compose.dev.yaml' (target: development) and 'docker-compose.prod.yaml' (target: production).`