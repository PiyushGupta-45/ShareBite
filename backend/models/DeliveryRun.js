import mongoose from 'mongoose';

const deliveryRunSchema = new mongoose.Schema(
  {
    restaurantId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Restaurant',
      required: true,
    },
    ngoId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'NGO',
      required: true,
    },
    volunteerId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    pickupTime: {
      type: Date,
      required: true,
    },
    deliveryTime: {
      type: Date,
      required: true,
    },
    numberOfMeals: {
      type: Number,
      required: true,
    },
    status: {
      type: String,
      enum: ['pending', 'accepted', 'in_progress', 'completed'],
      default: 'pending',
    },
    description: {
      type: String,
      default: '',
    },
    urgencyTag: {
      type: String,
      default: 'Flex',
    },
    pointsAwarded: {
      type: Number,
      default: 0,
    },
    completedAt: {
      type: Date,
      default: null,
    },
  },
  {
    timestamps: true,
  }
);

const DeliveryRun = mongoose.model('DeliveryRun', deliveryRunSchema);

export default DeliveryRun;

