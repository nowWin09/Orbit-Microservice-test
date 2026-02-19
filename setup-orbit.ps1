# Setup Orbit in your microservice project
# Usage: .\setup-orbit.ps1

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "       Orbit Framework Setup Script" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Check if we're in a git repo
if (-not (Test-Path ".git")) {
    Write-Host "❌ Error: Not a git repository" -ForegroundColor Red
    Write-Host "Run this script from your microservice project root" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Git repository detected" -ForegroundColor Green
Write-Host ""

# Check if Orbit template folder exists
if (-not (Test-Path "orbit-template")) {
    Write-Host "📥 Cloning Orbit template repository..." -ForegroundColor Yellow
    git clone https://github.com/nowWin09/Orbit-Microservice-test.git orbit-template
} else {
    Write-Host "📥 Updating Orbit template repository..." -ForegroundColor Yellow
    cd orbit-template
    git pull origin main
    cd ..
}

Write-Host "✅ Template cloned" -ForegroundColor Green
Write-Host ""

# Check if .cursor already exists
if (Test-Path ".cursor") {
    Write-Host "⚠️  .cursor folder already exists" -ForegroundColor Yellow
    $response = Read-Host "Overwrite? (y/n)"
    if ($response -eq "y" -or $response -eq "Y") {
        Remove-Item -Path ".cursor" -Recurse -Force
        Copy-Item -Path "orbit-template\.cursor" -Destination ".cursor" -Recurse
        Write-Host "✅ .cursor copied" -ForegroundColor Green
    } else {
        Write-Host "Skipping .cursor copy" -ForegroundColor Yellow
    }
} else {
    Copy-Item -Path "orbit-template\.cursor" -Destination ".cursor" -Recurse
    Write-Host "✅ .cursor copied" -ForegroundColor Green
}

Write-Host ""

# Check if docs already exists
if (Test-Path "docs") {
    Write-Host "⚠️  docs folder already exists" -ForegroundColor Yellow
    $response = Read-Host "Overwrite? (y/n)"
    if ($response -eq "y" -or $response -eq "Y") {
        Remove-Item -Path "docs" -Recurse -Force
        Copy-Item -Path "orbit-template\docs" -Destination "docs" -Recurse
        Write-Host "✅ docs copied" -ForegroundColor Green
    } else {
        Write-Host "Skipping docs copy" -ForegroundColor Yellow
    }
} else {
    Copy-Item -Path "orbit-template\docs" -Destination "docs" -Recurse
    Write-Host "✅ docs copied" -ForegroundColor Green
}

Write-Host ""

# Cleanup template folder
Write-Host "🧹 Cleaning up template..." -ForegroundColor Yellow
Remove-Item -Path "orbit-template" -Recurse -Force
Write-Host "✅ Template removed" -ForegroundColor Green

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "       Setup Complete!" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Green
Write-Host "  1. Run: /init" -ForegroundColor White
Write-Host "  2. Read: docs/ORBIT_QUICK_START.md" -ForegroundColor White
Write-Host "  3. Start: /start implement <feature> for <TICKET>" -ForegroundColor White
Write-Host ""
Write-Host "Commit to git:" -ForegroundColor Green
Write-Host "  git add .cursor/ docs/" -ForegroundColor White
Write-Host "  git commit -m 'Add: Project Orbit framework'" -ForegroundColor White
Write-Host "  git push" -ForegroundColor White
Write-Host ""
Write-Host "For help: See docs/README.md" -ForegroundColor Green
Write-Host ""
