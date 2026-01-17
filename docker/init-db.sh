#!/bin/bash
set -e

# ==========================================
# PostgreSQL Initialization Script
# ==========================================
# Creates custom user with proper permissions
# Runs automatically on first container start
# ==========================================

echo "🔧 Initializing PostgreSQL with custom user..."

# Create user if it doesn't exist (only if different from postgres)
if [ "$POSTGRES_USER" != "postgres" ]; then
    echo "Creating user: $POSTGRES_USER"
    
    psql -v ON_ERROR_STOP=1 --username postgres --dbname "$POSTGRES_DB" <<-EOSQL
        DO \$\$
        BEGIN
            IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '$POSTGRES_USER') THEN
                CREATE ROLE $POSTGRES_USER WITH LOGIN PASSWORD '$POSTGRES_PASSWORD';
            END IF;
        END
        \$\$;
        
        -- Grant all privileges on database
        GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO $POSTGRES_USER;
        
        -- Grant privileges on schema
        GRANT ALL ON SCHEMA public TO $POSTGRES_USER;
        
        -- Grant privileges on all tables
        GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $POSTGRES_USER;
        GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $POSTGRES_USER;
        
        -- Set default privileges for future objects
        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO $POSTGRES_USER;
        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO $POSTGRES_USER;
        
        -- Make user owner of the database
        ALTER DATABASE $POSTGRES_DB OWNER TO $POSTGRES_USER;
EOSQL

    echo "✅ User $POSTGRES_USER created with full privileges"
else
    echo "ℹ️  Using default postgres user"
fi

echo "✅ Database initialization complete"
