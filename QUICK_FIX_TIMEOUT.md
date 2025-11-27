# 🚨 Quick Fix: Backend Server Not Responding

## The Error You're Seeing

```
Request timeout: Backend server is not responding. 
Please check if the server is running at http://10.0.2.2:5000/api/auth/google
```

**This means:** The Flutter app cannot connect to your backend server.

## ✅ Quick Fix Steps

### Step 1: Check if Backend is Running

Open a **new terminal window** and run:

```bash
cd backend
npm run dev
```

**You should see:**
```
✅ Environment variables loaded successfully
📡 CORS: Allowing all origins (development mode)
🔑 Google Client ID: ✅ Set
✅ MongoDB Connected: ...
Server running in development mode on port 5000
```

**If you see errors instead:**
- Check `backend/.env` file has all required variables
- Make sure MongoDB URI is correct

### Step 2: Verify Backend is Accessible

Once the server is running, test it:

**Option A: Open in Browser**
- Go to: `http://localhost:5000/health`
- Should see: `{"success": true, "message": "Server is healthy", ...}`

**Option B: Test from Terminal**
```bash
curl http://localhost:5000/health
```

### Step 3: Keep Backend Running

**IMPORTANT:** The backend server must stay running while you use the app!

- Leave the terminal with `npm run dev` open
- Don't close it or press Ctrl+C
- The server needs to be running for the app to work

### Step 4: Try Again in Flutter App

Once backend is running:
1. Go back to your Flutter app
2. Try signing up again
3. The timeout error should be gone

## 🔍 Common Issues

### Issue 1: Backend Not Started
**Solution:** Run `cd backend && npm run dev` in a terminal

### Issue 2: Backend Stopped Running
**Solution:** 
- Check the terminal where backend is running
- Look for error messages
- Restart: Stop (Ctrl+C) and start again (`npm run dev`)

### Issue 3: Port 5000 Already in Use
**Error:** "Port 5000 is already in use"

**Solution:**
1. Find what's using port 5000: `netstat -ano | findstr :5000`
2. Kill that process or change backend port in `backend/.env`:
   ```
   PORT=5001
   ```
3. Update Flutter API URL to match new port

### Issue 4: MongoDB Connection Failed
**Error in backend console:** "MongoDB connection failed"

**Solution:**
- Check `MONGODB_URI` in `backend/.env` is correct
- Verify MongoDB allows connections from your IP
- Check internet connection

## ✅ Success Checklist

- [ ] Backend terminal shows "Server running on port 5000"
- [ ] Browser can access `http://localhost:5000/health`
- [ ] No errors in backend console
- [ ] Backend terminal stays open (not closed)
- [ ] Try signup/signin again in Flutter app

## 🎯 What to Do Right Now

1. **Open a new terminal/command prompt**
2. **Run:**
   ```bash
   cd backend
   npm run dev
   ```
3. **Wait for:** "Server running in development mode on port 5000"
4. **Keep that terminal open**
5. **Go back to Flutter app and try again**

The error message is working correctly - it's telling you the backend isn't running. Once you start it, everything should work! 🚀

