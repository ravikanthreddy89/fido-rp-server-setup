#!/bin/bash

# Simple script to test docker-compose locally

set -e

echo "🐳 Starting Docker containers with docker-compose..."
docker-compose up -d

echo ""
echo "⏳ Waiting for services to be ready..."
sleep 5

echo ""
echo "📊 Container status:"
docker-compose ps

echo ""
echo "✨ Services are ready!"
echo ""
echo "📝 Connection details:"
echo ""
echo "PostgreSQL:"
echo "  Host: localhost"
echo "  Port: 5432"
echo "  User: postgres"
echo "  Password: postgres"
echo "  Database: demo_db"
echo ""
echo "Redis:"
echo "  Host: localhost"
echo "  Port: 6379"
echo ""
echo "🧪 Test commands:"
echo ""
echo "1. Test PostgreSQL:"
echo "   docker-compose exec postgres psql -U postgres -d demo_db -c 'SELECT version();'"
echo ""
echo "2. Test Redis:"
echo "   docker-compose exec redis redis-cli ping"
echo ""
echo "3. View PostgreSQL logs:"
echo "   docker-compose logs postgres"
echo ""
echo "4. View Redis logs:"
echo "   docker-compose logs redis"
echo ""
echo "5. Stop services:"
echo "   docker-compose down"
echo ""
echo "6. Stop and remove volumes:"
echo "   docker-compose down -v"
