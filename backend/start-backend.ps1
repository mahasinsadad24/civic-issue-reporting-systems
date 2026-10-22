# Quick Start - Backend Only
# Use this if you want to start just the backend (AI service optional)

Write-Host "🚀 Starting Backend Server..." -ForegroundColor Cyan
Write-Host ""

# Check MongoDB
Write-Host "📊 Checking MongoDB..." -ForegroundColor Yellow
try {
    $mongoTest = & mongosh --eval "db.runCommand({ ping: 1 })" --quiet 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ MongoDB is ready" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Warning: MongoDB may not be running" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️  MongoDB check skipped" -ForegroundColor Gray
}

Write-Host ""
Write-Host "🎯 Starting Backend Server on port 3000..." -ForegroundColor Cyan
npm start
