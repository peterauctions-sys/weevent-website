# Deploy WE Event website to Vultr VPS
# Usage: .\deploy\scripts\deploy.ps1
# Requires: deploy\config.env, OpenSSH (scp/ssh), npm build output in dist/

$ErrorActionPreference = "Stop"
$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ConfigFile = Join-Path $ProjectRoot "deploy\config.env"

if (-not (Test-Path $ConfigFile)) {
    Write-Host "Missing deploy\config.env — copy from deploy\config.env.example and set VULTR_HOST" -ForegroundColor Red
    exit 1
}

$config = @{}
Get-Content $ConfigFile | ForEach-Object {
    if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
        $config[$matches[1].Trim()] = $matches[2].Trim()
    }
}

$host_ip = $config["VULTR_HOST"]
$user = $config["SSH_USER"]
$port = if ($config["SSH_PORT"]) { $config["SSH_PORT"] } else { "22" }
$remote = if ($config["REMOTE_PATH"]) { $config["REMOTE_PATH"] } else { "/var/www/weevent" }

if (-not $host_ip -or $host_ip -eq "YOUR_SERVER_IP") {
    Write-Host "Set VULTR_HOST in deploy\config.env to your Vultr server IP" -ForegroundColor Red
    exit 1
}

Write-Host "==> Building site..." -ForegroundColor Cyan
Push-Location $ProjectRoot
npm run build
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Pop-Location

$dist = Join-Path $ProjectRoot "dist"
$archive = Join-Path $ProjectRoot "deploy\release.tar.gz"

Write-Host "==> Packaging dist/ ..." -ForegroundColor Cyan
if (Test-Path $archive) { Remove-Item $archive -Force }
tar -czf $archive -C $dist .

$keyFile = Join-Path $ProjectRoot "deploy\.vultr-key"
$sshTarget = "${user}@${host_ip}"
$scpArgs = @("-P", $port)
$sshArgs = @("-p", $port)
if (Test-Path $keyFile) {
    icacls $keyFile /inheritance:r /grant:r "${env:USERNAME}:F" | Out-Null
    $scpArgs += @("-i", $keyFile, "-o", "IdentitiesOnly=yes")
    $sshArgs += @("-i", $keyFile, "-o", "IdentitiesOnly=yes")
}
$scpArgs += @($archive, "${sshTarget}:/tmp/weevent-release.tar.gz")

Write-Host "==> Uploading to Vultr ($host_ip) ..." -ForegroundColor Cyan
& scp @scpArgs
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$remoteCmd = @"
set -e
mkdir -p $remote
rm -rf ${remote}/*
tar -xzf /tmp/weevent-release.tar.gz -C $remote
chown -R www-data:www-data $remote
chmod -R 755 $remote
rm -f /tmp/weevent-release.tar.gz
echo 'Deploy OK: $remote'
"@

Write-Host "==> Extracting on server ..." -ForegroundColor Cyan
& ssh @sshArgs $remoteCmd
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Remove-Item $archive -Force -ErrorAction SilentlyContinue

$domain = $config["DOMAIN"]
$url = if ($domain) { "http://${domain}/en/" } else { "http://${host_ip}/en/" }
Write-Host ""
Write-Host "Done! Site live at:" -ForegroundColor Green
Write-Host "  $url"
Write-Host ""
