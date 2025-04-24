#!/bin/sh
# Create credentials.json at runtime
jq -cn --arg AccountTag "${CF_TUNNEL_ACCOUNT_TAG}" \
       --arg TunnelSecret "${CF_TUNNEL_SECRET}" \
       --arg TunnelID "${CF_TUNNEL_ID}" \
       '$ARGS.named' > /etc/cloudflared/credentials.json

# If config.yml exists (mounted by user), update the tunnel ID
if [ -f /etc/cloudflared/config.yml ]; then
  # Update the tunnel ID in the existing config
  sed -i "/^tunnel:/c\tunnel: ${CF_TUNNEL_ID}" /etc/cloudflared/config.yml
else
  # Create a minimal config.yml if none is provided
  echo "tunnel: ${CF_TUNNEL_ID}" > /etc/cloudflared/config.yml
  echo "credentials-file: /etc/cloudflared/credentials.json" >> /etc/cloudflared/config.yml
  echo "" >> /etc/cloudflared/config.yml
  echo "ingress:" >> /etc/cloudflared/config.yml
  echo "  - service: http_status:404" >> /etc/cloudflared/config.yml
  echo "" >> /etc/cloudflared/config.yml
  echo "# Please mount your own config.yml with proper ingress rules!" >> /etc/cloudflared/config.yml
fi

# Execute cloudflared with the provided arguments
exec cloudflared --no-autoupdate "$@"

