#!/usr/bin/env bash
# ==========================================
# SIM AI STUDIO - Check Available Ports
# ==========================================
# Purpose: Verify which ports are available
# Usage: ./scripts/check-ports.sh
# ==========================================

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Ports to check
PORTS=(3000 3002 5432)
PORT_NAMES=("App" "Realtime" "PostgreSQL")

echo "=========================================="
echo "Checking Port Availability"
echo "=========================================="
echo ""

check_port() {
    local port=$1
    local name=$2
    
    # Check if port is in use
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 || \
       netstat -tuln 2>/dev/null | grep -q ":$port " || \
       ss -tuln 2>/dev/null | grep -q ":$port "; then
        echo -e "${RED}✗ Port $port ($name) is IN USE${NC}"
        
        # Try to show what's using it
        if command -v lsof >/dev/null 2>&1; then
            echo -e "${YELLOW}  Used by:${NC}"
            lsof -Pi :$port -sTCP:LISTEN 2>/dev/null | tail -n +2 || echo "  (Unable to determine)"
        fi
        return 1
    else
        echo -e "${GREEN}✓ Port $port ($name) is AVAILABLE${NC}"
        return 0
    fi
}

# Track if all ports are available
all_available=true

# Check each port
for i in "${!PORTS[@]}"; do
    if ! check_port "${PORTS[$i]}" "${PORT_NAMES[$i]}"; then
        all_available=false
    fi
    echo ""
done

echo "=========================================="

if [ "$all_available" = true ]; then
    echo -e "${GREEN}✓ All ports are available!${NC}"
    echo -e "${BLUE}You can proceed with: make up${NC}"
    exit 0
else
    echo -e "${RED}⚠ Some ports are in use${NC}"
    echo ""
    echo -e "${YELLOW}Solutions:${NC}"
    echo "  1. Stop services using those ports"
    echo "  2. Change ports in .env file:"
    echo ""
    echo "     APP_PORT=3001      # Instead of 3000"
    echo "     SOCKET_PORT=3003   # Instead of 3002"
    echo "     POSTGRES_PORT=5433 # Instead of 5432"
    echo ""
    echo "  3. Update docker-compose.yml to use new ports"
    exit 1
fi
