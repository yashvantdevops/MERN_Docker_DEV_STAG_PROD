#!/bin/bash
# ============================================================================
# MERN Stack Docker Build Verification Script
# ============================================================================
# Verify all docker builds work correctly

set -e

RESET='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BLUE}║         MERN Stack Docker Build Verification Script            ║${RESET}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${RESET}\n"

# Check Docker installation
echo -e "${YELLOW}[1/5] Checking Docker installation...${RESET}"
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    echo -e "${GREEN}✓ Docker found: $DOCKER_VERSION${RESET}"
else
    echo -e "${RED}✗ Docker not found. Please install Docker.${RESET}"
    exit 1
fi

# Check Docker Compose installation
echo -e "\n${YELLOW}[2/5] Checking Docker Compose installation...${RESET}"
if command -v docker-compose &> /dev/null; then
    COMPOSE_VERSION=$(docker-compose --version)
    echo -e "${GREEN}✓ Docker Compose found: $COMPOSE_VERSION${RESET}"
else
    echo -e "${RED}✗ Docker Compose not found. Please install Docker Compose.${RESET}"
    exit 1
fi

# Check required files
echo -e "\n${YELLOW}[3/5] Checking required files...${RESET}"
REQUIRED_FILES=(
    "docker-compose.dev.yaml"
    "docker-compose.staging.yaml"
    "docker-compose.prod.yaml"
    ".env.dev"
    ".env.staging"
    ".env.prod"
    "backend/Dockerfile"
    "frontend/Dockerfile"
    "frontend/nginx/nginx.conf"
    "frontend/nginx/default.conf"
)

MISSING_FILES=0
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓ $file${RESET}"
    else
        echo -e "${RED}✗ $file - MISSING${RESET}"
        MISSING_FILES=$((MISSING_FILES + 1))
    fi
done

if [ $MISSING_FILES -gt 0 ]; then
    echo -e "\n${RED}✗ Missing $MISSING_FILES required files!${RESET}"
    exit 1
fi

# Verify docker-compose syntax
echo -e "\n${YELLOW}[4/5] Verifying Docker Compose files syntax...${RESET}"
COMPOSE_FILES=("docker-compose.dev.yaml" "docker-compose.staging.yaml" "docker-compose.prod.yaml")
for compose_file in "${COMPOSE_FILES[@]}"; do
    if docker-compose -f "$compose_file" config > /dev/null 2>&1; then
        echo -e "${GREEN}✓ $compose_file - Valid${RESET}"
    else
        echo -e "${RED}✗ $compose_file - Invalid syntax${RESET}"
        docker-compose -f "$compose_file" config
        exit 1
    fi
done

# Check Dockerfile syntax
echo -e "\n${YELLOW}[5/5] Checking Dockerfile syntax...${RESET}"
if docker build -f backend/Dockerfile --target development --dry-run . > /dev/null 2>&1; then
    echo -e "${GREEN}✓ backend/Dockerfile - Valid${RESET}"
else
    echo -e "${RED}✗ backend/Dockerfile - Invalid${RESET}"
    exit 1
fi

if docker build -f frontend/Dockerfile --target development --dry-run . > /dev/null 2>&1; then
    echo -e "${GREEN}✓ frontend/Dockerfile - Valid${RESET}"
else
    echo -e "${RED}✗ frontend/Dockerfile - Invalid${RESET}"
    exit 1
fi

# Summary
echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}✓ All checks passed! Your Docker setup is ready.${RESET}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${RESET}\n"

echo -e "${YELLOW}Next steps:${RESET}"
echo -e "${BLUE}1. Development:${RESET}   docker-compose -f docker-compose.dev.yaml --env-file .env.dev up --build"
echo -e "${BLUE}2. Staging:${RESET}      docker-compose -f docker-compose.staging.yaml --env-file .env.staging up --build -d"
echo -e "${BLUE}3. Production:${RESET}   docker-compose -f docker-compose.prod.yaml --env-file .env.prod up --build -d"
echo ""
