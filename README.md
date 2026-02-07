# OmniVerse – Custom Thor + QNAP USD Pipeline

This repo documents our customized Omniverse stack that connects an x86 authoring workstation, Jetson Thor (headless USD services + local 3D generation), and QNAP storage. It focuses on **our local workflow** rather than general Omniverse setup.

## What’s Customized

- **Thor USD Brain Service** (headless Kit app) is the SSOT for versioned USD scenes under `/srv/omniverse/scenes`.
- **Local 3D generation on Thor** (TRELLIS / TripoSR) produces GLB/USD assets used in scenes.
- **QNAP-mounted storage** feeds models into the pipeline (via mount + bridge tooling in the qnap-bridge repo).
- **Lightweight HTTP USD server** as a fallback when Nucleus isn’t in use.

## High-Level Topology

```
QNAP NAS (SMB/NFS) ──► Thor (/mnt/qnap_share) ──► /srv/omniverse/scenes (SSOT)
                                      │
                                      ├─ Thor USD Brain Service (Kit) :8011
                                      ├─ Local Model Gen (TRELLIS/TripoSR)
                                      └─ USD outputs (.usd/.usda)

x86 Workstation (Authoring)
  ├─ USD Composer (Kit)
  └─ Optional Nucleus Server (enterprise)
```

## Quick Start (Our Environment)

### 1) Start Thor USD Brain Service (Jetson Thor)
```bash
/home/dsi-thor/kit-app-template/_build/linux-aarch64/release/kit/kit \
  /home/dsi-thor/kit-app-template/source/apps/thor.usd_brain.kit
```

### 2) Start USD HTTP fallback server (x86)
```bash
cd ~/OmniVerse/scripts
./start_usd_server.sh
```

### 3) Optional: Start Nucleus Enterprise (x86)
```bash
cd ~/nucleus-server/base_stack
docker compose --env-file nucleus-stack.env -f nucleus-stack-no-ssl.yml up -d
```

## Key Paths

- **Thor scenes SSOT**: `/srv/omniverse/scenes`
- **QNAP mount (Thor)**: `/mnt/qnap_share`
- **Local USD stages (x86)**: `~/OmniVerse/stages`
- **Reusable assets (x86)**: `~/OmniVerse/assets`

## Ports (Typical)

| Service | Host | Port | Notes |
|--------|------|------|------|
| Thor USD Brain Service | Thor | 8011 | API docs at `/docs` |
| Nucleus API | x86 | 3009 | Optional enterprise setup |
| Nucleus Web | x86 | 8080 | Optional enterprise setup |
| USD HTTP fallback | x86 | 8080 | If Nucleus is not used |

## Repo Structure

```
OmniVerse/
├── README.md
├── scripts/
│   ├── start_usd_server.sh
│   └── setup_nucleus.sh
├── stages/                 # USD scenes for local authoring
├── assets/                 # Reusable USD assets
├── nucleus-config/         # Nucleus Enterprise configuration
└── docs/                   # Architecture + setup notes
```

## Notes

- This repo is the **custom integration layer**. Operational tools for QNAP ingestion and USD versioning live in the **qnap-bridge** repo.
- Thor runs headless Kit services and local model generation; x86 is used for authoring and optional Nucleus.
