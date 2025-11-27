import express from 'express';
import {
  createDemand,
  getAllDemands,
  getDemandsByNGO,
  acceptDemand,
  ignoreDemand,
} from '../controllers/ngoDemandController.js';
import { protect } from '../middleware/auth.js';

const router = express.Router();

// All routes require authentication
router.use(protect);

// Get all demands (for restaurant users)
router.get('/', getAllDemands);

// Get demands by NGO (for NGO admin)
router.get('/ngo/:ngoId', getDemandsByNGO);

// Create demand (NGO admin only)
router.post('/', createDemand);

// Accept demand (Restaurant only)
router.post('/:id/accept', acceptDemand);

// Ignore demand (Restaurant only)
router.post('/:id/ignore', ignoreDemand);

export default router;

