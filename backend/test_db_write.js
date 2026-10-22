require('dotenv').config();
const mongoose = require('mongoose');

async function testDBConnection() {
    console.log("🧪 Testing Direct MongoDB Connection...");

    const uri = process.env.MONGO_URI;
    if (!uri) {
        console.error("❌ MONGO_URI is missing in .env");
        process.exit(1);
    }

    try {
        // 1. Connect
        console.log("1️⃣  Connecting to Atlas...");
        await mongoose.connect(uri);
        console.log("✅ Connected successfully.");

        // 2. Define Temp Schema
        const TestSchema = new mongoose.Schema({
            message: String,
            timestamp: Date
        });
        const TestModel = mongoose.model('ConnectionTest', TestSchema);

        // 3. Write Data
        console.log("2️⃣  Writing Temp Data...");
        const doc = new TestModel({
            message: "Hello MongoDB! Connectivity Check.",
            timestamp: new Date()
        });
        await doc.save();
        console.log(`✅ Data Written: ID=${doc._id}`);

        // 4. Read Data
        console.log("3️⃣  Reading Data Back...");
        const found = await TestModel.findById(doc._id);
        if (found && found.message === "Hello MongoDB! Connectivity Check.") {
            console.log("✅ Read Verification Successful.");
            console.log("   Doc:", found.toJSON());
        } else {
            throw new Error("❌ Data mismatch or not found.");
        }

        // 5. Cleanup
        console.log("4️⃣  Cleaning Up...");
        await TestModel.deleteOne({ _id: doc._id });
        console.log("✅ Temp Data Deleted.");

        console.log("\n🎉 MongoDB Connection is PERFECT.");

    } catch (error) {
        console.error("❌ DB Test Failed:", error.message);
    } finally {
        await mongoose.disconnect();
    }
}

testDBConnection();
