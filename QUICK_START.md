Here is the comprehensive `README.md` file containing all instructions, commands, and interactive shell examples.

```markdown
# MERN Stack Docker Project - Complete Guide

This project contains a full production-ready Docker setup for a MERN (MongoDB, Express, React, Node.js) stack, including Redis for caching and Nginx for the frontend server. It supports **Development**, **Staging**, and **Production** environments with best practices for security and performance.

---

## 📋 Table of Contents

1.  [Prerequisites](#prerequisites)
2.  [Project Structure](#project-structure)
3.  [Environments & Commands](#environments--commands)
    *   [Development](#development)
    *   [Staging](#staging)
    *   [Production](#production)
4.  [Interactive Shell Access](#interactive-shell-access)
5.  [Database & Cache Management](#database--cache-management)
6.  [Troubleshooting](#troubleshooting)
7.  [File Verification](#file-verification)

---

## 🛠 Prerequisites

*   **Docker Engine:** v24.0+
*   **Docker Compose:** v2.0+
*   **Hardware:** MERN stack typically requires ~2GB RAM minimum for all containers.

---

## 📂 Project Structure

```
.
├── backend/                 # Express.js Backend
│   ├── Dockerfile           # Multi-stage Dockerfile
│   └── ...
├── frontend/                # React Frontend
│   ├── Dockerfile           # Multi-stage Dockerfile
│   └── nginx/               # Nginx Configs
├── docker-compose.dev.yaml     # Development orchestration
├── docker-compose.staging.yaml # Staging orchestration
├── docker-compose.prod.yaml    # Production orchestration
├── .env.dev                 # Development variables
├── .env.staging             # Staging variables
├── .env.prod                # Production variables
├── helper.sh                # Helper shortcuts script
└── verify-build.sh          # Build verification script
```

---

## 🚀 Environments & Commands

We provide a `helper.sh` script to simplify all commands.
**First, enable the helper script:**
```
chmod +x helper.sh
source ./helper.sh
```

### 1️⃣ Development
*Hot-reloading enabled. Logs stream to console.*

| Action | Command | Manual Equivalent |
| :--- | :--- | :--- |
| **Start** | `dev-up` | `docker-compose -f docker-compose.dev.yaml --env-file .env.dev up --build` |
| **Stop** | `dev-down` | `docker-compose -f docker-compose.dev.yaml down` |
| **Logs** | `dev-logs` | `docker-compose -f docker-compose.dev.yaml logs -f` |

### 2️⃣ Staging
*Optimized builds, internal networking, simulates production.*

| Action | Command | Manual Equivalent |
| :--- | :--- | :--- |
| **Start** | `staging-up` | `docker-compose -f docker-compose.staging.yaml --env-file .env.staging up -d --build` |
| **Stop** | `staging-down` | `docker-compose -f docker-compose.staging.yaml down` |
| **Logs** | `staging-logs` | `docker-compose -f docker-compose.staging.yaml logs -f` |

### 3️⃣ Production
*Security hardened, read-only filesystems, persistent volumes.*

| Action | Command | Manual Equivalent |
| :--- | :--- | :--- |
| **Start** | `prod-up` | `docker-compose -f docker-compose.prod.yaml --env-file .env.prod up -d --build` |
| **Stop** | `prod-down` | `docker-compose -f docker-compose.prod.yaml down` |
| **Logs** | `prod-logs` | `docker-compose -f docker-compose.prod.yaml logs -f` |

---

## 💻 Interactive Shell Access

Use these commands to enter running containers for debugging.

### Backend (Node.js)
Enter the backend container to run scripts, check files, or debug.
```
# Development
dev-shell-backend
# OR Manual: docker-compose -f docker-compose.dev.yaml exec backend-api-dev sh

# Production
docker-compose -f docker-compose.prod.yaml exec backend-api-prod sh
```

### Frontend (Nginx/Node)
**Development (Node container):**
```
dev-shell-frontend
# OR Manual: docker-compose -f docker-compose.dev.yaml exec frontend-web-dev sh
```
**Production (Nginx container):**
```
docker-compose -f docker-compose.prod.yaml exec frontend-web-prod sh
```

---

## 🗄️ Database & Cache Management

### MongoDB Shell (`mongosh`)
Access the database directly to run queries.

**Development:**
```
dev-shell-mongodb
# Manual: docker-compose -f docker-compose.dev.yaml exec mongodb-dev mongosh -u admin -p
```
*You will be prompted for the password (default: `dev_password`).*

**Production:**
```
docker-compose -f docker-compose.prod.yaml exec mongodb-prod mongosh -u prod_admin -p
```

### Redis CLI (`redis-cli`)
Access the Redis cache directly.

**Development:**
```
dev-shell-redis
# Manual: docker-compose -f docker-compose.dev.yaml exec redis-dev redis-cli
```

**Production:**
```
prod-shell-redis
# Manual: docker-compose -f docker-compose.prod.yaml exec redis-prod redis-cli
```
*If you enabled a password in production, authenticate inside the CLI:*
```
127.0.0.1:6379> AUTH your_production_password
```

---

## 🔧 Troubleshooting

### 1. "Container name already in use"
If a container is stuck or wasn't removed properly:
```
docker rm -f mern-backend-api-dev mern-frontend-web-dev mern-mongodb-dev mern-redis-dev
```

### 2. Database Connection Errors
*   Ensure your `.env` file passwords match `docker-compose` secrets.
*   Check if MongoDB is healthy:
    ```
    docker ps --filter "name=mongo"
    ```
    *(Look for `(healthy)` status)*

### 3. Redis Connection Refused
*   Ensure the Backend is using the correct hostname (`redis-dev` in dev, `redis-prod` in prod).
*   Verify Redis is running:
    ```
    dev-redis-logs
    ```

### 4. Resetting Data (Fresh Start)
**WARNING:** This deletes all database data!
```
# Stop containers
dev-down

# Delete volumes
docker volume rm mern-mongodb-dev-data mern-redis-dev-data
```

---

## ✅ File Verification

Run the included verification script to ensure your setup is correct before building.

```
chmod +x verify-build.sh
./verify-build.sh
```

This checks:
1.  Docker & Compose versions
2.  Existence of all required config files
3.  Syntax of all `docker-compose` files
4.  Syntax of all `Dockerfiles` (via dry-run build)
```

[1](https://stackoverflow.com/questions/64130775/docker-compose-file-for-nodejs-mongo-redis-rabbitmq)
[2](https://github.com/JCGonzaga01/nodejs-express-mongodb-redis-docker/blob/master/docker-compose.yml)
[3](https://docs.docker.com/reference/cli/docker/compose/exec/)
[4](https://insight.vayuz.com/insight-detail/complete-guide:-node.js-+-mongodb-+-redis-with-docker---wsl/bmV3c18xNzU1NTAyMjUyMDM5)
[5](https://collabnix.com/how-to-run-mongodb-with-docker-and-docker-compose-a-step-by-step-guide/)
[6](https://kodaschool.com/blog/using-docker-exec-for-interactive-shell-access)
[7](https://signoz.io/guides/docker-compose-logs/)
[8](https://stackoverflow.com/questions/34559557/how-to-enable-authentication-on-mongodb-through-docker)
[9](https://stackoverflow.com/questions/70807705/how-to-use-redis-username-with-password-in-docker-compose)
[10](https://www.freecodecamp.org/news/how-to-use-to-docker-with-nodejs-handbook/)
[11](https://spacelift.io/blog/docker-exec)
[12](https://spacelift.io/blog/docker-compose-logs)
[13](https://www.mongodb.com/community/forums/t/authenticationfailed-while-trying-to-connect-to-mongo-docker-container/247161)
[14](https://github.com/redis/docker-library-redis/issues/176)
[15](https://www.youtube.com/watch?v=wZZMuqDmNmU)
[16](https://www.geeksforgeeks.org/devops/mastering-docker-exec/)
[17](https://www.warp.dev/terminus/docker-compose-logs)
[18](https://hub.docker.com/_/mongo)
[19](https://redis.io/docs/latest/develop/tools/cli/)
[20](https://www.bigscal.com/blogs/backend/how-to-setup-node-js-with-mongodb-using-docker/)