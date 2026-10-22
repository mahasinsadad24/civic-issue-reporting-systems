const Minio = require('minio');
require('dotenv').config();

const minioClient = new Minio.Client({
    endPoint: process.env.MINIO_ENDPOINT || 'localhost',
    port: parseInt(process.env.MINIO_PORT) || 9000,
    useSSL: process.env.MINIO_USE_SSL === 'true',
    accessKey: process.env.MINIO_ACCESS_KEY || 'minioadmin',
secretKey: process.env.MINIO_SECRET_KEY
});

const bucketName = process.env.MINIO_BUCKET_NAME || 'reports-media';

async function setup() {
    try {
        const exists = await minioClient.bucketExists(bucketName);
        if (exists) {
            console.log(`Bucket '${bucketName}' already exists.`);
        } else {
            await minioClient.makeBucket(bucketName, 'us-east-1');
            console.log(`Bucket '${bucketName}' created successfully.`);
        }

        // Set policy to public read (optional, generally good for media)
        const policy = {
            Version: "2012-10-17",
            Statement: [
                {
                    Effect: "Allow",
                    Principal: { AWS: ["*"] },
                    Action: ["s3:GetObject"],
                    Resource: [`arn:aws:s3:::${bucketName}/*`]
                }
            ]
        };
        await minioClient.setBucketPolicy(bucketName, JSON.stringify(policy));
        console.log(`Bucket policy set to public read for '${bucketName}'.`);

    } catch (err) {
        console.error('Error creating bucket:', err);
    }
}

setup();
