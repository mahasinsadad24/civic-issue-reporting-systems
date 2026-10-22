# Quick Start - AI Service Only
# Use this if you want to start just the AI classification service

Write-Host "🤖 Starting AI Classification Service..." -ForegroundColor Cyan
Write-Host ""

Set-Location ai_service

Write-Host "📦 Checking Python dependencies..." -ForegroundColor Yellow
pip show fastapi uvicorn | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  Installing dependencies..." -ForegroundColor Yellow
    pip install -r requirements.txt
}

Write-Host ""
Write-Host "🎯 Starting AI Service on port 8000..." -ForegroundColor Cyan
Write-Host "   API Docs: http://localhost:8000/docs" -ForegroundColor Gray
Write-Host ""

python ai_service.py
