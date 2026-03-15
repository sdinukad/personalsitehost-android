#!/data/data/com.termux/files/usr/bin/bash

# === Manual Website Launcher ===
# Run this from Termux with: launch
# Or directly with: ~/launch-site.sh

echo "--- Initializing Website Infrastructure ---"

# 1. Keep Device Awake
echo "[1/4] Securing wake lock..."
termux-wake-lock

# 2. Start SSH
echo "[2/4] Starting SSH server..."
sshd 2>/dev/null
echo "       SSH running on port 8022"

# 3. Start Nginx
echo "[3/4] Starting Nginx..."
proot-distro login ubuntu -- service nginx start

# 4. Start Cloudflare Tunnel
echo "[4/4] Launching Cloudflare Tunnel..."
proot-distro login ubuntu -- cloudflared tunnel run mysite &
TUNNEL_PID=$!

# Give it a few seconds to connect
sleep 5

# Check if tunnel process is still alive
if kill -0 $TUNNEL_PID 2>/dev/null; then
    echo "------------------------------------------"
    echo "SUCCESS! Website is live at https://suvind.qzz.io"
    echo ""
    echo "Tunnel PID: $TUNNEL_PID"
    echo "To stop:    kill $TUNNEL_PID"
    echo "------------------------------------------"
else
    echo "------------------------------------------"
    echo "ERROR: Tunnel failed to start!"
    echo "Check logs: proot-distro login ubuntu -- cat /var/log/cloudflared.log"
    echo "------------------------------------------"
fi
