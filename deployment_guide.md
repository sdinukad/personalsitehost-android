# Personal Site Deployment Guide (MediaPad M6 + Termux)

This guide takes you through the networking and server setup required to host your site publicly.

---

## 0. Prerequisites (On the Tablet via SSH)

Before beginning the server configuration, you must set up the local Linux environment on your MediaPad M6 using Termux.

### A. Termux & Ubuntu Setup
Run these commands in your active SSH session:
```bash
# Prevent Android from killing Termux in the background
termux-wake-lock

# Update Termux packages
pkg update && pkg upgrade -y

# Install the proot-distro environment manager
pkg install proot-distro -y

# Install Ubuntu
proot-distro install ubuntu

# Log into the new Ubuntu environment
proot-distro login ubuntu
```

### B. Ubuntu Initial Configuration
Once logged into Ubuntu, install the necessary routing and server software:
```bash
# Update Ubuntu packages
apt update && apt upgrade -y

# Install Nginx web server and curl (required for Cloudflare)
apt install nginx curl -y
```

### C. File Transfer
You must move the configuration files to the tablet. Open a **new terminal on your local machine** (not the SSH session):
```bash
# Termux SSH runs on port 8022 by default
# Replace '192.168.8.158' with your tablet's local IP if it changes
scp -P 8022 index.html nginx_site.conf cloudflared_config.yml startup.sh user@192.168.8.158:~/
```
_Note: You will move these to their correct folders in Step 2._

---

## 1. Local Network Setup (Optional: Static IP)

Your router assigns IPs dynamically. If your tablet's IP changes, your **local SSH access** will break and you will need to find the new IP.
1. Log in to your router (usually `192.168.1.1` or `192.168.0.1`).
2. Look for **DHCP Reservation**, **Address Reservation**, or **Static IP**.
3. Bind your tablet's **MAC Address** to a specific IP so it never changes.

*(Note: Thanks to Cloudflare Tunnels, you **do not** need to do any Port Forwarding! You can safely delete any Port Forwarding rules you previously created for port 80/443).*

---

## 2. Server Setup (Inside Ubuntu Proot)

### A. Nginx Configuration
Use the optimized `nginx_site.conf` transferred earlier. The files are in your Termux home directory, which Ubuntu can access at `/data/data/com.termux/files/home/`.
1. Copy the config to the Nginx directory:
   ```bash
   cp /data/data/com.termux/files/home/nginx_site.conf /etc/nginx/sites-available/personal-site
   ```
2. Enable it:
   ```bash
   ln -s /etc/nginx/sites-available/personal-site /etc/nginx/sites-enabled/
   rm /etc/nginx/sites-enabled/default
   nginx -t && service nginx restart
   ```

### B. Site Files
Deploy the minimal `index.html`:
```bash
mkdir -p /var/www/site
cp /data/data/com.termux/files/home/index.html /var/www/site/index.html
chmod -R 755 /var/www/site
```

---

## 3. Public Access & Protection (Cloudflare)

### Cloudflare Tunnel (`cloudflared`)
The tunnel protects your site and manages routing seamlessly.
1. **Install**:
   ```bash
   curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -o cloudflared
   chmod +x cloudflared && mv cloudflared /usr/local/bin/
   ```
2. **Login**: `cloudflared tunnel login`
   *(Note: You can open the provided URL on your laptop/local machine; you do not need to do it on the tablet itself.)*
3. **Create Tunnel**: Run the creation command:
   ```bash
   cloudflared tunnel create mysite
   ```
   **Important:** This command will output a long mix of letters and numbers called a UUID (e.g., `a1b2c3d4-e5f6-7890-abcd-1234567890ab`). **Copy this UUID**, you will need it for the next step.
 
4. **Configure**: Move the config file and edit it to include your specific Tunnel ID.
   ```bash
   # Make the directory
   mkdir -p ~/.cloudflared
   
   # Copy the config file you transferred earlier
   cp /data/data/com.termux/files/home/cloudflared_config.yml ~/.cloudflared/config.yml
   
   # Open the config file in a text editor
   nano ~/.cloudflared/config.yml
   ```
   *Instructions for Nano:*
   - Find the line that says `credentials-file: /root/.cloudflared/TUNNEL-ID.json`.
   - Delete the word `TUNNEL-ID` and paste the UUID you copied in Step 3.
     *(Example: it should look like `/root/.cloudflared/a1b2c3d4-e5f6-7890-abcd-1234567890ab.json`)*
   - Press **Ctrl+O**, then **Enter** to save.
   - Press **Ctrl+X** to exit.
5. **Route DNS**: `cloudflared tunnel route dns mysite suvind.qzz.io`
6. **Run**: `nohup cloudflared tunnel run mysite > /var/log/cloudflared.log 2>&1 &`

---

## 4. Automation (Termux:Boot)
To make your server start when the tablet reboots:
1. Exit Ubuntu (`exit`), returning to standard Termux.
2. Create the boot directory: `mkdir -p ~/.termux/boot/`
3. Move the startup script: `mv ~/startup.sh ~/.termux/boot/start-server.sh`
4. Make it executable: `chmod +x ~/.termux/boot/start-server.sh`
