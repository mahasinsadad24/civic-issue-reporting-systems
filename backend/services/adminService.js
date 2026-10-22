const Issue = require("../models/Issue");
const User = require("../models/User");
const notificationService = require("./notificationService");

/**
 * Admin Service - Contains business logic for admin operations
 */
class AdminService {
  
  /**
   * Get filtered and paginated issues for admin dashboard
   */
  async getIssuesWithFilters(filters = {}, pagination = {}, sorting = {}) {
    const mongoFilter = this.buildMongoFilter(filters);
    
    const {
      page = 1,
      limit = 20
    } = pagination;

    const {
      sortBy = "createdAt",
      sortOrder = "desc"
    } = sorting;

    // Calculate pagination
    const skip = (page - 1) * limit;
    const sortObj = {};
    sortObj[sortBy] = sortOrder === "desc" ? -1 : 1;

    // Execute queries in parallel
    const [issues, totalCount] = await Promise.all([
      Issue.find(mongoFilter)
        .populate("createdBy", "name email")
        .populate("lastUpdatedBy", "name email")
        .sort(sortObj)
        .limit(parseInt(limit))
        .skip(skip),
      Issue.countDocuments(mongoFilter)
    ]);

    return {
      issues,
      pagination: {
        currentPage: parseInt(page),
        totalPages: Math.ceil(totalCount / limit),
        totalCount,
        limit: parseInt(limit),
        hasNextPage: page < Math.ceil(totalCount / limit),
        hasPrevPage: page > 1
      }
    };
  }

  /**
   * Build MongoDB filter object from query parameters
   */
  buildMongoFilter(filters) {
    const {
      status,
      category,
      aiCategory,
      dateFrom,
      dateTo,
      search,
      createdBy
    } = filters;

    const mongoFilter = {};
    
    // Status filter
    if (status) {
      if (Array.isArray(status)) {
        mongoFilter.status = { $in: status };
      } else {
        mongoFilter.status = status;
      }
    }
    
    // Category filters (both user-selected and AI-predicted)
    if (category) {
      if (Array.isArray(category)) {
        mongoFilter.category = { $in: category };
      } else {
        mongoFilter.category = category;
      }
    }
    
    if (aiCategory) {
      if (Array.isArray(aiCategory)) {
        mongoFilter.aiCategory = { $in: aiCategory };
      } else {
        mongoFilter.aiCategory = aiCategory;
      }
    }
    
    // Date range filter
    if (dateFrom || dateTo) {
      mongoFilter.createdAt = {};
      if (dateFrom) mongoFilter.createdAt.$gte = new Date(dateFrom);
      if (dateTo) mongoFilter.createdAt.$lte = new Date(dateTo);
    }
    
    // Text search in description or speechText
    if (search) {
      mongoFilter.$or = [
        { description: { $regex: search, $options: 'i' } },
        { speechText: { $regex: search, $options: 'i' } }
      ];
    }
    
    // Filter by user
    if (createdBy) {
      mongoFilter.createdBy = createdBy;
    }

    return mongoFilter;
  }

  /**
   * Get detailed issue by ID with full relationship data
   */
  async getIssueDetails(issueId) {
    const issue = await Issue.findById(issueId)
      .populate("createdBy", "name email createdAt")
      .populate("lastUpdatedBy", "name email")
      .populate("statusHistory.updatedBy", "name email");

    return issue;
  }

  /**
   * Update issue status with validation, history tracking, and notifications
   */
  async updateIssueStatus(issueId, newStatus, adminUser, adminNotes = '') {
    const issue = await Issue.findById(issueId);
    
    if (!issue) {
      throw new Error('Issue not found');
    }

    // Store old status for notification
    const oldStatus = issue.status;

    try {
      // Use the model method for status validation and history tracking
      issue.updateStatus(newStatus, adminUser._id, adminNotes);
      
      // Update admin notes if provided
      if (adminNotes) {
        issue.adminNotes = adminNotes;
      }
      
      await issue.save();
      
      // 🔔 TRIGGER NOTIFICATIONS
      // Send status update notification to issue owner
      if (oldStatus !== newStatus) {
        try {
          await notificationService.notifyIssueStatusUpdate(
            issueId, 
            oldStatus, 
            newStatus, 
            adminUser._id
          );
          console.log(`✓ Status notification sent for issue ${issueId}: ${oldStatus} → ${newStatus}`);
        } catch (notificationError) {
          // Log but don't fail the status update if notification fails
          console.error('Notification failed (status update succeeded):', notificationError.message);
        }
      }

      // Send admin comment notification if notes provided
      if (adminNotes && adminNotes.trim()) {
        try {
          await notificationService.notifyAdminComment(issueId, adminNotes, adminUser);
          console.log(`✓ Admin comment notification sent for issue ${issueId}`);
        } catch (notificationError) {
          // Log but don't fail the status update if notification fails
          console.error('Notification failed (admin comment):', notificationError.message);
        }
      }
      
      // Return populated issue
      return await this.getIssueDetails(issueId);
    } catch (error) {
      throw new Error(`Status update failed: ${error.message}`);
    }
  }

  /**
   * Get comprehensive admin dashboard metrics
   */
  async getDashboardMetrics() {
    const [
      totalIssues,
      activeUsers,
      issuesByStatus,
      issuesByCategory,
      issuesByAiCategory,
      recentIssues,
      issuesLast7Days,
      avgResolutionTime
    ] = await Promise.all([
      // Total issues count
      Issue.countDocuments(),
      
      // Active users count
      User.countDocuments({ isActive: true }),
      
      // Issues grouped by status
      Issue.aggregate([
        { $group: { _id: "$status", count: { $sum: 1 } } }
      ]),
      
      // Issues grouped by user-selected category
      Issue.aggregate([
        { $group: { _id: "$category", count: { $sum: 1 } } }
      ]),
      
      // Issues grouped by AI-predicted category
      Issue.aggregate([
        { $group: { _id: "$aiCategory", count: { $sum: 1 } } }
      ]),
      
      // Recent issues
      Issue.find()
        .populate("createdBy", "name")
        .sort({ createdAt: -1 })
        .limit(10),
      
      // Issues per day (last 7 days)
      this.getIssuesPerDay(7),
      
      // Average resolution time
      this.getAverageResolutionTime()
    ]);

    return {
      totals: {
        issues: totalIssues,
        activeUsers
      },
      issuesByStatus: this.aggregationToObject(issuesByStatus),
      issuesByCategory: this.aggregationToObject(issuesByCategory),
      issuesByAiCategory: this.aggregationToObject(issuesByAiCategory),
      recentIssues,
      issuesLast7Days,
      avgResolutionTime,
      statusDistribution: this.calculateStatusDistribution(issuesByStatus, totalIssues)
    };
  }

  /**
   * Get issues count per day for the last N days
   */
  async getIssuesPerDay(days = 7) {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    const result = await Issue.aggregate([
      {
        $match: {
          createdAt: { $gte: startDate }
        }
      },
      {
        $group: {
          _id: {
            year: { $year: "$createdAt" },
            month: { $month: "$createdAt" },
            day: { $dayOfMonth: "$createdAt" }
          },
          count: { $sum: 1 }
        }
      },
      {
        $sort: { "_id.year": 1, "_id.month": 1, "_id.day": 1 }
      }
    ]);

    // Format the result to include dates with zero counts
    const dateMap = new Map();
    for (let i = 0; i < days; i++) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      const key = `${date.getFullYear()}-${date.getMonth() + 1}-${date.getDate()}`;
      dateMap.set(key, {
        date: date.toISOString().split('T')[0],
        count: 0
      });
    }

    // Fill in actual counts
    result.forEach(item => {
      const key = `${item._id.year}-${item._id.month}-${item._id.day}`;
      if (dateMap.has(key)) {
        dateMap.get(key).count = item.count;
      }
    });

    return Array.from(dateMap.values()).reverse();
  }

  /**
   * Calculate average resolution time for resolved issues
   */
  async getAverageResolutionTime() {
    const result = await Issue.aggregate([
      {
        $match: { status: "resolved" }
      },
      {
        $project: {
          resolutionTime: {
            $subtract: ["$lastUpdatedAt", "$createdAt"]
          }
        }
      },
      {
        $group: {
          _id: null,
          avgTime: { $avg: "$resolutionTime" },
          count: { $sum: 1 }
        }
      }
    ]);

    if (result.length === 0) {
      return { avgTimeMs: 0, avgTimeDays: 0, resolvedCount: 0 };
    }

    const avgTimeMs = result[0].avgTime;
    const avgTimeDays = avgTimeMs / (1000 * 60 * 60 * 24); // Convert to days

    return {
      avgTimeMs: Math.round(avgTimeMs),
      avgTimeDays: Math.round(avgTimeDays * 100) / 100,
      resolvedCount: result[0].count
    };
  }

  /**
   * Helper: Convert MongoDB aggregation result to object
   */
  aggregationToObject(aggregationResult) {
    return aggregationResult.reduce((acc, item) => {
      acc[item._id] = item.count;
      return acc;
    }, {});
  }

  /**
   * Helper: Calculate status distribution percentages
   */
  calculateStatusDistribution(statusData, totalIssues) {
    const distribution = {};
    statusData.forEach(item => {
      distribution[item._id] = {
        count: item.count,
        percentage: totalIssues > 0 ? Math.round((item.count / totalIssues) * 100) : 0
      };
    });
    return distribution;
  }

  /**
   * Bulk update multiple issues (for batch operations)
   */
  async bulkUpdateIssues(issueIds, updates, adminUser) {
    const validIds = issueIds.filter(id => id.match(/^[0-9a-fA-F]{24}$/));
    
    if (validIds.length === 0) {
      throw new Error('No valid issue IDs provided');
    }

    const results = {
      successful: [],
      failed: []
    };

    // Process updates sequentially to maintain status history
    for (const issueId of validIds) {
      try {
        if (updates.status) {
          const updatedIssue = await this.updateIssueStatus(
            issueId, 
            updates.status, 
            adminUser, 
            updates.adminNotes || ''
          );
          results.successful.push(updatedIssue);
        } else {
          // Handle other bulk updates
          const issue = await Issue.findByIdAndUpdate(
            issueId,
            { 
              ...updates, 
              lastUpdatedAt: new Date(),
              lastUpdatedBy: adminUser._id 
            },
            { new: true, runValidators: true }
          );
          results.successful.push(issue);
        }
      } catch (error) {
        results.failed.push({
          issueId,
          error: error.message
        });
      }
    }

    return results;
  }
}

module.exports = new AdminService();
