# Backend Admin Setup Guide

This guide explains how to add the `role` field to your backend and set users as admin.

## Step 1: Update User Model

Add the `role` field to your User schema in `backend/models/User.js`:

```javascript
const userSchema = new mongoose.Schema(
  {
    googleId: {
      type: String,
      unique: true,
      sparse: true,
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
      select: false,
    },
    authProvider: {
      type: String,
      enum: ['google', 'email'],
      default: 'google',
    },
    // ADD THIS FIELD:
    role: {
      type: String,
      enum: ['user', 'admin'],
      default: 'user',
    },
  },
  {
    timestamps: true,
  }
);
```

## Step 2: Update Auth Controllers

Update all auth controller methods to return the `role` field in the response.

### 2.1 Update `signUp` function

In `backend/controllers/authController.js`, find the `signUp` function and update the response:

```javascript
res.status(201).json({
  success: true,
  message: 'Sign up successful',
  data: {
    token,
    user: {
      id: user._id,
      email: user.email,
      name: user.name,
      picture: user.picture,
      isEmailVerified: user.isEmailVerified,
      authProvider: user.authProvider,
      role: user.role || 'user', // ADD THIS LINE
    },
  },
});
```

### 2.2 Update `signIn` function

Find the `signIn` function and update the response:

```javascript
res.status(200).json({
  success: true,
  message: 'Sign in successful',
  data: {
    token,
    user: {
      id: user._id,
      email: user.email,
      name: user.name,
      picture: user.picture,
      isEmailVerified: user.isEmailVerified,
      authProvider: user.authProvider,
      role: user.role || 'user', // ADD THIS LINE
    },
  },
});
```

### 2.3 Update `googleAuth` function

Find the `googleAuth` function and update both the new user creation and existing user response:

**For new user:**
```javascript
res.status(201).json({
  success: true,
  message: 'Sign up successful',
  data: {
    token,
    user: {
      id: user._id,
      email: user.email,
      name: user.name,
      picture: user.picture,
      isEmailVerified: user.isEmailVerified,
      authProvider: user.authProvider,
      role: user.role || 'user', // ADD THIS LINE
    },
  },
});
```

**For existing user:**
```javascript
res.status(200).json({
  success: true,
  message: 'Sign in successful',
  data: {
    token,
    user: {
      id: user._id,
      email: user.email,
      name: user.name,
      picture: user.picture,
      isEmailVerified: user.isEmailVerified,
      authProvider: user.authProvider,
      role: user.role || 'user', // ADD THIS LINE
    },
  },
});
```

### 2.4 Update `getCurrentUser` function

Find the `getCurrentUser` function and update the response:

```javascript
res.status(200).json({
  success: true,
  data: {
    user: {
      id: user._id,
      email: user.email,
      name: user.name,
      picture: user.picture,
      isEmailVerified: user.isEmailVerified,
      authProvider: user.authProvider,
      role: user.role || 'user', // ADD THIS LINE
      createdAt: user.createdAt,
    },
  },
});
```

## Step 3: Set a User as Admin

You have three options to set a user as admin:

### Option 1: Using MongoDB Compass (Recommended)

1. Open MongoDB Compass
2. Connect to your database
3. Navigate to your database → `users` collection
4. Find the user you want to make admin (search by email: `pgupta3883@gmail.com`)
5. Click on the document to edit it
6. Add a new field:
   - Field name: `role`
   - Field value: `admin`
7. Click "Update" to save

### Option 2: Using MongoDB Shell

Connect to your MongoDB and run:

```javascript
// Update by email
db.users.updateOne(
  { email: "pgupta3883@gmail.com" },
  { $set: { role: "admin" } }
);

// Or update by user ID
db.users.updateOne(
  { _id: ObjectId("6927ffb9b6566083c359bf2e") },
  { $set: { role: "admin" } }
);
```

### Option 3: Using Node.js Script

Create a file `backend/scripts/setAdmin.js`:

```javascript
import mongoose from 'mongoose';
import User from '../models/User.js';
import dotenv from 'dotenv';

dotenv.config();

const setAdmin = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to MongoDB');

    // Update user by email
    const user = await User.findOneAndUpdate(
      { email: 'pgupta3883@gmail.com' }, // Change this to your email
      { $set: { role: 'admin' } },
      { new: true }
    );

    if (user) {
      console.log('User updated to admin:', user);
    } else {
      console.log('User not found');
    }

    await mongoose.disconnect();
    console.log('Disconnected from MongoDB');
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
};

setAdmin();
```

Run it:
```bash
cd backend
node scripts/setAdmin.js
```

## Step 4: Verify

After setting a user as admin:

1. **Sign out** from the Flutter app (if logged in)
2. **Sign in again** with the admin user account
3. Click the **profile icon** (top right)
4. You should see:
   - "Admin" badge instead of "Volunteer"
   - "Admin Tools" section with "Add NGO" and "Add Restaurant" buttons

## Step 5: Update Existing Users (Optional)

If you have existing users in the database, you can add the `role` field to all of them:

```javascript
// In MongoDB shell
db.users.updateMany(
  { role: { $exists: false } },
  { $set: { role: "user" } }
);
```

This sets all users without a role to "user" by default.

## Testing

1. Make sure your backend is running
2. Update a user to admin using one of the methods above
3. Sign in with that user in the Flutter app
4. Check the profile screen - you should see admin features

## Notes

- The `role` field defaults to `'user'` for new users
- Only users with `role: 'admin'` will see admin features in the app
- You can change a user back to regular user by setting `role: 'user'`
- The role is checked on every authentication, so changes take effect immediately after re-login

