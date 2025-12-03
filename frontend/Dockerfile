# syntax=docker/dockerfile:1.4
# Multi-stage Dockerfile for React Frontend - MERN Stack
# Supports development, staging, and production builds with Nginx

# ============================================================================
# BASE STAGE - Common dependencies
# ============================================================================
FROM node:18.19-alpine3.18 AS base
LABEL maintainer="MERN Stack Team"
LABEL version="1.0"
LABEL description="React.js Frontend for MERN Stack"

WORKDIR /app

# Copy package files
COPY package*.json ./

# ============================================================================
# DEPENDENCIES STAGE - Install dependencies
# ============================================================================
FROM base AS dependencies
RUN npm ci --verbose

# ============================================================================
# DEVELOPMENT STAGE - Development environment with hot reload
# ============================================================================
FROM dependencies AS development
LABEL stage="development"

ENV NODE_ENV=development
ENV REACT_APP_API_URL=http://backend-api:5000

# Copy entire project
COPY . .

EXPOSE 3000

# Health check for development
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:3000 || exit 1

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
FROM nginx:1.25-alpine3.18 AS staging
LABEL stage="staging"

# Copy Nginx configuration
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# Copy built application from staging-build
COPY --from=staging-build /app/build /usr/share/nginx/html

# Create non-root user for nginx
RUN addgroup -g 101 -S www-data && \
    adduser -S www-data -u 101 && \
    chown -R www-data:www-data /usr/share/nginx/html && \
    chown -R www-data:www-data /var/cache/nginx && \
    chown -R www-data:www-data /var/log/nginx && \
    chown -R www-data:www-data /etc/nginx/conf.d

EXPOSE 8080

USER www-data

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:8080 || exit 1

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
FROM nginx:1.25-alpine3.18 AS production
LABEL stage="production"

# Copy Nginx configuration
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# Copy built application from production-build
COPY --from=production-build /app/build /usr/share/nginx/html

# Remove unnecessary files
RUN rm -rf /app && \
    rm -rf /usr/share/nginx/html/.map && \
    find /usr/share/nginx/html -name "*.map" -delete

# Create non-root user for nginx
RUN addgroup -g 101 -S www-data && \
    adduser -S www-data -u 101 && \
    chown -R www-data:www-data /usr/share/nginx/html && \
    chown -R www-data:www-data /var/cache/nginx && \
    chown -R www-data:www-data /var/log/nginx && \
    chown -R www-data:www-data /etc/nginx/conf.d

EXPOSE 8080

USER www-data

HEALTHCHECK --interval=60s --timeout=10s --start-period=10s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:8080 || exit 1

CMD ["nginx", "-g", "daemon off;"]
