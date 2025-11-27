import express from 'express';
import {
  googleAuth,
  signUp,
  signIn,
  getCurrentUser,
  verifyToken,
} from '../controllers/authController.js';
import { protect } from '../middleware/auth.js';

const router = express.Router();

// Public routes
router.post('/google', googleAuth);
router.post('/signup', signUp);
router.post('/signin', signIn);

// Protected routes
router.get('/me', protect, getCurrentUser);
router.get('/verify', protect, verifyToken);

export default router;

