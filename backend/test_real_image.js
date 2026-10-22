const axios = require('axios');
const fs = require('fs');
const FormData = require('form-data');
const path = require('path');

const API_URL = 'http://localhost:3000/api';
// Path to the user's uploaded image
const IMAGE_PATH = '/Users/prudhvi/.gemini/antigravity/brain/64a58eb2-07ee-4603-99e6-23f0aab298a0/uploaded_image_1768059247574.png';

async function runRealImageTest() {
    console.log("🚀 Starting Real Image Integration Test...");

    if (!fs.existsSync(IMAGE_PATH)) {
        console.error(`❌ Image file not found at: ${IMAGE_PATH}`);
        process.exit(1);
    }

    try {
        // 1. Authenticate (Login as the user created in previous step or register new one)
        // We'll try to register a new user to be clean, or login if exists.
        const email = `test_user_real_${Date.now()}@example.com`;
        const password = 'password123';

        console.log("1️⃣  Authenticating...");
        let token;
        try {
            const regRes = await axios.post(`${API_URL}/auth/register`, {
                name: "Real Image Tester",
                email,
                password,
                role: "user"
            });
            token = regRes.data.data ? regRes.data.data.token : regRes.data.token;
            console.log("✅ Registered & Got Token");
        } catch (e) {
            console.log("⚠️  Registration failed, trying login...");
            // Fallback logic if needed, but unique email should work
            throw e;
        }

        // 2. Upload The Real Image
        console.log("2️⃣  Uploading User Image...");
        const form = new FormData();
        form.append('description', 'User Provided Test Image - Garbage Pile?');
        form.append('category', 'garbage'); // Guessing category based on file name or random
        form.append('lat', '19.0760'); // Mumbai coordinates example
        form.append('lng', '72.8777');

        // Append the actual file
        form.append('image', fs.createReadStream(IMAGE_PATH));

        const uploadRes = await axios.post(`${API_URL}/issues`, form, {
            headers: {
                ...form.getHeaders(),
                'Authorization': `Bearer ${token}`
            }
        });

        if (uploadRes.status === 201) {
            const issue = uploadRes.data.data;
            console.log("✅ Issue Created Successfully!");
            console.log("---------------------------------------------------");
            console.log(`🆔 Issue ID: ${issue.id || issue._id}`);
            console.log(`🔗 MinIO URL: ${issue.imageUrl}`);
            console.log(`🤖 AI Category: ${issue.aiCategory}`);
            console.log("---------------------------------------------------");

            // 3. Verify URL
            if (!issue.imageUrl.startsWith('http')) {
                throw new Error("❌ Invalid URL format");
            }
        }

        console.log("🎉 Real Image Test PASSED!");

    } catch (error) {
        console.error("❌ Test Failed:", error.response ? error.response.data : error.message);
        process.exit(1);
    }
}

runRealImageTest();
