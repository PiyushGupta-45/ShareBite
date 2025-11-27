import express from 'express';
import {
  createRestaurant,
  getAllRestaurants,
  getRestaurantById,
} from '../controllers/restaurantController.js';
import { protect } from '../middleware/auth.js';

const router = express.Router();

// Public routes
router.get('/', getAllRestaurants);
router.get('/:id', getRestaurantById);

// Protected routes (Admin only)
router.post('/', protect, createRestaurant);

export default router;

