# MERN Stack Docker & Docker Compose Guide

## 📋 Overview

This guide covers the complete Docker setup for the MERN (MongoDB, Express, React, Node.js) stack with support for **Development**, **Staging**, and **Production** environments.

### Key Features
- ✅ Multi-stage builds for optimized images
- ✅ Proper container naming conventions
- ✅ Distinct networks for each environment
- ✅ Named volumes with bind mounts
- ✅ Health checks for all services
- ✅ Security best practices
- ✅ Environment-specific configurations
- ✅ Non-root user execution
- ✅ Resource logging and limits

---

## 🏗️ Architecture

### File Structure
```
project-root/
├── backend/
│   ├── Dockerfile                 # Multi-stage backend build
│   ├── package.json
│   ├── server.js
│   └── logs/                      # Persistent logs
├── frontend/
│   ├── Dockerfile                 # Multi-stage frontend build
│   ├── nginx/
│   │   ├── nginx.conf             # Nginx main config
│   │   └── default.conf           # Nginx default server
│   ├── package.json
│   └── public/
├── docker/
│   ├── docker-helper.sh           # Bash helper script
│   └── docker-helper.ps1          # PowerShell helper script
├── data/
│   └── mongodb/                   # Persistent MongoDB data
│       ├── dev/
│       ├── staging/
│       └── production/
├── docker-compose.dev.yaml        # Development composition
├── docker-compose.staging.yaml    # Staging composition
├── docker-compose.prod.yaml       # Production composition
├── .env.dev                       # Development environment
├── .env.staging                   # Staging environment
├── .env.prod                      # Production environment
└── DOCKER_GUIDE.md               # This file
```

---

## 🚀 Quick Start

### Prerequisites
- Docker >= 20.10
- Docker Compose >= 2.0
- 4GB+ RAM available
- Git

### Development Environment

```bash
# Start all services
docker-compose -f docker-compose.dev.yaml --env-file .env.dev up --build

# Or using helper script
# Linux/Mac
source docker/docker-helper.sh
dev-up

# Windows PowerShell
. docker/docker-helper.ps1
dev-up
```

**Endpoints:**
- Frontend: `http://localhost:3000`
- Backend API: `http://localhost:5000`
- MongoDB: `localhost:27017`

### Staging Environment

```bash
# Start all services in background
docker-compose -f docker-compose.staging.yaml --env-file .env.staging up --build -d

# Or using helper script
staging-up
```

**Endpoints:**
- Frontend: `http://localhost:8080`
- Backend API: `http://localhost:5001`
- MongoDB: `localhost:27018`

### Production Environment

```bash
# Start all services in background
docker-compose -f docker-compose.prod.yaml --env-file .env.prod up --build -d

# Or using helper script
prod-up
```

**Endpoints:**
- Frontend: `http://localhost:80` (or `http://localhost`)
- Backend API: `http://localhost:5002`
- MongoDB: `localhost:27019`

---

## 🎯 Container Naming Convention

### Development
| Service | Container Name | Hostname | Port |
|---------|----------------|----------|------|
| MongoDB | `mern-mongodb-dev` | `mongodb-dev.local` | 27017 |
| Backend | `mern-backend-api-dev` | `backend-api-dev.local` | 5000 |
| Frontend | `mern-frontend-web-dev` | `frontend-web-dev.local` | 3000 |

### Staging
| Service | Container Name | Hostname | Port |
|---------|----------------|----------|------|
| MongoDB | `mern-mongodb-staging` | `mongodb-staging.local` | 27018 |
| Backend | `mern-backend-api-staging` | `backend-api-staging.local` | 5001 |
| Frontend | `mern-frontend-web-staging` | `frontend-web-staging.local` | 8080 |

### Production
| Service | Container Name | Hostname | Port |
|---------|----------------|----------|------|
| MongoDB | `mern-mongodb-prod` | `mongodb-prod.local` | 27019 |
| Backend | `mern-backend-api-prod` | `backend-api-prod.local` | 5002 |
| Frontend | `mern-frontend-web-prod` | `frontend-web-prod.local` | 80 |

---

## 📦 Image Naming Convention

```
mern/<service>:<environment>-latest

Examples:
- mern/backend-api:dev-latest
- mern/backend-api:staging-latest
- mern/backend-api:prod-latest
- mern/frontend-web:dev-latest
- mern/frontend-web:staging-latest
- mern/frontend-web:prod-latest
```

---

## 🌐 Network Configuration

### Network Names & Subnets
| Environment | Network Name | Subnet |
|-------------|--------------|--------|
| Development | `mern-dev-network` | 172.20.0.0/16 |
| Staging | `mern-staging-network` | 172.21.0.0/16 |
| Production | `mern-prod-network` | 172.22.0.0/16 |

### Service Discovery
Services communicate using container hostnames:
- `mongodb-dev` → MongoDB in dev
- `backend-api-dev` → Backend API in dev
- `frontend-web-dev` → Frontend in dev

---

## 💾 Volume Management

### Named Volumes (Persistent Data)

#### Development
| Volume | Mount Path | Bind Path | Purpose |
|--------|-----------|-----------|---------|
| `mern-mongodb-dev-data` | `/data/db` | `./data/mongodb/dev` | MongoDB data |
| `mern-mongodb-dev-config` | `/data/configdb` | `./data/mongodb/dev/config` | MongoDB config |
| `mern-backend-dev-node_modules` | `/app/node_modules` | Anonymous | Dependencies |
| `mern-backend-dev-logs` | `/app/logs` | `./backend/logs` | Application logs |
| `mern-frontend-dev-node_modules` | `/app/node_modules` | Anonymous | Dependencies |

#### Staging
| Volume | Mount Path | Bind Path | Purpose |
|--------|-----------|-----------|---------|
| `mern-mongodb-staging-data` | `/data/db` | `./data/mongodb/staging` | MongoDB data |
| `mern-backend-staging-node_modules` | `/app/node_modules` | Anonymous | Dependencies |
| `mern-backend-staging-logs` | `/app/logs` | `./backend/logs/staging` | Application logs |
| `mern-frontend-staging-cache` | `/var/cache/nginx` | Anonymous | Nginx cache |
| `mern-frontend-staging-logs` | `/var/log/nginx` | `./frontend/logs/staging` | Nginx logs |

#### Production
| Volume | Mount Path | Bind Path | Purpose |
|--------|-----------|-----------|---------|
| `mern-mongodb-prod-data` | `/data/db` | `./data/mongodb/production` | MongoDB data |
| `mern-backend-prod-node_modules` | `/app/node_modules` | Anonymous | Dependencies |
| `mern-backend-prod-logs` | `/app/logs` | `./backend/logs/production` | Application logs |
| `mern-frontend-prod-cache` | `/var/cache/nginx` | Anonymous | Nginx cache |
| `mern-frontend-prod-logs` | `/var/log/nginx` | `./frontend/logs/production` | Nginx logs |

### Bind Mounts (Development Hot Reload)
```yaml
# Development uses bind mounts for source code
volumes:
  - ./backend:/app              # Source code sync
  - /app/node_modules          # Don't sync node_modules
  
  - ./frontend:/app
  - /app/node_modules
```

---

## 🔒 Security Best Practices Implemented

### 1. Non-Root User Execution
```dockerfile
USER nodejs        # Backend
USER www-data      # Frontend (Nginx)
```

### 2. Health Checks
```yaml
healthcheck:
  test: curl -f http://localhost:5000/health || exit 1
  interval: 30s
  timeout: 10s
  start_period: 15s
  retries: 3
```

### 3. Security Headers (Nginx)
```nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
```

### 4. Read-Only Root Filesystem (Staging/Prod)
```yaml
read_only_rootfs: false  # Set true if possible
```

### 5. Capability Dropping (Prod)
```yaml
cap_drop:
  - ALL
cap_add:
  - NET_BIND_SERVICE
```

### 6. No New Privileges
```yaml
security_opt:
  - no-new-privileges:true
```

---

## 🔧 Common Tasks

### View Logs

**Development:**
```bash
# All logs
dev-logs

# Specific service
dev-backend-logs
dev-frontend-logs
dev-mongodb-logs
```

**Staging:**
```bash
staging-logs
staging-backend-logs
staging-frontend-logs
```

**Production:**
```bash
prod-logs
prod-backend-logs
prod-frontend-logs
```

### Access Container Shell

**Development:**
```bash
dev-shell-backend      # Backend shell
dev-shell-frontend     # Frontend shell
dev-shell-mongodb      # MongoDB shell
```

### Restart Services

**Staging:**
```bash
staging-restart
```

**Production:**
```bash
prod-restart
```

### Stop Services

```bash
# Development
dev-down

# Staging
staging-down

# Production
prod-down
```

### Clean Up Resources

```bash
# Remove containers and volumes
dev-prune

# General cleanup
docker-clean
```

---

## 📊 Dockerfile Stages

### Backend Dockerfile

#### Stage 1: `base`
- Node.js 18.19-alpine3.18
- Essential packages installation
- Package files copy

#### Stage 2: `dependencies`
- Install all dependencies
- Reusable layer for all stages

#### Stage 3: `development`
- Development tools (nodemon)
- Full source code
- Hot reload enabled
- Health checks enabled

#### Stage 4: `staging`
- Production dependencies only
- Optimized image
- Non-root user

#### Stage 5: `production`
- Alpine base (minimal)
- Production-only dependencies
- Non-root user (nodejs)
- Cleanup of unnecessary files
- Enhanced security

### Frontend Dockerfile

#### Stage 1: `base`
- Node.js 18.19-alpine3.18

#### Stage 2: `dependencies`
- npm packages installed

#### Stage 3: `development`
- Hot reload enabled
- Development server

#### Stage 4: `staging-build`
- Build React app

#### Stage 5: `staging`
- Nginx alpine
- Production-optimized
- Static serving

#### Stage 6: `production-build`
- Build React app

#### Stage 7: `production`
- Nginx alpine
- Minimal size
- Security headers
- Non-root user

---

## 🌍 Environment-Specific Configuration

### .env.dev
```env
NODE_ENV=development
LOG_LEVEL=debug
MONGO_ROOT_PASSWORD=dev_password
```

### .env.staging
```env
NODE_ENV=staging
LOG_LEVEL=info
MONGO_ROOT_PASSWORD=staging_secure_password_change_me
```

### .env.prod
```env
NODE_ENV=production
LOG_LEVEL=warn
MONGO_ROOT_PASSWORD=CHANGE_ME_PRODUCTION_PASSWORD_STRONG
```

---

## 🚨 Important Security Notes

### For Production

1. **Change all passwords** in `.env.prod`
   ```bash
   MONGO_ROOT_PASSWORD=YOUR_STRONG_PASSWORD_HERE
   ```

2. **Update domain names** in environment variables
   ```env
   REACT_APP_API_URL=https://api.yourdomain.com
   CORS_ORIGIN=https://yourdomain.com
   ```

3. **Configure HTTPS/SSL** (add to nginx config)
   ```nginx
   listen 443 ssl http2;
   ssl_certificate /path/to/cert.pem;
   ssl_certificate_key /path/to/key.pem;
   ```

4. **Set up backups** for MongoDB data
   ```bash
   docker-compose -f docker-compose.prod.yaml exec mongodb-prod mongodump --uri="mongodb://..." -o /backup
   ```

5. **Monitor resources**
   ```bash
   docker stats
   ```

---

## 🐛 Troubleshooting

### Container won't start

```bash
# Check logs
docker-compose logs <service_name>

# Inspect container
docker inspect <container_name>

# Rebuild without cache
docker-compose build --no-cache <service_name>
```

### Port already in use

```bash
# Find process using port
lsof -i :5000

# Or on Windows
netstat -ano | findstr :5000

# Kill process
kill -9 <PID>
```

### Permission denied errors

```bash
# Fix ownership
sudo chown -R $USER:$USER ./data

# Or use sudo
sudo docker-compose up
```

### Database connection issues

```bash
# Test connection from backend container
docker-compose exec backend-api-dev npm test

# Check MongoDB logs
docker-compose logs mongodb-dev
```

---

## 📈 Performance Optimization

### Image Size Optimization
- Used alpine base images
- Multi-stage builds
- Removed unnecessary files
- Cleaned npm cache

### Build Speed Optimization
- Layer caching
- Dependency installation before code copy
- .dockerignore file usage

### Runtime Optimization
- Health checks prevent restart loops
- Proper logging levels by environment
- Resource limits (consider adding)

---

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [Best Practices for Node.js](https://nodejs.org/en/docs/guides/dockerfile/)
- [React Production Build](https://create-react-app.dev/docs/production-build/)
- [MongoDB in Docker](https://hub.docker.com/_/mongo)
- [Nginx Documentation](https://nginx.org/en/docs/)

---

## 📝 License

This Docker configuration is part of the MERN Stack project.

---

**Last Updated:** December 2025
**Version:** 1.0.0
