# OmniVerse – Local Thor + QNAP USD Pipeline (Client/Host Architecture)

This repo documents our **custom Omniverse stack** that connects:
- **Client workstation (x86)** for authoring and local testing
- **Host services (Jetson Thor)** for headless USD SSOT + conversions
- **QNAP storage** as the shared ingest surface

The focus is our **local workflow**, not generic Omniverse setup.

---

## Client/Host Architecture (Who Runs What)

```
Client (x86 authoring)                     Host (Jetson Thor)
┌───────────────────────────┐             ┌───────────────────────────────────┐
│ USD Composer / Kit        │             │ Thor USD Brain (headless Kit)     │
│ Local stages + assets     │             │ SSOT scenes: /srv/omniverse/scenes │
│ Optional Nucleus server   │             │ QNAP mount: /mnt/qnap_share        │
│ Local USD HTTP fallback   │             │ Model conversion (Kit converter)   │
└──────────────┬────────────┘             └──────────────┬────────────────────┘
               │                                         │
               │ QNAP Bridge (watch + USD versioning)    │
               └──────────────►  /mnt/qnap_share  ◄──────┘
                                (shared NAS mount)
```

Key idea: **Thor is the SSOT** for versioned USD scenes. The x86 client is for authoring, review, and local testing.

---

## Local Workflows (with Local Models + Testing)

### 1) Local model → QNAP → Thor SSOT
1. Drop a model into the QNAP share (mounted locally).
2. **qnap-bridge watchdog** detects it and pushes to Thor.
3. Thor versions the scene under `/srv/omniverse/scenes/<scene_id>`.
4. A `*.usd_index.json` is written next to the model on QNAP with scene metadata.

### 2) Local authoring on x86
- Use `stages/` for local USD work.
- Use `assets/` for reusable USD assets.
- Pull versioned USD from Thor when needed (Nucleus optional).

### 3) Local testing (quick sanity)
- Start Thor USD Brain on the host.
- Use USD Composer locally to open a stage and reference Thor’s SSOT scenes.
- If Nucleus is not running, use the HTTP fallback server.

---

## Integration with QNAP Bridge (Required)

All ingestion, USD versioning, and (optional) Speckle upload live in:

**`qnap-bridge` repo**
- Watches the QNAP mount
- Runs USD conversion + SSOT versioning on Thor
- Writes `*.usd_index.json`
- (Optional) pushes to Speckle + Google Chat notification

This OmniVerse repo documents **how the client and host interact** with that bridge.

---

## Quick Start (Our Environment)

### 1) Start Thor USD Brain (Jetson Thor)
```bash
/home/dsi-thor/kit-app-template/_build/linux-aarch64/release/kit/kit \
  /home/dsi-thor/kit-app-template/source/apps/thor.usd_brain.kit
```

### 2) Start USD HTTP fallback (x86)
```bash
cd ~/OmniVerse/scripts
./start_usd_server.sh
```

### 3) Optional: Nucleus Enterprise (x86)
```bash
cd ~/nucleus-server/base_stack
docker compose --env-file nucleus-stack.env -f nucleus-stack-no-ssl.yml up -d
```

---

## Key Paths

- **Thor SSOT**: `/srv/omniverse/scenes`
- **QNAP mount (Thor)**: `/mnt/qnap_share`
- **Client stages (x86)**: `~/OmniVerse/stages`
- **Client assets (x86)**: `~/OmniVerse/assets`

---

## Ports (Typical)

| Service | Host | Port | Notes |
|--------|------|------|------|
| Thor USD Brain Service | Thor | 8011 | API docs at `/docs` |
| Nucleus API | x86 | 3009 | Optional enterprise setup |
| Nucleus Web | x86 | 8080 | Optional enterprise setup |
| USD HTTP fallback | x86 | 8080 | If Nucleus is not used |

---

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

---

## Notes

- This repo is the **client/host architecture reference**.
- The operational ingestion pipeline lives in **qnap-bridge**.
- Thor remains the **single source of truth** for USD scene versions.
