#!/bin/bash
# Setup script for Nucleus Enterprise Server

set -e

NUCLEUS_DIR="$HOME/nucleus-server"

echo "========================================"
echo "  Nucleus Enterprise Setup"
echo "========================================"

# Check NGC login
echo "Checking NGC registry access..."
if ! docker manifest inspect nvcr.io/nvidia/omniverse/nucleus-api:1.14.53 &>/dev/null; then
    echo ""
    echo "ERROR: Cannot access Nucleus Enterprise containers."
    echo ""
    echo "Requirements:"
    echo "  1. NGC account: https://ngc.nvidia.com"
    echo "  2. Omniverse Enterprise subscription with Nucleus entitlement"
    echo "  3. NGC API key"
    echo ""
    echo "Login to NGC:"
    echo "  docker login nvcr.io --username '\$oauthtoken' --password '<NGC_API_KEY>'"
    echo ""
    exit 1
fi

echo "NGC access verified."

# Check if Nucleus is already installed
if [ ! -d "$NUCLEUS_DIR" ]; then
    echo "Downloading Nucleus Enterprise stack..."
    ngc registry resource download-version "nvidia/omniverse/enterprise-nucleus-server:4.2.141"
    mv enterprise-nucleus-server_v4.2.141 "$NUCLEUS_DIR"
fi

cd "$NUCLEUS_DIR/base_stack"

# Generate secrets if not present
if [ ! -f "secrets/auth_root_of_trust.pem" ]; then
    echo "Generating secrets..."
    ./generate-sample-insecure-secrets.sh
fi

# Pull containers
echo "Pulling Nucleus containers..."
docker compose --env-file nucleus-stack.env -f nucleus-stack-no-ssl.yml pull

echo ""
echo "========================================"
echo "  Nucleus Enterprise Ready"
echo "========================================"
echo ""
echo "Start Nucleus:"
echo "  cd $NUCLEUS_DIR/base_stack"
echo "  docker compose --env-file nucleus-stack.env -f nucleus-stack-no-ssl.yml up -d"
echo ""
echo "Access:"
echo "  Web UI: http://$(hostname -I | awk '{print $1}'):8080"
echo "  Nucleus: omniverse://$(hostname -I | awk '{print $1}')/Projects/"
echo ""
echo "Default login:"
echo "  Username: omniverse"
echo "  Password: (see nucleus-stack.env MASTER_PASSWORD)"
echo ""
