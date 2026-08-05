<#
  deploy.ps1  -  One-command deploy for the Corymba CRM
  ---------------------------------------------------------------
  Copies a CRM html file to index.html, commits, and pushes to
  GitHub. GitHub Pages then serves it live in ~1-2 minutes.

  USAGE
    .\deploy.ps1                 # deploy NEWEST corymba_crm_v*.html from Downloads
    .\deploy.ps1 -Source "C:\path\to\file.html"   # deploy a specific file
    .\deploy.ps1 -Force          # skip the confirmation prompt

  The live site: https://sebastian-tuerk.github.io/corymba-crm/
#>
param(
    [string]$Source = "",
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$repo = $PSScriptRoot
$liveUrl = "https://sebastian-tuerk.github.io/corymba-crm/"

# 1. Pick the source file -------------------------------------------------
if (-not $Source) {
    $downloads = Join-Path $env:USERPROFILE "Downloads"
    $newest = Get-ChildItem -Path $downloads -Filter "corymba_crm_v*.html" -ErrorAction SilentlyContinue |
              Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $newest) {
        Write-Host "No corymba_crm_v*.html found in $downloads. Pass one with -Source." -ForegroundColor Red
        exit 1
    }
    $Source = $newest.FullName
}
if (-not (Test-Path $Source)) {
    Write-Host "Source file not found: $Source" -ForegroundColor Red
    exit 1
}

$srcInfo = Get-Item $Source
Write-Host ""
Write-Host "About to deploy:" -ForegroundColor Cyan
Write-Host ("  File : {0}" -f $srcInfo.Name)
Write-Host ("  Saved: {0}" -f $srcInfo.LastWriteTime)
Write-Host ("  Size : {0:N0} bytes" -f $srcInfo.Length)
Write-Host ("  ->   : {0}" -f $liveUrl)
Write-Host ""

# 2. Copy into the repo as index.html ------------------------------------
Copy-Item $Source (Join-Path $repo "index.html") -Force

# 3. Bail out early if nothing actually changed --------------------------
Push-Location $repo
try {
    git add index.html | Out-Null
    $changes = git status --porcelain index.html
    if (-not $changes) {
        Write-Host "index.html is already identical to what's live. Nothing to deploy." -ForegroundColor Yellow
        exit 0
    }

    # 4. Confirm ----------------------------------------------------------
    if (-not $Force) {
        $answer = Read-Host "Publish this now? (y/n)"
        if ($answer -notmatch '^(y|yes)$') {
            Write-Host "Aborted. index.html was staged but not committed." -ForegroundColor Yellow
            git restore --staged index.html | Out-Null
            git checkout -- index.html | Out-Null
            exit 0
        }
    }

    # 5. Commit & push ----------------------------------------------------
    $stamp = Get-Date -Format "yyyy-MM-dd HH:mm"
    git commit -m "Deploy $($srcInfo.Name) ($stamp)" | Out-Null
    Write-Host "Pushing to GitHub..." -ForegroundColor Cyan
    git push origin main

    Write-Host ""
    Write-Host "Deployed. Live in ~1-2 minutes at:" -ForegroundColor Green
    Write-Host "  $liveUrl"
    Write-Host "(Hard-refresh with Ctrl+F5 if you still see the old version.)"
}
finally {
    Pop-Location
}
