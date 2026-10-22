const express = require("express");
const router = express.Router();
const { register, login, getMe, updateProfile } = require("../controllers/authController");
const { authenticate } = require("../middlewares/authMiddleware");
const { authLimiter } = require("../middlewares/rateLimiter");

// @route   POST /api/auth/register
// @desc    Register a new user
// @access  Public
router.post("/register", authLimiter, register);

// @route   POST /api/auth/login
// @desc    Login user & get token
// @access  Public
router.post("/login", authLimiter, login);

// @route   GET /api/auth/me
// @desc    Get current user profile
// @access  Private
router.get("/me", authenticate, getMe);

// @route   PATCH /api/auth/profile
// @desc    Update user profile
// @access  Private
router.patch("/profile", authenticate, updateProfile);

module.exports = router;
