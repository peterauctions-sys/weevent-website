# Initialize repo, commit, create GitHub repo, push, enable Pages workflow
$ErrorActionPreference = "Stop"
$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $ProjectRoot

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

Write-Host "Checking GitHub login..." -ForegroundColor Cyan
gh auth status
if ($LASTEXITCODE -ne 0) {
    Write-Host "Please login first: gh auth login" -ForegroundColor Yellow
    gh auth login
}

if (-not (Test-Path ".git")) {
    git init -b main
}

git add -A
$status = git status --porcelain
if ($status) {
    git commit -m "Initial WE Event bilingual marketing site with GitHub Pages deploy"
}

$repoName = "weevent-website"
$owner = (gh api user -q .login)
$remote = "https://github.com/$owner/$repoName.git"

$hasOrigin = git remote 2>$null | Select-String -Pattern '^origin$' -Quiet
if (-not $hasOrigin) {
    Write-Host "Creating GitHub repo $owner/$repoName ..." -ForegroundColor Cyan
    gh repo create $repoName --public --source=. --remote=origin --description "WE Events x WE Displays - bilingual marketing site preview"
} else {
    Write-Host "Remote origin already set." -ForegroundColor Cyan
}

Write-Host "Pushing to GitHub..." -ForegroundColor Cyan
git push -u origin main

Write-Host ""
Write-Host "Done!" -ForegroundColor Green
Write-Host "Repo:  https://github.com/$owner/$repoName"
Write-Host "Pages: https://$owner.github.io/$repoName/en/"
Write-Host ""
Write-Host "Enable Pages: GitHub repo -> Settings -> Pages -> Source: GitHub Actions" -ForegroundColor Yellow
