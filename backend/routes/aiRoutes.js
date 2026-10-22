const express = require("express");
const router = express.Router();
const { analyzeImage } = require("../controllers/aiController");

// POST /api/ai/analyze/:id - Analyze specific issue
router.post("/analyze/:id", analyzeImage);

module.exports = router;
