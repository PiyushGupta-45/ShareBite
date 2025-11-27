# Backend Environment Variables Setup

## Where to Add Your Google API Key (Client ID)

### Location: `backend/.env`

Create or edit the `.env` file in the `backend` folder and add/update the following:

```env
# MongoDB Atlas Connection
MONGODB_URI=your_mongodb_atlas_connection_string

# JWT Secret (generate a strong random string)
JWT_SECRET=your_super_secret_jwt_key_here

# Google OAuth Credentials - ADD YOUR WEB CLIENT ID HERE
GOOGLE_CLIENT_ID=999767491672-t7mbdvp91k5lbsjkclk7hrpqcm5sfep6.apps.googleusercontent.com

# Server Configuration
PORT=5000
NODE_ENV=development

# Frontend URL (for CORS)
FRONTEND_URL=http://localhost:3000
```

## Important:

1. **Use the SAME Web Client ID** that you added to `android/app/src/main/res/values/strings.xml`
2. **No quotes** around the value
3. **No spaces** around the `=` sign
4. **Restart the backend server** after updating the `.env` file

## Quick Steps:

1. Open or create `backend/.env` file
2. Add this line (or update if it already exists):
   ```
   GOOGLE_CLIENT_ID=999767491672-t7mbdvp91k5lbsjkclk7hrpqcm5sfep6.apps.googleusercontent.com
   ```
3. Save the file
4. Restart your backend server:
   ```bash
   cd backend
   npm run dev
   ```

That's it! 🎉

