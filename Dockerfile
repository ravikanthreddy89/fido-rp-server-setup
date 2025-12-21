# Multi-stage Dockerfile for Fly.io deployment
# This runs both PostgreSQL and Redis in a single container

FROM alpine:3.18

# Install supervisord, PostgreSQL client, and Redis
RUN apk add --no-cache \
    supervisor \
    postgresql15-client \
    postgresql15-server \
    postgresql15 \
    redis \
    bash \
    curl

# Create directories
RUN mkdir -p /var/run/postgresql /var/lib/postgresql/data /data /etc/supervisor/conf.d

# Setup PostgreSQL
RUN chown -R postgres:postgres /var/lib/postgresql/data /var/run/postgresql

# Copy supervisor configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy PostgreSQL initialization scripts
COPY sql/ /docker-entrypoint-initdb.d/

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose ports
EXPOSE 5432 6379

# Set working directory
WORKDIR /

# Health check
HEALTHCHECK --interval=10s --timeout=5s --retries=5 \
    CMD curl -f http://localhost:8080/health || exit 1

# Run entrypoint
ENTRYPOINT ["/entrypoint.sh"]
