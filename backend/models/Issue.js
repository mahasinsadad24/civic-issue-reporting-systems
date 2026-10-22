const mongoose = require("mongoose");

const IssueSchema = new mongoose.Schema({
  description: {
    type: String,
    required: [true, "Please provide a description"],
    trim: true,
    maxlength: [500, "Description cannot exceed 500 characters"]
  },
  speechText: {
    type: String,
    trim: true,
    maxlength: [500, "Speech text cannot exceed 500 characters"]
  },
  category: {
    type: String,
    enum: ["pothole", "streetlight", "garbage", "water", "traffic", "other"],
    default: "other"
  },
  location: {
    type: {
      type: String,
      enum: ["Point"],
      default: "Point",
      required: true
    },
    coordinates: {
      type: [Number],
      required: [true, "Please provide coordinates"],
      validate: {
        validator: function (coords) {
          return coords.length === 2 &&
            coords[0] >= -180 && coords[0] <= 180 && // longitude
            coords[1] >= -90 && coords[1] <= 90;    // latitude
        },
        message: "Invalid coordinates format"
      }
    }
  },
  status: {
    type: String,
    enum: ["submitted", "in-progress", "resolved", "rejected"],
    default: "submitted"
  },
  // Status history for tracking changes
  statusHistory: [{
    status: {
      type: String,
      enum: ["submitted", "in-progress", "resolved", "rejected"],
      required: true
    },
    timestamp: {
      type: Date,
      default: Date.now
    },
    updatedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User"
    },
    notes: {
      type: String,
      trim: true,
      maxlength: [500, "Status notes cannot exceed 500 characters"]
    }
  }],
  imageUrl: {
    type: String,
    trim: true
  },
  // AI Classification fields
  aiCategory: {
    type: String,
    enum: ["pothole", "streetlight", "garbage", "water", "traffic", "unknown"],
    default: "unknown"
  },
  aiConfidence: {
    type: Number,
    min: 0,
    max: 1,
    default: 0
  },
  // User submission metadata
  submissionMethod: {
    type: String,
    enum: ["text", "speech", "mixed"],
    default: "text"
  },
  // 🆕 User who created this issue
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true
  },
  // Admin notes (optional)
  adminNotes: {
    type: String,
    trim: true,
    maxlength: [1000, "Admin notes cannot exceed 1000 characters"]
  },
  // Last updated metadata
  lastUpdatedAt: {
    type: Date,
    default: Date.now
  },
  lastUpdatedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User"
  }
}, {
  timestamps: true
});

// Create 2dsphere index for geospatial queries
IssueSchema.index({ location: "2dsphere" });

// Index for efficient queries
IssueSchema.index({ status: 1 });
IssueSchema.index({ createdBy: 1 });
IssueSchema.index({ category: 1 });
IssueSchema.index({ aiCategory: 1 });
IssueSchema.index({ createdAt: -1 });
IssueSchema.index({ lastUpdatedAt: -1 });

// Method to update status with history tracking
IssueSchema.methods.updateStatus = function (newStatus, updatedBy, notes = '') {
  // Validate status transition
  const validTransitions = {
    'submitted': ['in-progress', 'rejected'],
    'in-progress': ['resolved', 'rejected', 'submitted'],
    'resolved': ['in-progress'], // Can reopen resolved issues
    'rejected': ['submitted', 'in-progress'] // Can reactivate rejected issues
  };

  if (!validTransitions[this.status]?.includes(newStatus) && this.status !== newStatus) {
    throw new Error(`Invalid status transition from ${this.status} to ${newStatus}`);
  }

  // Update status and add to history
  const oldStatus = this.status;
  this.status = newStatus;
  this.lastUpdatedAt = new Date();
  this.lastUpdatedBy = updatedBy;

  // Add to status history if status actually changed
  if (oldStatus !== newStatus) {
    this.statusHistory.push({
      status: newStatus,
      timestamp: new Date(),
      updatedBy: updatedBy,
      notes: notes
    });
  }

  return this;
};

// Virtual for getting the final description (prioritize speechText if available)
IssueSchema.virtual('finalDescription').get(function () {
  return this.speechText || this.description;
});

// Ensure virtual fields are serialized
IssueSchema.set('toJSON', { virtuals: true });

module.exports = mongoose.model("Issue", IssueSchema);