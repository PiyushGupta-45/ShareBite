import DeliveryRun from '../models/DeliveryRun.js';
import Restaurant from '../models/Restaurant.js';
import NGO from '../models/NGO.js';

// Accept a delivery run (Volunteer)
export const acceptDeliveryRun = async (req, res) => {
  try {
    const { restaurantId, ngoId, pickupTime, deliveryTime, numberOfMeals, description, urgencyTag } = req.body;

    // Validation
    if (!restaurantId || !ngoId || !pickupTime || !deliveryTime || !numberOfMeals) {
      return res.status(400).json({
        success: false,
        message: 'Please provide all required fields: restaurantId, ngoId, pickupTime, deliveryTime, numberOfMeals',
      });
    }

    // Check if restaurant exists
    const restaurant = await Restaurant.findById(restaurantId);
    if (!restaurant) {
      return res.status(404).json({
        success: false,
        message: 'Restaurant not found',
      });
    }

    // Check if NGO exists
    const ngo = await NGO.findById(ngoId);
    if (!ngo) {
      return res.status(404).json({
        success: false,
        message: 'NGO not found',
      });
    }

    // Create delivery run
    const deliveryRun = await DeliveryRun.create({
      restaurantId,
      ngoId,
      volunteerId: req.user._id,
      pickupTime: new Date(pickupTime),
      deliveryTime: new Date(deliveryTime),
      numberOfMeals: parseInt(numberOfMeals),
      status: 'accepted',
      description: description || '',
      urgencyTag: urgencyTag || 'Flex',
    });

    // Populate restaurant and NGO details
    await deliveryRun.populate('restaurantId', 'name location address latitude longitude phone email');
    await deliveryRun.populate('ngoId', 'name location address latitude longitude phone email');

    res.status(201).json({
      success: true,
      message: 'Delivery run accepted successfully',
      data: {
        deliveryRun: {
          id: deliveryRun._id,
          restaurant: {
            id: restaurant._id,
            name: restaurant.name,
            location: restaurant.location,
            address: restaurant.address,
            latitude: restaurant.latitude,
            longitude: restaurant.longitude,
            phone: restaurant.phone,
            email: restaurant.email,
          },
          ngo: {
            id: ngo._id,
            name: ngo.name,
            location: ngo.location,
            address: ngo.address,
            latitude: ngo.latitude,
            longitude: ngo.longitude,
            phone: ngo.phone,
            email: ngo.email,
          },
          pickupTime: deliveryRun.pickupTime,
          deliveryTime: deliveryRun.deliveryTime,
          numberOfMeals: deliveryRun.numberOfMeals,
          status: deliveryRun.status,
          description: deliveryRun.description,
          urgencyTag: deliveryRun.urgencyTag,
          createdAt: deliveryRun.createdAt,
        },
      },
    });
  } catch (error) {
    console.error('Accept Delivery Run Error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to accept delivery run',
      error: error.message,
    });
  }
};

// Get all delivery runs for a user
export const getUserDeliveryRuns = async (req, res) => {
  try {
    const userId = req.user._id;
    const { status } = req.query; // Optional filter by status

    let query = { volunteerId: userId };
    if (status) {
      query.status = status;
    }

    const deliveryRuns = await DeliveryRun.find(query)
      .populate('restaurantId', 'name location address latitude longitude phone email')
      .populate('ngoId', 'name location address latitude longitude phone email')
      .sort({ createdAt: -1 })
      .select('-__v');

    res.status(200).json({
      success: true,
      data: {
        deliveryRuns: deliveryRuns.map((run) => ({
          id: run._id,
          restaurant: {
            id: run.restaurantId._id,
            name: run.restaurantId.name,
            location: run.restaurantId.location,
            address: run.restaurantId.address,
            latitude: run.restaurantId.latitude,
            longitude: run.restaurantId.longitude,
            phone: run.restaurantId.phone,
            email: run.restaurantId.email,
          },
          ngo: {
            id: run.ngoId._id,
            name: run.ngoId.name,
            location: run.ngoId.location,
            address: run.ngoId.address,
            latitude: run.ngoId.latitude,
            longitude: run.ngoId.longitude,
            phone: run.ngoId.phone,
            email: run.ngoId.email,
          },
          pickupTime: run.pickupTime,
          deliveryTime: run.deliveryTime,
          numberOfMeals: run.numberOfMeals,
          status: run.status,
          description: run.description,
          urgencyTag: run.urgencyTag,
          createdAt: run.createdAt,
        })),
      },
    });
  } catch (error) {
    console.error('Get User Delivery Runs Error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch delivery runs',
      error: error.message,
    });
  }
};

// Update delivery run status
export const updateDeliveryRunStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    if (!status || !['accepted', 'in_progress', 'completed'].includes(status)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid status. Must be: accepted, in_progress, or completed',
      });
    }

    const deliveryRun = await DeliveryRun.findById(id);

    if (!deliveryRun) {
      return res.status(404).json({
        success: false,
        message: 'Delivery run not found',
      });
    }

    // Check if user owns this delivery run
    if (deliveryRun.volunteerId.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: 'You can only update your own delivery runs',
      });
    }

    deliveryRun.status = status;
    await deliveryRun.save();

    await deliveryRun.populate('restaurantId', 'name location address latitude longitude phone email');
    await deliveryRun.populate('ngoId', 'name location address latitude longitude phone email');

    res.status(200).json({
      success: true,
      message: 'Delivery run status updated successfully',
      data: {
        deliveryRun: {
          id: deliveryRun._id,
          restaurant: {
            id: deliveryRun.restaurantId._id,
            name: deliveryRun.restaurantId.name,
            location: deliveryRun.restaurantId.location,
            address: deliveryRun.restaurantId.address,
            latitude: deliveryRun.restaurantId.latitude,
            longitude: deliveryRun.restaurantId.longitude,
            phone: deliveryRun.restaurantId.phone,
            email: deliveryRun.restaurantId.email,
          },
          ngo: {
            id: deliveryRun.ngoId._id,
            name: deliveryRun.ngoId.name,
            location: deliveryRun.ngoId.location,
            address: deliveryRun.ngoId.address,
            latitude: deliveryRun.ngoId.latitude,
            longitude: deliveryRun.ngoId.longitude,
            phone: deliveryRun.ngoId.phone,
            email: deliveryRun.ngoId.email,
          },
          pickupTime: deliveryRun.pickupTime,
          deliveryTime: deliveryRun.deliveryTime,
          numberOfMeals: deliveryRun.numberOfMeals,
          status: deliveryRun.status,
          description: deliveryRun.description,
          urgencyTag: deliveryRun.urgencyTag,
          createdAt: deliveryRun.createdAt,
        },
      },
    });
  } catch (error) {
    console.error('Update Delivery Run Error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update delivery run',
      error: error.message,
    });
  }
};

