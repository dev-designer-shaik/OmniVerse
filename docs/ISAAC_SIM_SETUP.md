# Isaac Sim Setup on Jetson Thor

## Overview

Isaac Sim runs in headless mode on Jetson Thor, connecting to Nucleus for USD scene synchronization.

## Prerequisites

- Jetson Thor with JetPack 7.x
- CUDA 13.0
- Docker with NVIDIA runtime
- Network access to Nucleus server (192.168.10.146)

## Installation

### 1. Pull Isaac Sim Container

```bash
docker pull nvcr.io/nvidia/isaac-sim:4.5.0-aarch64
```

### 2. Create Run Script

```bash
#!/bin/bash
# run_isaac_sim.sh

docker run --rm -it \
    --runtime nvidia \
    --gpus all \
    --network host \
    -e DISPLAY=$DISPLAY \
    -e ACCEPT_EULA=Y \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v ~/isaac-sim-data:/root/.local/share/ov/data \
    -v ~/omniverse-cache:/root/.cache/ov \
    nvcr.io/nvidia/isaac-sim:4.5.0-aarch64 \
    ./runheadless.native.sh
```

### 3. Configure Nucleus Connection

In Isaac Sim settings, add Nucleus server:
- Server: omniverse://192.168.10.146
- Port: 3009
- Username: omniverse
- Password: (Nucleus MASTER_PASSWORD)

## Headless Operation

### Start Simulation

```bash
./runheadless.native.sh \
    --/app/livestream/enabled=true \
    --/app/window/width=1920 \
    --/app/window/height=1080
```

### Load USD from Nucleus

```python
import omni.usd
from pxr import Usd

# Connect to Nucleus
stage = omni.usd.get_context().get_stage()
omni.usd.get_context().open_stage("omniverse://192.168.10.146/Projects/RobotSim/main.usd")
```

### HTTP Fallback (when Nucleus unavailable)

```python
# Use HTTP server as fallback
omni.usd.get_context().open_stage("http://192.168.10.146:8080/stages/main.usd")
```

## Isaac ROS Integration

### 1. Install Isaac ROS

```bash
# Clone Isaac ROS workspace
git clone https://github.com/NVIDIA-ISAAC-ROS/isaac_ros_common.git
cd isaac_ros_common
./scripts/run_dev.sh
```

### 2. Bridge Isaac Sim to ROS

In Isaac Sim:
```python
import omni.isaac.core.utils.extensions as extensions_utils
extensions_utils.enable_extension("omni.isaac.ros2_bridge")
```

### 3. Launch ROS Node

```bash
ros2 launch isaac_ros_sim omniverse_launch.py
```

## Performance Optimization

### Jetson Thor Specific Settings

```bash
# Set max performance mode
sudo nvpmodel -m 0
sudo jetson_clocks

# Increase GPU memory allocation
# Thor has unified memory, allocate more to GPU
sudo sysctl -w vm.swappiness=10
```

### Isaac Sim Settings

In `~/.local/share/ov/pkg/isaac_sim-4.5.0/apps/omni.isaac.sim.base.kit`:

```toml
[settings]
# Optimize for Jetson
renderer.resolution.width = 1280
renderer.resolution.height = 720
renderer.raytracing.enabled = false
physics.substeps = 1
```

## Troubleshooting

### Cannot Connect to Nucleus

1. Check network: `ping 192.168.10.146`
2. Check Nucleus ports: `nc -zv 192.168.10.146 3009`
3. Verify credentials

### GPU Out of Memory

Thor has 122.8GB unified memory, but:
1. Check current usage: `tegrastats`
2. Reduce scene complexity
3. Lower render resolution

### Slow Scene Loading

1. Use HTTP server for static assets
2. Enable caching in Isaac Sim
3. Pre-convert USD to Crate format (.usdc)
