# Civic Issue Reporting System (Karylok)

## Overview
Karylok is a comprehensive civic issue reporting platform designed to streamline the process of reporting, classifying, and resolving civic problems like garbage dumps, potholes, and broken streetlights. It leverages AI for automated image classification and provides a real-time dashboard for administration.

## Tech Stack

### Mobile App (Flutter)
- **Framework**: Flutter (Dart)
- **Features**: 
    - Real-time Camera & Gallery upload
    - Geolocation tagging
    - Voice description recording
    - Offline support with local storage
    - Smart text hinting for AI assistance

### Backend (Node.js)
- **Framework**: Express.js
- **Database**: MongoDB (Atlas)
- **Storage**: MinIO (S3 Compatible Object Storage)
- **AI Integration**: Python Microservice (FastAPI) + Mock/TFLite Logic
- **Security**: Helmet, CORS, Rate Limiting, JWT Authentication

### Frontend Dashboard (React + Vite)
- **Tech**: React, TypeScript, Tailwind CSS
- **Features**:
    - Interactive Maps (Leaflet)
    - Real-time Issue Tracking
    - Department-wise Filtering
    - Secure Admin Authentication

### AI Service (Python)
- **Framework**: FastAPI
- **Logic**: Mock AI with Smart Hinting (Context-aware classification based on description/category) and filename pattern matching.

## Project Structure
```
/
├── app/                  # Flutter Mobile Application
├── backend/              # Node.js Express Server
│   ├── ai_service/       # Python FastAPI AI Microservice
│   ├── controllers/      # API Logic
│   ├── models/           # Mongoose Schemas
│   └── services/         # Storage & AI Services
├── dashboard/            # React Admin Dashboard
└── docker-compose.yml    # (Coming Soon) Container Orchestration
```

## Setup & Running

### Prerequisites
- Node.js (v18+)
- Flutter SDK
- Python 3.9+
- MongoDB Atlas URI
- MinIO Server (Local or hosted)

### Quick Start (Local)
1. **Start MinIO**: `minio server ~/minio-data`
2. **Start AI Service**: `python backend/ai_service/ai_service.py`
3. **Start Backend**: `cd backend && npm start`
4. **Start Dashboard**: `cd dashboard && npm run dev`
5. **Run App**: `cd app && flutter run`

## Deployment
This project is containerized using Docker. See `Dockerfile` in each directory for deployment details.
