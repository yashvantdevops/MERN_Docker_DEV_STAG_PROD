# syntax=docker/dockerfile:1.4
# Multi-stage Dockerfile for Node.js Backend - MERN Stack
# Supports development, staging, and production builds

# ============================================================================
# BASE STAGE - Common dependencies
# ============================================================================
FROM node:18.19-alpine3.18 AS base
LABEL maintainer="MERN Stack Team"
LABEL version="1.0"
LABEL description="Express.js Backend for MERN Stack"

# Install security updates and essential packages
RUN apk add --no-cache \
    dumb-init \
    curl \
    && rm -rf /var/cache/apk/*

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

# Install nodemon globally for development
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
RUN npm ci --only=production --verbose

# Copy application code
COPY . .

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

USER node

CMD ["node", "server.js"]

# ============================================================================
# PRODUCTION STAGE - Lightweight production build
# ============================================================================
FROM alpine:3.18 AS production
LABEL stage="production"

ENV NODE_ENV=production
ENV PORT=5000

# Install Node.js runtime and dumb-init only
RUN apk add --no-cache \
    nodejs=18.19.0-r0 \
    dumb-init \
    curl \
    && rm -rf /var/cache/apk/*

WORKDIR /app

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Copy only production dependencies from staging
COPY --from=staging --chown=nodejs:nodejs /app/node_modules ./node_modules

# Copy application code
COPY --chown=nodejs:nodejs . .

# Remove unnecessary files
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
    logs/* \
    && chown -R nodejs:nodejs /app

EXPOSE 5000

USER nodejs

HEALTHCHECK --interval=60s --timeout=10s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "server.js"]