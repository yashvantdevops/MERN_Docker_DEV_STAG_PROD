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
    # Fallback check for 'docker compose' plugin
    if docker compose version &> /dev/null; then
         COMPOSE_VERSION=$(docker compose version)
         echo -e "${GREEN}✓ Docker Compose (Plugin) found: $COMPOSE_VERSION${RESET}"
    else
        echo -e "${RED}✗ Docker Compose not found. Please install Docker Compose.${RESET}"
        exit 1
    fi
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
    # Supports both 'docker-compose' and 'docker compose'
    if command -v docker-compose &> /dev/null; then
        CMD="docker-compose"
    else
        CMD="docker compose"
    fi

    # Use --env-file to load variables so config check doesn't fail on missing env vars
    ENV_FILE=".env.dev"
    if [[ "$compose_file" == *"prod"* ]]; then ENV_FILE=".env.prod"; fi
    if [[ "$compose_file" == *"staging"* ]]; then ENV_FILE=".env.staging"; fi

    if $CMD -f "$compose_file" --env-file "$ENV_FILE" config > /dev/null 2>&1; then
        echo -e "${GREEN}✓ $compose_file - Valid${RESET}"
    else
        echo -e "${RED}✗ $compose_file - Invalid syntax${RESET}"
        $CMD -f "$compose_file" --env-file "$ENV_FILE" config
        exit 1
    fi
done

# Check Dockerfile syntax
# NOTE: 'docker build --check' is a newer feature (BuildKit).
# We use a simple build check or BuildKit check if available.
echo -e "\n${YELLOW}[5/5] Checking Dockerfile syntax...${RESET}"

check_dockerfile() {
    local context=$1
    local dockerfile=$2
    local target=$3

    # Try using BuildKit check (Docker 20.10+) or fall back to basic check
    if DOCKER_BUILDKIT=1 docker build -f "$dockerfile" --target "$target" --no-cache --check "$context" > /dev/null 2>&1; then
         echo -e "${GREEN}✓ $dockerfile ($target) - Valid${RESET}"
    else
         # Fallback: If --check isn't supported, just try a dry run (limited validation)
         # or report failure if the build command itself failed
         echo -e "${RED}✗ $dockerfile - Syntax Check Failed${RESET}"
         # Run again without mute to show error
         DOCKER_BUILDKIT=1 docker build -f "$dockerfile" --target "$target" --check "$context"
         exit 1
    fi
}

# We check 'development' target as it's usually the base for others
# Assuming current directory structure
if [ -d "backend" ]; then
    check_dockerfile "." "backend/Dockerfile" "development"
else
     echo -e "${YELLOW}⚠ backend/ directory missing, skipping backend check${RESET}"
fi

if [ -d "frontend" ]; then
    check_dockerfile "." "frontend/Dockerfile" "development"
else
     echo -e "${YELLOW}⚠ frontend/ directory missing, skipping frontend check${RESET}"
fi


# Summary
echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}✓ All checks passed! Your Docker setup is ready.${RESET}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${RESET}\n"

echo -e "${YELLOW}Next steps:${RESET}"
echo -e "${BLUE}1. Development:${RESET}   ./helper.sh dev-up"
echo -e "${BLUE}2. Staging:${RESET}       ./helper.sh staging-up"
echo -e "${BLUE}3. Production:${RESET}    ./helper.sh prod-up"
echo ""
