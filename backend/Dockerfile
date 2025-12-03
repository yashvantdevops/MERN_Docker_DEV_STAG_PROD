# syntax=docker/dockerfile:1.4
# Multi-stage Dockerfile for Node.js Backend - MERN Stack
# Uses standard Debian-based images ("Core" Linux) instead of Alpine

# ============================================================================
# BASE STAGE - Common dependencies (Debian based)
# ============================================================================
# Using 'node:24-bookworm' (Debian 12) for a stable, standard "core" environment
FROM node:24-bookworm AS base
LABEL maintainer="MERN Stack Team"
LABEL version="2.1-core"
LABEL description="Express.js Backend - Standard Debian Build"

# Install essential packages using apt-get (Debian package manager)
# dumb-init is critical for proper signal handling in PID 1
RUN apt-get update && apt-get install -y --no-install-recommends \
    dumb-init \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy package files
COPY package*.json ./

# ============================================================================
# DEPENDENCIES STAGE - Install all dependencies
# ============================================================================
FROM base AS dependencies
RUN npm ci --verbose

# ============================================================================
# DEVELOPMENT STAGE - Development environment with hot reload
# ============================================================================
FROM dependencies AS development
LABEL stage="development"

ENV NODE_ENV=development
ENV PORT=5000

# Copy entire project
COPY . .

# Install nodemon globally
RUN npm install -g nodemon

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

CMD ["nodemon", "server.js"]

# ============================================================================
# STAGING STAGE - Optimized staging build
# ============================================================================
FROM base AS staging
LABEL stage="staging"

ENV NODE_ENV=staging
ENV PORT=5000

# Install production dependencies only
RUN npm ci --omit=dev --verbose

# Copy application code
COPY . .

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

USER node

CMD ["node", "server.js"]

# ============================================================================
# PRODUCTION STAGE - Lightweight "Slim" Production Build
# ============================================================================
# Uses 'slim' variant: Standard Debian Linux but stripped of build tools.
# Much smaller than 'base' but keeps full binary compatibility (unlike Alpine).
FROM node:24-bookworm-slim AS production
LABEL stage="production"

ENV NODE_ENV=production
ENV PORT=5000

# Install runtime dependencies only
RUN apt-get update && apt-get install -y --no-install-recommends \
    dumb-init \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Note: The official Node image already creates a 'node' user (uid 1000)

# Copy only production dependencies from staging
COPY --from=staging --chown=node:node /app/node_modules ./node_modules

# Copy application code
COPY --chown=node:node . .

# Remove unnecessary files (cleanup)
RUN rm -rf \
    .git \
    .gitignore \
    .env.* \
    .dockerignore \
    Dockerfile \
    docker-compose*.yaml \
    README.md \
    .eslintrc* \
    .prettierrc* \
    tests \
    test \
    *.test.js \
    *.spec.js \
    logs/*

EXPOSE 5000

USER node

HEALTHCHECK --interval=60s --timeout=10s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "server.js"]
