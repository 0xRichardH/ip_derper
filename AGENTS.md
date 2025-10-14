# Agent Guidelines for ip_derper

## Project Overview
Dockerized Tailscale DERP server with modified certificate validation. Built from Tailscale submodule with patches applied during CI/CD.

## Build Commands
- **Docker build**: `docker build -t ip_derper .`
- **Local test**: Requires initialized tailscale submodule: `git submodule update --init --recursive`
- **No native Go build** - build happens inside Docker container

## Code Modification Pattern
The project modifies upstream Tailscale code during CI:
- Patch location: `tailscale/cmd/derper/cert.go`
- Modification: Removes ServerName validation (see `.github/workflows/main.yml:24`)

## Shell Script Style
- Use `#!/bin/sh` (POSIX shell, not bash)
- Variables: UPPER_SNAKE_CASE
- No comments unless documenting complex logic

## Docker/Environment
- Multi-stage builds (builder + alpine)
- ENV vars: `DERP_*` prefix for configuration
- Certificate generation via OpenSSL with SAN support

## Key Files
- `Dockerfile`: Multi-stage Go build + Alpine runtime
- `build_cert.sh`: Self-signed cert generation with configurable SANs
- `.github/workflows/main.yml`: Builds multi-arch images (amd64/arm64)
