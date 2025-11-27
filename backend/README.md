# Food Donation App - Backend API

Backend API for the Food Donation App with Google OAuth authentication.

## Features

- Google OAuth Sign In / Sign Up
- JWT Token Authentication
- MongoDB Atlas Integration
- User Management
- Protected Routes

## Setup Instructions

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Environment Variables

Create a `.env` file in the `backend` directory with the following variables:

```env
# MongoDB Atlas Connection
MONGODB_URI=your_mongodb_atlas_connection_string

# JWT Secret
JWT_SECRET=your_jwt_secret_key

# Google OAuth Credentials (Client Secret not required for mobile apps)
GOOGLE_CLIENT_ID=your_google_client_id

# Server Configuration
PORT=5000
NODE_ENV=development

# Frontend URL (for CORS)
FRONTEND_URL=http://localhost:3000
```

### 3. Run the Server

**Development mode (with auto-reload):**
```bash
npm run dev
```

**Production mode:**
```bash
npm start
```

The server will run on `http://localhost:5000` by default.

## API Endpoints

### Authentication

#### POST `/api/auth/google`
Google OAuth sign in/sign up

**Request Body:**
```json
{
  "tokenId": "google_id_token_here"
}
```

**Response (Success):**
```json
{
  "success": true,
  "message": "Sign in successful",
  "data": {
    "token": "jwt_token_here",
    "user": {
      "id": "user_id",
      "email": "user@example.com",
      "name": "User Name",
      "picture": "profile_picture_url",
      "isEmailVerified": true
    }
  }
}
```

#### GET `/api/auth/me`
Get current authenticated user (Protected)

**Headers:**
```
Authorization: Bearer <jwt_token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "user_id",
      "email": "user@example.com",
      "name": "User Name",
      "picture": "profile_picture_url",
      "isEmailVerified": true,
      "authProvider": "google",
      "createdAt": "2024-01-01T00:00:00.000Z"
    }
  }
}
```

#### GET `/api/auth/verify`
Verify JWT token (Protected)

**Headers:**
```
Authorization: Bearer <jwt_token>
```

### Health Check

#### GET `/health`
Check server health status

## Project Structure

```
backend/
├── config/
│   └── database.js          # MongoDB connection
├── controllers/
│   └── authController.js    # Authentication logic
├── middleware/
│   └── auth.js              # JWT authentication middleware
├── models/
│   └── User.js              # User model
├── routes/
│   └── authRoutes.js        # Authentication routes
├── utils/
│   └── generateToken.js     # JWT token generation
├── .env                     # Environment variables (create this)
├── .gitignore
├── package.json
├── server.js                # Main server file
└── README.md
```

## Security Notes

1. Never commit your `.env` file to version control
2. Use strong, random JWT secrets
3. Keep your Google OAuth credentials secure
4. Use HTTPS in production
5. Regularly update dependencies

## Testing

You can test the API using tools like:
- Postman
- cURL
- Thunder Client (VS Code extension)
- Your Flutter app

## Support

For issues or questions, please check the main project README or create an issue.

