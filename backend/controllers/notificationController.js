const notificationService = require("../services/notificationService");

/**
 * Notification Controller - Handles HTTP requests for notification management
 */

// @desc    Get user notifications with filtering and pagination
// @route   GET /api/notifications
// @access  Private (User must be authenticated)
const getUserNotifications = async (req, res) => {
  try {
    const userId = req.user._id;
    const {
      page = 1,
      limit = 20,
      type,
      isRead,
      includeDeleted = false
    } = req.query;

    // Parse boolean values from query string
    const options = {
      page: parseInt(page),
      limit: Math.min(parseInt(limit), 50), // Max 50 per page for performance
      includeDeleted: includeDeleted === 'true'
    };

    if (type) options.type = type;
    if (isRead !== undefined) options.isRead = isRead === 'true';

    const result = await notificationService.getUserNotifications(userId, options);

    res.json({
      success: true,
      data: {
        ...result,
        filters: {
          type: type || 'all',
          isRead: isRead || 'all',
          includeDeleted
        }
      }
    });

  } catch (error) {
    console.error("Get notifications error:", error);
    res.status(500).json({
      success: false,
      message: "Server error while fetching notifications",
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// @desc    Mark notification as read
// @route   PATCH /api/notifications/:id/read
// @access  Private (User must own the notification)
const markNotificationAsRead = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user._id;

    const notification = await notificationService.markAsRead(id, userId);

    res.json({
      success: true,
      message: "Notification marked as read",
      data: {
        notification
      }
    });

  } catch (error) {
    console.error("Mark notification read error:", error);
    
    if (error.message === 'Notification not found or access denied') {
      return res.status(404).json({
        success: false,
        message: error.message
      });
    }

    res.status(500).json({
      success: false,
      message: "Server error while updating notification",
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// @desc    Mark all notifications as read
// @route   PATCH /api/notifications/read-all
// @access  Private (User's own notifications)
const markAllNotificationsAsRead = async (req, res) => {
  try {
    const userId = req.user._id;
    
    const result = await notificationService.markAllAsRead(userId);

    res.json({
      success: true,
      message: result.message,
      data: {
        modifiedCount: result.modifiedCount
      }
    });

  } catch (error) {
    console.error("Mark all notifications read error:", error);
    res.status(500).json({
      success: false,
      message: "Server error while updating notifications",
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// @desc    Get notification statistics for user
// @route   GET /api/notifications/stats
// @access  Private
const getNotificationStats = async (req, res) => {
  try {
    const userId = req.user._id;
    
    const stats = await notificationService.getUserNotificationStats(userId);

    res.json({
      success: true,
      data: {
        stats,
        summary: {
          unreadPercentage: stats.total > 0 ? Math.round((stats.unread / stats.total) * 100) : 0,
          readCount: stats.total - stats.unread
        }
      }
    });

  } catch (error) {
    console.error("Get notification stats error:", error);
    res.status(500).json({
      success: false,
      message: "Server error while fetching notification statistics",
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// @desc    Get notification by ID (for detailed view)
// @route   GET /api/notifications/:id
// @access  Private (User must own the notification)
const getNotificationById = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user._id;

    const Notification = require("../models/Notification");
    
    const notification = await Notification.findOne({ 
      _id: id, 
      userId 
    })
    .populate('issueId', 'description category status location createdAt')
    .populate('userId', 'name email');

    if (!notification) {
      return res.status(404).json({
        success: false,
        message: "Notification not found or access denied"
      });
    }

    // Auto-mark as read when viewed (optional behavior)
    if (!notification.isRead) {
      await notification.markAsRead();
    }

    res.json({
      success: true,
      data: {
        notification
      }
    });

  } catch (error) {
    console.error("Get notification by ID error:", error);
    
    if (error.name === "CastError") {
      return res.status(400).json({
        success: false,
        message: "Invalid notification ID"
      });
    }

    res.status(500).json({
      success: false,
      message: "Server error while fetching notification",
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// @desc    Delete notification (soft delete)
// @route   DELETE /api/notifications/:id
// @access  Private (User must own the notification)
const deleteNotification = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user._id;

    const Notification = require("../models/Notification");
    
    const notification = await Notification.findOneAndUpdate(
      { _id: id, userId },
      { isDeleted: true },
      { new: true }
    );

    if (!notification) {
      return res.status(404).json({
        success: false,
        message: "Notification not found or access denied"
      });
    }

    res.json({
      success: true,
      message: "Notification deleted successfully",
      data: {
        deletedId: id
      }
    });

  } catch (error) {
    console.error("Delete notification error:", error);
    
    if (error.name === "CastError") {
      return res.status(400).json({
        success: false,
        message: "Invalid notification ID"
      });
    }

    res.status(500).json({
      success: false,
      message: "Server error while deleting notification",
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// @desc    Get unread notification count (for badges)
// @route   GET /api/notifications/unread-count
// @access  Private
const getUnreadCount = async (req, res) => {
  try {
    const userId = req.user._id;
    const Notification = require("../models/Notification");
    
    const count = await Notification.getUnreadCount(userId);

    res.json({
      success: true,
      data: {
        unreadCount: count
      }
    });

  } catch (error) {
    console.error("Get unread count error:", error);
    res.status(500).json({
      success: false,
      message: "Server error while getting unread count",
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

module.exports = {
  getUserNotifications,
  markNotificationAsRead,
  markAllNotificationsAsRead,
  getNotificationStats,
  getNotificationById,
  deleteNotification,
  getUnreadCount
};
