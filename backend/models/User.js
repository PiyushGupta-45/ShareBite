import mongoose from 'mongoose';

const userSchema = new mongoose.Schema(
  {
    googleId: {
      type: String,
      unique: true,
      sparse: true, // Allows null values but ensures uniqueness when present
    },
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },
    name: {
      type: String,
      required: true,
      trim: true,
    },
    picture: {
      type: String,
      default: '',
    },
    isEmailVerified: {
      type: Boolean,
      default: false,
    },
    password: {
      type: String,
      select: false, // Don't include password in queries by default
    },
    authProvider: {
      type: String,
      enum: ['google', 'email'],
      default: 'google',
    },
    role: {
      type: String,
      enum: ['user', 'admin', 'restaurant', 'ngo_admin'],
      default: 'user',
    },
  },
  {
    timestamps: true,
  }
);

// Note: email and googleId already have indexes via 'unique: true' in schema
// Additional indexes are only needed if you want compound indexes or different types

const User = mongoose.model('User', userSchema);

export default User;

