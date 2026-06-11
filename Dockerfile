FROM debian:stable-slim

ARG CF_TUNNEL_ID
ARG CF_TUNNEL_ACCOUNT_TAG
ARG CF_TUNNEL_SECRET
# Leave empty to resolve the latest release at build time (see RUN block below).
# CI passes an explicit version for reproducible, version-tagged builds.
ARG CF_CLOUDFLARED_VERSION=""

ENV CF_TUNNEL_ID $CF_TUNNEL_ID
ENV CF_TUNNEL_ACCOUNT_TAG $CF_TUNNEL_ACCOUNT_TAG
ENV CF_TUNNEL_SECRET $CF_TUNNEL_SECRET

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
RUN mkdir -p /etc/cloudflared
COPY config.yml /etc/cloudflared/config.yml
RUN \
  echo "**** apt update ****" && \
  apt update && \
  echo "**** install cloudflared ****" && \
  apt install -y curl jq && \
  cd /tmp/ && \
  CF_VERSION="${CF_CLOUDFLARED_VERSION}" && \
  if [ -z "$CF_VERSION" ]; then \
    echo "**** no version pinned, resolving latest release ****" && \
    CF_VERSION=$(curl -sL https://api.github.com/repos/cloudflare/cloudflared/releases/latest | jq -r '.tag_name'); \
  fi && \
  echo "**** installing cloudflared $CF_VERSION ****" && \
  curl --location --fail -o cloudflared-linux-amd64.deb "https://github.com/cloudflare/cloudflared/releases/download/${CF_VERSION}/cloudflared-linux-amd64.deb" && \
  dpkg -i cloudflared-linux-amd64.deb && \
  echo "**** cleanup ****" && \
  apt clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

ENTRYPOINT ["/entrypoint.sh"]
CMD ["tunnel", "--config", "/etc/cloudflared/runtime-config.yml", "run"]

