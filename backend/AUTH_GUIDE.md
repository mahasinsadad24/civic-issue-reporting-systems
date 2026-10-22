# 🔐 JWT Authentication & Role-Based Access Control Guide

## Overview

This document explains how JWT (JSON Web Token) authentication and role-based access control work in the Civic Issue Reporting System.

## 🔑 What is JWT?

JWT (JSON Web Token) is a secure way to transmit information between parties as a JSON object. In our system:

- **Stateless**: No server-side session storage needed
- **Secure**: Digitally signed using a secret key
- **Self-contained**: Contains user information and permissions
- **Portable**: Works across different domains and services

### JWT Structure
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2OTUxMGU1NGE3ZGNjMmNiOGIxMDQ5NmUiLCJyb2xlIjoidXNlciIsImlhdCI6MTc2NjkxOTc3NSwiZXhwIjoxNzY3NTI0NTc1fQ.YxbONruAjow38aI61GoAhjVdcp2GfP-EOzqSext9om4

[Header].[Payload].[Signature]
```

**Payload contains:**
- `userId`: User's database ID
- `role`: User's role (user/admin)  
- `iat`: Token issued at timestamp
- `exp`: Token expiration timestamp

## 🚪 Authentication Flow

### 1. User Registration
```bash
POST /api/auth/register
{
  "name": "John Doe",
  "email": "john@example.com", 
  "password": "password123",
  "role": "user" # Optional, defaults to "user"
}
```

**Process:**
1. Validate input data
2. Check if email already exists
3. Hash password using bcrypt (salt rounds: 12)
4. Save user to database
5. Generate JWT token
6. Return user info + token

### 2. User Login
```bash
POST /api/auth/login
{
  "email": "john@example.com",
  "password": "password123"
}
```

**Process:**
1. Find user by email
2. Compare provided password with hashed password
3. Generate new JWT token if valid
4. Return user info + token

### 3. Protected Route Access
```bash
GET /api/auth/me
Authorization: Bearer <JWT_TOKEN>
```

**Process:**
1. Extract token from Authorization header
2. Verify token signature using JWT_SECRET
3. Check token expiration
4. Fetch user from database using userId from token
5. Attach user info to `req.user`
6. Continue to route handler

## 🛡️ Role-Based Access Control

### User Roles
- **`user`**: Regular users who can report issues
- **`admin`**: Administrators who can manage all issues

### Permission Matrix

| Endpoint | Public | User | Admin |
|----------|--------|------|-------|
| `POST /api/auth/register` | ✅ | ✅ | ✅ |
| `POST /api/auth/login` | ✅ | ✅ | ✅ |
| `GET /api/auth/me` | ❌ | ✅ | ✅ |
| `POST /api/issues` | ❌ | ✅ | ✅ |
| `GET /api/issues` | ✅* | ✅** | ✅** |
| `GET /api/admin/stats` | ❌ | ❌ | ✅ |
| `PATCH /api/admin/issues/:id/status` | ❌ | ❌ | ✅ |

*Public: Limited info
**Authenticated: Enhanced info + user-specific features

## 🔧 Implementation Details

### Password Security
- **Hashing**: bcryptjs with salt rounds: 12
- **Pre-save middleware**: Automatic hashing on user creation/update
- **No plaintext**: Passwords never stored in plaintext
- **Comparison**: Secure comparison using bcrypt.compare()

### Token Security
- **Secret Key**: Stored in environment variable `JWT_SECRET`
- **Expiration**: 7 days by default (configurable via `JWT_EXPIRE`)
- **Validation**: Signature verification on every request
- **Automatic Refresh**: Not implemented (tokens expire and require re-login)

### Database Security
- **Password Field**: `select: false` by default (excluded from queries)
- **Unique Email**: Database-level unique constraint
- **Indexes**: Optimized queries for email lookups
- **Soft Delete**: `isActive` field for deactivating users

## 📚 API Examples

### Complete Authentication Workflow

#### 1. Register User
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123"
  }'
```

**Response:**
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "user": {
      "_id": "69510e54a7dcc2cb8b10496e",
      "name": "John Doe", 
      "email": "john@example.com",
      "role": "user",
      "isActive": true,
      "createdAt": "2025-12-28T11:02:44.660Z",
      "updatedAt": "2025-12-28T11:02:44.660Z"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

#### 2. Login User
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'
```

#### 3. Create Issue (Authenticated)
```bash
curl -X POST http://localhost:3000/api/issues \
  -H "Authorization: Bearer <JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "description": "Large pothole needs repair",
    "category": "pothole",
    "lat": 40.7128,
    "lng": -74.0060
  }'
```

#### 4. Get User Profile
```bash
curl -H "Authorization: Bearer <JWT_TOKEN>" \
  http://localhost:3000/api/auth/me
```

### Admin Operations

#### 1. Register Admin
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Admin User",
    "email": "admin@example.com", 
    "password": "admin123",
    "role": "admin"
  }'
```

#### 2. Admin Dashboard Stats
```bash
curl -H "Authorization: Bearer <ADMIN_JWT_TOKEN>" \
  http://localhost:3000/api/admin/stats
```

**Response:**
```json
{
  "success": true,
  "data": {
    "totals": {
      "issues": 4,
      "users": 2
    },
    "issuesByStatus": {
      "submitted": 3,
      "in-progress": 1
    },
    "issuesByCategory": {
      "pothole": 2,
      "streetlight": 1,
      "other": 1
    },
    "recentIssues": [...]
  }
}
```

#### 3. Update Issue Status
```bash
curl -X PATCH http://localhost:3000/api/admin/issues/<ISSUE_ID>/status \
  -H "Authorization: Bearer <ADMIN_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "in-progress",
    "adminNotes": "Scheduled for repair next week"
  }'
```

## ⚠️ Error Handling

### Authentication Errors
```json
// Missing token
{
  "success": false,
  "message": "Access denied. No token provided."
}

// Invalid token
{
  "success": false,
  "message": "Access denied. Invalid token."
}

// Expired token
{
  "success": false,
  "message": "Access denied. Token expired."
}
```

### Authorization Errors
```json
// Insufficient permissions
{
  "success": false,
  "message": "Access denied. Required role: admin. Your role: user"
}
```

### Validation Errors
```json
// Registration validation
{
  "success": false,
  "message": "Please provide a valid email address"
}

// Login validation  
{
  "success": false,
  "message": "Invalid email or password"
}
```

## 🔒 Security Best Practices

### Environment Variables
```bash
# .env file
JWT_SECRET=your_super_secret_jwt_key_change_in_production_123456789
JWT_EXPIRE=7d
```

### Token Usage
- **Storage**: Store tokens securely (not in localStorage for web apps)
- **Headers**: Always use Authorization header: `Bearer <token>`
- **HTTPS**: Use HTTPS in production to prevent token interception
- **Expiration**: Tokens expire after 7 days, require re-authentication

### Password Requirements
- **Minimum length**: 6 characters (configurable)
- **Hashing**: bcrypt with salt rounds 12
- **No storage**: Plaintext passwords never stored

## 🚀 Testing Authentication

Use the provided test script:
```bash
chmod +x test_auth.sh
./test_auth.sh
```

Or test manually with cURL commands above.

## 🔮 Future Enhancements

- **Refresh Tokens**: Automatic token renewal
- **OAuth Integration**: Google/GitHub login
- **Rate Limiting**: Prevent brute force attacks  
- **2FA**: Two-factor authentication
- **Password Reset**: Email-based password reset
- **Session Management**: Active session tracking

This authentication system provides a secure, scalable foundation for user management and access control! 🛡️
