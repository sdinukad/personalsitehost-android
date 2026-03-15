# Android Device Maintenance Cheat Sheet

Quick commands for managing, starting, and troubleshooting your personal site hosted at **https://suvind.qzz.io**.

---

## 1. SSH Into Your Android Device
From your laptop, connect to the device over your local network:
```bash
ssh -p 8022 192.168.8.158
```

---

## 2. Starting the Site (From Termux)

### Quick Launch (Recommended)
Just type this in the Termux shell (`~ $`). Do **NOT** enter Ubuntu first.
```bash
launch
```
This runs `~/launch-site.sh` which starts Nginx + Cloudflare Tunnel in a single Ubuntu session.

### What `launch` Does Behind the Scenes
1. `termux-wake-lock` — Prevents the device from sleeping
2. `sshd` — Starts the SSH server on port 8022
3. `proot-distro login ubuntu -- bash -c "service nginx start && cloudflared tunnel run mysite"` — Starts Nginx and the tunnel together in one session

### On Reboot (Automatic)
If Termux:Boot or MacroDroid is configured, `~/.termux/boot/start-server.sh` runs automatically when the device powers on.

---

## 3. Stopping the Site (From Termux)

**Important:** Do NOT run these inside Ubuntu. Run them from the Termux `~ $` prompt.

```bash
# Kill the background tunnel + nginx session
kill %1

# Verify nothing is running
proot-distro login ubuntu -- service nginx status
```

---

## 4. Updating Site Content

### Option A: Edit Directly on the Device (Inside Ubuntu)
```bash
proot-distro login ubuntu
cd /var/www/site/
nano index.html
```
Press **Ctrl+O** → **Enter** to save, **Ctrl+X** to exit.

### Option B: Push Files from Your Laptop
```bash
# From your laptop terminal (NOT inside SSH)
scp -P 8022 index.html user@192.168.8.158:~/

# Then inside SSH, copy to the web folder
proot-distro login ubuntu -- cp /data/data/com.termux/files/home/index.html /var/www/site/index.html
```

*Note: Cloudflare caches your site. Use **Ctrl+F5** in the browser to force reload after changes.*

---

## 5. Nginx Commands (Inside Ubuntu)
```bash
# Check status
service nginx status

# Validate config (ALWAYS do this before restarting!)
nginx -t

# Restart Nginx
service nginx restart

# Reload config without dropping connections
nginx -s reload
```

---

## 6. View Logs & Debug (Inside Ubuntu)
```bash
# Live visitor log
tail -f /var/log/nginx/access.log

# Nginx error log
tail -f /var/log/nginx/error.log

# Cloudflare tunnel log
cat /var/log/cloudflared.log

# Check tunnel info
cloudflared tunnel info mysite
```

---

## 7. Common Issues

| Problem | Fix |
|---|---|
| Site down after reboot | Open Termux and type `launch` |
| `nginx is not running` | Nginx crashed. Run `launch` again from Termux |
| `bind() to 0.0.0.0:80 failed` | Something is trying to use port 80. Make sure only port 8080 is used in `/etc/nginx/sites-enabled/personal-site` |
| `sched_setaffinity() failed` | Normal on Android/Proot. Already fixed in nginx.conf (`worker_processes 1`, no `worker_cpu_affinity`) |
| `Bad Gateway` on Cloudflare | Nginx isn't running. Start it with `launch` |
| Can't SSH after reboot | Open Termux on the device and type `sshd` |

---

## 8. Key File Locations

| File | Location |
|---|---|
| Website files | `/var/www/site/` (inside Ubuntu) |
| Nginx site config | `/etc/nginx/sites-available/personal-site` (inside Ubuntu) |
| Nginx main config | `/etc/nginx/nginx.conf` (inside Ubuntu) |
| Cloudflare tunnel config | `~/.cloudflared/config.yml` (inside Ubuntu) |
| Cloudflare tunnel logs | `/var/log/cloudflared.log` (inside Ubuntu) |
| Boot script | `~/.termux/boot/start-server.sh` (in Termux) |
| Manual launch script | `~/launch-site.sh` (in Termux) |
