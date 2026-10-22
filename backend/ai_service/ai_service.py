#!/usr/bin/env python3
"""
AI Classification Service
A FastAPI service that provides AI-powered civic issue classification.
Supports both TFLite model and mock classification modes.
"""

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional
import random
import os
import time

# Try to import TFLite classifier, fall back to mock if unavailable
try:
    from civic_image_classifier import CivicImageClassifier
    TFLITE_AVAILABLE = True
    print("✅ TFLite classifier loaded successfully")
except Exception as e:
    TFLITE_AVAILABLE = False
    print(f"⚠️  TFLite classifier not available: {e}")
    print("📝 Using mock classification mode")

app = FastAPI(
    title="Civic Issue AI Classification Service",
    description="AI service for classifying civic issues from images",
    version="2.0.0"
)

class ClassificationRequest(BaseModel):
    image_path: str
    hint: Optional[str] = None

class ClassificationResponse(BaseModel):
    category: str
    confidence: float
    processing_time_ms: int

class ServiceInfo(BaseModel):
    name: str
    version: str
    status: str
    model_loaded: bool
    supported_categories: list

# Mock categories with realistic confidence patterns
CATEGORY_PATTERNS = {
    "pothole": {"base_confidence": 0.85, "variance": 0.10},
    "garbage": {"base_confidence": 0.78, "variance": 0.12},
    "streetlight": {"base_confidence": 0.82, "variance": 0.08},
    "water": {"base_confidence": 0.75, "variance": 0.15},
    "traffic": {"base_confidence": 0.80, "variance": 0.10},
    "unknown": {"base_confidence": 0.30, "variance": 0.20}
}

# Initialize TFLite classifier if available
classifier = None
if TFLITE_AVAILABLE:
    try:
        classifier = CivicImageClassifier()
        print(f"✅ TFLite classifier initialized with {len(classifier.CATEGORIES)} categories")
    except Exception as e:
        print(f"⚠️  Failed to initialize TFLite classifier: {e}")
        print("📝 Falling back to mock classification")
        classifier = None

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "timestamp": time.time()}

@app.get("/info", response_model=ServiceInfo)
async def get_service_info():
    """Get service information"""
    return ServiceInfo(
        name="Civic Issue AI Classifier",
        version="2.0.0",
        status="running",
        model_loaded=classifier is not None,
        supported_categories=list(CATEGORY_PATTERNS.keys())
    )

@app.post("/classify", response_model=ClassificationResponse)
async def classify_image(request: ClassificationRequest):
    """
    Classify a civic issue from an image
    Uses TFLite model if available, otherwise falls back to mock classification
    """
    start_time = time.time()
    
    # Validate image path
    if not request.image_path:
        raise HTTPException(status_code=400, detail="Image path is required")
    
    # Check if file exists
    if not os.path.exists(request.image_path):
        print(f"Warning: Image file not found: {request.image_path}")
        # Don't fail - proceed with mock classification
    
    # Try TFLite classification first
    if classifier is not None and os.path.exists(request.image_path):
        try:
            category, confidence = classifier.classify(request.image_path)
            processing_time = int((time.time() - start_time) * 1000)
            
            return ClassificationResponse(
                category=category,
                confidence=round(confidence, 3),
                processing_time_ms=processing_time
            )
        except Exception as e:
            print(f"⚠️  TFLite classification failed: {e}")
            print("📝 Falling back to mock classification")
    
    # Fallback to mock classification
    # Simulate processing time (50-200ms)
    processing_delay = random.uniform(0.05, 0.2)
    time.sleep(processing_delay)
    
    # Mock AI classification logic
    # Pass hint to mock classifier
    category = classify_mock_image(request.image_path, request.hint)
    
    pattern = CATEGORY_PATTERNS.get(category, CATEGORY_PATTERNS["unknown"])
    base_confidence = pattern["base_confidence"]
    variance = pattern["variance"]
    
    # Generate realistic confidence with some randomness
    confidence = max(0.0, min(1.0, 
        base_confidence + random.uniform(-variance, variance)))
    
    processing_time = int((time.time() - start_time) * 1000)
    
    return ClassificationResponse(
        category=category,
        confidence=round(confidence, 3),
        processing_time_ms=processing_time
    )

def classify_mock_image(image_path: str, hint: str = None) -> str:
    """
    Mock classification logic based on filename patterns OR hint
    In a real implementation, this would use computer vision models
    """
    filename = os.path.basename(image_path).lower()
    
    # 1. Priority: Filename keywords (Simulates "Test Data")
    if any(word in filename for word in ["pothole", "hole", "road", "crack"]):
        return "pothole"
    elif any(word in filename for word in ["garbage", "trash", "litter", "waste"]):
        return "garbage"
    elif any(word in filename for word in ["light", "lamp", "street", "bulb"]):
        return "streetlight"
    elif any(word in filename for word in ["water", "leak", "pipe", "flood"]):
        return "water"
    elif any(word in filename for word in ["traffic", "sign", "signal", "stop"]):
        return "traffic"
    
    # 2. Secondary: Use Hint (User's input category)
    if hint and hint.lower() in ["pothole", "garbage", "streetlight", "water", "traffic"]:
        return hint.lower()
        
    # 3. Fallback: Unknown (Do NOT guess randomly)
    return "unknown"

# CORS middleware for development
@app.middleware("http")
async def add_cors_header(request, call_next):
    response = await call_next(request)
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "Content-Type"
    return response

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "ai_service:app", 
        host="0.0.0.0", 
        port=8000, 
        reload=True,
        log_level="info"
    )
