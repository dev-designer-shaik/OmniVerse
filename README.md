# NVIDIA Omniverse Integration

Full NVIDIA Omniverse integration between x86 workstation (RTX 3070 Ti) and Jetson Thor.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        x86 PC (192.168.10.146)                              │
│                           RTX 3070 Ti                                       │
│  ┌─────────────────┐  ┌────────────────────┐  ┌────────────────────────┐   │
│  │  USD Composer   │  │  Nucleus Server    │  │  HTTP File Server      │   │
│  │  (Kit SDK)      │  │  (Enterprise)      │  │  :8080 (fallback)      │   │
│  │  Authoring      │  │  :3009 (API)       │  │                        │   │
│  └────────┬────────┘  │  :8080 (Web)       │  └────────────────────────┘   │
│           │           └─────────┬──────────┘                               │
│           └─────────────────────┼──────────────────────────────────────────┤
└─────────────────────────────────┼──────────────────────────────────────────┘
                                  │ omniverse://
                                  │ USD LiveSync
                                  ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                      Jetson Thor (192.168.10.156)                           │
│                    JetPack 7.x | CUDA 13.0 | 122.8GB                        │
│  ┌─────────────────────┐  ┌────────────────────┐  ┌─────────────────────┐  │
│  │  Isaac Sim          │  │  Personaplex 7B    │  │  Isaac ROS          │  │
│  │  (headless)         │  │  Speech-to-Speech  │  │  Robot Control      │  │
│  │  Simulation         │  │  :8998 (SSL)       │  │                     │  │
│  └─────────────────────┘  └────────────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Components

### 1. USD Composer (x86 PC)
Scene authoring and USD creation using Kit SDK.
- Location: `~/kit-app-template/`
- Start: `./run_usd_composer.sh`

### 2. Nucleus Enterprise Server (x86 PC)
Central USD file management with collaboration features.
- Location: `~/nucleus-server/`
- Config: `base_stack/nucleus-stack.env`
- **Status**: Requires Omniverse Enterprise subscription with Nucleus entitlement

### 3. USD File Server (Fallback)
Simple HTTP server for USD file access when Nucleus is unavailable.
- Port: 8080
- Access: `http://192.168.10.146:8080/stages/scene.usd`

### 4. Isaac Sim (Jetson Thor)
Headless simulation for robotics applications.
- Connects to Nucleus via `omniverse://192.168.10.146/`

## Quick Start

### Start USD Composer (x86 PC)
```bash
cd ~/kit-app-template
./run_usd_composer.sh
```

### Start File Server (Fallback)
```bash
cd ~/OmniVerse/scripts
./start_usd_server.sh
```

### Start Nucleus Enterprise (when entitlements available)
```bash
cd ~/nucleus-server/base_stack
docker compose --env-file nucleus-stack.env -f nucleus-stack-no-ssl.yml up -d
```

## Directory Structure

```
OmniVerse/
├── README.md
├── scripts/
│   ├── start_usd_server.sh      # HTTP fallback server
│   └── setup_nucleus.sh          # Nucleus setup script
├── stages/                       # USD scene files
├── assets/                       # Reusable USD assets
├── nucleus-config/               # Nucleus Enterprise configuration
│   └── nucleus-stack.env.example
└── docs/
    ├── ARCHITECTURE.md
    ├── NUCLEUS_SETUP.md
    └── ISAAC_SIM_SETUP.md
```

## Nucleus Enterprise Requirements

The Nucleus Enterprise containers require:
1. NGC account with Omniverse Enterprise subscription
2. Nucleus Enterprise entitlement (not included in Essentials)
3. NGC API key with appropriate access

NGC Login:
```bash
docker login nvcr.io --username '$oauthtoken' --password '<NGC_API_KEY>'
```

## Network Configuration

| Service | Host | Port | Protocol |
|---------|------|------|----------|
| Nucleus API | 192.168.10.146 | 3009 | TCP |
| Nucleus Web | 192.168.10.146 | 8080 | HTTP |
| Nucleus LFT | 192.168.10.146 | 3030 | TCP |
| USD HTTP (fallback) | 192.168.10.146 | 8080 | HTTP |
| Personaplex | 192.168.10.156 | 8998 | HTTPS |

## Related Repositories

- [Personaplex](https://github.com/dev-designer-shaik/Personaplex) - NVIDIA Personaplex 7B deployment on Jetson Thor
