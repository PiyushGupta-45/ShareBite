# 🔧 Fix: Google Sign-In Timeout Issue

## The Problem

You're getting timeout when trying to sign in with Google:
```
Request timeout: Backend server is not responding. 
Please check if the server is running at http://10.0.2.2:5000/api/auth/google
```

## ✅ What I Just Fixed

I've added:
1. **Better logging** - Backend now logs each step of the Google auth process
2. **Timeout handling** - Added timeouts for Google token verification and database queries
3. **Error tracking** - See exactly where it's getting stuck

## 🔍 How to Debug

### Step 1: Check Backend Console

When you try Google Sign-In, **watch the backend terminal**. You should see:

```
📥 Google Auth Request received
🔍 Verifying Google token...
✅ Google token verified successfully
👤 Looking up user with email: user@example.com
✅ User found (or 📝 New user, creating account...)
```

**If you see errors:**
- Token verification timeout → Google API issue
- Database query timeout → MongoDB connection issue
- No logs at all → Request not reaching backend

### Step 2: Common Issues & Fixes

#### Issue 1: No Logs Appearing
**Problem:** Request not reaching backend

**Check:**
- ✅ Backend is running (`npm run dev`)
- ✅ Backend shows "Server running on port 5000"
- ✅ Test: `http://localhost:5000/health` works in browser

**Fix:** Restart backend server

#### Issue 2: "Google token verification timeout"
**Problem:** Google API taking too long

**Possible causes:**
- Slow internet connection
- Google API servers slow
- Invalid Google Client ID

**Fix:**
- Check internet connection
- Verify GOOGLE_CLIENT_ID in backend/.env matches Android strings.xml
- Wait a few minutes and try again

#### Issue 3: "Database query timeout"
**Problem:** MongoDB connection slow

**Check backend console for:**
- "✅ MongoDB Connected: ..." message at startup
- Any MongoDB errors

**Fix:**
- Check MongoDB URI in backend/.env
- Verify MongoDB cluster is accessible
- Check internet connection (MongoDB Atlas requires internet)

#### Issue 4: Request Never Reaches Backend
**Problem:** Network connectivity issue

**Fix:**
- For Android Emulator: Make sure backend is on localhost:5000
- For Physical Device: Use your computer's IP address, not localhost

## 🚀 Quick Test Steps

1. **Start Backend** (if not running):
   ```bash
   cd backend
   npm run dev
   ```

2. **Watch Backend Console** - Keep it visible

3. **Try Google Sign-In** in Flutter app

4. **Check Backend Console** for logs:
   - See which step it reaches
   - See where it stops/fails

5. **Share the logs** - The console will show exactly what's happening!

## 📋 What the Logs Tell You

| Log Message | Meaning |
|------------|---------|
| `📥 Google Auth Request received` | ✅ Request reached backend |
| `🔍 Verifying Google token...` | ⏳ Verifying with Google API |
| `✅ Google token verified successfully` | ✅ Token is valid |
| `👤 Looking up user...` | ⏳ Checking database |
| `✅ User found` | ✅ User exists, signing in |
| `📝 New user, creating account...` | ✅ New user, signing up |

**If logs stop at any step:** That's where the timeout is happening!

## 🎯 Most Likely Causes

1. **MongoDB connection slow** (most common)
   - Check MongoDB Atlas connection
   - Verify network is fast enough

2. **Google API verification slow**
   - Usually fast, but can be slow sometimes
   - Check internet connection

3. **Backend not responding**
   - Backend crashed or stopped
   - Restart backend server

## ✅ Next Steps

1. **Restart backend** (fresh start)
2. **Try Google Sign-In again**
3. **Watch backend console logs**
4. **Share the logs** - they'll tell us exactly what's wrong!

The new logging will help us pinpoint the exact issue! 🔍

