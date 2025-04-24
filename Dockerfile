FROM debian:stable-slim

ARG CF_TUNNEL_ID
ARG CF_TUNNEL_ACCOUNT_TAG
ARG CF_TUNNEL_SECRET
ARG CF_CLOUDFLARED_VERSION="2025.4.0"

ENV CF_TUNNEL_ID $CF_TUNNEL_ID
ENV CF_TUNNEL_ACCOUNT_TAG $CF_TUNNEL_ACCOUNT_TAG
ENV CF_TUNNEL_SECRET $CF_TUNNEL_SECRET

COPY config.yml /etc/cloudflared/config.yml
RUN \
  echo "**** apt update ****" && \
  apt update && \
  echo "**** install cloudflared ****" && \
  apt install -y curl && \
  cd /tmp/ && \
  curl --location -o cloudflared-linux-amd64.deb 'https://github.com/cloudflare/cloudflared/releases/download/${CF_CLOUDFLARED_VERSION}/cloudflared-linux-amd64.deb' && \
  dpkg -i cloudflared-linux-amd64.deb && \
  echo "**** install jq ***" && \
  apt install -y jq && \
  echo "**** create credentials.json ****" && \
  jq -cn --arg AccountTag ${CF_TUNNEL_ACCOUNT_TAG} --arg TunnelSecret ${CF_TUNNEL_SECRET} --arg TunnelID ${CF_TUNNEL_ID} '$ARGS.named' > /etc/cloudflared/credentials.json && \
  echo "**** update config.yml ****" && \
  sed -i "/^tunnel:/c\tunnel: ${CF_TUNNEL_ID}" /etc/cloudflared/config.yml && \
  echo "**** cleanup ****" && \
  apt clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# command / entrypoint of container
ENTRYPOINT ["cloudflared", "--no-autoupdate"]
#CMD ["version"]
CMD ["tunnel", "--config", "/etc/cloudflared/config.yml", "run"]

