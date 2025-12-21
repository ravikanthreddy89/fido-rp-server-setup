# Local Testing Guide

This guide walks you through building and testing the Docker image locally before deploying to Fly.io.

## Prerequisites

- **Docker**: Install from https://www.docker.com/products/docker-desktop
- **PostgreSQL Client**: `brew install postgresql@15` (macOS)
- **Redis CLI**: `brew install redis` (macOS)

## Quick Start

### 1. Build the Docker Image

```bash
cd /Users/ravikanth/code/demo-pg

# Using the provided script (recommended)
chmod +x build-local.sh
./build-local.sh

# OR build manually
docker build -t demo-pg:local -f Dockerfile .
```

### 2. Run the Container

```bash
# Using the script (easiest)
./build-local.sh

# OR run manually
docker run -d \
  --name demo-pg-test \
  -p 5432:5432 \
  -p 6379:6379 \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=password \
  -e POSTGRES_DB=demo_db \
  demo-pg:local
```

The script will:
- Build the image
- Start the container
- Wait 30 seconds for initialization
- Show you the logs
- Give you next steps

### 3. Wait for Services to Initialize

```bash
# Monitor logs in real-time
docker logs -f demo-pg-test

# You should see:
# - PostgreSQL initialization
# - SQL scripts running
# - Redis starting
```

### 4. Test PostgreSQL Connection

```bash
# From your terminal
psql -h localhost -U postgres -d demo_db -W
# Password: password

# Inside psql, try:
\dt           # List tables
SELECT * FROM users;
SELECT * FROM posts;
\q            # Quit
```

### 5. Test Redis Connection

```bash
# From your terminal
redis-cli -h localhost -p 6379

# Inside redis-cli, try:
PING          # Should return PONG
SET key value
GET key
DBSIZE        # Check number of keys
QUIT          # Exit
```

## Common Commands

### View Container Status

```bash
# Check if container is running
docker ps

# Show all containers (including stopped)
docker ps -a

# Show container details
docker inspect demo-pg-test
```

### View Logs

```bash
# View last 100 lines
docker logs demo-pg-test

# Follow logs in real-time
docker logs -f demo-pg-test

# View logs since last 5 minutes
docker logs --since 5m demo-pg-test
```

### Execute Commands Inside Container

```bash
# Enter the container shell
docker exec -it demo-pg-test /bin/bash

# Check supervisord status
docker exec -it demo-pg-test supervisorctl status

# View PostgreSQL logs
docker exec -it demo-pg-test tail -f /var/log/postgres.log

# View Redis logs
docker exec -it demo-pg-test tail -f /var/log/redis.log

# Connect to PostgreSQL inside container
docker exec -it demo-pg-test psql -U postgres -d demo_db

# Connect to Redis inside container
docker exec -it demo-pg-test redis-cli -h localhost
```

### Restart Services

```bash
# Restart the entire container
docker restart demo-pg-test

# Inside container, restart just PostgreSQL
docker exec -it demo-pg-test supervisorctl restart postgres

# Inside container, restart just Redis
docker exec -it demo-pg-test supervisorctl restart redis
```

## Troubleshooting

### Container won't start

```bash
# Check logs for errors
docker logs demo-pg-test

# Try rebuilding without cache
docker build -t demo-pg:local --no-cache -f Dockerfile .

# Run in foreground to see output
docker run --rm -it -p 5432:5432 -p 6379:6379 demo-pg:local
```

### PostgreSQL won't initialize

```bash
# Check PostgreSQL logs
docker exec -it demo-pg-test tail -f /var/log/postgres.log

# Check if data directory exists
docker exec -it demo-pg-test ls -la /var/lib/postgresql/data

# Check supervisord status
docker exec -it demo-pg-test supervisorctl status postgres
```

### Can't connect to PostgreSQL

```bash
# Verify port is exposed
docker port demo-pg-test

# Test port connectivity
nc -zv localhost 5432

# Check PostgreSQL is listening
docker exec -it demo-pg-test netstat -an | grep 5432

# Try connecting from inside container
docker exec -it demo-pg-test psql -U postgres -d demo_db
```

### Can't connect to Redis

```bash
# Verify port is exposed
docker port demo-pg-test

# Test port connectivity
nc -zv localhost 6379

# Check Redis is listening
docker exec -it demo-pg-test netstat -an | grep 6379

# Try connecting from inside container
docker exec -it demo-pg-test redis-cli -h localhost ping
```

### Out of disk space

```bash
# Remove stopped containers
docker container prune

# Remove unused images
docker image prune

# Remove unused volumes
docker volume prune

# Clean up everything
docker system prune -a
```

## Step-by-Step Testing Checklist

- [ ] Build image successfully
- [ ] Container starts without errors
- [ ] PostgreSQL initializes and runs SQL scripts
- [ ] Redis starts successfully
- [ ] Can connect to PostgreSQL from local machine
- [ ] Can query PostgreSQL tables (users, posts, comments)
- [ ] Can connect to Redis from local machine
- [ ] Can ping Redis
- [ ] Logs show no errors
- [ ] Services survive container restart

## Cleanup

When you're done testing:

```bash
# Using the cleanup script (recommended)
chmod +x cleanup-local.sh
./cleanup-local.sh

# OR manually
docker stop demo-pg-test
docker rm demo-pg-test
docker rmi demo-pg:local

# Verify cleanup
docker ps -a
docker images | grep demo-pg
```

## Next Steps

Once testing is complete and everything works:

1. Fix any issues found during testing
2. Rebuild the image if you made changes
3. Test again
4. Deploy to Fly.io:

```bash
flyctl deploy
```

## Performance Notes

When running locally:

- **First start**: 30-60 seconds (initializing PostgreSQL)
- **Subsequent starts**: 10-15 seconds (databases already initialized)
- **Memory usage**: ~300-400MB
- **Disk usage**: ~500MB for base image, varies with data

## Tips & Tricks

### Persistent Storage Between Runs

By default, Docker removes the container after `docker run`. To keep data:

```bash
# Use --rm=false or don't use --rm flag
docker run -d \
  --name demo-pg-test \
  -p 5432:5432 \
  -p 6379:6379 \
  demo-pg:local

# Then you can:
docker stop demo-pg-test
docker start demo-pg-test  # Data persists
```

### Docker Compose Alternative

You can also use the `docker-compose.yml` for local testing:

```bash
# Start services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Clean up including volumes
docker-compose down -v
```

### View Resource Usage

```bash
# Real-time resource monitoring
docker stats demo-pg-test

# Or for all containers
docker stats
```
