const axios = require('axios');
const fs = require('fs');
const FormData = require('form-data');
const path = require('path');

const API_URL = 'http://localhost:3000/api';

async function runIntegrationTest() {
    console.log("🚀 Starting Full Integration Test (Auth + Upload + DB)...");

    try {
        // 1. Authenticate (Get Token)
        // Note: Assuming a seed user exists or we can register.
        // Let's try to register a temp admin user.
        const email = `test_admin_${Date.now()}@example.com`;
        const password = 'password123';

        console.log("1️⃣  Registering Test User...");
        let token;
        try {
            const regRes = await axios.post(`${API_URL}/auth/register`, {
                name: "Integration Tester",
                email,
                password,
                role: "admin"
            });
            console.log("Response Status:", regRes.status);
            console.log("Response Data keys:", Object.keys(regRes.data));
            if (regRes.data.data) console.log("Data keys:", Object.keys(regRes.data.data));

            token = regRes.data.data ? regRes.data.data.token : regRes.data.token;

            if (!token) {
                console.error("❌ Token not found in response:", JSON.stringify(regRes.data));
                throw new Error("No token returned");
            }
            console.log("✅ Registered & Got Token:", token.substring(0, 20) + "...");
        } catch (e) {
            console.log("⚠️  Registration failed:", e.response ? e.response.data : e.message);
            // Try login if user already exists
            try {
                console.log("🔄 Trying Login...");
                const loginRes = await axios.post(`${API_URL}/auth/login`, { email, password });
                token = loginRes.data.data ? loginRes.data.data.token : loginRes.data.token;
                console.log("✅ Logged in & Got Token");
            } catch (loginErr) {
                throw e;
            }
        }

        // 2. Upload Issue with Image
        console.log("2️⃣  Uploading Issue with Image...");
        const form = new FormData();
        form.append('description', 'Integration Test Issue - Pothole');
        form.append('category', 'pothole');
        form.append('lat', '28.6139');
        form.append('lng', '77.2090');

        // Create dummy image
        const imgPath = path.join(__dirname, 'test_img.jpg');
        fs.writeFileSync(imgPath, 'fake image content');
        form.append('image', fs.createReadStream(imgPath));

        const uploadRes = await axios.post(`${API_URL}/issues`, form, {
            headers: {
                ...form.getHeaders(),
                'Authorization': `Bearer ${token}`
            }
        });

        if (uploadRes.status === 201) {
            const issue = uploadRes.data.data;
            console.log("✅ Issue Created!");
            console.log("   ID:", issue.id || issue._id);
            console.log("   Image URL:", issue.imageUrl);

            // 3. Validation
            if (!issue.imageUrl.startsWith('http')) {
                throw new Error("❌ Image URL is not a valid HTTP string (MinIO URL expected)");
            }
            if (issue.imageUrl.includes('localhost')) {
                console.warn("⚠️  Warning: URL points to localhost. Ensure valid MinIO IP for production.");
            }
            console.log("✅ Image URL format looks valid.");

        } else {
            throw new Error(`Unexpected status: ${uploadRes.status}`);
        }

        // Cleanup
        fs.unlinkSync(imgPath);
        console.log("🎉 Integration Test PASSED!");

    } catch (error) {
        console.error("❌ Test Failed:", error.response ? error.response.data : error.message);
        process.exit(1);
    }
}

runIntegrationTest();
