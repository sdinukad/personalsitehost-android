# 🖥️ Personal Site — Hosted on a Tablet

An ultra-minimalist personal site (~2.5KB) self-hosted on a **Huawei MediaPad M6** using **Termux + Nginx + Cloudflare Tunnel**.

> A terminal-themed single-page site served from a tablet on my desk.

## ✨ Features

- **Terminal aesthetic** — Styled like a `neofetch` output in a real terminal window
- **Self-hosted** — Runs on a MediaPad M6 via Termux + Ubuntu (proot)
- **Cloudflare Tunnel** — Secure public access with no port forwarding required
- **Tiny footprint** — Single HTML file, under 5KB, with embedded CSS
- **Live uptime display** — Shows real server uptime pulled from the host
- **Rate-limited & hardened** — Nginx config with security headers, gzip, and bot blocking

## 📂 Project Structure

```
├── index.html                 # The site (terminal-themed, single page)
├── v1.html                    # Earlier design iteration
├── nginx_site.conf            # Nginx server config (port 8080, gzip, security headers)
├── cloudflared_config.yml     # Cloudflare Tunnel config template
├── launch-site.sh             # Manual launch script (Termux)
├── startup.sh                 # Auto-start script for Termux:Boot
├── deployment_guide.md        # Full setup walkthrough
├── maintenance_cheat_sheet.md # Quick-reference commands
└── walkthrough.md             # Project summary
```

## 🚀 Getting Started

1. **Clone** this repo onto your tablet (or transfer files via SCP).
2. Follow the step-by-step **[Deployment Guide](deployment_guide.md)** to set up Nginx and Cloudflare.
3. Use the **[Maintenance Cheat Sheet](maintenance_cheat_sheet.md)** for day-to-day management.

## 🛠️ Tech Stack

| Component | Role |
|---|---|
| **Nginx** | Local web server (port 8080) |
| **Cloudflare Tunnel** | Secure public access (no port forwarding) |
| **Termux + proot** | Linux environment on Android |
| **HTML/CSS** | Single-file site with embedded styles |

## 📝 License

This project is open source under the [MIT License](LICENSE).
