#!/bin/sh
# ─── Pioneer Agent Entrypoint ──────────────────────────────────────────────
# Merges git-tracked tools.d/*.toml fragments into the runtime config, then
# launches zeroclaw.
#
# Credentials are NOT loaded here. Secrets for tool invocations are fetched
# on-demand from the Pioneer Desktop vault (via the gateway) or supplied by
# peers in the swarm. This agent carries no admin tokens.
# ───────────────────────────────────────────────────────────────────────────
set -e

# Resolve writable zeroclaw home (prefer a persistent volume if mounted)
ZEROCLAW_HOME="${ZEROCLAW_HOME:-/home/agent/.zeroclaw}"
if [ -d /app/data/sessions ] && [ -w /app/data/sessions ]; then
  ZEROCLAW_HOME="/app/data/sessions/.zeroclaw"
  export HOME="/app/data/sessions"
fi
mkdir -p "$ZEROCLAW_HOME/workspace"

# Locate the committed config (ConfigMap or baked-in)
CONFIG_SRC=""
[ -f /app/config/config.toml ] && CONFIG_SRC=/app/config/config.toml
[ -z "$CONFIG_SRC" ] && CONFIG_SRC=/app/config.toml
[ -z "$CONFIG_SRC" ] && { echo "[entrypoint] no config.toml found"; exit 1; }

CONFIG="$ZEROCLAW_HOME/config.toml"
cp "$CONFIG_SRC" "$CONFIG"

# ── Merge local tool fragments ────────────────────────────────────────────
TOOLS_DIR="${TOOLS_DIR:-/app/tools.d}"
echo "[registry] merging local tool fragments from $TOOLS_DIR"

for f in "$TOOLS_DIR"/*.toml; do
  [ -f "$f" ] || continue
  case "$(basename "$f")" in registry.toml) continue ;; esac
  {
    echo ""
    echo "# --- $(basename "$f") ---"
    cat "$f"
  } >> "$CONFIG"
  echo "[registry]   + $(basename "$f")"
done

TOTAL=$(grep -c '^\[\[http_tools\]\]' "$CONFIG" 2>/dev/null || echo 0)
echo "[registry] ready — $TOTAL tools registered"

# ── Launch zeroclaw ───────────────────────────────────────────────────────
exec zeroclaw run --config "$CONFIG" "$@"
