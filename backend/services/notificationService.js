const Notification = require("../models/Notification");
const Issue = require("../models/Issue");
const User = require("../models/User");

/**
 * Notification Service - Handles all notification operations
 * 
 * This service provides a clean abstraction for:
 * - Creating notifications
 * - Triggering status-based notifications
 * - Managing notification delivery
 * - Future integration hooks for push notifications
 */
class NotificationService {

  /**
   * Create a new notification
   */
  async createNotification({
    userId,
    issueId = null,
    title,
    message,
    type,
    priority = 'normal',
    metadata = {}
  }) {
    try {
      const notification = new Notification({
        userId,
        issueId,
        title,
        message,
        type,
        priority,
        metadata,
        // Set readAt timestamp manually when needed
        isRead: false,
        readAt: null
      });

      await notification.save();
      
      // TODO: Hook for push notification delivery
      // await this.sendPushNotification(notification);
      
      return notification;
    } catch (error) {
      console.error('Error creating notification:', error);
      throw new Error('Failed to create notification');
    }
  }

  /**
   * Send issue status update notification
   */
  async notifyIssueStatusUpdate(issueId, oldStatus, newStatus, updatedBy) {
    try {
      const issue = await Issue.findById(issueId)
        .populate('createdBy', 'name email')
        .populate('lastUpdatedBy', 'name');

      if (!issue || !issue.createdBy) {
        console.warn(`Issue ${issueId} or creator not found for notification`);
        return null;
      }

      // Don't notify if the user updated their own issue
      if (issue.createdBy._id.toString() === updatedBy.toString()) {
        return null;
      }

      const statusMessages = {
        'submitted': 'has been received and is under review',
        'in-progress': 'is now being worked on by our team', 
        'resolved': 'has been resolved! Thank you for reporting it',
        'rejected': 'has been reviewed and marked as not actionable'
      };

      const title = this.generateNotificationTitle(newStatus, issue);
      const message = `Your reported issue "${this.truncateText(issue.description, 50)}" ${statusMessages[newStatus] || 'status has been updated'}.`;

      // Determine notification type
      let notificationType = 'ISSUE_STATUS_UPDATE';
      if (newStatus === 'resolved') {
        notificationType = 'ISSUE_RESOLVED';
      } else if (newStatus === 'rejected') {
        notificationType = 'ISSUE_REJECTED';
      }

      const notification = await this.createNotification({
        userId: issue.createdBy._id,
        issueId: issue._id,
        title,
        message,
        type: notificationType,
        priority: newStatus === 'resolved' ? 'high' : 'normal',
        metadata: {
          oldStatus,
          newStatus,
          updatedBy: updatedBy.toString(),
          issueCategory: issue.category,
          location: issue.location
        }
      });

      console.log(`Notification sent to user ${issue.createdBy.name} for issue ${issueId} status change: ${oldStatus} → ${newStatus}`);
      
      return notification;
    } catch (error) {
      console.error('Error sending status update notification:', error);
      throw error;
    }
  }

  /**
   * Send admin comment notification  
   */
  async notifyAdminComment(issueId, adminNotes, adminUser) {
    try {
      const issue = await Issue.findById(issueId)
        .populate('createdBy', 'name email');

      if (!issue || !issue.createdBy || !adminNotes) {
        return null;
      }

      // Don't notify if the admin is the issue creator
      if (issue.createdBy._id.toString() === adminUser._id.toString()) {
        return null;
      }

      const title = "Update on your reported issue";
      const message = `Admin added a comment on your issue "${this.truncateText(issue.description, 50)}": ${this.truncateText(adminNotes, 100)}`;

      return await this.createNotification({
        userId: issue.createdBy._id,
        issueId: issue._id,
        title,
        message,
        type: 'ADMIN_COMMENT',
        priority: 'normal',
        metadata: {
          adminId: adminUser._id.toString(),
          adminName: adminUser.name,
          comment: adminNotes
        }
      });
    } catch (error) {
      console.error('Error sending admin comment notification:', error);
      throw error;
    }
  }

  /**
   * Send welcome notification to new users
   */
  async sendWelcomeNotification(userId) {
    try {
      const user = await User.findById(userId);
      if (!user) return null;

      const title = `Welcome to Civic Issues, ${user.name}!`;
      const message = "Thank you for joining our community. You can now report civic issues and track their progress. Help make your city better!";

      return await this.createNotification({
        userId: user._id,
        title,
        message,
        type: 'WELCOME',
        priority: 'normal',
        metadata: {
          registrationDate: user.createdAt
        }
      });
    } catch (error) {
      console.error('Error sending welcome notification:', error);
      throw error;
    }
  }

  /**
   * Get notifications for a user with filtering and pagination
   */
  async getUserNotifications(userId, options = {}) {
    try {
      const {
        page = 1,
        limit = 20,
        type = null,
        isRead = null,
        includeDeleted = false
      } = options;

      const filter = { 
        userId,
        isDeleted: includeDeleted ? { $in: [true, false] } : false
      };
      
      if (type) filter.type = type;
      if (isRead !== null) filter.isRead = isRead;

      const skip = (page - 1) * limit;

      const [notifications, totalCount, unreadCount] = await Promise.all([
        Notification.find(filter)
          .populate('issueId', 'description category status location')
          .sort({ createdAt: -1 })
          .limit(parseInt(limit))
          .skip(skip),
        Notification.countDocuments(filter),
        Notification.getUnreadCount(userId)
      ]);

      return {
        notifications,
        pagination: {
          currentPage: parseInt(page),
          totalPages: Math.ceil(totalCount / limit),
          totalCount,
          limit: parseInt(limit),
          hasNextPage: page < Math.ceil(totalCount / limit),
          hasPrevPage: page > 1
        },
        unreadCount
      };
    } catch (error) {
      console.error('Error getting user notifications:', error);
      throw error;
    }
  }

  /**
   * Mark notification as read
   */
  async markAsRead(notificationId, userId) {
    try {
      const notification = await Notification.findOne({
        _id: notificationId,
        userId
      });

      if (!notification) {
        throw new Error('Notification not found or access denied');
      }

      return await notification.markAsRead();
    } catch (error) {
      console.error('Error marking notification as read:', error);
      throw error;
    }
  }

  /**
   * Mark all notifications as read for user
   */
  async markAllAsRead(userId) {
    try {
      const result = await Notification.markAllAsRead(userId);
      return {
        modifiedCount: result.modifiedCount,
        message: `${result.modifiedCount} notifications marked as read`
      };
    } catch (error) {
      console.error('Error marking all notifications as read:', error);
      throw error;
    }
  }

  /**
   * Get notification statistics for a user
   */
  async getUserNotificationStats(userId) {
    try {
      const stats = await Notification.aggregate([
        { $match: { userId: new require('mongoose').Types.ObjectId(userId), isDeleted: false } },
        {
          $group: {
            _id: null,
            total: { $sum: 1 },
            unread: { $sum: { $cond: [{ $eq: ["$isRead", false] }, 1, 0] } },
            byType: {
              $push: {
                type: "$type",
                isRead: "$isRead"
              }
            }
          }
        }
      ]);

      if (stats.length === 0) {
        return { total: 0, unread: 0, byType: {} };
      }

      // Process type statistics  
      const typeStats = {};
      stats[0].byType.forEach(item => {
        if (!typeStats[item.type]) {
          typeStats[item.type] = { total: 0, unread: 0 };
        }
        typeStats[item.type].total++;
        if (!item.isRead) {
          typeStats[item.type].unread++;
        }
      });

      return {
        total: stats[0].total,
        unread: stats[0].unread,
        byType: typeStats
      };
    } catch (error) {
      console.error('Error getting notification stats:', error);
      throw error;
    }
  }

  /**
   * Bulk delete old read notifications (maintenance)
   */
  async cleanupOldNotifications(daysOld = 90) {
    try {
      const result = await Notification.cleanOldNotifications(daysOld);
      console.log(`Cleaned up ${result.deletedCount} old notifications`);
      return result;
    } catch (error) {
      console.error('Error cleaning up notifications:', error);
      throw error;
    }
  }

  // ========================================
  // HELPER METHODS
  // ========================================

  /**
   * Generate appropriate notification title based on status
   */
  generateNotificationTitle(status, issue) {
    const categoryNames = {
      'pothole': 'Pothole',
      'streetlight': 'Streetlight', 
      'garbage': 'Garbage',
      'water': 'Water Issue',
      'traffic': 'Traffic Issue',
      'other': 'Issue'
    };

    const statusTitles = {
      'submitted': 'Issue Received',
      'in-progress': 'Issue In Progress',
      'resolved': 'Issue Resolved ✓', 
      'rejected': 'Issue Update'
    };

    const categoryName = categoryNames[issue.category] || 'Issue';
    const statusTitle = statusTitles[status] || 'Issue Updated';
    
    return `${statusTitle}: ${categoryName}`;
  }

  /**
   * Truncate text for notifications
   */
  truncateText(text, maxLength) {
    if (!text) return '';
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength).trim() + '...';
  }

  // ========================================
  // FUTURE INTEGRATION HOOKS
  // ========================================

  /**
   * TODO: Firebase Cloud Messaging integration
   * This method will be implemented when push notifications are needed
   */
  async sendPushNotification(notification) {
    // TODO: Implement FCM push notification
    // 
    // const fcm = require('./fcm-service');
    // const user = await User.findById(notification.userId);
    // 
    // if (user.fcmToken) {
    //   await fcm.send({
    //     token: user.fcmToken,
    //     title: notification.title,
    //     body: notification.message,
    //     data: {
    //       notificationId: notification._id.toString(),
    //       type: notification.type,
    //       issueId: notification.issueId?.toString()
    //     }
    //   });
    // }
    
    console.log(`[TODO] Push notification would be sent: ${notification.title}`);
  }

  /**
   * TODO: MQTT-based push notification integration
   * Alternative to FCM for self-hosted solutions
   */
  async sendMQTTNotification(notification) {
    // TODO: Implement MQTT push notification
    //
    // const mqtt = require('./mqtt-service'); 
    // await mqtt.publish(`user/${notification.userId}/notifications`, {
    //   id: notification._id,
    //   title: notification.title,
    //   message: notification.message,
    //   type: notification.type,
    //   timestamp: notification.createdAt
    // });
    
    console.log(`[TODO] MQTT notification would be published: ${notification.title}`);
  }

  /**
   * TODO: Email notification fallback
   * For important notifications when push is not available
   */
  async sendEmailNotification(notification) {
    // TODO: Implement email notification
    //
    // const emailService = require('./email-service');
    // const user = await User.findById(notification.userId);
    //
    // if (user.email && notification.priority === 'high') {
    //   await emailService.send({
    //     to: user.email,
    //     subject: notification.title,
    //     body: notification.message
    //   });
    // }
    
    console.log(`[TODO] Email notification would be sent: ${notification.title}`);
  }
}

module.exports = new NotificationService();
