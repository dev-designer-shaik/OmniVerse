#!/bin/bash
# Start HTTP server for USD file access (fallback when Nucleus unavailable)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"
LOCAL_IP=$(hostname -I | awk '{print $1}')

echo "========================================"
echo "  USD File Server (HTTP Fallback)"
echo "========================================"
echo ""
echo "Server URL: http://$LOCAL_IP:8080/"
echo ""
echo "Access USD files from Isaac Sim/Thor:"
echo "  http://$LOCAL_IP:8080/stages/my_scene.usd"
echo "  http://$LOCAL_IP:8080/assets/robot.usd"
echo ""
echo "Note: For production, use Nucleus Enterprise"
echo "      omniverse://$LOCAL_IP/Projects/..."
echo ""
echo "Press Ctrl+C to stop"
echo "========================================"

python3 -m http.server 8080 --bind 0.0.0.0
