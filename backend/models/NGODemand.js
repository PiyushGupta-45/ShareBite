import mongoose from 'mongoose';

const ngoDemandSchema = new mongoose.Schema(
  {
    ngoId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'NGO',
      required: true,
    },
    ngoName: {
      type: String,
      required: true,
      trim: true,
    },
    amount: {
      type: Number,
      required: true,
      min: 1,
    },
    unit: {
      type: String,
      required: true,
      enum: ['meals', 'kg', 'plates'],
      default: 'meals',
    },
    requiredBy: {
      type: Date,
      required: true,
    },
    description: {
      type: String,
      default: '',
    },
    status: {
      type: String,
      enum: ['pending', 'accepted', 'fulfilled', 'ignored'],
      default: 'pending',
    },
    acceptedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      default: null,
    },
    acceptedAt: {
      type: Date,
      default: null,
    },
    ignoredBy: {
      type: [mongoose.Schema.Types.ObjectId],
      ref: 'User',
      default: [],
    },
  },
  {
    timestamps: true,
  }
);

// Index for efficient queries
ngoDemandSchema.index({ ngoId: 1, status: 1 });
ngoDemandSchema.index({ status: 1, requiredBy: 1 });

const NGODemand = mongoose.model('NGODemand', ngoDemandSchema);

export default NGODemand;

