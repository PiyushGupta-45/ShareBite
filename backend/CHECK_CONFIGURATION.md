# Backend Configuration Check

## ✅ Required Environment Variables

Make sure your `backend/.env` file has all these variables:

```env
# ✅ REQUIRED - MongoDB connection string
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/database

# ✅ REQUIRED - JWT secret for token signing
JWT_SECRET=your_super_secret_jwt_key_at_least_32_characters_long

# ✅ REQUIRED - Google OAuth Web Client ID
GOOGLE_CLIENT_ID=999767491672-t7mbdvp91k5lbsjkclk7hrpqcm5sfep6.apps.googleusercontent.com

# Optional - Server port (default: 5000)
PORT=5000

# Optional - Environment mode
NODE_ENV=development

# Optional - Frontend URL for CORS (not needed for mobile apps)
FRONTEND_URL=http://localhost:3000
```

## 🔍 How to Verify

1. **Check if .env file exists:**
   ```bash
   ls backend/.env
   ```

2. **Start the server and check console:**
   ```bash
   cd backend
   npm run dev
   ```
   
   You should see:
   ```
   ✅ Environment variables loaded successfully
   📡 CORS: Allowing all origins (development mode)
   🔑 Google Client ID: ✅ Set
   MongoDB Connected: ...
   Server running in development mode on port 5000
   ```

3. **If you see errors:**
   - ❌ Missing required environment variables → Check your .env file
   - ❌ MongoDB connection failed → Check MONGODB_URI
   - ❌ Google Client ID: ❌ Missing → Add GOOGLE_CLIENT_ID to .env

## 🚨 Common Issues

### Issue 1: "GOOGLE_CLIENT_ID is not set"
**Solution:** Add this to `backend/.env`:
```
GOOGLE_CLIENT_ID=999767491672-t7mbdvp91k5lbsjkclk7hrpqcm5sfep6.apps.googleusercontent.com
```
Then restart the server.

### Issue 2: CORS errors
**Solution:** The server now allows all origins in development. If you still get CORS errors:
- Make sure the server is running
- Check that the API URL in Flutter matches the server port (default: 5000)

### Issue 3: "Invalid token" errors
**Solution:** 
- Verify the GOOGLE_CLIENT_ID in backend/.env matches the one in Android strings.xml
- Make sure you're using the Web Client ID (not Android Client ID)
- Restart the backend server after changing .env

### Issue 4: MongoDB connection failed
**Solution:**
- Check your MongoDB URI is correct
- Ensure your MongoDB cluster allows connections from your IP
- Verify your MongoDB credentials are correct

## 🔄 After Making Changes

Always restart the backend server after updating `.env`:
```bash
# Stop the server (Ctrl+C)
# Then start again:
cd backend
npm run dev
```

