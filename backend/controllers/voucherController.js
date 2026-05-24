import Voucher from '../models/Voucher.js';
import User from '../models/User.js';

export const createVoucher = async (req, res) => {
  try {
    if (req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Only admins can create vouchers',
      });
    }

    const { title, code, description, pointsRequired, discountValue } = req.body;

    if (!title || !code || !pointsRequired) {
      return res.status(400).json({
        success: false,
        message: 'Please provide title, code, and pointsRequired',
      });
    }

    const existingVoucher = await Voucher.findOne({ code: code.toUpperCase() });
    if (existingVoucher) {
      return res.status(400).json({
        success: false,
        message: 'Voucher code already exists',
      });
    }

    const voucher = await Voucher.create({
      title,
      code: code.toUpperCase(),
      description: description || '',
      pointsRequired: parseInt(pointsRequired, 10),
      discountValue: discountValue || '',
      createdBy: req.user._id,
    });

    res.status(201).json({
      success: true,
      message: 'Voucher created successfully',
      data: {
        voucher: {
          id: voucher._id,
          title: voucher.title,
          code: voucher.code,
          description: voucher.description,
          pointsRequired: voucher.pointsRequired,
          discountValue: voucher.discountValue,
          isActive: voucher.isActive,
          createdAt: voucher.createdAt,
        },
      },
    });
  } catch (error) {
    console.error('Create Voucher Error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create voucher',
      error: error.message,
    });
  }
};

export const getActiveVouchers = async (req, res) => {
  try {
    const vouchers = await Voucher.find({ isActive: true })
      .sort({ pointsRequired: 1, createdAt: -1 })
      .select('-__v');

    res.status(200).json({
      success: true,
      data: {
        vouchers: vouchers.map((voucher) => ({
          id: voucher._id,
          title: voucher.title,
          code: voucher.code,
          description: voucher.description,
          pointsRequired: voucher.pointsRequired,
          discountValue: voucher.discountValue,
          isActive: voucher.isActive,
          createdAt: voucher.createdAt,
        })),
      },
    });
  } catch (error) {
    console.error('Get Active Vouchers Error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch vouchers',
      error: error.message,
    });
  }
};

export const redeemVoucher = async (req, res) => {
  try {
    const { id } = req.params;
    const user = await User.findById(req.user._id);
    const voucher = await Voucher.findById(id);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    if (!voucher || !voucher.isActive) {
      return res.status(404).json({
        success: false,
        message: 'Voucher not found or inactive',
      });
    }

    if (user.rewardPoints < voucher.pointsRequired) {
      return res.status(400).json({
        success: false,
        message: 'Not enough points to redeem this voucher',
      });
    }

    const alreadyRedeemed = user.redeemedVouchers.some(
      (entry) => entry.voucherId.toString() === voucher._id.toString()
    );

    if (alreadyRedeemed) {
      return res.status(400).json({
        success: false,
        message: 'Voucher already redeemed',
      });
    }

    user.rewardPoints -= voucher.pointsRequired;
    user.redeemedVouchers.push({
      voucherId: voucher._id,
      code: voucher.code,
      title: voucher.title,
      pointsUsed: voucher.pointsRequired,
      redeemedAt: new Date(),
    });

    await user.save();

    res.status(200).json({
      success: true,
      message: 'Voucher redeemed successfully',
      data: {
        rewardPoints: user.rewardPoints,
        redeemedVoucher: {
          voucherId: voucher._id,
          code: voucher.code,
          title: voucher.title,
          pointsUsed: voucher.pointsRequired,
          redeemedAt: user.redeemedVouchers[user.redeemedVouchers.length - 1].redeemedAt,
        },
      },
    });
  } catch (error) {
    console.error('Redeem Voucher Error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to redeem voucher',
      error: error.message,
    });
  }
};

export const getMyRedeemedVouchers = async (req, res) => {
  try {
    const user = await User.findById(req.user._id).select('redeemedVouchers rewardPoints');

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    res.status(200).json({
      success: true,
      data: {
        rewardPoints: user.rewardPoints,
        redeemedVouchers: user.redeemedVouchers
          .slice()
          .sort((a, b) => new Date(b.redeemedAt) - new Date(a.redeemedAt))
          .map((voucher) => ({
            voucherId: voucher.voucherId,
            code: voucher.code,
            title: voucher.title,
            pointsUsed: voucher.pointsUsed,
            redeemedAt: voucher.redeemedAt,
          })),
      },
    });
  } catch (error) {
    console.error('Get Redeemed Vouchers Error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch redeemed vouchers',
      error: error.message,
    });
  }
};
