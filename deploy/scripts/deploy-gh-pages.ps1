# Build and publish to gh-pages branch for GitHub Pages preview
$ErrorActionPreference = "Stop"
$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

Set-Location $ProjectRoot
$env:BASE_PATH = "/weevent-website/"
$env:SITE_URL = "https://peterauctions-sys.github.io/weevent-website"

npm run build

$dist = Join-Path $ProjectRoot "dist"
$deployDir = Join-Path $ProjectRoot ".gh-pages-deploy"
if (Test-Path $deployDir) { Remove-Item $deployDir -Recurse -Force }
New-Item -ItemType Directory -Path $deployDir | Out-Null
Copy-Item -Path "$dist\*" -Destination $deployDir -Recurse -Force

Set-Location $deployDir
git init -b gh-pages
git -c user.email="joy@we-events.co.nz" -c user.name="WE Displays" add -A
git -c user.email="joy@we-events.co.nz" -c user.name="WE Displays" commit -m "Deploy site preview"
git remote add origin https://github.com/peterauctions-sys/weevent-website.git
git push -f origin gh-pages

Write-Host "Live: https://peterauctions-sys.github.io/weevent-website/en/" -ForegroundColor Green
