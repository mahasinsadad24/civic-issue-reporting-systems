#!/bin/bash

# AI Service Startup Script
echo "🤖 Starting Civic Issue AI Classification Service..."

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is required but not installed."
    exit 1
fi

# Check if pip is installed
if ! command -v pip3 &> /dev/null; then
    echo "❌ pip3 is required but not installed."
    exit 1
fi

# Install dependencies if requirements.txt exists
if [ -f "requirements.txt" ]; then
    echo "📦 Installing Python dependencies..."
    pip3 install -r requirements.txt
else
    echo "⚠️  requirements.txt not found. Installing FastAPI manually..."
    pip3 install fastapi uvicorn
fi

echo "🚀 Starting AI service on http://localhost:8000"
echo "📊 Access API docs at http://localhost:8000/docs"
echo ""
echo "To test the service:"
echo "curl http://localhost:8000/health"
echo ""

# Start the service
python3 ai_service.py
