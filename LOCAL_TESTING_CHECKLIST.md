# ✅ Local Testing Checklist - Fix Before Deploying

**IMPORTANT:** Always fix and test everything locally before deploying! Deploying broken code won't solve errors - it will just move them to production.

## 🔍 Step-by-Step Local Verification

### 1. ✅ Check Backend Server Status

**Start your backend:**
```bash
cd backend
npm run dev
```

**You should see (WITHOUT errors/warnings):**
```
✅ Environment variables loaded successfully
📡 CORS: Allowing all origins (development mode)
🔑 Google Client ID: ✅ Set
✅ MongoDB Connected: ac-gllouau-shard-00-01.mgpn6zl.mon...
Server running in development mode on port 5000
```

**If you see errors:**
- ❌ Missing environment variables → Fix `.env` file
- ❌ MongoDB connection failed → Fix MongoDB URI
- ❌ Any warnings → They should be fixed now, restart server

### 2. ✅ Test Backend API Endpoints

**Open your browser and test:**

1. **Health Check:**
   ```
   http://localhost:5000/health
   ```
   Should return: `{"success": true, "message": "Server is healthy", ...}`

2. **API Root:**
   ```
   http://localhost:5000/
   ```
   Should return: `{"success": true, "message": "Food Donation App API is running", ...}`

### 3. ✅ Test Email/Password Authentication (Easiest First)

**From your Flutter app:**
1. Click "Sign Up"
2. Fill in:
   - Name: Test User
   - Email: test@example.com
   - Password: test123 (at least 6 characters)
3. Click "Sign Up"

**Expected Result:**
- ✅ Success message
- ✅ User is signed in
- ✅ Backend console shows successful sign up

**If it fails:**
- Check backend console for error messages
- Check Flutter console for API errors
- Verify MongoDB connection is working

### 4. ✅ Test Google Sign-In (After Email/Password Works)

**Prerequisites:**
- ✅ Email/password authentication works
- ✅ SHA-1 fingerprint added to Google Cloud Console
- ✅ Google Client ID in both places (Android + Backend)

**Test Steps:**
1. Click "Sign in with Google"
2. Select Google account
3. Should sign in successfully

**If it fails:**
- Check error message in Flutter app
- Check backend console for detailed error
- Verify Google Client ID matches in both places

### 5. ✅ Verify All Environment Variables

**Check `backend/.env` has:**
```env
MONGODB_URI=your_mongodb_uri_here
JWT_SECRET=your_jwt_secret_here
GOOGLE_CLIENT_ID=999767491672-t7mbdvp91k5lbsjkclk7hrpqcm5sfep6.apps.googleusercontent.com
PORT=5000
NODE_ENV=development
```

### 6. ✅ Check Flutter App Configuration

**Verify API URL matches your setup:**
- **Android Emulator:** `http://10.0.2.2:5000/api`
- **Physical Device:** `http://YOUR_COMPUTER_IP:5000/api`

**Check `lib/core/constants/api_constants.dart`**

## 🚨 Common Issues to Fix Before Deploying

### Issue 1: Backend won't start
**Fix:** Check all required env vars are in `.env` file

### Issue 2: MongoDB connection fails
**Fix:** Verify MongoDB URI and network access

### Issue 3: Authentication doesn't work
**Fix:** 
- Test email/password first (simpler)
- Then fix Google Sign-In configuration

### Issue 4: CORS errors
**Fix:** Already fixed! Backend allows all origins in dev mode

### Issue 5: Google Sign-In fails
**Fix:**
- Add SHA-1 to Google Cloud Console
- Match Client IDs in Android and Backend

## ✅ Ready to Deploy When:

- [ ] Backend starts without errors/warnings
- [ ] Health check endpoint works
- [ ] Email/password sign-up works
- [ ] Email/password sign-in works
- [ ] Google Sign-In works (if using)
- [ ] All environment variables are set
- [ ] MongoDB connection is stable
- [ ] No console errors or warnings

## 📋 Next Steps After Local Testing Works

Once everything works locally:

1. **Choose a hosting platform:**
   - Heroku (easiest for beginners)
   - Railway
   - Render
   - AWS/GCP/Azure (more complex)

2. **Set environment variables on hosting platform**

3. **Deploy backend code**

4. **Update Flutter app API URL** to point to deployed backend

But first - **FIX AND TEST LOCALLY!** 🎯

