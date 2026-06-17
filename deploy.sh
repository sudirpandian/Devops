#!/bin/bash
# =============================================================
# deploy.sh — Deploy the Docker image using docker-compose
# Usage: ./deploy.sh [docker-image-name]
# =============================================================

set -euo pipefail

# ---------- Config ----------
if [ -n "${1:-}" ]; then
  DOCKER_IMAGE="$1"
elif [ -f .last_build_image ]; then
  source .last_build_image
else
  DOCKER_IMAGE="${DOCKER_IMAGE:-your-dockerhub-username/dev:latest}"
fi

COMPOSE_FILE="docker-compose.yml"
CONTAINER_NAME="react-app"
APP_PORT=80

echo "============================================="
echo " DevOps Deploy Script"
echo " Image   : $DOCKER_IMAGE"
echo " Port    : $APP_PORT"
echo "============================================="

# ---------- Validate ----------
if ! command -v docker &>/dev/null; then
  echo "[ERROR] Docker not found"
  exit 1
fi

if ! command -v docker-compose &>/dev/null && ! docker compose version &>/dev/null 2>&1; then
  echo "[ERROR] docker-compose not found"
  exit 1
fi

# Detect compose command (v1 vs v2)
if docker compose version &>/dev/null 2>&1; then
  COMPOSE_CMD="docker compose"
else
  COMPOSE_CMD="docker-compose"
fi

# ---------- Pre-deploy ----------
echo "[1/5] Pulling latest image..."
docker pull "$DOCKER_IMAGE"

echo "[2/5] Stopping existing container (if running)..."
$COMPOSE_CMD -f "$COMPOSE_FILE" down --remove-orphans 2>/dev/null || true

# ---------- Deploy ----------
echo "[3/5] Starting container..."
DOCKER_IMAGE="$DOCKER_IMAGE" $COMPOSE_CMD -f "$COMPOSE_FILE" up -d

# ---------- Health Check ----------
echo "[4/5] Waiting for health check..."
MAX_WAIT=60
ELAPSED=0
until curl -sf "http://localhost:${APP_PORT}/health" >/dev/null 2>&1; do
  if [ $ELAPSED -ge $MAX_WAIT ]; then
    echo "[ERROR] Health check failed after ${MAX_WAIT}s"
    echo "--- Container logs ---"
    docker logs "$CONTAINER_NAME" --tail=50
    exit 1
  fi
  echo "  Waiting... (${ELAPSED}s)"
  sleep 5
  ELAPSED=$((ELAPSED + 5))
done

echo "[5/5] Application is healthy!"

# ---------- Cleanup ----------
echo "Cleaning up unused Docker images..."
docker image prune -f --filter "until=24h" 2>/dev/null || true

echo "============================================="
echo " Deployment Complete!"
echo " App URL : http://$(curl -sf http://checkip.amazonaws.com/ 2>/dev/null || echo 'YOUR-SERVER-IP')/"
echo "============================================="
