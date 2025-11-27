import NGODemand from '../models/NGODemand.js';
import NGO from '../models/NGO.js';

// Create NGO Demand (NGO Admin only)
export const createDemand = async (req, res) => {
  try {
    const { ngoId, amount, unit, requiredBy, description } = req.body;

    // Validation
    if (!ngoId || !amount || !unit || !requiredBy) {
      return res.status(400).json({
        success: false,
        message: 'Please provide all required fields: ngoId, amount, unit, requiredBy',
      });
    }

    // Check if user is NGO admin
    if (req.user.role !== 'ngo_admin') {
      return res.status(403).json({
        success: false,
        message: 'Only NGO admins can create demands',
      });
    }

    // Verify NGO exists
    const ngo = await NGO.findById(ngoId);
    if (!ngo) {
      return res.status(404).json({
        success: false,
        message: 'NGO not found',
      });
    }

    // Validate date
    const requiredByDate = new Date(requiredBy);
    if (isNaN(requiredByDate.getTime()) || requiredByDate < new Date()) {
      return res.status(400).json({
        success: false,
        message: 'Required by date must be a valid future date',
      });
    }

    // Create demand
    const demand = await NGODemand.create({
      ngoId,
      ngoName: ngo.name,
      amount: parseInt(amount),
      unit,
      requiredBy: requiredByDate,
      description: description || '',
      status: 'pending',
    });

    res.status(201).json({
      success: true,
      message: 'Demand created successfully',
      data: {
        demand: {
          id: demand._id,
          ngoId: demand.ngoId,
          ngoName: demand.ngoName,
          amount: demand.amount,
          unit: demand.unit,
          requiredBy: demand.requiredBy,
          description: demand.description,
          status: demand.status,
          createdAt: demand.createdAt,
        },
      },
    });
  } catch (error) {
    console.error('Create Demand Error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create demand',
      error: error.message,
    });
  }
};

// Get all demands (for restaurant users - excludes ignored ones)
export const getAllDemands = async (req, res) => {
  try {
    let query = { status: 'pending' };

    // If user is restaurant, exclude demands they've ignored
    if (req.user.role === 'restaurant') {
      query.ignoredBy = { $ne: req.user._id };
    }

    const demands = await NGODemand.find(query)
      .sort({ requiredBy: 1, createdAt: -1 })
      .select('-__v')
      .populate('ngoId', 'name location address email phone')
      .lean();

    res.status(200).json({
      success: true,
      data: {
        demands: demands.map((demand) => ({
          id: demand._id,
          ngoId: demand.ngoId._id || demand.ngoId,
          ngoName: demand.ngoName,
          amount: demand.amount,
          unit: demand.unit,
          requiredBy: demand.requiredBy,
          description: demand.description,
          status: demand.status,
          createdAt: demand.createdAt,
        })),
      },
    });
  } catch (error) {
    console.error('Get Demands Error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch demands',
      error: error.message,
    });
  }
};

// Get accepted demands for volunteers (with restaurant info)
export const getAcceptedDemandsForVolunteers = async (req, res) => {
  try {
    const demands = await NGODemand.find({ status: 'accepted' })
      .sort({ requiredBy: 1, createdAt: -1 })
      .select('-__v')
      .populate('ngoId', 'name location address latitude longitude')
      .populate('acceptedBy', 'name email')
      .lean();

    res.status(200).json({
      success: true,
      data: {
        demands: demands.map((demand) => ({
          id: demand._id,
          ngoId: demand.ngoId._id || demand.ngoId,
          ngoName: demand.ngoName,
          ngoLocation: demand.ngoId?.location || '',
          ngoAddress: demand.ngoId?.address || '',
          ngoLatitude: demand.ngoId?.latitude || 0,
          ngoLongitude: demand.ngoId?.longitude || 0,
          restaurantName: demand.acceptedBy?.name || 'Unknown Restaurant',
          restaurantEmail: demand.acceptedBy?.email || '',
          amount: demand.amount,
          unit: demand.unit,
          requiredBy: demand.requiredBy,
          description: demand.description,
          status: demand.status,
          acceptedAt: demand.acceptedAt,
          createdAt: demand.createdAt,
        })),
      },
    });
  } catch (error) {
    console.error('Get Accepted Demands Error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch accepted demands',
      error: error.message,
    });
  }
};

// Get demands by NGO (for NGO admin)
export const getDemandsByNGO = async (req, res) => {
  try {
    const { ngoId } = req.params;

    // Check if user is NGO admin
    if (req.user.role !== 'ngo_admin') {
      return res.status(403).json({
        success: false,
        message: 'Only NGO admins can view their demands',
      });
    }

    const demands = await NGODemand.find({ ngoId })
      .sort({ createdAt: -1 })
      .select('-__v')
      .lean();

    res.status(200).json({
      success: true,
      data: {
        demands: demands.map((demand) => ({
          id: demand._id,
          ngoId: demand.ngoId,
          ngoName: demand.ngoName,
          amount: demand.amount,
          unit: demand.unit,
          requiredBy: demand.requiredBy,
          description: demand.description,
          status: demand.status,
          acceptedBy: demand.acceptedBy,
          acceptedAt: demand.acceptedAt,
          createdAt: demand.createdAt,
        })),
      },
    });
  } catch (error) {
    console.error('Get Demands by NGO Error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch demands',
      error: error.message,
    });
  }
};

// Accept demand (Restaurant only)
export const acceptDemand = async (req, res) => {
  try {
    const { id } = req.params;

    // Check if user is restaurant
    if (req.user.role !== 'restaurant') {
      return res.status(403).json({
        success: false,
        message: 'Only restaurants can accept demands',
      });
    }

    const demand = await NGODemand.findById(id);
    if (!demand) {
      return res.status(404).json({
        success: false,
        message: 'Demand not found',
      });
    }

    if (demand.status !== 'pending') {
      return res.status(400).json({
        success: false,
        message: 'Demand is no longer available',
      });
    }

    // Update demand
    demand.status = 'accepted';
    demand.acceptedBy = req.user._id;
    demand.acceptedAt = new Date();
    await demand.save();

    res.status(200).json({
      success: true,
      message: 'Demand accepted successfully',
      data: {
        demand: {
          id: demand._id,
          ngoId: demand.ngoId,
          ngoName: demand.ngoName,
          amount: demand.amount,
          unit: demand.unit,
          requiredBy: demand.requiredBy,
          description: demand.description,
          status: demand.status,
          acceptedBy: demand.acceptedBy,
          acceptedAt: demand.acceptedAt,
        },
      },
    });
  } catch (error) {
    console.error('Accept Demand Error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to accept demand',
      error: error.message,
    });
  }
};

// Ignore demand (Restaurant only)
export const ignoreDemand = async (req, res) => {
  try {
    const { id } = req.params;

    // Check if user is restaurant
    if (req.user.role !== 'restaurant') {
      return res.status(403).json({
        success: false,
        message: 'Only restaurants can ignore demands',
      });
    }

    const demand = await NGODemand.findById(id);
    if (!demand) {
      return res.status(404).json({
        success: false,
        message: 'Demand not found',
      });
    }

    // Add user to ignoredBy array if not already there
    if (!demand.ignoredBy.includes(req.user._id)) {
      demand.ignoredBy.push(req.user._id);
      await demand.save();
    }

    res.status(200).json({
      success: true,
      message: 'Demand ignored successfully',
    });
  } catch (error) {
    console.error('Ignore Demand Error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to ignore demand',
      error: error.message,
    });
  }
};

// Update demand (NGO Admin only)
export const updateDemand = async (req, res) => {
  try {
    const { id } = req.params;
    const { amount, unit, requiredBy, description } = req.body;

    // Check if user is NGO admin
    if (req.user.role !== 'ngo_admin') {
      return res.status(403).json({
        success: false,
        message: 'Only NGO admins can update demands',
      });
    }

    const demand = await NGODemand.findById(id);
    if (!demand) {
      return res.status(404).json({
        success: false,
        message: 'Demand not found',
      });
    }

    // Can't update if already accepted
    if (demand.status === 'accepted') {
      return res.status(400).json({
        success: false,
        message: 'Cannot update an accepted demand',
      });
    }

    // Update fields
    if (amount !== undefined) demand.amount = parseInt(amount);
    if (unit !== undefined) demand.unit = unit;
    if (requiredBy !== undefined) {
      const requiredByDate = new Date(requiredBy);
      if (isNaN(requiredByDate.getTime()) || requiredByDate < new Date()) {
        return res.status(400).json({
          success: false,
          message: 'Required by date must be a valid future date',
        });
      }
      demand.requiredBy = requiredByDate;
    }
    if (description !== undefined) demand.description = description || '';

    await demand.save();

    res.status(200).json({
      success: true,
      message: 'Demand updated successfully',
      data: {
        demand: {
          id: demand._id,
          ngoId: demand.ngoId,
          ngoName: demand.ngoName,
          amount: demand.amount,
          unit: demand.unit,
          requiredBy: demand.requiredBy,
          description: demand.description,
          status: demand.status,
        },
      },
    });
  } catch (error) {
    console.error('Update Demand Error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update demand',
      error: error.message,
    });
  }
};

// Delete demand (NGO Admin only)
export const deleteDemand = async (req, res) => {
  try {
    const { id } = req.params;

    // Check if user is NGO admin
    if (req.user.role !== 'ngo_admin') {
      return res.status(403).json({
        success: false,
        message: 'Only NGO admins can delete demands',
      });
    }

    const demand = await NGODemand.findById(id);
    if (!demand) {
      return res.status(404).json({
        success: false,
        message: 'Demand not found',
      });
    }

    // Can't delete if already accepted
    if (demand.status === 'accepted') {
      return res.status(400).json({
        success: false,
        message: 'Cannot delete an accepted demand',
      });
    }

    await NGODemand.findByIdAndDelete(id);

    res.status(200).json({
      success: true,
      message: 'Demand deleted successfully',
    });
  } catch (error) {
    console.error('Delete Demand Error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete demand',
      error: error.message,
    });
  }
};

