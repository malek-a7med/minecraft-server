# Minecraft Paper 1.21.1 Server

Optimized Minecraft Paper server for Railway Free Plan (1 GB RAM).

## Stack
- **Server**: Paper 1.21.1 (build 130)
- **Java**: 21 (eclipse-temurin:21-jre-alpine)
- **Deployment**: Railway (Docker)

## Plugins
| Plugin | Purpose |
|---|---|
| **Chunky** | Pre-generates world chunks to prevent exploration lag |
| **AuthMe Reloaded** | Login system for offline-mode (cracked) servers |
| **EssentialsX** | Core commands: /home, /spawn, /tpa, /warp |

## Performance Config
- `view-distance=4` / `simulation-distance=4`
- G1GC with Aikar's flags (tuned for 1 GB)
- `optimize-explosions=true`
- `redstone-implementation=ALTERNATE_CURRENT`
- Entity activation ranges minimized
- Armor Stand ticking disabled

## Running Locally
```bash
chmod +x start.sh
./start.sh
```
The script auto-downloads Paper and all plugins on first run.

## Railway Deployment
- Dockerfile is the entrypoint
- World data should live in a Railway Volume mounted at `/minecraft`
- Port: **25565**

## User preferences
- Arabic language preferred for comments
