#!/usr/bin/env bash
# ==========================================
# SIM AI STUDIO - Generate Secure Secrets
# ==========================================
# Purpose: Generate cryptographically secure secrets
# Usage: ./scripts/generate-secrets.sh
# ==========================================

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=========================================="
echo "SIM AI Studio - Secret Generator"
echo "=========================================="
echo ""
echo -e "${YELLOW}⚠️  Copy these values to your .env file${NC}"
echo ""
echo "=========================================="

echo -e "${BLUE}# Core Security Secrets${NC}"
echo "BETTER_AUTH_SECRET=$(openssl rand -hex 32)"
echo "ENCRYPTION_KEY=$(openssl rand -hex 32)"
echo "INTERNAL_API_SECRET=$(openssl rand -hex 32)"
echo "API_ENCRYPTION_KEY=$(openssl rand -hex 32)"
echo ""

echo -e "${BLUE}# Optional Secrets${NC}"
echo "ADMIN_API_KEY=$(openssl rand -hex 32)"
echo "CRON_SECRET=$(openssl rand -hex 32)"
echo ""

echo "=========================================="
echo -e "${GREEN}✓ Secrets generated successfully${NC}"
echo ""
echo -e "${YELLOW}IMPORTANT:${NC}"
echo "  1. Copy these values to your .env file"
echo "  2. Never commit .env to version control"
echo "  3. Store secrets securely (use a password manager)"
echo "  4. Rotate secrets regularly in production"
echo "=========================================="
