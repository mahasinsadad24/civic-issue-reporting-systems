const Minio = require('minio');
const fs = require('fs');
const path = require('path');

// Initialize MinIO Client
const minioClient = new Minio.Client({
    endPoint: process.env.MINIO_ENDPOINT,
    port: parseInt(process.env.MINIO_PORT),
    useSSL: process.env.MINIO_USE_SSL === 'true',
    accessKey: process.env.MINIO_ACCESS_KEY,
    secretKey: process.env.MINIO_SECRET_KEY
});

const BUCKET_NAME = process.env.MINIO_BUCKET_NAME || 'reports-media';

/**
 * Uploads a file to MinIO and returns the public URL
 * @param {Object} file - The file object from Multer (req.file)
 * @returns {Promise<string>} - The public URL of the uploaded file
 */
const uploadFile = async (file) => {
    try {
        // Create unique object name: reports/<timestamp>_<originalfilename>
        const timestamp = Date.now();
        // sanitize filename
        const sanitizedFilename = file.originalname.replace(/[^a-zA-Z0-9.-]/g, '_');
        const objectName = `reports/${timestamp}_${sanitizedFilename}`;

        // Read file stream
        const fileStream = fs.createReadStream(file.path);
        const fileStat = fs.statSync(file.path);

        console.log(`[MINIO] Uploading ${objectName} to bucket ${BUCKET_NAME}...`);

        // Upload to MinIO
        await minioClient.putObject(BUCKET_NAME, objectName, fileStream, fileStat.size, {
            'Content-Type': file.mimetype
        });

        console.log(`[MINIO] Upload successful: ${objectName}`);

        // Return ONLY the object name (Key) - NO public URL
        return objectName;
    } catch (error) {
        console.error('[MINIO] Upload failed:', error);
        throw new Error(`Storage upload failed: ${error.message}`);
    }
};

/**
 * Get file stream from MinIO for proxying
 * @param {string} objectName - The key of the object
 * @returns {Promise<Stream>} - Readable stream of the file
 */
const getFileStream = async (objectName) => {
    try {
        return await minioClient.getObject(BUCKET_NAME, objectName);
    } catch (error) {
        throw new Error(`Failed to get file stream: ${error.message}`);
    }
};

/**
 * Check if MinIO connection is healthy
 */
const checkHealth = async () => {
    try {
        await minioClient.bucketExists(BUCKET_NAME);
        return true;
    } catch (error) {
        console.error('[MINIO] Health check failed:', error.message);
        return false;
    }
}

module.exports = {
    uploadFile,
    getFileStream,
    checkHealth
};
