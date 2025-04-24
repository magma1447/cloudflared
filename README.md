# cloudflared

A customized Cloudflare Tunnel container that supports environment variables for tunnel credentials.

## Overview

This container helps you run cloudflared tunnels while keeping sensitive credentials out of your codebase. It generates the required `credentials.json` file at build time using environment variables.

## Usage

### Required configuration

Your `config.yml` file should include these minimal required lines:

```yaml
tunnel:
credentials-file: /etc/cloudflared/credentials.json

ingress:
  # Your ingress rules here
  - hostname: "yourdomain.com"
    service: "http://yourservice:port"
  - service: http_status:404
```

### Docker Compose example

```yaml
services:
  cloudflared:
    image: ghcr.io/yourusername/cloudflared:latest
    build:
      context: .
      args:
        CF_TUNNEL_ID: "${CF_TUNNEL_ID}"
        CF_TUNNEL_ACCOUNT_TAG: "${CF_TUNNEL_ACCOUNT_TAG}"
        CF_TUNNEL_SECRET: "${CF_TUNNEL_SECRET}"
    volumes:
      - ./config.yml:/etc/cloudflared/config.yml
    restart: unless-stopped
    depends_on:
      - your-service

  your-service:
    image: nginx:alpine
    # Other service configuration...
```

### Required build arguments

- `CF_TUNNEL_ID`: Your Cloudflare Tunnel ID
- `CF_TUNNEL_ACCOUNT_TAG`: Your Cloudflare Account Tag
- `CF_TUNNEL_SECRET`: The tunnel secret (keep this secure!)

### Environment variables in .env file

Create a `.env` file (and add it to `.gitignore`):

```
CF_TUNNEL_ID=your-tunnel-id
CF_TUNNEL_ACCOUNT_TAG=your-account-tag
CF_TUNNEL_SECRET=your-tunnel-secret
```

### Security recommendations

Always pass these values as environment variables or through a secure CI/CD system. Never commit these values to your repository.

