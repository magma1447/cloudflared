# cloudflared

A customized Cloudflare Tunnel container that supports environment variables for tunnel credentials.

## Overview

This container helps you run cloudflared tunnels while keeping sensitive credentials out of your codebase. It generates the required `credentials.json` file at runtime using environment variables.

## Usage

### Required configuration

Create a `config.yml` file with your tunnel configuration. It must include these lines (the values will be automatically updated at runtime):

```yaml
# These lines are required but will be automatically configured by the container
tunnel:
credentials-file: /etc/cloudflared/credentials.json

# Add your ingress rules below
ingress:
  - hostname: "yourdomain.com"
    service: "http://yourservice:port"
  - service: http_status:404
```

### Docker Compose example

```yaml
services:
  cloudflared:
    image: ghcr.io/magma1447/cloudflared:main
    environment:
      - CF_TUNNEL_ID=${CF_TUNNEL_ID}
      - CF_TUNNEL_ACCOUNT_TAG=${CF_TUNNEL_ACCOUNT_TAG}
      - CF_TUNNEL_SECRET=${CF_TUNNEL_SECRET}
    volumes:
      - ./config.yml:/etc/cloudflared/config.yml
    restart: unless-stopped
    depends_on:
      - your-service

  your-service:
    image: nginx:alpine
    # Other service configuration...
```

### Required environment variables

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

### How it works

The container:
1. Creates a runtime configuration based on your mounted config.yml
2. Automatically updates the tunnel ID and credentials file path in the config
3. Generates the credentials.json file at runtime using your environment variables
4. Runs cloudflared with the proper configuration

### Security recommendations

Always pass sensitive values as environment variables or through a secure CI/CD system. Never commit these values to your repository.

