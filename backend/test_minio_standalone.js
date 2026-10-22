require('dotenv').config();
const storageService = require('./services/storageService');
const fs = require('fs');

async function testMinio() {
    console.log("🧪 Testing MinIO Connection Independent of MongoDB...");

    // 1. Check Health
    console.log("1️⃣  Checking Health...");
    const isHealthy = await storageService.checkHealth();
    if (isHealthy) {
        console.log("✅ MinIO Health Check Passed");
    } else {
        console.error("❌ MinIO Health Check Failed");
        process.exit(1);
    }

    // 2. Try Upload (Mock File)
    console.log("2️⃣  Attempting File Upload...");
    const testFileName = `test_upload_${Date.now()}.txt`;
    fs.writeFileSync(testFileName, "Integration Test File Content");

    try {
        const mockFile = {
            originalname: testFileName,
            path: testFileName,
            mimetype: 'text/plain'
        };

        const url = await storageService.uploadFile(mockFile);
        console.log("✅ Upload Successful!");
        console.log(`🔗 Public URL: ${url}`);

    } catch (e) {
        console.error("❌ Upload Failed:", e.message);
    } finally {
        fs.unlinkSync(testFileName);
    }
}

testMinio();
