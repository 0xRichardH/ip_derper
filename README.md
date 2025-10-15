# ip_derper

Dockerized Tailscale DERP (Designated Encrypted Relay for Packets) server with modified certificate validation to support IP addresses.

## Features

- **IP Address Support**: Automatically generates certificates with proper IP SANs for IP-based hostnames
- **Modified Certificate Validation**: Removes ServerName validation from upstream Tailscale DERP
- **Multi-arch Support**: Built for `linux/amd64` and `linux/arm64`
- **Self-signed Certificates**: Automatic certificate generation with OpenSSL

## Quick Start

### Docker Run

```bash
docker run -d \
  -p 12345:12345 \
  -p 3478:3478/udp \
  -v /var/run/tailscale/tailscaled.sock:/var/run/tailscale/tailscaled.sock \
  -e DERP_ADDR=:12345 \
  -e DERP_HOST=your-ip-or-hostname \
  -e DERP_CERTS=/app/certs \
  -e DERP_VERIFY_CLIENTS=true \
  ghcr.io/0xrichardh/ip_derper:latest
```

### Docker Compose

```yaml
services:
  derper:
    container_name: derper
    image: ghcr.io/0xrichardh/ip_derper:latest
    restart: unless-stopped
    ports:
      - "12345:12345"
      - "3478:3478/udp"
    volumes:
      - /var/run/tailscale/tailscaled.sock:/var/run/tailscale/tailscaled.sock
    environment:
      - DERP_ADDR=:12345
      - DERP_HOST=your-ip-or-hostname
      - DERP_CERTS=/app/certs
      - DERP_VERIFY_CLIENTS=true
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DERP_HOST` | `127.0.0.1` | Hostname or IP address for the DERP server |
| `DERP_ADDR` | `:443` | HTTPS listen address |
| `DERP_HTTP_PORT` | `80` | HTTP port for ACME challenges |
| `DERP_CERTS` | `/app/certs/` | Certificate directory |
| `DERP_STUN` | `true` | Enable STUN server |
| `DERP_VERIFY_CLIENTS` | `false` | Verify client certificates |

## Building from Source

```bash
# Initialize submodule
git submodule update --init --recursive

# Build Docker image
docker build -t ip_derper .
```

## Testing Certificate Generation

```bash
# Test with IP address
sh build_cert.sh 192.0.2.1 /tmp/certs /tmp/san.conf

# Verify certificate
openssl x509 -in /tmp/certs/192.0.2.1.crt -text -noout | grep -A2 "Subject Alternative Name"
```

## How It Works

1. **Build Time**: The CI/CD pipeline patches `tailscale/cmd/derper/cert.go` to remove ServerName validation
2. **Runtime**: The `build_cert.sh` script detects if `DERP_HOST` is an IP address and generates the appropriate SAN (IP vs DNS)
3. **Certificate**: Self-signed EC certificate with 20-year validity
4. **Auto-updates**: Tailscale submodule syncs weekly (every Monday at 2:00 AM UTC) via GitHub Actions

## Development

See [AGENTS.md](AGENTS.md) for development guidelines.
