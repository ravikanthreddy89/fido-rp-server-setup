# Demo PostgreSQL + Redis Docker Setup

This project sets up a containerized environment with PostgreSQL and Redis using Docker Compose.

## Prerequisites

- Docker (version 20+)
- Docker Compose (version 1.29+)

## Quick Start

### 1. Start the Services

```bash
docker-compose up -d
```

This will:
- Build and start a PostgreSQL 15 container with initialization scripts
- Start a Redis 7 Alpine container
- Create persistent volumes for both services
- Set up a shared network

### 2. Verify Services are Running

```bash
docker-compose ps
```

### 3. Connect to PostgreSQL

**From your host machine:**
```bash
psql -h localhost -U postgres -d demo_db -W
# Password: password
```

**From inside the container:**
```bash
docker-compose exec postgres psql -U postgres -d demo_db
```

### 4. Connect to Redis

**From your host machine:**
```bash
redis-cli -h localhost -p 6379
```

**From inside the container:**
```bash
docker-compose exec redis redis-cli
```

## Project Structure

```
.
├── docker-compose.yml          # Main Docker Compose configuration
├── Dockerfile.postgres         # Custom PostgreSQL Dockerfile
├── sql/                        # SQL initialization scripts
│   ├── 01-init.sql            # Initial schema and sample data
│   └── 02-additional-schema.sql # Additional tables and data
├── .dockerignore               # Docker build exclusions
├── .env.example                # Environment variables template
└── README.md                   # This file
```

## Configuration

### Environment Variables

Copy `.env.example` to `.env` and modify as needed:

```bash
cp .env.example .env
```

Available variables:
- `POSTGRES_USER`: PostgreSQL username (default: postgres)
- `POSTGRES_PASSWORD`: PostgreSQL password (default: password)
- `POSTGRES_DB`: Initial database name (default: demo_db)
- `POSTGRES_PORT`: External port mapping (default: 5432)
- `REDIS_PORT`: External port mapping (default: 6379)

### PostgreSQL Initialization Scripts

SQL files in the `sql/` directory are automatically executed when PostgreSQL starts (in alphabetical order):
- `01-init.sql`: Creates tables and inserts sample data
- `02-additional-schema.sql`: Adds additional tables and relationships

To add more initialization scripts, create files like `03-custom.sql` in the `sql/` directory.

## Common Commands

### View Logs

```bash
# All services
docker-compose logs -f

# PostgreSQL only
docker-compose logs -f postgres

# Redis only
docker-compose logs -f redis
```

### Stop Services

```bash
docker-compose stop
```

### Remove Containers and Volumes

```bash
# Remove containers only
docker-compose down

# Remove containers and volumes (WARNING: deletes data)
docker-compose down -v
```

### Access Database

```bash
# PostgreSQL
docker-compose exec postgres psql -U postgres -d demo_db

# Redis
docker-compose exec redis redis-cli
```

## Database Schema

### Tables

**users**
- id (SERIAL PRIMARY KEY)
- username (VARCHAR UNIQUE)
- email (VARCHAR UNIQUE)
- created_at, updated_at (TIMESTAMP)

**posts**
- id (SERIAL PRIMARY KEY)
- user_id (FOREIGN KEY -> users)
- title, content (TEXT)
- created_at, updated_at (TIMESTAMP)

**comments**
- id (SERIAL PRIMARY KEY)
- post_id (FOREIGN KEY -> posts)
- user_id (FOREIGN KEY -> users)
- content (TEXT)
- created_at (TIMESTAMP)

**sessions**
- session_id (VARCHAR PRIMARY KEY)
- user_id (FOREIGN KEY -> users)
- data (JSONB)
- expires_at, created_at (TIMESTAMP)

## Troubleshooting

### PostgreSQL won't start

```bash
# Check logs
docker-compose logs postgres

# Ensure port 5432 is not in use
lsof -i :5432

# Rebuild the image
docker-compose up -d --build
```

### Redis connection refused

```bash
# Check if Redis is running
docker-compose ps redis

# Check Redis logs
docker-compose logs redis

# Test Redis connection inside container
docker-compose exec redis redis-cli ping
```

### Volumes not persisting

Ensure volumes are properly mounted:
```bash
docker volume ls
docker volume inspect demo-pg_postgres_data
```

## Connecting from Your Application

### PostgreSQL Connection String

```
postgresql://postgres:password@localhost:5432/demo_db
```

### Redis Connection

```
redis://localhost:6379
```

## Next Steps

1. Add custom SQL initialization files to `sql/` directory
2. Modify `docker-compose.yml` to add more services as needed
3. Update `.env` with your actual credentials (never commit `.env` to version control)
4. Integrate with your application code
