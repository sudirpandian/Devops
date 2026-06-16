#!/bin/bash
# =============================================================
# setup-monitoring.sh — Deploy Uptime Kuma monitoring stack
# =============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="$SCRIPT_DIR/docker-compose.monitoring.yml"

echo "============================================="
echo " Setting up Monitoring (Uptime Kuma)"
echo "============================================="

if ! command -v docker &>/dev/null; then
  echo "[ERROR] Docker not installed"
  exit 1
fi

# Detect compose command
if docker compose version &>/dev/null 2>&1; then
  COMPOSE_CMD="docker compose"
else
  COMPOSE_CMD="docker-compose"
fi

echo "[1/2] Starting Uptime Kuma..."
$COMPOSE_CMD -f "$COMPOSE_FILE" up -d

echo "[2/2] Waiting for Uptime Kuma to start..."
sleep 15

SERVER_IP=$(curl -sf http://checkip.amazonaws.com/ 2>/dev/null || echo "YOUR-SERVER-IP")

echo "============================================="
echo " Monitoring is UP!"
echo " Dashboard: http://${SERVER_IP}:3001"
echo ""
echo " Next steps:"
echo "  1. Open the dashboard and create an admin account"
echo "  2. Add a new monitor:"
echo "     - Type: HTTP(s)"
echo "     - Name: React App"
echo "     - URL:  http://${SERVER_IP}/health"
echo "     - Interval: 60 seconds"
echo "  3. Add notifications (Telegram/Slack/Email)"
echo "     under Settings > Notifications"
echo "============================================="
