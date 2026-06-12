# Upload tarball + install on server (dedicated preview port)
# Usage: .\deploy\scripts\push-from-windows.ps1
#        .\deploy\scripts\push-from-windows.ps1 -Port 8888

param([int]$Port = 8888)

$ErrorActionPreference = "Stop"
$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ConfigFile = Join-Path $ProjectRoot "deploy\config.env"
$keyFile = Join-Path $ProjectRoot "deploy\.vultr-key"
$archive = Join-Path $ProjectRoot "deploy\release.tar.gz"
$installSh = Join-Path $ProjectRoot "deploy\scripts\install-port.sh"

if (-not (Test-Path $ConfigFile)) { throw "Missing deploy\config.env" }

$config = @{}
Get-Content $ConfigFile | ForEach-Object {
    if ($_ -match '^\s*([^#][^=]+)=(.*)$') { $config[$matches[1].Trim()] = $matches[2].Trim() }
}

$host_ip = $config["VULTR_HOST"]
$user = $config["SSH_USER"]
$sshPort = if ($config["SSH_PORT"]) { $config["SSH_PORT"] } else { "22" }

if (-not (Test-Path $archive)) {
    Push-Location $ProjectRoot
    npm run build
    tar -czf $archive -C dist .
    Pop-Location
}

$sshArgs = @("-p", $sshPort)
$scpArgs = @("-P", $sshPort)
if (Test-Path $keyFile) {
    icacls $keyFile /inheritance:r /grant:r "${env:USERNAME}:F" | Out-Null
    $sshArgs += @("-i", $keyFile, "-o", "IdentitiesOnly=yes")
    $scpArgs += @("-i", $keyFile, "-o", "IdentitiesOnly=yes")
}

$target = "${user}@${host_ip}"
Write-Host "Uploading site package..." -ForegroundColor Cyan
& scp @scpArgs $archive "${target}:/tmp/weevent-release.tar.gz"
& scp @scpArgs $installSh "${target}:/root/install-port.sh"
Write-Host "Installing on port $Port ..." -ForegroundColor Cyan
& ssh @sshArgs $target "bash /root/install-port.sh $Port /tmp/weevent-release.tar.gz"
Write-Host ""
Write-Host "Preview: http://${host_ip}:${Port}/en/" -ForegroundColor Green
