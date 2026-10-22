const rateLimit = require('express-rate-limit');

/**
 * Rate Limiting Configuration
 * Protects against brute force attacks and API abuse
 */

// General API rate limiter - 100 requests per 15 minutes
const apiLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // Limit each IP to 100 requests per windowMs
    message: {
        success: false,
        message: 'Too many requests from this IP, please try again later.'
    },
    standardHeaders: true, // Return rate limit info in the `RateLimit-*` headers
    legacyHeaders: false, // Disable the `X-RateLimit-*` headers
});

// Strict limiter for authentication endpoints - 5 requests per 15 minutes
const authLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 5, // Limit each IP to 5 login/register attempts per windowMs
    message: {
        success: false,
        message: 'Too many authentication attempts from this IP, please try again after 15 minutes.'
    },
    standardHeaders: true,
    legacyHeaders: false,
    skipSuccessfulRequests: false, // Count all requests
});

// Moderate limiter for issue creation - 20 requests per 15 minutes
const createIssueLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 20, // Limit each IP to 20 issue creations per windowMs
    message: {
        success: false,
        message: 'Too many issue submissions from this IP, please try again later.'
    },
    standardHeaders: true,
    legacyHeaders: false,
});

// Admin operations limiter - 50 requests per 15 minutes
const adminLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 50,
    message: {
        success: false,
        message: 'Too many admin requests, please slow down.'
    },
    standardHeaders: true,
    legacyHeaders: false,
});

module.exports = {
    apiLimiter,
    authLimiter,
    createIssueLimiter,
    adminLimiter
};
