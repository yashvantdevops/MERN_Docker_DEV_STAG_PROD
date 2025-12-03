# syntax=docker/dockerfile:1.4
# Multi-stage Dockerfile for React Frontend - MERN Stack
# Uses standard Debian-based images ("Core" Linux) for maximum compatibility

# ============================================================================
# BASE STAGE - Common dependencies
# ============================================================================
FROM node:24-bookworm AS base
LABEL maintainer="MERN Stack Team"
LABEL version="2.1-core"
LABEL description="React.js Frontend - Standard Debian Build"

WORKDIR /app

# Copy package files
COPY package*.json ./

# ============================================================================
# DEPENDENCIES STAGE - Install dependencies
# ============================================================================
FROM base AS dependencies
# npm ci is faster and more reliable for builds
RUN npm ci --verbose

# ============================================================================
# DEVELOPMENT STAGE - Development environment with hot reload
# ============================================================================
FROM dependencies AS development
LABEL stage="development"

ENV NODE_ENV=development
# Default to internal Docker network hostname (matches docker-compose)
ENV REACT_APP_API_URL=http://backend-srv:5000

# Copy entire project
COPY . .

EXPOSE 3000

# Health check using curl (standard in Debian images)
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD curl -f http://localhost:3000 || exit 1

CMD ["npm", "start"]

# ============================================================================
# STAGING STAGE - Build stage for staging
# ============================================================================
FROM dependencies AS staging-build
LABEL stage="staging-build"

ENV NODE_ENV=staging
ENV REACT_APP_API_URL=https://api-staging.yourdomain.com

COPY . .

RUN npm run build

# ============================================================================
# STAGING STAGE - Serve staging build with Nginx
# ============================================================================
# Using 'nginx:mainline-bookworm' for the absolute latest Nginx features on Debian
FROM nginx:mainline-bookworm AS staging
LABEL stage="staging"

# Install curl for healthchecks (Debian images might need this updated)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy Nginx configuration
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# Copy built application from staging-build
COPY --from=staging-build /app/build /usr/share/nginx/html

# Setup permissions for the built-in 'nginx' user (UID 101)
# We must make sure the user can write to cache/logs if running as non-root
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid

EXPOSE 8080

USER nginx

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080 || exit 1

CMD ["nginx", "-g", "daemon off;"]

# ============================================================================
# PRODUCTION STAGE - Build stage for production
# ============================================================================
FROM dependencies AS production-build
LABEL stage="production-build"

ENV NODE_ENV=production
ENV REACT_APP_API_URL=https://api.yourdomain.com

COPY . .

RUN npm run build && \
    npm cache clean --force

# ============================================================================
# PRODUCTION STAGE - Serve production build with Nginx
# ============================================================================
FROM nginx:mainline-bookworm AS production
LABEL stage="production"

# Install curl for healthchecks
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy Nginx configuration
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# Copy built application from production-build
COPY --from=production-build /app/build /usr/share/nginx/html

# Remove unnecessary files (maps, etc.)
RUN rm -rf /usr/share/nginx/html/.map && \
    find /usr/share/nginx/html -name "*.map" -delete

# Setup permissions for the built-in 'nginx' user
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid

EXPOSE 8080

USER nginx

HEALTHCHECK --interval=60s --timeout=10s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8080 || exit 1

CMD ["nginx", "-g", "daemon off;"]
