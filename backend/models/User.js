const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");

const UserSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, "Please provide a name"],
    trim: true,
    maxlength: [100, "Name cannot exceed 100 characters"]
  },
  email: {
    type: String,
    required: [true, "Please provide an email"],
    unique: true,
    lowercase: true,
    trim: true,
    match: [
      /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/,
      "Please provide a valid email address"
    ]
  },
  password: {
    type: String,
    required: [true, "Please provide a password"],
    minlength: [6, "Password must be at least 6 characters"],
    select: false // Don't return password by default in queries
  },
  role: {
    type: String,
    enum: ["user", "admin"],
    default: "user"
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

// Index for email for faster lookups
// Index for email is handled by unique: true option above

// Pre-save middleware to hash password
UserSchema.pre("save", async function() {
  // Only hash password if it's been modified (or is new)
  if (!this.isModified("password")) return;
  
  // Hash password with cost of 12
  const salt = await bcrypt.genSalt(12);
  this.password = await bcrypt.hash(this.password, salt);
});

// Instance method to check password
UserSchema.methods.matchPassword = async function(enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};

// Static method to find user by email with password field
UserSchema.statics.findByCredentials = async function(email, password) {
  const user = await this.findOne({ email, isActive: true }).select("+password");
  
  if (!user) {
    throw new Error("Invalid email or password");
  }
  
  const isMatch = await user.matchPassword(password);
  if (!isMatch) {
    throw new Error("Invalid email or password");
  }
  
  return user;
};

// Transform output to remove sensitive data
UserSchema.methods.toJSON = function() {
  const userObject = this.toObject();
  delete userObject.password;
  delete userObject.__v;
  return userObject;
};

module.exports = mongoose.model("User", UserSchema);
