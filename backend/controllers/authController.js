const User = require("../models/User");
const { generateToken } = require("../utils/jwt");
const notificationService = require("../services/notificationService");

// @desc    Register a new user
// @route   POST /api/auth/register
// @access  Public
const register = async (req, res) => {
  try {
    const { name, email, password, role } = req.body;

    // Basic validation
    if (!name || !email || !password) {
      return res.status(400).json({
        success: false,
        message: "Please provide name, email, and password"
      });
    }

    // Check if user already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: "User already exists with this email"
      });
    }

    // Create user (password will be hashed by pre-save middleware)
    const userData = {
      name: name.trim(),
      email: email.toLowerCase().trim(),
      password
    };

    // Only allow admin role if explicitly set (for initial setup)
    if (role && role === "admin") {
      userData.role = "admin";
    }

    const user = await User.create(userData);

    // Generate JWT token
    const token = generateToken({
      userId: user._id,
      role: user.role
    });

    // 🔔 SEND WELCOME NOTIFICATION
    // Send welcome notification to new user (async, non-blocking)
    if (user.role === 'user') { // Only send to regular users, not admins
      notificationService.sendWelcomeNotification(user._id)
        .then(() => {
          console.log(`✓ Welcome notification sent to new user: ${user.name} (${user.email})`);
        })
        .catch(error => {
          console.error('Welcome notification failed (registration succeeded):', error.message);
        });
    }

    res.status(201).json({
      success: true,
      message: "User registered successfully",
      data: {
        user: user.toJSON(),
        token
      }
    });

  } catch (error) {
    console.error("Registration error:", error);
    
    // Handle mongoose validation errors
    if (error.name === "ValidationError") {
      const messages = Object.values(error.errors).map(err => err.message);
      return res.status(400).json({
        success: false,
        message: messages.join(". ")
      });
    }

    // Handle duplicate key error
    if (error.code === 11000) {
      return res.status(400).json({
        success: false,
        message: "User already exists with this email"
      });
    }

    res.status(500).json({
      success: false,
      message: "Server error during registration"
    });
  }
};

// @desc    Login user
// @route   POST /api/auth/login
// @access  Public
const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Basic validation
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: "Please provide email and password"
      });
    }

    // Find user and check credentials
    const user = await User.findByCredentials(email.toLowerCase().trim(), password);

    // Generate JWT token
    const token = generateToken({
      userId: user._id,
      role: user.role
    });

    res.json({
      success: true,
      message: "Login successful",
      data: {
        user: user.toJSON(),
        token
      }
    });

  } catch (error) {
    console.error("Login error:", error.message);
    
    res.status(401).json({
      success: false,
      message: "Invalid email or password"
    });
  }
};

// @desc    Get current user profile
// @route   GET /api/auth/me
// @access  Private
const getMe = async (req, res) => {
  try {
    // User is attached to req by auth middleware
    res.json({
      success: true,
      data: {
        user: req.user.toJSON()
      }
    });
  } catch (error) {
    console.error("Get profile error:", error);
    res.status(500).json({
      success: false,
      message: "Server error while fetching profile"
    });
  }
};

// @desc    Update user profile
// @route   PATCH /api/auth/profile
// @access  Private
const updateProfile = async (req, res) => {
  try {
    const { name } = req.body;
    const allowedUpdates = ["name"];
    const updates = {};

    // Filter allowed updates
    Object.keys(req.body).forEach(key => {
      if (allowedUpdates.includes(key) && req.body[key]) {
        updates[key] = req.body[key];
      }
    });

    if (Object.keys(updates).length === 0) {
      return res.status(400).json({
        success: false,
        message: "No valid updates provided"
      });
    }

    const user = await User.findByIdAndUpdate(
      req.user._id,
      updates,
      { new: true, runValidators: true }
    );

    res.json({
      success: true,
      message: "Profile updated successfully",
      data: {
        user: user.toJSON()
      }
    });

  } catch (error) {
    console.error("Update profile error:", error);
    
    if (error.name === "ValidationError") {
      const messages = Object.values(error.errors).map(err => err.message);
      return res.status(400).json({
        success: false,
        message: messages.join(". ")
      });
    }

    res.status(500).json({
      success: false,
      message: "Server error while updating profile"
    });
  }
};

module.exports = {
  register,
  login,
  getMe,
  updateProfile
};
