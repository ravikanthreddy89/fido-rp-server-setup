#!/bin/bash

# Clean up test container and image

IMAGE_NAME="demo-pg"
IMAGE_TAG="local"
CONTAINER_NAME="demo-pg-test"

echo "🧹 Cleaning up..."

# Stop container if running
if docker ps -a --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
    echo "Stopping container: $CONTAINER_NAME"
    docker stop "$CONTAINER_NAME" || true
    docker rm "$CONTAINER_NAME" || true
fi

# Remove image if exists
if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^$IMAGE_NAME:$IMAGE_TAG$"; then
    echo "Removing image: $IMAGE_NAME:$IMAGE_TAG"
    docker rmi "$IMAGE_NAME:$IMAGE_TAG" || true
fi

echo "✅ Cleanup complete!"
