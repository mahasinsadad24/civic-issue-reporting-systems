const Issue = require("../models/Issue");
const User = require("../models/User");
const adminService = require("../services/adminService");

// @desc    Get all issues for admin dashboard with advanced filtering
// @route   GET /api/admin/issues
// @access  Private (Admin only)
const getAllIssues = async (req, res) => {
  try {
    const { 
      status, 
      category,
      aiCategory,
      dateFrom,
      dateTo,
      search,
      createdBy,
      page = 1, 
      limit = 20,
      sortBy = "createdAt",
      sortOrder = "desc"
    } = req.query;

    // Parse comma-separated values for multiple selections
    const parseArray = (value) => {
      if (!value) return undefined;
      return value.includes(',') ? value.split(',').map(v => v.trim()) : value;
    };

    const filters = {
      status: parseArray(status),
      category: parseArray(category),
      aiCategory: parseArray(aiCategory),
      dateFrom,
      dateTo,
      search,
      createdBy
    };

    const pagination = { page: parseInt(page), limit: parseInt(limit) };
    const sorting = { sortBy, sortOrder };

    const result = await adminService.getIssuesWithFilters(filters, pagination, sorting);

    // Get quick stats for the current filter
    const mongoFilter = adminService.buildMongoFilter(filters);
    const filterStats = await Issue.aggregate([
      { $match: mongoFilter },
      { $group: { _id: "$status", count: { $sum: 1 } } }
    ]).catch(() => []); // Graceful fallback

    res.json({
      success: true,
      data: {
        ...result,
        filterStats: adminService.aggregationToObject(filterStats)
      }
    });

  } catch (error) {
    console.error("Admin get issues error:", error);
    res.status(500).json({
      success: false,
      message: "Server error while fetching issues",
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// @desc    Update issue status with validation and history tracking
// @route   PATCH /api/admin/issues/:id/status
// @access  Private (Admin only)
const updateIssueStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status, adminNotes } = req.body;

    // Validate status
    const validStatuses = ["submitted", "in-progress", "resolved", "rejected"];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        message: `Invalid status. Valid statuses are: ${validStatuses.join(", ")}`
      });
    }

    const updatedIssue = await adminService.updateIssueStatus(
      id, 
      status, 
      req.user, 
      adminNotes || ''
    );

    res.json({
      success: true,
      message: `Issue status updated to ${status}`,
      data: {
        issue: updatedIssue
      }
    });

  } catch (error) {
    console.error("Admin update issue error:", error);
    
    if (error.name === "CastError") {
      return res.status(400).json({
        success: false,
        message: "Invalid issue ID"
      });
    }

    if (error.message === 'Issue not found') {
      return res.status(404).json({
        success: false,
        message: "Issue not found"
      });
    }

    if (error.message.includes('Invalid status transition')) {
      return res.status(400).json({
        success: false,
        message: error.message
      });
    }

    res.status(500).json({
      success: false,
      message: "Server error while updating issue",
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// @desc    Get issue by ID (admin view with full details)
// @route   GET /api/admin/issues/:id
// @access  Private (Admin only)
const getIssueById = async (req, res) => {
  try {
    const issue = await adminService.getIssueDetails(req.params.id);

    if (!issue) {
      return res.status(404).json({
        success: false,
        message: "Issue not found"
      });
    }

    res.json({
      success: true,
      data: {
        issue
      }
    });

  } catch (error) {
    console.error("Admin get issue error:", error);
    
    if (error.name === "CastError") {
      return res.status(400).json({
        success: false,
        message: "Invalid issue ID"
      });
    }

    res.status(500).json({
      success: false,
      message: "Server error while fetching issue"
    });
  }
};

// @desc    Get admin dashboard statistics (enhanced metrics)
// @route   GET /api/admin/metrics
// @access  Private (Admin only)
const getDashboardStats = async (req, res) => {
  try {
    const metrics = await adminService.getDashboardMetrics();

    res.json({
      success: true,
      data: metrics
    });

  } catch (error) {
    console.error("Admin stats error:", error);
    res.status(500).json({
      success: false,
      message: "Server error while fetching statistics",
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// @desc    Bulk update multiple issues
// @route   PATCH /api/admin/issues/bulk
// @access  Private (Admin only)
const bulkUpdateIssues = async (req, res) => {
  try {
    const { issueIds, updates } = req.body;

    if (!issueIds || !Array.isArray(issueIds) || issueIds.length === 0) {
      return res.status(400).json({
        success: false,
        message: "Please provide an array of issue IDs"
      });
    }

    if (!updates || Object.keys(updates).length === 0) {
      return res.status(400).json({
        success: false,
        message: "Please provide updates to apply"
      });
    }

    const result = await adminService.bulkUpdateIssues(issueIds, updates, req.user);

    res.json({
      success: true,
      message: `Bulk update completed: ${result.successful.length} successful, ${result.failed.length} failed`,
      data: {
        successful: result.successful.length,
        failed: result.failed.length,
        results: result
      }
    });

  } catch (error) {
    console.error("Admin bulk update error:", error);
    res.status(500).json({
      success: false,
      message: "Server error during bulk update",
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

module.exports = {
  getAllIssues,
  updateIssueStatus,
  getIssueById,
  getDashboardStats,
  bulkUpdateIssues
};
