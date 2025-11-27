import { OAuth2Client } from 'google-auth-library';
import bcrypt from 'bcryptjs';
import User from '../models/User.js';
import { generateToken } from '../utils/generateToken.js';

// Initialize OAuth2Client with only Client ID (Client Secret not needed for ID token verification)
// Note: Server startup validates GOOGLE_CLIENT_ID is set before this module is used
const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

// Google Sign In / Sign Up
export const googleAuth = async (req, res) => {
  try {
    console.log('📥 Google Auth Request received');
    const { tokenId } = req.body;

    if (!tokenId) {
      console.log('❌ No tokenId provided');
      return res.status(400).json({
        success: false,
        message: 'Google token is required',
      });
    }

    // Check if Google Client ID is configured
    if (!process.env.GOOGLE_CLIENT_ID) {
      console.log('❌ GOOGLE_CLIENT_ID not configured');
      return res.status(500).json({
        success: false,
        message: 'Server configuration error: Google Client ID is not configured',
      });
    }

    console.log('🔍 Verifying Google token...');
    // Verify the Google token
    let ticket;
    try {
      ticket = await Promise.race([
        client.verifyIdToken({
          idToken: tokenId,
          audience: process.env.GOOGLE_CLIENT_ID,
        }),
        new Promise((_, reject) =>
          setTimeout(() => reject(new Error('Google token verification timeout after 20 seconds')), 20000)
        ),
      ]);
      console.log('✅ Google token verified successfully');
    } catch (verifyError) {
      console.error('❌ Google token verification failed:', verifyError.message);
      return res.status(401).json({
        success: false,
        message: 'Google token verification failed',
        error: verifyError.message,
      });
    }

    const payload = ticket.getPayload();
    const { sub: googleId, email, name, picture, email_verified } = payload;

    if (!email) {
      console.log('❌ No email in Google token payload');
      return res.status(400).json({
        success: false,
        message: 'Email not provided by Google',
      });
    }

    console.log(`👤 Looking up user with email: ${email}`);
    // Check if user exists
    let user;
    try {
      user = await Promise.race([
        User.findOne({
          $or: [{ email }, { googleId }],
        }),
        new Promise((_, reject) =>
          setTimeout(() => reject(new Error('Database query timeout after 15 seconds')), 15000)
        ),
      ]);
      console.log(user ? '✅ User found' : '📝 New user, creating account...');
    } catch (dbError) {
      console.error('❌ Database query failed:', dbError.message);
      return res.status(500).json({
        success: false,
        message: 'Database connection timeout',
        error: dbError.message,
      });
    }

    if (user) {
      // User exists - sign in
      // Update user info if needed
      user.googleId = googleId;
      user.name = name;
      user.picture = picture || user.picture;
      user.isEmailVerified = email_verified || user.isEmailVerified;
      await user.save();

      const token = generateToken(user._id);

      return res.status(200).json({
        success: true,
        message: 'Sign in successful',
        data: {
          token,
          user: {
            id: user._id,
            email: user.email,
            name: user.name,
            picture: user.picture,
            isEmailVerified: user.isEmailVerified,
            authProvider: user.authProvider,
            role: user.role || 'user',
          },
        },
      });
    } else {
      // New user - sign up
      user = await User.create({
        googleId,
        email,
        name,
        picture: picture || '',
        isEmailVerified: email_verified || false,
        authProvider: 'google',
      });

      const token = generateToken(user._id);

      return res.status(201).json({
        success: true,
        message: 'Sign up successful',
        data: {
          token,
          user: {
            id: user._id,
            email: user.email,
            name: user.name,
            picture: user.picture,
            isEmailVerified: user.isEmailVerified,
            authProvider: user.authProvider,
            role: user.role || 'user',
          },
        },
      });
    }
  } catch (error) {
    console.error('Google Auth Error:', error);
    
    // Provide more specific error messages
    let errorMessage = 'Authentication failed';
    let statusCode = 500;
    
    if (error.message.includes('Invalid token') || error.message.includes('Token expired')) {
      errorMessage = 'Invalid or expired Google token';
      statusCode = 401;
    } else if (error.message.includes('Client ID')) {
      errorMessage = 'Server configuration error: Google Client ID not properly configured';
      statusCode = 500;
    } else if (!process.env.GOOGLE_CLIENT_ID) {
      errorMessage = 'Server configuration error: Google Client ID is missing';
      statusCode = 500;
    }
    
    res.status(statusCode).json({
      success: false,
      message: errorMessage,
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
};

// Get current user
export const getCurrentUser = async (req, res) => {
  try {
    const user = await User.findById(req.user._id).select('-__v');

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    res.status(200).json({
      success: true,
      data: {
        user: {
          id: user._id,
          email: user.email,
          name: user.name,
          picture: user.picture,
          isEmailVerified: user.isEmailVerified,
          authProvider: user.authProvider,
          role: user.role || 'user',
          createdAt: user.createdAt,
        },
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message,
    });
  }
};

// Email/Password Sign Up
export const signUp = async (req, res) => {
  try {
    const { name, email, password } = req.body;

    // Validation
    if (!name || !email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Please provide name, email, and password',
      });
    }

    if (password.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'Password must be at least 6 characters',
      });
    }

    // Check if user already exists
    const existingUser = await User.findOne({ email: email.toLowerCase() });

    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'User already exists with this email',
      });
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Create user
    const user = await User.create({
      name,
      email: email.toLowerCase(),
      password: hashedPassword,
      authProvider: 'email',
      isEmailVerified: false,
    });

    const token = generateToken(user._id);

    res.status(201).json({
      success: true,
      message: 'Sign up successful',
      data: {
        token,
        user: {
          id: user._id,
          email: user.email,
          name: user.name,
          picture: user.picture,
          isEmailVerified: user.isEmailVerified,
          authProvider: user.authProvider,
          role: user.role || 'user',
        },
      },
    });
  } catch (error) {
    console.error('Sign Up Error:', error);
    res.status(500).json({
      success: false,
      message: 'Sign up failed',
      error: error.message,
    });
  }
};

// Email/Password Sign In
export const signIn = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validation
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Please provide email and password',
      });
    }

    // Find user and include password field
    const user = await User.findOne({ email: email.toLowerCase() }).select('+password');

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password',
      });
    }

    // Check if user signed up with email/password
    if (user.authProvider !== 'email' || !user.password) {
      return res.status(401).json({
        success: false,
        message: 'Please sign in with Google or reset your password',
      });
    }

    // Check password
    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password',
      });
    }

    const token = generateToken(user._id);

    res.status(200).json({
      success: true,
      message: 'Sign in successful',
      data: {
        token,
        user: {
          id: user._id,
          email: user.email,
          name: user.name,
          picture: user.picture,
          isEmailVerified: user.isEmailVerified,
          authProvider: user.authProvider,
          role: user.role || 'user',
        },
      },
    });
  } catch (error) {
    console.error('Sign In Error:', error);
    res.status(500).json({
      success: false,
      message: 'Sign in failed',
      error: error.message,
    });
  }
};

// Verify token endpoint
export const verifyToken = async (req, res) => {
  try {
    // If middleware passes, token is valid
    res.status(200).json({
      success: true,
      message: 'Token is valid',
      data: {
        user: {
          id: req.user._id,
          email: req.user.email,
          name: req.user.name,
          picture: req.user.picture,
        },
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message,
    });
  }
};

