#!/usr/bin/env bash
# ==========================================
# SIM AI STUDIO - Health Check Script
# ==========================================
# Purpose: Check service health status
# Usage: ./scripts/health-check.sh [service]
# ==========================================

set -e

SERVICE="${1:-all}"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_service() {
    local service=$1
    local url=$2
    local name=$3
    
    echo -n "Checking $name... "
    
    if curl -sf "$url" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Healthy${NC}"
        return 0
    else
        echo -e "${RED}✗ Unhealthy${NC}"
        return 1
    fi
}

check_database() {
    echo -n "Checking Database... "
    
    if docker exec simstudio-db pg_isready -U postgres > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Healthy${NC}"
        return 0
    else
        echo -e "${RED}✗ Unhealthy${NC}"
        return 1
    fi
}

echo "=========================================="
echo "SIM AI Studio - Health Check"
echo "=========================================="

case $SERVICE in
    "all")
        check_database
        check_service "simstudio" "http://localhost:3000/api/health" "Main App"
        check_service "realtime" "http://localhost:3002/health" "Realtime Server"
        ;;
    "db")
        check_database
        ;;
    "app")
        check_service "simstudio" "http://localhost:3000/api/health" "Main App"
        ;;
    "realtime")
        check_service "realtime" "http://localhost:3002/health" "Realtime Server"
        ;;
    *)
        echo "Usage: $0 [all|db|app|realtime]"
        exit 1
        ;;
esac

echo "=========================================="
