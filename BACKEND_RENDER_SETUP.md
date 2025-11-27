# Backend Render Deployment - Troubleshooting Guide

## ✅ Current Configuration

Your Flutter app is configured to use:
- **Render URL**: `https://sharebite-hst4.onrender.com`
- **API Base URL**: `https://sharebite-hst4.onrender.com/api`
- **Google Auth Endpoint**: `https://sharebite-hst4.onrender.com/api/auth/google`

## 🔍 Testing Your Render Backend

### Step 1: Test Root Endpoint
Open in browser: `https://sharebite-hst4.onrender.com`

**Expected Response:**
```json
{
  "success": true,
  "message": "Food Donation App API is running",
  "version": "1.0.0"
}
```

### Step 2: Test Health Endpoint
Open in browser: `https://sharebite-hst4.onrender.com/health`

**Expected Response:**
```json
{
  "success": true,
  "message": "Server is healthy",
  "timestamp": "..."
}
```

### Step 3: Test API Test Endpoint
Open in browser: `https://sharebite-hst4.onrender.com/api/test`

**Expected Response:**
```json
{
  "success": true,
  "message": "Backend is reachable!",
  "timestamp": "..."
}
```

### Step 4: Test Google Auth Endpoint (POST)
Use Postman or curl:
```bash
curl -X POST https://sharebite-hst4.onrender.com/api/auth/google \
  -H "Content-Type: application/json" \
  -d '{"tokenId":"test"}'
```

**Expected Responses:**
- ✅ **400/401**: Route exists (bad request is OK, means route is found)
- ❌ **404**: Route not found (backend not configured correctly)

## 🚨 Common Issues & Fixes

### Issue 1: Route Not Found (404)

**Possible Causes:**
1. Backend not deployed correctly on Render
2. Routes not mounted under `/api`
3. Backend service is sleeping (Render free tier)

**Solutions:**
1. **Check Render Dashboard:**
   - Go to https://dashboard.render.com
   - Check if your service is "Live" (not "Sleeping")
   - Check logs for errors

2. **Verify Backend Routes:**
   - Make sure `server.js` has: `app.use('/api/auth', authRoutes);`
   - Routes should be accessible at `/api/auth/google`

3. **Check Render Environment Variables:**
   - MONGODB_URI
   - JWT_SECRET
   - GOOGLE_CLIENT_ID
   - PORT (usually auto-set by Render)

4. **Wake Up Sleeping Service:**
   - Render free tier services sleep after 15 minutes of inactivity
   - First request after sleep takes 30-60 seconds
   - Consider upgrading or using a keep-alive service

### Issue 2: CORS Errors

**Solution:**
Your backend already allows all origins in development. Make sure CORS is configured in `server.js`:
```javascript
app.use(cors({
  origin: function (origin, callback) {
    callback(null, true); // Allow all in development
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));
```

### Issue 3: Backend Returns 500 Error

**Check:**
1. MongoDB connection string is correct
2. Google Client ID is set correctly
3. JWT Secret is set
4. Check Render logs for specific errors

## 📝 Quick Checklist

- [ ] Backend service is "Live" on Render (not sleeping)
- [ ] Root endpoint works: `https://sharebite-hst4.onrender.com`
- [ ] Health endpoint works: `https://sharebite-hst4.onrender.com/health`
- [ ] API test endpoint works: `https://sharebite-hst4.onrender.com/api/test`
- [ ] Google auth endpoint exists (returns 400/401, not 404)
- [ ] All environment variables are set in Render
- [ ] MongoDB connection is working
- [ ] CORS is configured correctly

## 🔧 If Route Still Not Found

1. **Check Render Logs:**
   - Go to Render dashboard → Your service → Logs
   - Look for startup errors or route registration issues

2. **Verify Build Command:**
   - Render should run: `npm install` then `npm start` or `npm run dev`
   - Check `package.json` scripts

3. **Test Locally First:**
   - Set `useProductionBackend = false` in `api_constants.dart`
   - Test with local backend
   - If local works, issue is with Render deployment

4. **Check Render Service Type:**
   - Should be "Web Service" (not Static Site)
   - Port should be set automatically or via PORT env var

