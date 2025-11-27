import express from 'express';
import {
  createNGO,
  getAllNGOs,
  getNGOById,
} from '../controllers/ngoController.js';
import { protect } from '../middleware/auth.js';

const router = express.Router();

// Public routes
router.get('/', getAllNGOs);
router.get('/:id', getNGOById);

// Protected routes (Admin only)
router.post('/', protect, createNGO);

export default router;

