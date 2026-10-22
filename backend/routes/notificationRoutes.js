const express = require("express");
const router = express.Router();
const { authenticate } = require("../middlewares/authMiddleware");

const {
  getUserNotifications,
  markNotificationAsRead,
  markAllNotificationsAsRead,
  getNotificationStats,
  getNotificationById,
  deleteNotification,
  getUnreadCount
} = require("../controllers/notificationController");

// Apply authentication to all notification routes
router.use(authenticate);

// @route   GET /api/notifications
// @desc    Get user notifications with filtering and pagination
// @access  Private
router.get("/", getUserNotifications);

// @route   GET /api/notifications/stats
// @desc    Get notification statistics for user
// @access  Private
router.get("/stats", getNotificationStats);

// @route   GET /api/notifications/unread-count
// @desc    Get unread notification count
// @access  Private
router.get("/unread-count", getUnreadCount);

// @route   PATCH /api/notifications/read-all
// @desc    Mark all notifications as read for user
// @access  Private
router.patch("/read-all", markAllNotificationsAsRead);

// @route   GET /api/notifications/:id
// @desc    Get specific notification by ID
// @access  Private (User must own the notification)
router.get("/:id", getNotificationById);

// @route   PATCH /api/notifications/:id/read
// @desc    Mark specific notification as read
// @access  Private (User must own the notification)
router.patch("/:id/read", markNotificationAsRead);

// @route   DELETE /api/notifications/:id
// @desc    Delete notification (soft delete)
// @access  Private (User must own the notification)
router.delete("/:id", deleteNotification);

module.exports = router;
