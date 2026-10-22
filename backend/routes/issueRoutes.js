const express = require("express");
const router = express.Router();
const upload = require("../config/multer");
const { createIssue, getIssues, getIssueById, getAIServiceStatus } = require("../controllers/issueController");
const { authenticate, optionalAuth } = require("../middlewares/authMiddleware");
const { createIssueLimiter } = require("../middlewares/rateLimiter");

// GET /api/issues/ai/status - Check AI service status (must be before /:id route)
router.get("/ai/status", getAIServiceStatus);

// POST /api/issues - Create a new issue (requires authentication)
router.post("/", authenticate, createIssueLimiter, upload.single("image"), createIssue);

// GET /api/issues - Get all issues (optional auth for enhanced features)
router.get("/", optionalAuth, getIssues);

// GET /api/issues/:id - Get issue by ID (optional auth for enhanced info)
router.get("/:id", optionalAuth, getIssueById);

module.exports = router;