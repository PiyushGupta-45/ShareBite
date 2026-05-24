import express from 'express';
import {
  createVoucher,
  getActiveVouchers,
  redeemVoucher,
  getMyRedeemedVouchers,
} from '../controllers/voucherController.js';
import { protect } from '../middleware/auth.js';

const router = express.Router();

router.use(protect);

router.get('/', getActiveVouchers);
router.get('/my-redemptions', getMyRedeemedVouchers);
router.post('/', createVoucher);
router.post('/:id/redeem', redeemVoucher);

export default router;
