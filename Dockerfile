# syntax=docker/dockerfile:1.7
# Pioneer Agent — container image.
#
# Two ways to bring in the zeroclaw binary. Pick via ZEROCLAW_SOURCE:
#
#   A. Release (default) — fetch from GitHub Releases, works for both
#      public and private pioneer-platform repos:
#        export GH_TOKEN="$(gh auth token)"
#        DOCKER_BUILDKIT=1 docker build \
#          --secret id=gh_token,env=GH_TOKEN \
#          --build-arg ZEROCLAW_VERSION=v0.1.0 \
#          -t my-agent .
#      (GH_TOKEN is read via BuildKit secret — never baked into layers.)
#
#   B. Local — pre-fetch the binary to ./zeroclaw and skip the network:
#        gh release download v0.1.0 \
#          --repo coinmastersguild/pioneer-platform \
#          --pattern zeroclaw-linux-amd64 \
#          -O ./zeroclaw
#        docker build --build-arg ZEROCLAW_SOURCE=local-binary -t my-agent .
#      (./zeroclaw is .gitignored. Faster on Apple Silicon when building
#       linux/amd64 images under QEMU.)

ARG ZEROCLAW_SOURCE=release-binary
ARG ZEROCLAW_VERSION=v0.1.0
ARG ZEROCLAW_REPO=coinmastersguild/pioneer-platform
ARG ZEROCLAW_ASSET=zeroclaw-linux-amd64

# ─── Source A: fetch binary from GitHub Releases ──────────────────────────
FROM debian:bookworm-slim AS release-binary
ARG ZEROCLAW_VERSION
ARG ZEROCLAW_REPO
ARG ZEROCLAW_ASSET
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    ca-certificates curl jq && rm -rf /var/lib/apt/lists/*
RUN --mount=type=secret,id=gh_token,required=false \
    TOKEN=""; \
    [ -f /run/secrets/gh_token ] && TOKEN=$(cat /run/secrets/gh_token); \
    ASSET_ID=$(curl -sfL \
      ${TOKEN:+-H "Authorization: Bearer $TOKEN"} \
      -H "Accept: application/vnd.github+json" \
      "https://api.github.com/repos/${ZEROCLAW_REPO}/releases/tags/${ZEROCLAW_VERSION}" \
      | jq -r --arg name "$ZEROCLAW_ASSET" \
          '.assets[] | select(.name==$name) | .id' | head -n1); \
    if [ -z "$ASSET_ID" ] || [ "$ASSET_ID" = "null" ]; then \
      echo "ERROR: asset '$ZEROCLAW_ASSET' not found on $ZEROCLAW_REPO@$ZEROCLAW_VERSION" >&2; \
      echo "Hint: for private repos, pass --secret id=gh_token,env=GH_TOKEN" >&2; \
      exit 1; \
    fi; \
    curl -fsSL \
      ${TOKEN:+-H "Authorization: Bearer $TOKEN"} \
      -H "Accept: application/octet-stream" \
      "https://api.github.com/repos/${ZEROCLAW_REPO}/releases/assets/${ASSET_ID}" \
      -o /zeroclaw && \
    chmod +x /zeroclaw && \
    file /zeroclaw

# ─── Source B: use a pre-fetched binary from the build context ────────────
FROM debian:bookworm-slim AS local-binary
# Requires ./zeroclaw in the build context. Run `gh release download` first.
COPY zeroclaw /zeroclaw
RUN chmod +x /zeroclaw

# ─── Final runtime image ──────────────────────────────────────────────────
FROM debian:bookworm-slim AS runtime
ARG ZEROCLAW_SOURCE

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    ca-certificates curl git jq tini libssl3 && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd -g 1001 agent && useradd -u 1001 -g agent -m agent

# Pull the binary from whichever source stage was selected.
COPY --from=${ZEROCLAW_SOURCE} /zeroclaw /usr/local/bin/zeroclaw

RUN mkdir -p /app/workspace /app/config /app/tools.d && chown -R agent:agent /app

WORKDIR /app

COPY config.toml    /app/config/config.toml
COPY tools.d/       /app/tools.d/
COPY workspace/     /app/workspace/
COPY entrypoint.sh  /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh && chown -R agent:agent /app

RUN mkdir -p /home/agent/.zeroclaw && \
    ln -s /app/workspace /home/agent/.zeroclaw/workspace && \
    chown -R agent:agent /home/agent

USER agent
ENV HOME=/home/agent

EXPOSE 18789

HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD curl -sf http://localhost:18789/health || exit 1

ENTRYPOINT ["/usr/bin/tini","--"]
CMD ["/app/entrypoint.sh"]
