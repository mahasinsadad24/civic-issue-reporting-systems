const express = require("express");
const router = express.Router();
const { authenticate, authorize } = require("../middlewares/authMiddleware");
const { adminLimiter } = require("../middlewares/rateLimiter");
const {
  getAllIssues,
  updateIssueStatus,
  getIssueById,
  getDashboardStats,
  bulkUpdateIssues
} = require("../controllers/adminController");

// Apply authentication and admin authorization to all routes
router.use(authenticate);
router.use(authorize("admin"));
router.use(adminLimiter); // Apply rate limiting to admin routes

// @route   GET /api/admin/metrics
// @desc    Get admin dashboard statistics and metrics
// @access  Private (Admin only)
router.get("/metrics", getDashboardStats);

// @route   GET /api/admin/stats
// @desc    Alias for metrics (backward compatibility)
// @access  Private (Admin only)
router.get("/stats", getDashboardStats);

// @route   GET /api/admin/issues
// @desc    Get all issues for admin management (with advanced filtering)
// @access  Private (Admin only)
router.get("/issues", getAllIssues);

// @route   PATCH /api/admin/issues/bulk
// @desc    Bulk update multiple issues
// @access  Private (Admin only)
router.patch("/issues/bulk", bulkUpdateIssues);

// @route   GET /api/admin/issues/:id
// @desc    Get specific issue details for admin
// @access  Private (Admin only)
router.get("/issues/:id", getIssueById);

// @route   PATCH /api/admin/issues/:id/status
// @desc    Update issue status with validation and history
// @access  Private (Admin only)
router.patch("/issues/:id/status", updateIssueStatus);

module.exports = router;
