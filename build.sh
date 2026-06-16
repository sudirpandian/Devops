#!/bin/bash
# =============================================================
# build.sh — Build Docker image and push to Docker Hub
# Usage: ./build.sh [dev|prod] [dockerhub-username]
# =============================================================

set -euo pipefail

# ---------- Config ----------
BRANCH="${1:-dev}"
DOCKER_USER="${2:-${DOCKER_USER:-your-dockerhub-username}}"
IMAGE_NAME="devops-build"
TIMESTAMP=$(date +%Y%m%d%H%M%S)
GIT_SHA=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

# Map branch → Docker Hub repo
if [ "$BRANCH" = "master" ] || [ "$BRANCH" = "main" ]; then
  REPO="${DOCKER_USER}/prod"
  TAG="prod-${GIT_SHA}-${TIMESTAMP}"
else
  REPO="${DOCKER_USER}/dev"
  TAG="dev-${GIT_SHA}-${TIMESTAMP}"
fi

FULL_IMAGE="${REPO}:${TAG}"
LATEST_IMAGE="${REPO}:latest"

echo "============================================="
echo " DevOps Build Script"
echo " Branch  : $BRANCH"
echo " Image   : $FULL_IMAGE"
echo "============================================="

# ---------- Validate ----------
if ! command -v docker &>/dev/null; then
  echo "[ERROR] Docker is not installed or not in PATH"
  exit 1
fi

if [ ! -f Dockerfile ]; then
  echo "[ERROR] Dockerfile not found in current directory"
  exit 1
fi

# ---------- Build ----------
echo "[1/3] Building Docker image..."
docker build \
  --build-arg BUILD_DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
  --build-arg GIT_SHA="$GIT_SHA" \
  --build-arg BRANCH="$BRANCH" \
  -t "$FULL_IMAGE" \
  -t "$LATEST_IMAGE" \
  .

echo "[2/3] Build successful: $FULL_IMAGE"

# ---------- Push ----------
echo "[3/3] Pushing image to Docker Hub..."
docker push "$FULL_IMAGE"
docker push "$LATEST_IMAGE"

echo "============================================="
echo " Build & Push Complete!"
echo " Image : $FULL_IMAGE"
echo " Also  : $LATEST_IMAGE"
echo "============================================="

# Export for use by deploy.sh
export DOCKER_IMAGE="$FULL_IMAGE"
echo "DOCKER_IMAGE=$FULL_IMAGE" > .last_build_image
