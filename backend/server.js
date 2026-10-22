require("dotenv").config();
const express = require("express");
const cors = require("cors");
const path = require("path");
const helmet = require("helmet");
const mongoSanitize = require("express-mongo-sanitize");
const xss = require("xss-clean");
const mongoose = require("mongoose");

// Validate environment variables
const validateEnv = require("./utils/validateEnv");
validateEnv();

const connectDB = require("./config/db");
const storageService = require("./services/storageService");

// Security imports
const { apiLimiter } = require("./middlewares/rateLimiter");

// Route imports
const issueRoutes = require("./routes/issueRoutes");
const authRoutes = require("./routes/authRoutes");
const adminRoutes = require("./routes/adminRoutes");
const notificationRoutes = require("./routes/notificationRoutes");

// Connect to database
connectDB();

const app = express();

// ============================================
// SECURITY MIDDLEWARE
// ============================================

// Set security HTTP headers
// Set security HTTP headers
app.use(helmet({
  contentSecurityPolicy: false,
  crossOriginEmbedderPolicy: false,
  crossOriginResourcePolicy: { policy: "cross-origin" }
}));

// Enable CORS
app.use(cors({
  origin: '*', // Allow all for now, lock down in production
  credentials: true
}));

// Data sanitization against NoSQL query injection
// app.use(mongoSanitize()); // Incompatible with Express 5? Disabling to fix crash.

// Data sanitization against XSS
// app.use(xss()); // Causing TypeError: Cannot set property query

// General API rate limiting
app.use('/api/', apiLimiter);

// ============================================
// BODY PARSING MIDDLEWARE
// ============================================

app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true }));

// ============================================
// STATIC FILES
// ============================================

app.use("/uploads", express.static(path.join(__dirname, "uploads")));

// ============================================
// ROUTES
// ============================================

app.use("/api/issues", issueRoutes);
app.use("/api/auth", authRoutes);
app.use("/api/admin", adminRoutes);
app.use("/api/notifications", notificationRoutes);
app.use("/api/ai", require("./routes/aiRoutes"));
app.use("/api/media", require("./routes/mediaRoutes")); // Media Proxy

// ============================================
// HEALTH CHECK
// ============================================

app.get("/api/health", async (req, res) => {
  // Check MinIO
  const minioStatus = await storageService.checkHealth();

  // Check DB
  const dbStatus = mongoose.connection.readyState === 1;

  const status = minioStatus && dbStatus ? "ok" : "degraded";

  res.json({
    status,
    timestamp: new Date().toISOString(),
    services: {
      backend: "running",
      database: dbStatus ? "connected" : "disconnected",
      storage: minioStatus ? "connected" : "disconnected"
    }
  });
});

app.get("/", (req, res) => {
  res.json({
    message: "Civic Issue Reporting API",
    status: "Running",
    version: "3.3.0 (End-to-End Integrated)"
  });
});

// ============================================
// ERROR HANDLERS
// ============================================

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: "Route not found"
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    success: false,
    message: "Something went wrong!"
  });
});

// ============================================
// SERVER STARTUP
// ============================================

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📡 End-to-End Integration Active (MinIO + MongoDB)`);
});