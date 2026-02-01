# Omniverse Architecture

## Overview

This setup creates a full NVIDIA Omniverse pipeline connecting an x86 workstation to Jetson Thor for robotics simulation and AI-powered interaction.

## Network Topology

```
Internet
    │
    ▼
┌─────────────────────────────────────────────────────────────────┐
│                     Local Network (192.168.10.x)                │
│                                                                 │
│  ┌─────────────────────────┐    ┌────────────────────────────┐ │
│  │   x86 Workstation       │    │      Jetson Thor           │ │
│  │   192.168.10.146        │◄──►│      192.168.10.156        │ │
│  │                         │    │                            │ │
│  │   • RTX 3070 Ti         │    │   • Thor GPU (20 SMs)      │ │
│  │   • USD Composer        │    │   • 122.8GB Unified RAM    │ │
│  │   • Nucleus Server      │    │   • JetPack 7.x            │ │
│  │   • Docker Desktop      │    │   • CUDA 13.0              │ │
│  └─────────────────────────┘    └────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow

### USD Scene Flow
```
USD Composer (x86)          Nucleus Server              Isaac Sim (Thor)
      │                          │                           │
      │  ──Save USD──►           │                           │
      │                          │  ◄──LiveSync──►           │
      │                          │                           │
      │  ◄──Collaboration──►     │  ──Push Updates──►        │
      │                          │                           │
```

### AI Interaction Flow
```
User Voice Input
      │
      ▼
Personaplex 7B (Thor:8998)
      │
      ▼
Voice Response + Commands
      │
      ├──► Isaac Sim (Robot Control)
      │
      └──► USD Scene Updates
```

## Component Details

### x86 Workstation (192.168.10.146)

| Component | Purpose | Port |
|-----------|---------|------|
| USD Composer | Scene authoring | - |
| Nucleus API | USD sync | 3009 |
| Nucleus Web | Browser UI | 8080 |
| Nucleus LFT | Large file transfer | 3030 |
| Nucleus Auth | Authentication | 3100 |
| Discovery | Service registry | 3333 |

### Jetson Thor (192.168.10.156)

| Component | Purpose | Port |
|-----------|---------|------|
| Personaplex 7B | Speech AI | 8998 (HTTPS) |
| Isaac Sim | Headless simulation | - |
| Isaac ROS | Robot control | - |

## Protocol Stack

```
┌─────────────────────────────────────────┐
│           Application Layer             │
│  USD Composer │ Isaac Sim │ Personaplex │
├─────────────────────────────────────────┤
│         Omniverse Protocol              │
│  omniverse:// │ LiveSync │ Checkpoints  │
├─────────────────────────────────────────┤
│            Transport Layer              │
│     TCP/HTTP │ WebSocket │ HTTPS        │
├─────────────────────────────────────────┤
│            Network Layer                │
│         IPv4 (192.168.10.x)             │
└─────────────────────────────────────────┘
```

## USD File Organization

```
omniverse://192.168.10.146/
├── Projects/
│   └── RobotSim/
│       ├── Stages/
│       │   ├── main.usd          # Main scene
│       │   └── robot_cell.usd    # Sub-scene
│       ├── Assets/
│       │   ├── Robots/
│       │   ├── Environment/
│       │   └── Materials/
│       └── Cache/
└── NVIDIA/                        # Reference content
    └── Assets/
```

## Security Considerations

1. **Nucleus Authentication**: Use SSO/SAML for production
2. **SSL/TLS**: Enable for production deployments
3. **Network Isolation**: Keep Omniverse traffic on local network
4. **API Keys**: Store NGC keys in `.env` files (gitignored)
