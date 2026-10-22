const Issue = require("../models/Issue");
const aiService = require("../services/aiClassificationService");

// @desc    Analyze an existing issue using AI
// @route   POST /api/ai/analyze/:id
const analyzeImage = async (req, res) => {
    try {
        const issueId = req.params.id;

        // 1. Fetch Issue from DB
        console.log(`[AI-Pipeline] 1. Fetching Issue ID: ${issueId}`);
        const issue = await Issue.findById(issueId);

        if (!issue) {
            return res.status(404).json({ success: false, message: "Issue not found" });
        }

        // 2. Extract Image URL
        const imageUrl = issue.imageUrl;
        console.log(`[AI-Pipeline] 2. Found Image URL: ${imageUrl}`);

        if (!imageUrl) {
            return res.status(400).json({ success: false, message: "Issue has no image to analyze" });
        }

        // 3. Call AI Service (Pass URL)
        console.log("[AI-Pipeline] 3. Calling AI Service...");
        const aiResult = await aiService.classifyImage(imageUrl);
        console.log(`[AI-Pipeline] AI Output:`, JSON.stringify(aiResult));

        // 4. Update Database
        console.log("[AI-Pipeline] 4. Updating MongoDB Document...");
        issue.aiCategory = aiResult.category || "unknown";
        issue.aiConfidence = aiResult.confidence || 0;

        // Save using Mongoose to ensure validation and hooks run
        await issue.save();
        console.log(`[AI-Pipeline] 5. DB Write Complete. New Category: ${issue.aiCategory}`);

        res.json({
            success: true,
            data: {
                issueId: issue._id,
                aiAnalysis: aiResult,
                updatedIssue: {
                    category: issue.aiCategory,
                    confidence: issue.aiConfidence
                }
            }
        });

    } catch (error) {
        console.error("[AI-Pipeline] Error:", error);
        res.status(500).json({ success: false, message: error.message });
    }
};

module.exports = { analyzeImage };
