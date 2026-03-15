#!/data/data/com.termux/files/usr/bin/bash

# === Termux Boot Script ===
# This runs automatically when Termux starts (via Termux:Boot or MacroDroid)

# Keep the device awake
termux-wake-lock

# Start SSH server
sshd

# Start Nginx + Cloudflare Tunnel in a SINGLE proot session
# (Both must share the same session or Nginx dies when proot closes)
proot-distro login ubuntu -- bash -c "service nginx start && cloudflared tunnel run mysite"
