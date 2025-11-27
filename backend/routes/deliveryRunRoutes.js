import express from 'express';
import {
  acceptDeliveryRun,
  getUserDeliveryRuns,
  updateDeliveryRunStatus,
} from '../controllers/deliveryRunController.js';
import { protect } from '../middleware/auth.js';

const router = express.Router();

// All routes require authentication
router.use(protect);

// Get user's delivery runs (with optional status filter)
router.get('/', getUserDeliveryRuns);

// Accept a delivery run
router.post('/accept', acceptDeliveryRun);

// Update delivery run status
router.put('/:id/status', updateDeliveryRunStatus);

export default router;

