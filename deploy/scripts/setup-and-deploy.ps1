# Full Vultr setup + deploy (run from project root in PowerShell)
$ErrorActionPreference = "Stop"
$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ConfigFile = Join-Path $ProjectRoot "deploy\config.env"

if (-not (Test-Path $ConfigFile)) {
    Copy-Item (Join-Path $ProjectRoot "deploy\config.env.example") $ConfigFile
    Write-Host "Created deploy\config.env — please set VULTR_HOST and run again." -ForegroundColor Yellow
    notepad $ConfigFile
    exit 1
}

$config = @{}
Get-Content $ConfigFile | ForEach-Object {
    if ($_ -match '^\s*([^#][^=]+)=(.*)$') { $config[$matches[1].Trim()] = $matches[2].Trim() }
}

$ip = $config["VULTR_HOST"]
$user = $config["SSH_USER"]
$port = if ($config["SSH_PORT"]) { $config["SSH_PORT"] } else { "22" }
$domain = $config["DOMAIN"]
$email = $config["SSL_EMAIL"]

Write-Host "Testing SSH to ${user}@${ip} ..." -ForegroundColor Cyan
ssh -o ConnectTimeout=15 -p $port "${user}@${ip}" "echo SSH_OK"
if ($LASTEXITCODE -ne 0) {
    Write-Host "SSH failed. Ensure your key is loaded or password login works:" -ForegroundColor Red
    Write-Host "  ssh ${user}@${ip}"
    exit 1
}

Write-Host "Uploading server setup script ..." -ForegroundColor Cyan
scp -P $port (Join-Path $ProjectRoot "deploy\scripts\setup-vultr.sh") "${user}@${ip}:/root/setup-vultr.sh"
ssh -p $port "${user}@${ip}" "bash /root/setup-vultr.sh $domain $email"

Write-Host "Deploying website ..." -ForegroundColor Cyan
& (Join-Path $PSScriptRoot "deploy.ps1")

Write-Host ""
Write-Host "Optional — enable HTTPS after DNS points to this server:" -ForegroundColor Yellow
Write-Host "  ssh ${user}@${ip} `"certbot --nginx -d $domain -d www.$domain --email $email --agree-tos --no-eff-email --redirect`""
