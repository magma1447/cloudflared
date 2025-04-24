#!/bin/sh
# Create credentials.json at runtime
jq -cn --arg AccountTag "${CF_TUNNEL_ACCOUNT_TAG}" \
       --arg TunnelSecret "${CF_TUNNEL_SECRET}" \
       --arg TunnelID "${CF_TUNNEL_ID}" \
       '$ARGS.named' > /etc/cloudflared/credentials.json

# Always create a runtime config based on the available config
cp /etc/cloudflared/config.yml /etc/cloudflared/runtime-config.yml

# Update the tunnel ID in our runtime copy
sed -i "/^tunnel:/c\tunnel: ${CF_TUNNEL_ID}" /etc/cloudflared/runtime-config.yml
# Ensure the credentials file path is correct
sed -i "/^credentials-file:/c\credentials-file: /etc/cloudflared/credentials.json" /etc/cloudflared/runtime-config.yml

# Check if we're using the example configuration and warn the user
if grep -q "hostname: \"example.com\"" /etc/cloudflared/runtime-config.yml; then
  echo "WARNING: You appear to be using the example configuration with example.com."
  echo "WARNING: You should mount your own config.yml with proper ingress rules!"
fi

# Execute cloudflared with the provided arguments
exec cloudflared --no-autoupdate "$@"

