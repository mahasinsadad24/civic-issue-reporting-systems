# Civic Issue Reporting System

## Railway Deployment

### Project Structure
- **Backend Service**: Located in `backend-service/`.
- **Frontend Service**: Located in `frontend-service/`.

### Environment Variables
Add the following environment variables in the Railway dashboard:

#### Backend Service
- `MONGODB_ATLAS_URI`: MongoDB connection string.
- `MINIO_ACCESS_KEY`: MinIO access key.
- `MINIO_SECRET_KEY`: MinIO secret key.
- `JWT_SECRET`: Secret for JWT authentication.
- `PORT`: Railway dynamically assigns this.

#### Frontend Service
- `VITE_API_URL`: Base URL for the backend API.

### Deployment Steps
1. Connect the GitHub repository to Railway.
2. Railway will auto-detect the `backend-service` and `frontend-service` folders.
3. Add the environment variables in the Railway dashboard.
4. Deploy the services.

### Notes
- Ensure commits to the `main` branch trigger automatic deployments.
- If Railway fails to detect services, use the provided `Procfile` or Dockerfiles.
