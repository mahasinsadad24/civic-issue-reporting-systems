const mongoose = require("mongoose");

const NotificationSchema = new mongoose.Schema({
  // Recipient user
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
    index: true // Index for efficient user queries
  },
  
  // Related issue (optional for system notifications)
  issueId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Issue",
    index: true // Index for issue-related queries
  },
  
  // Notification content
  title: {
    type: String,
    required: [true, "Notification title is required"],
    trim: true,
    maxlength: [100, "Title cannot exceed 100 characters"]
  },
  
  message: {
    type: String,
    required: [true, "Notification message is required"],
    trim: true,
    maxlength: [500, "Message cannot exceed 500 characters"]
  },
  
  // Notification type for categorization
  type: {
    type: String,
    enum: [
      "ISSUE_STATUS_UPDATE",
      "ISSUE_RESOLVED", 
      "ISSUE_REJECTED",
      "ADMIN_COMMENT",
      "SYSTEM_ANNOUNCEMENT",
      "WELCOME"
    ],
    required: true,
    index: true // Index for filtering by type
  },
  
  // Read status
  isRead: {
    type: Boolean,
    default: false,
    index: true // Index for filtering read/unread
  },
  
  // Read timestamp
  readAt: {
    type: Date,
    default: null
  },
  
  // Priority level (for future sorting/filtering)
  priority: {
    type: String,
    enum: ["low", "normal", "high", "urgent"],
    default: "normal"
  },
  
  // Additional metadata for extensibility
  metadata: {
    type: mongoose.Schema.Types.Mixed,
    default: {}
  },
  
  // Soft delete flag (for data retention)
  isDeleted: {
    type: Boolean,
    default: false,
    index: true
  }
}, {
  timestamps: true
});

// Compound indexes for efficient queries
NotificationSchema.index({ userId: 1, isRead: 1, createdAt: -1 });
NotificationSchema.index({ userId: 1, type: 1, createdAt: -1 });
NotificationSchema.index({ issueId: 1, createdAt: -1 });

// Instance method to mark as read
NotificationSchema.methods.markAsRead = function() {
  this.isRead = true;
  this.readAt = new Date();
  return this.save();
};

// Static method to mark multiple notifications as read
NotificationSchema.statics.markAllAsRead = function(userId) {
  return this.updateMany(
    { userId, isRead: false },
    { 
      isRead: true, 
      readAt: new Date() 
    }
  );
};

// Static method to get unread count for user
NotificationSchema.statics.getUnreadCount = function(userId) {
  return this.countDocuments({ userId, isRead: false, isDeleted: false });
};

// Static method to clean old notifications (for maintenance)
NotificationSchema.statics.cleanOldNotifications = function(daysOld = 90) {
  const cutoffDate = new Date();
  cutoffDate.setDate(cutoffDate.getDate() - daysOld);
  
  return this.deleteMany({
    createdAt: { $lt: cutoffDate },
    isRead: true
  });
};

// Virtual for notification age
NotificationSchema.virtual('age').get(function() {
  const now = new Date();
  const diff = now - this.createdAt;
  const hours = Math.floor(diff / (1000 * 60 * 60));
  
  if (hours < 1) {
    return 'Just now';
  } else if (hours < 24) {
    return `${hours}h ago`;
  } else {
    const days = Math.floor(hours / 24);
    return `${days}d ago`;
  }
});

// Ensure virtual fields are serialized
NotificationSchema.set('toJSON', { virtuals: true });

module.exports = mongoose.model("Notification", NotificationSchema);
