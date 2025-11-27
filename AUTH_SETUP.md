# Authentication Setup Guide

This guide explains how to set up and use the authentication features in the Food Donation App.

## Features

- ✅ Email/Password Sign In
- ✅ Email/Password Sign Up
- ✅ Google Sign In/Sign Up
- ✅ JWT Token Authentication
- ✅ Persistent Authentication State
- ✅ Backend API Integration

## Backend Setup

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Configure Environment Variables

Create a `.env` file in the `backend` directory:

```env
# MongoDB Atlas Connection
MONGODB_URI=your_mongodb_atlas_connection_string

# JWT Secret (generate a strong random string)
JWT_SECRET=your_super_secret_jwt_key_here

# Google OAuth Credentials
GOOGLE_CLIENT_ID=your_google_client_id_here

# Server Configuration
PORT=5000
NODE_ENV=development

# Frontend URL (for CORS)
FRONTEND_URL=http://localhost:3000
```

### 3. Start the Backend Server

```bash
npm run dev
```

The server will run on `http://localhost:5000` by default.

## Flutter Setup

### 1. Install Dependencies

The following packages have been added to `pubspec.yaml`:
- `http: ^1.1.0` - For API calls
- `google_sign_in: ^6.1.5` - For Google authentication
- `shared_preferences: ^2.2.2` - For storing auth tokens

Run:
```bash
flutter pub get
```

### 2. Configure API Base URL

The API base URL is automatically configured based on the platform:
- **Android Emulator**: `http://10.0.2.2:5000/api`
- **iOS Simulator**: `http://localhost:5000/api`
- **Physical Device**: Update `lib/core/constants/api_constants.dart` with your computer's IP address

To use a custom URL, set the environment variable:
```bash
flutter run --dart-define=API_BASE_URL=http://your-ip:5000/api
```

### 3. Configure Google Sign-In

#### For Android:

1. Get your Google OAuth Client ID from [Google Cloud Console](https://console.cloud.google.com/)
2. Add the client ID to `android/app/build.gradle.kts` or create `android/app/src/main/res/values/strings.xml`:

```xml
<resources>
    <string name="default_web_client_id">YOUR_GOOGLE_CLIENT_ID</string>
</resources>
```

#### For iOS:

1. Add your Google Client ID to `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

2. Configure Google Sign-In in your Xcode project settings.

### 4. Run the App

```bash
flutter run
```

## Using Authentication

### Sign In / Sign Up Buttons

The sign-in and sign-up buttons are now available in the AppBar on all screens. Click them to:
- Navigate to the Sign In screen
- Navigate to the Sign Up screen

### Sign In Screen Features

- Email/Password authentication
- Google Sign-In button
- Form validation
- Error handling
- Link to Sign Up screen

### Sign Up Screen Features

- Email/Password registration
- Password confirmation
- Google Sign-Up button
- Form validation
- Error handling
- Link to Sign In screen

## API Endpoints

The backend exposes the following endpoints:

- `POST /api/auth/signin` - Email/Password sign in
- `POST /api/auth/signup` - Email/Password sign up
- `POST /api/auth/google` - Google OAuth sign in/sign up
- `GET /api/auth/me` - Get current user (requires auth token)
- `GET /api/auth/verify` - Verify auth token (requires auth token)

## Authentication Flow

1. User signs in/up through the Flutter app
2. Backend validates credentials and returns JWT token + user data
3. Token is stored securely in SharedPreferences
4. Token is automatically included in subsequent API requests
5. App state is managed using Riverpod providers

## Troubleshooting

### Connection Issues

- **Android Emulator**: Make sure backend is running and use `http://10.0.2.2:5000`
- **iOS Simulator**: Use `http://localhost:5000`
- **Physical Device**: Use your computer's IP address (e.g., `http://192.168.1.100:5000`)

### Google Sign-In Issues

- Ensure Google Client ID is configured correctly
- Check that OAuth consent screen is set up in Google Cloud Console
- Verify that the client ID matches in both Flutter app and backend

### Backend Connection Errors

- Check that the backend server is running
- Verify CORS settings in `backend/server.js`
- Check MongoDB connection string is correct
- Ensure all environment variables are set

## Security Notes

- Never commit `.env` files to version control
- Use strong JWT secrets in production
- Enable HTTPS in production
- Validate all user inputs on the backend
- Store tokens securely (currently using SharedPreferences)

## Next Steps

- [ ] Add password reset functionality
- [ ] Add email verification
- [ ] Implement token refresh mechanism
- [ ] Add biometric authentication
- [ ] Enhance error handling and user feedback

