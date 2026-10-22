# Civic Issue Reporting System - Startup Script
# Run this script to start the entire backend system

Write-Host "🚀 Starting Civic Issue Reporting System..." -ForegroundColor Cyan
Write-Host ""

# Check if MongoDB is running
Write-Host "📊 Checking MongoDB connection..." -ForegroundColor Yellow
try {
    $mongoTest = & mongosh --eval "db.runCommand({ ping: 1 })" --quiet 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ MongoDB is running" -ForegroundColor Green
    } else {
        Write-Host "⚠️  MongoDB is not running. Please start MongoDB first." -ForegroundColor Red
        Write-Host "   Run: mongod" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "⚠️  MongoDB connection check failed. Make sure MongoDB is installed." -ForegroundColor Red
    Write-Host "   Install: https://www.mongodb.com/try/download/community" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📦 Installing dependencies..." -ForegroundColor Yellow

# Install Node.js dependencies
Write-Host "  → Installing Node.js packages..." -ForegroundColor Gray
npm install --silent
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✅ Node.js dependencies installed" -ForegroundColor Green
} else {
    Write-Host "  ❌ Failed to install Node.js dependencies" -ForegroundColor Red
    exit 1
}

# Install Python dependencies for AI service
Write-Host "  → Installing Python packages..." -ForegroundColor Gray
Set-Location ai_service
pip install -r requirements.txt --quiet
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✅ Python dependencies installed" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  Some Python packages may have failed to install" -ForegroundColor Yellow
}
Set-Location ..

Write-Host ""
Write-Host "🎯 Starting services..." -ForegroundColor Cyan

# Start AI service in background
Write-Host "  → Starting AI Classification Service (Port 8000)..." -ForegroundColor Gray
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD\ai_service'; python ai_service.py" -WindowStyle Normal

# Wait a moment for AI service to start
Start-Sleep -Seconds 3

# Start backend server
Write-Host "  → Starting Backend Server (Port 3000)..." -ForegroundColor Gray
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "✅ System started successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📡 Services:" -ForegroundColor Yellow
Write-Host "   • Backend API:     http://localhost:3000" -ForegroundColor White
Write-Host "   • AI Service:      http://localhost:8000" -ForegroundColor White
Write-Host "   • AI Service Docs: http://localhost:8000/docs" -ForegroundColor White
Write-Host ""
Write-Host "🔧 MongoDB:         mongodb://127.0.0.1:27017/civicdb" -ForegroundColor White
Write-Host ""
Write-Host "Press Ctrl+C to stop the backend server" -ForegroundColor Gray
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Start the backend server (this will keep running in foreground)
npm start
