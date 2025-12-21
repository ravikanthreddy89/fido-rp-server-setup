#!/bin/bash

# Local testing script for demo-pg Docker image

set -e

PROJECT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
IMAGE_NAME="demo-pg"
IMAGE_TAG="local"
CONTAINER_NAME="demo-pg-test"

echo "🐳 Building Docker image: $IMAGE_NAME:$IMAGE_TAG"
docker build -t "$IMAGE_NAME:$IMAGE_TAG" -f Dockerfile "$PROJECT_DIR"

echo ""
echo "✅ Build successful!"
echo ""
echo "🚀 Starting container: $CONTAINER_NAME"
docker run -d \
  --name "$CONTAINER_NAME" \
  -p 5432:5432 \
  -p 6379:6379 \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=password \
  -e POSTGRES_DB=demo_db \
  "$IMAGE_NAME:$IMAGE_TAG"

echo ""
echo "⏳ Waiting for services to start (30 seconds)..."
sleep 30

echo ""
echo "📊 Checking container status..."
docker ps | grep "$CONTAINER_NAME"

echo ""
echo "🔍 Container logs:"
docker logs "$CONTAINER_NAME"

echo ""
echo "✨ Services are ready!"
echo ""
echo "📝 Next steps:"
echo ""
echo "1. Test PostgreSQL connection:"
echo "   psql -h localhost -U postgres -d demo_db -W"
echo "   Password: password"
echo ""
echo "2. Test Redis connection:"
echo "   redis-cli -h localhost -p 6379"
echo "   > PING"
echo ""
echo "3. View logs:"
echo "   docker logs -f $CONTAINER_NAME"
echo ""
echo "4. Stop container:"
echo "   docker stop $CONTAINER_NAME"
echo ""
echo "5. Remove container:"
echo "   docker rm $CONTAINER_NAME"
echo ""
echo "6. Remove image:"
echo "   docker rmi $IMAGE_NAME:$IMAGE_TAG"
