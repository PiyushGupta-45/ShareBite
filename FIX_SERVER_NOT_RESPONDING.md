# 🔧 Fix: Server Running But Not Responding

## ✅ Good News

Your backend server IS running on port 5000! ✅

But it's not responding to requests. Here's how to fix it:

## 🔍 Step 1: Test Backend Directly

Test if your backend responds:

```bash
curl http://localhost:5000/health
```

**Expected:** JSON response like `{"success": true, ...}`

**If this fails:**
- Backend might be stuck or crashed
- Restart the backend server

## 🔄 Step 2: Restart Backend Server

**If backend is not responding:**

1. **Stop the current backend:**
   - Go to the terminal where backend is running
   - Press `Ctrl+C` to stop it

2. **Start it again:**
   ```bash
   cd backend
   npm run dev
   ```

3. **Wait for:**
   ```
   ✅ Environment variables loaded successfully
   📡 CORS: Allowing all origins (development mode)
   🔑 Google Client ID: ✅ Set
   ✅ MongoDB Connected: ...
   Server running in development mode on port 5000
   ```

## 🧪 Step 3: Test Backend Endpoints

Once backend is running, test these in your browser:

1. **Health Check:**
   - URL: `http://localhost:5000/health`
   - Should return: `{"success": true, "message": "Server is healthy"}`

2. **API Root:**
   - URL: `http://localhost:5000/`
   - Should return: `{"success": true, "message": "Food Donation App API is running"}`

3. **Test Signup Endpoint (POST):**
   - Use Postman or curl to test
   - URL: `http://localhost:5000/api/auth/signup`
   - Method: POST
   - Body: `{"name": "Test", "email": "test@test.com", "password": "test123"}`

## 🚨 If Backend Still Doesn't Respond

### Check 1: MongoDB Connection
Backend might be stuck waiting for MongoDB connection.

**Look for in backend console:**
- "MongoDB Connected: ..." ✅ Good
- "Error: ..." ❌ Bad - fix MongoDB connection

### Check 2: Environment Variables
**Look for in backend console:**
- "✅ Environment variables loaded successfully" ✅ Good
- "❌ Missing required environment variables" ❌ Bad - fix .env file

### Check 3: Port Conflict
**Check if something else is using port 5000:**
```bash
netstat -ano | findstr :5000
```

If you see multiple entries, another process might be using the port.

## 🔧 Quick Restart Steps

1. **Stop backend** (Ctrl+C in backend terminal)

2. **Check .env file exists:**
   ```bash
   dir backend\.env
   ```

3. **Start backend again:**
   ```bash
   cd backend
   npm run dev
   ```

4. **Wait for all startup messages:**
   - Environment variables loaded ✅
   - CORS configured ✅
   - MongoDB connected ✅
   - Server running ✅

5. **Test in browser:**
   - `http://localhost:5000/health`

6. **Then try Flutter app again**

## ✅ Success Indicators

Your backend is working correctly when:

- ✅ Browser shows JSON response at `http://localhost:5000/health`
- ✅ Backend console shows "Server running on port 5000"
- ✅ No errors in backend console
- ✅ MongoDB connection successful

Once all these are ✅, your Flutter app should connect successfully!

## 🎯 Right Now: Do This

1. **Restart your backend server**
2. **Wait for all startup messages**
3. **Test in browser:** `http://localhost:5000/health`
4. **If browser works, try Flutter app again**

The server is listening, but might need a restart to work properly!

