# Docker Setup - Troubleshooting & Checklist

## ✅ Pre-Deployment Checklist

### System Requirements
- [ ] Docker installed (version 20.10+)
  ```bash
  docker --version
  ```
- [ ] Docker Compose installed (version 2.0+)
  ```bash
  docker-compose --version
  ```
- [ ] 4GB+ RAM available
- [ ] 20GB+ free disk space
- [ ] Network connectivity

### Configuration Files
- [ ] `.env.dev` exists and is configured
- [ ] `.env.staging` exists and is configured
- [ ] `.env.prod` exists and is configured
- [ ] All environment variables set correctly
- [ ] MongoDB passwords are strong (especially in `.env.prod`)

### Docker Files
- [ ] `backend/Dockerfile` exists
- [ ] `frontend/Dockerfile` exists
- [ ] `docker-compose.dev.yaml` exists
- [ ] `docker-compose.staging.yaml` exists
- [ ] `docker-compose.prod.yaml` exists
- [ ] `frontend/nginx/nginx.conf` exists
- [ ] `frontend/nginx/default.conf` exists

### Source Code
- [ ] `backend/package.json` updated with scripts
- [ ] `frontend/package.json` updated with scripts
- [ ] `backend/server.js` exists
- [ ] `frontend/public/index.html` exists
- [ ] No hardcoded API URLs in code

---

## 🚀 Startup Verification

### Development Environment
```bash
# Step 1: Verify compose file
docker-compose -f docker-compose.dev.yaml config > /dev/null && echo "✓ Valid"

# Step 2: Build images
docker-compose -f docker-compose.dev.yaml build

# Step 3: Start services
docker-compose -f docker-compose.dev.yaml up -d

# Step 4: Check status
docker-compose -f docker-compose.dev.yaml ps

# Step 5: Test endpoints
curl http://localhost:3000    # Frontend
curl http://localhost:5000    # Backend
```

### Staging Environment
```bash
# Step 1: Verify compose file
docker-compose -f docker-compose.staging.yaml config > /dev/null && echo "✓ Valid"

# Step 2: Build images
docker-compose -f docker-compose.staging.yaml build

# Step 3: Start services
docker-compose -f docker-compose.staging.yaml up -d

# Step 4: Check status
docker-compose -f docker-compose.staging.yaml ps

# Step 5: Test endpoints
curl http://localhost:8080    # Frontend
curl http://localhost:5001    # Backend API
```

### Production Environment
```bash
# Step 1: Verify compose file
docker-compose -f docker-compose.prod.yaml config > /dev/null && echo "✓ Valid"

# Step 2: Build images
docker-compose -f docker-compose.prod.yaml build

# Step 3: Start services
docker-compose -f docker-compose.prod.yaml up -d

# Step 4: Check status
docker-compose -f docker-compose.prod.yaml ps

# Step 5: Test endpoints
curl http://localhost:80      # Frontend
curl http://localhost:5002    # Backend API
```

---

## 🔍 Common Issues & Solutions

### Issue: "Port Already in Use"
**Error:** `bind: address already in use`

**Solution:**
```bash
# Find what's using the port
lsof -i :5000

# Kill the process
kill -9 <PID>

# Or use different port in docker-compose
# Change: "5000:5000" to "5001:5000"
```

### Issue: "Cannot Connect to Docker Daemon"
**Error:** `Cannot connect to the Docker daemon`

**Solution:**
```bash
# Start Docker service
# On macOS
open -a Docker

# On Linux
sudo systemctl start docker

# On Windows
# Launch Docker Desktop from Start Menu
```

### Issue: "Permission Denied"
**Error:** `permission denied while trying to connect to Docker daemon`

**Solution:**
```bash
# Add user to docker group (Linux)
sudo usermod -aG docker $USER
newgrp docker

# Or use sudo
sudo docker-compose up
```

### Issue: "Container Exiting Immediately"
**Error:** `Container exits with code 1`

**Solution:**
```bash
# Check logs
docker-compose logs <service-name>

# Check specific container
docker logs <container-id>

# Rebuild without cache
docker-compose build --no-cache <service-name>
```

### Issue: "MongoDB Connection Failed"
**Error:** `MongooseError: connect ECONNREFUSED`

**Solution:**
```bash
# Verify MongoDB is running
docker-compose ps mongodb-dev

# Check MongoDB logs
docker-compose logs mongodb-dev

# Wait for service to be healthy
docker-compose ps | grep mongodb

# Force restart
docker-compose restart mongodb-dev

# Check connection string in backend
# Should be: mongodb://admin:password@mongodb-dev:27017/dbname?authSource=admin
```

### Issue: "Frontend Can't Connect to Backend"
**Error:** `CORS error` or `API endpoint not found`

**Solution:**
```bash
# Verify backend is running
curl http://localhost:5000

# Check frontend environment variable
docker-compose logs frontend-web-dev | grep REACT_APP_API_URL

# Update .env.dev if needed:
# REACT_APP_API_URL=http://backend-api-dev:5000

# Rebuild frontend
docker-compose build --no-cache frontend-web-dev
docker-compose up frontend-web-dev
```

### Issue: "Out of Disk Space"
**Error:** `no space left on device`

**Solution:**
```bash
# Check disk usage
df -h

# Clean up Docker resources
docker system prune -a

# Remove unused volumes
docker volume prune

# Remove unused images
docker image prune -a

# Clear build cache
docker builder prune
```

### Issue: "High Memory Usage"
**Solution:**
```bash
# Check container memory
docker stats

# Limit memory in docker-compose
services:
  backend-api-dev:
    deploy:
      resources:
        limits:
          memory: 512M
```

### Issue: "Health Check Failing"
**Error:** `unhealthy` status in `docker-compose ps`

**Solution:**
```bash
# Check logs
docker logs <container-id>

# Manually test health
docker-compose exec <service> curl http://localhost:PORT/health

# Increase health check timeout
healthcheck:
  start_period: 30s  # Increase this
  interval: 30s
  timeout: 10s
  retries: 5
```

---

## 📊 Diagnostic Commands

### View Running Services
```bash
docker-compose -f docker-compose.dev.yaml ps
```

### Check Container Logs
```bash
# All services
docker-compose -f docker-compose.dev.yaml logs -f

# Specific service
docker-compose -f docker-compose.dev.yaml logs -f backend-api-dev

# Last 100 lines
docker-compose -f docker-compose.dev.yaml logs --tail=100

# With timestamps
docker-compose -f docker-compose.dev.yaml logs -f --timestamps
```

### Access Container Shell
```bash
# Backend shell
docker-compose -f docker-compose.dev.yaml exec backend-api-dev sh

# Frontend shell
docker-compose -f docker-compose.dev.yaml exec frontend-web-dev sh

# MongoDB shell
docker-compose -f docker-compose.dev.yaml exec mongodb-dev mongosh -u admin -p
```

### Inspect Container
```bash
docker inspect <container-id>

# Get IP address
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' <container-id>
```

### Network Diagnostics
```bash
# List networks
docker network ls

# Inspect network
docker network inspect mern-dev-network

# Test connectivity between containers
docker-compose -f docker-compose.dev.yaml exec backend-api-dev ping mongodb-dev
```

### Volume Information
```bash
# List volumes
docker volume ls

# Inspect volume
docker volume inspect <volume-name>

# Check mounted path
docker inspect <container-id> | grep -A 5 Mounts
```

---

## 🧹 Cleanup Commands

### Stop Services
```bash
# Development
docker-compose -f docker-compose.dev.yaml down

# Staging
docker-compose -f docker-compose.staging.yaml down

# Production
docker-compose -f docker-compose.prod.yaml down
```

### Remove Containers
```bash
# Specific environment
docker-compose -f docker-compose.dev.yaml down

# All MERN containers
docker ps -a | grep mern | awk '{print $1}' | xargs docker rm -f

# All containers
docker container prune -f
```

### Remove Images
```bash
# MERN images
docker images | grep mern | awk '{print $3}' | xargs docker rmi -f

# Dangling images
docker image prune -f

# All unused images
docker image prune -a -f
```

### Remove Volumes
```bash
# MERN volumes
docker volume ls | grep mern | awk '{print $2}' | xargs docker volume rm

# All unused volumes
docker volume prune -f
```

### Complete Cleanup
```bash
docker system prune -a --volumes -f
```

---

## 🔐 Production Deployment Checklist

### Security
- [ ] Changed all default passwords
- [ ] Updated API URLs to production domains
- [ ] Configured HTTPS/SSL certificates
- [ ] Set strong MongoDB credentials
- [ ] Enabled CORS for specific domains only
- [ ] Configured security headers
- [ ] Disabled debug mode
- [ ] Set appropriate log levels

### Configuration
- [ ] Updated `.env.prod` with production values
- [ ] Set NODE_ENV=production
- [ ] Configured proper log level (warn)
- [ ] Set resource limits
- [ ] Configured restart policies

### Monitoring
- [ ] Logs are being written to files
- [ ] Health checks are working
- [ ] Monitoring/alerting system configured
- [ ] Backup strategy for MongoDB data
- [ ] Log rotation configured

### Performance
- [ ] Images built and tested
- [ ] No debug dependencies installed
- [ ] Nginx caching enabled
- [ ] Gzip compression enabled
- [ ] Static assets optimized

---

## 📈 Performance Optimization Checklist

### Frontend
- [ ] Production build created
- [ ] Source maps removed
- [ ] Gzip compression enabled
- [ ] Asset caching configured
- [ ] CDN configured (optional)

### Backend
- [ ] Production dependencies only
- [ ] Error handling configured
- [ ] Rate limiting enabled (optional)
- [ ] Connection pooling configured
- [ ] Logging optimized

### Database
- [ ] Indexes created on frequently queried fields
- [ ] Backups automated
- [ ] Storage space monitored
- [ ] Performance metrics tracked

### Infrastructure
- [ ] Resource limits set
- [ ] Restart policies configured
- [ ] Update strategy planned
- [ ] Disaster recovery plan

---

## 🆘 Getting Help

### Check Documentation
1. Read `DOCKER_GUIDE.md` for comprehensive information
2. Check `QUICK_START.md` for common commands
3. Review error message carefully

### Enable Debug Mode
```bash
# Set debug environment variable
export DEBUG=*

# Run docker-compose
docker-compose -f docker-compose.dev.yaml up

# Or for specific service
docker-compose -f docker-compose.dev.yaml exec backend-api-dev npm run dev
```

### Verify Setup
```bash
# Run verification script
bash docker/verify-docker-setup.sh
```

### Common Commands Reference
```bash
# Status
docker-compose ps

# Logs
docker-compose logs -f

# Shell access
docker-compose exec <service> sh

# Restart
docker-compose restart

# Rebuild
docker-compose build --no-cache
```

---

## 📝 Notes

- All services have health checks - monitor `docker-compose ps`
- Development uses bind mounts for hot reload
- Staging and Production use built images
- Different ports prevent environment conflicts
- Networks are isolated per environment
- Volumes persist data across restarts
- All services should restart on failure (unless stopped manually)

---

**Last Updated:** December 2025
**Version:** 1.0.0
