# Deploy to Vultr

Static Astro site → Ubuntu VPS + Nginx. Recommended region: **Sydney** (closest to NZ).

## Step 1 — Create Vultr VPS

1. Log in at [vultr.com](https://www.vultr.com)
2. **Deploy** → **Cloud Compute** → **Regular**
3. **Location**: Sydney (`syd`) or Auckland if available
4. **OS**: Ubuntu 24.04 LTS
5. **Plan**: $6/mo (1 vCPU / 1 GB) is enough for this static site
6. **SSH Keys**: add your public key (recommended) or use password
7. Deploy and note the **Server IP**

## Step 2 — One-time server setup

From your PC (replace `YOUR_IP`):

```powershell
scp -P 22 deploy\scripts\setup-vultr.sh root@YOUR_IP:/root/
ssh root@YOUR_IP "bash /root/setup-vultr.sh we-events.co.nz joy@we-events.co.nz"
```

Open `http://YOUR_IP/` — you should see a placeholder page.

## Step 3 — DNS (we-events.co.nz)

At your domain registrar (or Vultr DNS):

| Type | Name | Value |
|------|------|-------|
| A | `@` | `YOUR_VULTR_IP` |
| A | `www` | `YOUR_VULTR_IP` |

Wait 5–30 minutes for propagation.

## Step 4 — Configure deploy on your PC

```powershell
cd C:\Users\Peter\Projects\weevent-website
copy deploy\config.env.example deploy\config.env
# Edit deploy\config.env — set VULTR_HOST=your.ip.here
```

## Step 5 — Publish site

```powershell
.\deploy\scripts\deploy.ps1
```

This builds `dist/`, uploads to `/var/www/weevent`, and reloads nginx.

## Step 6 — HTTPS (after DNS works)

```powershell
ssh root@YOUR_IP "certbot --nginx -d we-events.co.nz -d www.we-events.co.nz --email joy@we-events.co.nz --agree-tos --no-eff-email --redirect"
```

Site will be live at **https://www.we-events.co.nz/en/**

## Update site later

After content changes, run again:

```powershell
.\deploy\scripts\deploy.ps1
```

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `Permission denied (publickey)` | Add SSH key in Vultr panel or use `ssh root@IP` with password first |
| 404 on `/en/about/` | Ensure `try_files` nginx config is installed (re-run setup script) |
| Images missing | Re-run deploy — gallery lives in `public/images/gallery/` |
