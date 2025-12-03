# MERN Stack Docker Setup - Quick Reference

## 🎯 Quick Start Commands

### Development
```bash
# Start development
docker-compose -f docker-compose.dev.yaml --env-file .env.dev up --build

# Stop development
docker-compose -f docker-compose.dev.yaml down

# View logs
docker-compose -f docker-compose.dev.yaml logs -f

# Access container shell
docker-compose -f docker-compose.dev.yaml exec backend-api-dev sh
```

### Staging
```bash
# Start staging
docker-compose -f docker-compose.staging.yaml --env-file .env.staging up --build -d

# Stop staging
docker-compose -f docker-compose.staging.yaml down

# View logs
docker-compose -f docker-compose.staging.yaml logs -f
```

### Production
```bash
# Start production
docker-compose -f docker-compose.prod.yaml --env-file .env.prod up --build -d

# Stop production
docker-compose -f docker-compose.prod.yaml down

# View logs
docker-compose -f docker-compose.prod.yaml logs -f
```

---

## 📊 Services & Ports

### Development
| Service | Container | Port | URL |
|---------|-----------|------|-----|
| Frontend | mern-frontend-web-dev | 3000 | http://localhost:3000 |
| Backend | mern-backend-api-dev | 5000 | http://localhost:5000 |
| MongoDB | mern-mongodb-dev | 27017 | mongodb://localhost:27017 |

### Staging
| Service | Container | Port | URL |
|---------|-----------|------|-----|
| Frontend | mern-frontend-web-staging | 8080 | http://localhost:8080 |
| Backend | mern-backend-api-staging | 5001 | http://localhost:5001 |
| MongoDB | mern-mongodb-staging | 27018 | mongodb://localhost:27018 |

### Production
| Service | Container | Port | URL |
|---------|-----------|------|-----|
| Frontend | mern-frontend-web-prod | 80 | http://localhost |
| Backend | mern-backend-api-prod | 5002 | http://localhost:5002 |
| MongoDB | mern-mongodb-prod | 27019 | mongodb://localhost:27019 |

---

## 🔐 Environment Variables

Update `.env.dev`, `.env.staging`, and `.env.prod` with your configuration:

```env
# MongoDB
MONGO_ROOT_USER=admin
MONGO_ROOT_PASSWORD=your_password_here
MONGO_DB_NAME=mern_db

# Backend
NODE_ENV=development
PORT=5000

# Frontend
REACT_APP_API_URL=http://localhost:5000
```

---

## 🐚 Helper Commands (Using Docker Helper)

### PowerShell (Windows)
```powershell
# Import helper functions
. docker/docker-helper.ps1

# Development
dev-up
dev-down
dev-logs
dev-backend-logs
dev-frontend-logs

# Staging
staging-up
staging-down
staging-logs

# Production
prod-up
prod-down
prod-logs
```

### Bash (Linux/Mac)
```bash
# Source helper functions
source docker/docker-helper.sh

# Development
dev-up
dev-down
dev-logs
dev-backend-logs
dev-frontend-logs

# Staging
staging-up
staging-down
staging-logs

# Production
prod-up
prod-down
prod-logs
```

---

## 📁 Volume & Data

### Persistent Directories
```
data/
├── mongodb/
│   ├── dev/               # Development database
│   ├── staging/           # Staging database
│   └── production/        # Production database

backend/
└── logs/
    ├── staging/           # Staging logs
    └── production/        # Production logs

frontend/
└── logs/
    ├── staging/           # Staging logs
    └── production/        # Production logs
```

---

## 🔍 Troubleshooting

### Check container status
```bash
docker ps -a | grep mern
```

### View detailed logs
```bash
docker-compose -f docker-compose.dev.yaml logs backend-api-dev
```

### Rebuild without cache
```bash
docker-compose -f docker-compose.dev.yaml build --no-cache
```

### Remove all MERN containers
```bash
docker ps -a | grep mern | awk '{print $1}' | xargs docker rm -f
```

### Clean up volumes
```bash
docker volume prune -f
```

---

## 🔒 Production Security

⚠️ **IMPORTANT:** Before deploying to production:

1. **Change MongoDB password:**
   ```bash
   # In .env.prod
   MONGO_ROOT_PASSWORD=YOUR_STRONG_PASSWORD
   ```

2. **Update API URLs:**
   ```bash
   REACT_APP_API_URL=https://api.yourdomain.com
   CORS_ORIGIN=https://yourdomain.com
   ```

3. **Configure HTTPS/SSL** in nginx config

4. **Set resource limits** in docker-compose

5. **Enable logging and monitoring**

---

## 📚 Documentation

For detailed information, see:
- `DOCKER_GUIDE.md` - Complete Docker setup guide
- Backend `README.md` - Backend configuration
- Frontend `README.md` - Frontend configuration

---

**Version:** 1.0.0  
**Last Updated:** December 2025
