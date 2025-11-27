# 🔍 Debugging Timeout Issues

## What I've Added

1. **Request Logging** - Backend now logs every incoming request
2. **Response Logging** - Backend logs every response
3. **Step-by-step logging** in Google auth process
4. **Timeout handling** for slow operations

## 🔍 How to Debug

### Step 1: Watch Backend Console

When you try to sign up/sign in, **watch the backend terminal**. You should see logs like:

```
📥 2025-11-25T16:20:00.000Z - POST /api/auth/google
   Body: {"tokenId":"..."}
📥 Google Auth Request received
🔍 Verifying Google token...
✅ Google token verified successfully
👤 Looking up user with email: user@example.com
✅ User found
📤 POST /api/auth/google - Status: 200
```

### Step 2: Check What You See

**If you see NO logs at all:**
- Request is not reaching the backend
- Check network connectivity
- Verify API URL is correct

**If you see logs but they stop at a certain step:**
- That's where it's hanging/timeout
- Check that specific operation (Google API, MongoDB, etc.)

**If you see error logs:**
- Backend will show the exact error
- Fix that specific issue

## 🚨 Common Scenarios

### Scenario 1: No Logs Appear
**Meaning:** Request never reaches backend

**Check:**
- Is backend running? (`npm run dev`)
- Is port 5000 correct?
- For emulator: Using `http://10.0.2.2:5000`?
- For physical device: Using your computer's IP?

### Scenario 2: Logs Stop at "Verifying Google token..."
**Meaning:** Google API is slow or not responding

**Fix:**
- Check internet connection
- Wait and try again
- Verify Google Client ID is correct

### Scenario 3: Logs Stop at "Looking up user..."
**Meaning:** MongoDB connection is slow

**Fix:**
- Check MongoDB connection in backend console
- Verify MongoDB URI is correct
- Check internet connection (for MongoDB Atlas)

### Scenario 4: Request Logs But No Response
**Meaning:** Request is hanging somewhere

**Check:**
- Look at where logs stop
- That's the operation causing timeout

## ✅ Next Steps

1. **Restart backend** (to get fresh logs)
2. **Try signing up/signing in**
3. **Watch backend console carefully**
4. **Share the logs** - they'll show exactly what's happening!

The detailed logging will help us identify the exact issue! 🔍

