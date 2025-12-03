#!/bin/bash
# ============================================================================
# MERN Stack Docker Helper Scripts
# ============================================================================

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# Development Environment
# ============================================================================

dev-up() {
    echo -e "${BLUE}Starting MERN Stack - Development Environment...${NC}"
    docker-compose -f docker-compose.dev.yaml --env-file .env.dev up --build
}

dev-down() {
    echo -e "${BLUE}Stopping MERN Stack - Development Environment...${NC}"
    docker-compose -f docker-compose.dev.yaml down
}

dev-logs() {
    docker-compose -f docker-compose.dev.yaml logs -f
}

dev-backend-logs() {
    docker-compose -f docker-compose.dev.yaml logs -f backend-api-dev
}

dev-frontend-logs() {
    docker-compose -f docker-compose.dev.yaml logs -f frontend-web-dev
}

dev-mongodb-logs() {
    docker-compose -f docker-compose.dev.yaml logs -f mongodb-dev
}

dev-shell-backend() {
    docker-compose -f docker-compose.dev.yaml exec backend-api-dev sh
}

dev-shell-frontend() {
    docker-compose -f docker-compose.dev.yaml exec frontend-web-dev sh
}

dev-shell-mongodb() {
    docker-compose -f docker-compose.dev.yaml exec mongodb-dev mongosh -u admin -p
}

dev-prune() {
    echo -e "${YELLOW}Pruning development Docker resources...${NC}"
    docker-compose -f docker-compose.dev.yaml down -v
    docker container prune -f
    docker image prune -f
}

# ============================================================================
# Staging Environment
# ============================================================================

staging-up() {
    echo -e "${BLUE}Starting MERN Stack - Staging Environment...${NC}"
    docker-compose -f docker-compose.staging.yaml --env-file .env.staging up --build -d
}

staging-down() {
    echo -e "${BLUE}Stopping MERN Stack - Staging Environment...${NC}"
    docker-compose -f docker-compose.staging.yaml down
}

staging-logs() {
    docker-compose -f docker-compose.staging.yaml logs -f
}

staging-backend-logs() {
    docker-compose -f docker-compose.staging.yaml logs -f backend-api-staging
}

staging-frontend-logs() {
    docker-compose -f docker-compose.staging.yaml logs -f frontend-web-staging
}

staging-mongodb-logs() {
    docker-compose -f docker-compose.staging.yaml logs -f mongodb-staging
}

staging-restart() {
    echo -e "${BLUE}Restarting Staging services...${NC}"
    docker-compose -f docker-compose.staging.yaml restart
}

# ============================================================================
# Production Environment
# ============================================================================

prod-up() {
    echo -e "${RED}Starting MERN Stack - Production Environment...${NC}"
    docker-compose -f docker-compose.prod.yaml --env-file .env.prod up --build -d
}

prod-down() {
    echo -e "${RED}Stopping MERN Stack - Production Environment...${NC}"
    docker-compose -f docker-compose.prod.yaml down
}

prod-logs() {
    docker-compose -f docker-compose.prod.yaml logs -f
}

prod-backend-logs() {
    docker-compose -f docker-compose.prod.yaml logs -f backend-api-prod
}

prod-frontend-logs() {
    docker-compose -f docker-compose.prod.yaml logs -f frontend-web-prod
}

prod-mongodb-logs() {
    docker-compose -f docker-compose.prod.yaml logs -f mongodb-prod
}

prod-restart() {
    echo -e "${RED}Restarting Production services...${NC}"
    docker-compose -f docker-compose.prod.yaml restart
}

# ============================================================================
# General Docker Utilities
# ============================================================================

docker-ps() {
    echo -e "${BLUE}Running MERN Docker containers:${NC}"
    docker ps | grep -E "mern|CONTAINER"
}

docker-stats() {
    echo -e "${BLUE}MERN Docker container stats:${NC}"
    docker stats --no-stream $(docker ps -q --filter "label=project=mern" 2>/dev/null) 2>/dev/null || docker stats
}

docker-clean() {
    echo -e "${YELLOW}Cleaning up unused Docker resources...${NC}"
    docker container prune -f
    docker image prune -f
    docker volume prune -f
    docker network prune -f
}

# ============================================================================
# Build Commands
# ============================================================================

build-backend() {
    echo -e "${BLUE}Building Backend image...${NC}"
    docker build -f backend/Dockerfile -t mern/backend-api:dev-latest ./backend --target development
}

build-frontend() {
    echo -e "${BLUE}Building Frontend image...${NC}"
    docker build -f frontend/Dockerfile -t mern/frontend-web:dev-latest ./frontend --target development
}

build-all() {
    build-backend
    build-frontend
}

# ============================================================================
# Network Diagnostics
# ============================================================================

check-network() {
    echo -e "${BLUE}MERN Docker Networks:${NC}"
    docker network ls | grep -E "mern|NETWORK"
}

inspect-network() {
    echo -e "${BLUE}Inspecting development network...${NC}"
    docker network inspect mern_dev_network 2>/dev/null || echo "Network not found"
}

# ============================================================================
# Help
# ============================================================================

help() {
    cat << EOF
${BLUE}MERN Stack Docker Helper Commands${NC}

${YELLOW}Development:${NC}
  dev-up              - Start development environment
  dev-down            - Stop development environment
  dev-logs            - View all development logs
  dev-backend-logs    - View backend logs
  dev-frontend-logs   - View frontend logs
  dev-mongodb-logs    - View MongoDB logs
  dev-shell-backend   - Open shell in backend container
  dev-shell-frontend  - Open shell in frontend container
  dev-shell-mongodb   - Open MongoDB shell
  dev-prune           - Remove development containers and volumes

${YELLOW}Staging:${NC}
  staging-up          - Start staging environment
  staging-down        - Stop staging environment
  staging-logs        - View all staging logs
  staging-backend-logs    - View backend logs
  staging-frontend-logs   - View frontend logs
  staging-mongodb-logs    - View MongoDB logs
  staging-restart     - Restart staging services

${YELLOW}Production:${NC}
  prod-up             - Start production environment
  prod-down           - Stop production environment
  prod-logs           - View all production logs
  prod-backend-logs   - View backend logs
  prod-frontend-logs  - View frontend logs
  prod-mongodb-logs   - View MongoDB logs
  prod-restart        - Restart production services

${YELLOW}Build & General:${NC}
  build-backend       - Build backend image
  build-frontend      - Build frontend image
  build-all           - Build all images
  docker-ps           - List MERN containers
  docker-stats        - Show container stats
  docker-clean        - Clean up unused resources
  check-network       - List MERN networks
  inspect-network     - Inspect development network
  help                - Show this help message

EOF
}

# ============================================================================
# Main
# ============================================================================

if [ $# -eq 0 ]; then
    help
else
    "$@"
fi
