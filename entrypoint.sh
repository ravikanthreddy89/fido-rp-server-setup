#!/bin/bash
set -e

# Set environment variables
export POSTGRES_USER="${POSTGRES_USER:-postgres}"
export POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-password}"
export POSTGRES_DB="${POSTGRES_DB:-demo_db}"

# Initialize PostgreSQL if needed
if [ ! -f /var/lib/postgresql/data/PG_VERSION ]; then
    echo "Initializing PostgreSQL database..."
    
    # Initialize database cluster
    initdb -D /var/lib/postgresql/data \
        -U "$POSTGRES_USER" \
        --locale=en_US.UTF-8 \
        --encoding=UTF8
    
    # Configure PostgreSQL to accept connections
    echo "host    all             all             127.0.0.1/32            trust" >> /var/lib/postgresql/data/pg_hba.conf
    echo "host    all             all             0.0.0.0/0               md5" >> /var/lib/postgresql/data/pg_hba.conf
    
    # Start PostgreSQL temporarily to create database
    echo "Starting PostgreSQL for initial setup..."
    /usr/bin/postgres -D /var/lib/postgresql/data &
    PG_PID=$!
    
    # Wait for PostgreSQL to be ready
    sleep 5
    
    # Create the initial database
    PGPASSWORD="$POSTGRES_PASSWORD" psql -U "$POSTGRES_USER" -h localhost -c "CREATE DATABASE $POSTGRES_DB;" || true
    
    # Run initialization scripts
    if [ -d /docker-entrypoint-initdb.d ]; then
        echo "Running initialization scripts..."
        for sql_file in /docker-entrypoint-initdb.d/*.sql; do
            if [ -f "$sql_file" ]; then
                echo "Executing $sql_file..."
                PGPASSWORD="$POSTGRES_PASSWORD" psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -h localhost < "$sql_file"
            fi
        done
    fi
    
    # Stop temporary PostgreSQL
    kill $PG_PID
    wait $PG_PID 2>/dev/null || true
    
    echo "PostgreSQL initialization completed"
fi

# Ensure correct permissions
chown -R postgres:postgres /var/lib/postgresql/data /var/run/postgresql

# Create redis user and data directory
mkdir -p /data
chown -R redis:redis /data

# Start supervisord (manages both PostgreSQL and Redis)
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
