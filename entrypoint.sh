#!/usr/bin/env bash
set -euo pipefail

# ── Directory & permission setup ──
mkdir -p /data/.openclaw/identity /data/workspace
chown -R openclaw:openclaw /data
chmod 700 /data/.openclaw

# ── Homebrew persistence ──
# On first run, move the container's Homebrew install into the persistent volume
# so that `brew install` packages survive redeploys.
if [ ! -d /data/.linuxbrew ]; then
  if [ -d /home/linuxbrew/.linuxbrew ] && [ ! -L /home/linuxbrew/.linuxbrew ]; then
    echo "[entrypoint] Moving Homebrew to persistent volume..."
    mv /home/linuxbrew/.linuxbrew /data/.linuxbrew
    chown -R openclaw:openclaw /data/.linuxbrew
  fi
fi

# Ensure the symlink exists so the expected path resolves
if [ -d /data/.linuxbrew ] && [ ! -L /home/linuxbrew/.linuxbrew ]; then
  rm -rf /home/linuxbrew/.linuxbrew
  ln -s /data/.linuxbrew /home/linuxbrew/.linuxbrew
fi

# ── Launch ──
exec gosu openclaw node src/server.js
