# MERN Stack - Quick Reference

## Docker Compose Commands

```bash
# Start all services (MongoDB, Redis, Backend, Frontend)
docker-compose -f docker-compose.yaml --env-file .env up --build -d

# Stop all services
docker-compose down

# View service status
docker-compose ps

# View logs
docker-compose logs -f backend-api-dev
docker-compose logs -f frontend-web-dev
```

## Access Services

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:5000
- **MongoDB**: localhost:27017 (docker internal)

## MongoDB Commands

```bash
# Connect to MongoDB and view todos
docker exec mern-mongodb-dev mongosh --username admin --password dev_password --authenticationDatabase admin mern_dev_db --eval "db.todos.find()"

# Count todos in database
docker exec mern-mongodb-dev mongosh --username admin --password dev_password --authenticationDatabase admin mern_dev_db --eval "db.todos.countDocuments()"

# Delete all todos
docker exec mern-mongodb-dev mongosh --username admin --password dev_password --authenticationDatabase admin mern_dev_db --eval "db.todos.deleteMany({})"
```

## API Endpoints

```bash
# Get all todos
curl http://localhost:5000/api

# Add a new todo
curl -X POST http://localhost:5000/api/todos -H "Content-Type: application/json" -d '{"text":"Your todo text"}'

# Health check
curl http://localhost:5000/health
```
