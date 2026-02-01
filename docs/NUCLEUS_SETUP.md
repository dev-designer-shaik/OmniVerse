# Nucleus Enterprise Setup Guide

## Prerequisites

1. **NGC Account**: https://ngc.nvidia.com
2. **Omniverse Enterprise Subscription**: With Nucleus Enterprise entitlement
3. **NGC API Key**: Generate at https://ngc.nvidia.com/setup/api-key
4. **Docker Desktop**: Running on the host machine

## Installation Steps

### 1. Login to NGC Registry

```bash
docker login nvcr.io --username '$oauthtoken' --password '<YOUR_NGC_API_KEY>'
```

### 2. Download Nucleus Enterprise Stack

Using NGC CLI:
```bash
ngc registry resource download-version "nvidia/omniverse/enterprise-nucleus-server:4.2.141"
```

Or manually from NGC catalog:
https://catalog.ngc.nvidia.com/orgs/nvidia/teams/omniverse/collections/enterprise-nucleus

### 3. Configure Environment

Edit `base_stack/nucleus-stack.env`:

```bash
# Required settings
ACCEPT_EULA=1
SECURITY_REVIEWED=1
SERVER_IP_OR_HOST=192.168.10.146  # Your server IP

# Passwords (change these!)
MASTER_PASSWORD=<strong-password>
SERVICE_PASSWORD=<service-password>

# Data location
DATA_ROOT=/home/mdad/nucleus-data
```

### 4. Generate Secrets

```bash
cd base_stack
./generate-sample-insecure-secrets.sh
```

For production, generate proper secrets:
```bash
# RSA keypairs for auth tokens
openssl genrsa -out secrets/auth_root_of_trust.pem 4096
openssl rsa -in secrets/auth_root_of_trust.pem -pubout -out secrets/auth_root_of_trust.pub

openssl genrsa -out secrets/auth_root_of_trust_lt.pem 4096
openssl rsa -in secrets/auth_root_of_trust_lt.pem -pubout -out secrets/auth_root_of_trust_lt.pub

# Salt files
openssl rand 32 > secrets/pwd_salt
openssl rand 32 > secrets/lft_salt
openssl rand 32 > secrets/svc_reg_token
```

### 5. Pull Containers

```bash
docker compose --env-file nucleus-stack.env -f nucleus-stack-no-ssl.yml pull
```

### 6. Start Nucleus

```bash
docker compose --env-file nucleus-stack.env -f nucleus-stack-no-ssl.yml up -d
```

### 7. Verify Deployment

Check container status:
```bash
docker compose --env-file nucleus-stack.env -f nucleus-stack-no-ssl.yml ps
```

Access Web UI:
- URL: http://192.168.10.146:8080
- Username: omniverse
- Password: (MASTER_PASSWORD from env file)

## Container Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Nucleus Enterprise Stack                     │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │ nucleus-api  │  │ nucleus-auth │  │  nucleus-navigator   │  │
│  │   :3009      │  │   :3100      │  │       :8080          │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │ nucleus-lft  │  │nucleus-search│  │  nucleus-discovery   │  │
│  │   :3030      │  │   :3400      │  │       :3333          │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
│                                                                 │
│  ┌────────────────────────────────────────────────────────────┐│
│  │                     nucleus-data                           ││
│  │              /home/mdad/nucleus-data                       ││
│  └────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

## Troubleshooting

### 401 Unauthorized on Container Pull

This means your NGC account lacks Nucleus Enterprise entitlement.

**Solution**:
1. Contact NVIDIA sales for Omniverse Enterprise subscription
2. Verify entitlement at https://ngc.nvidia.com/setup
3. Re-login to NGC registry

### Container Fails to Start

Check logs:
```bash
docker compose --env-file nucleus-stack.env -f nucleus-stack-no-ssl.yml logs nucleus-api
```

Common issues:
- Port conflicts (check 3009, 8080, 3030 are available)
- DATA_ROOT directory doesn't exist
- Secrets not generated

### Cannot Connect from Isaac Sim

1. Verify Nucleus is running: `docker ps | grep nucleus`
2. Check firewall allows ports 3009, 3030, 8080
3. Test connectivity: `curl http://192.168.10.146:3009/health`

## Management Commands

```bash
# Start
docker compose --env-file nucleus-stack.env -f nucleus-stack-no-ssl.yml up -d

# Stop
docker compose --env-file nucleus-stack.env -f nucleus-stack-no-ssl.yml down

# View logs
docker compose --env-file nucleus-stack.env -f nucleus-stack-no-ssl.yml logs -f

# Restart specific service
docker compose --env-file nucleus-stack.env -f nucleus-stack-no-ssl.yml restart nucleus-api
```
