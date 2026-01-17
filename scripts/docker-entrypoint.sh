#!/usr/bin/env bash
# ==========================================
# SIM AI STUDIO - Docker Entrypoint Script
# ==========================================
# Purpose: Idempotent initialization script
# Ensures safe startup across all environments
# ==========================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# ==========================================
# Environment Validation
# ==========================================
validate_environment() {
    log_info "Validating environment variables..."
    
    local required_vars=(
        "DATABASE_URL"
        "BETTER_AUTH_SECRET"
        "BETTER_AUTH_URL"
        "NEXT_PUBLIC_APP_URL"
        "ENCRYPTION_KEY"
        "INTERNAL_API_SECRET"
    )
    
    local missing_vars=()
    
    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            missing_vars+=("$var")
        fi
    done
    
    if [ ${#missing_vars[@]} -ne 0 ]; then
        log_error "Missing required environment variables:"
        for var in "${missing_vars[@]}"; do
            log_error "  - $var"
        done
        exit 1
    fi
    
    log_success "Environment validation passed"
}

# ==========================================
# Database Connection Check
# ==========================================
wait_for_database() {
    log_info "Waiting for database connection..."
    
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if pg_isready -h db -p 5432 -U "${POSTGRES_USER:-postgres}" > /dev/null 2>&1; then
            log_success "Database is ready"
            return 0
        fi
        
        log_info "Attempt $attempt/$max_attempts: Database not ready, waiting..."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    log_error "Database connection timeout after $max_attempts attempts"
    exit 1
}

# ==========================================
# Security Checks
# ==========================================
check_secrets_strength() {
    log_info "Checking secret strength..."
    
    local weak_secrets=(
        "your_secret_key"
        "your_auth_secret_here"
        "your_encryption_key_here"
        "your_internal_api_secret_here"
        "your_api_encryption_key_here"
        "changeme"
        "password"
        "secret"
    )
    
    for secret in "${weak_secrets[@]}"; do
        if [[ "${BETTER_AUTH_SECRET}" == *"$secret"* ]] || \
           [[ "${ENCRYPTION_KEY}" == *"$secret"* ]] || \
           [[ "${INTERNAL_API_SECRET}" == *"$secret"* ]]; then
            log_warning "⚠️  SECURITY WARNING: Weak or default secret detected!"
            log_warning "    Please generate strong secrets with: openssl rand -hex 32"
            log_warning "    Current setup is NOT secure for production use!"
        fi
    done
}

# ==========================================
# Main Execution
# ==========================================
main() {
    log_info "Starting SIM AI Studio initialization..."
    echo "=========================================="
    
    # Validate environment
    validate_environment
    
    # Check secret strength
    check_secrets_strength
    
    # Display configuration
    log_info "Configuration:"
    log_info "  - Environment: ${NODE_ENV:-production}"
    log_info "  - App URL: ${NEXT_PUBLIC_APP_URL}"
    log_info "  - Database: ${DATABASE_URL%%\?*}"
    log_info "  - Socket URL: ${NEXT_PUBLIC_SOCKET_URL:-http://localhost:3002}"
    
    echo "=========================================="
    log_success "Initialization complete!"
    log_info "Starting application..."
    
    # Execute the main command
    exec "$@"
}

# Run main function with all arguments
main "$@"
