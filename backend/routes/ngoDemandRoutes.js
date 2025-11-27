import express from 'express';
import {
  createDemand,
  getAllDemands,
  getDemandsByNGO,
  acceptDemand,
  ignoreDemand,
  updateDemand,
  deleteDemand,
  getAcceptedDemandsForVolunteers,
} from '../controllers/ngoDemandController.js';
import { protect } from '../middleware/auth.js';

const router = express.Router();

// All routes require authentication
router.use(protect);

// Get all demands (for restaurant users)
router.get('/', getAllDemands);

// Get accepted demands for volunteers (with restaurant info)
router.get('/accepted-for-volunteers', getAcceptedDemandsForVolunteers);

// Get demands by NGO (for NGO admin)
router.get('/ngo/:ngoId', getDemandsByNGO);

// Create demand (NGO admin only)
router.post('/', createDemand);

// Accept demand (Restaurant only)
router.post('/:id/accept', acceptDemand);

// Ignore demand (Restaurant only)
router.post('/:id/ignore', ignoreDemand);

// Update demand (NGO Admin only)
router.put('/:id', updateDemand);

// Delete demand (NGO Admin only)
router.delete('/:id', deleteDemand);

export default router;

