import Restaurant from '../models/Restaurant.js';

// Create Restaurant (Admin only)
export const createRestaurant = async (req, res) => {
  try {
    const {
      name,
      description,
      location,
      address,
      latitude,
      longitude,
      email,
      phone,
      website,
      image,
    } = req.body;

    // Validation
    if (!name || !location || !address || !email || !phone) {
      return res.status(400).json({
        success: false,
        message: 'Please provide all required fields: name, location, address, email, phone',
      });
    }

    if (latitude === undefined || longitude === undefined) {
      return res.status(400).json({
        success: false,
        message: 'Please provide latitude and longitude',
      });
    }

    // Check if user is admin
    if (req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Only admins can create restaurants',
      });
    }

    // Create Restaurant
    const restaurant = await Restaurant.create({
      name,
      description: description || '',
      location,
      address,
      latitude: parseFloat(latitude),
      longitude: parseFloat(longitude),
      email: email.toLowerCase(),
      phone,
      website: website || '',
      image: image || '',
      createdBy: req.user._id,
    });

    res.status(201).json({
      success: true,
      message: 'Restaurant created successfully',
      data: {
        restaurant: {
          id: restaurant._id,
          name: restaurant.name,
          description: restaurant.description,
          location: restaurant.location,
          address: restaurant.address,
          latitude: restaurant.latitude,
          longitude: restaurant.longitude,
          email: restaurant.email,
          phone: restaurant.phone,
          website: restaurant.website,
          image: restaurant.image,
          createdAt: restaurant.createdAt,
        },
      },
    });
  } catch (error) {
    console.error('Create Restaurant Error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create restaurant',
      error: error.message,
    });
  }
};

// Get all Restaurants
export const getAllRestaurants = async (req, res) => {
  try {
    const restaurants = await Restaurant.find().sort({ createdAt: -1 }).select('-__v');

    res.status(200).json({
      success: true,
      data: {
        restaurants: restaurants.map((restaurant) => ({
          id: restaurant._id,
          name: restaurant.name,
          description: restaurant.description,
          location: restaurant.location,
          address: restaurant.address,
          latitude: restaurant.latitude,
          longitude: restaurant.longitude,
          email: restaurant.email,
          phone: restaurant.phone,
          website: restaurant.website,
          image: restaurant.image,
          createdAt: restaurant.createdAt,
        })),
      },
    });
  } catch (error) {
    console.error('Get Restaurants Error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch restaurants',
      error: error.message,
    });
  }
};

// Get single Restaurant by ID
export const getRestaurantById = async (req, res) => {
  try {
    const { id } = req.params;

    const restaurant = await Restaurant.findById(id).select('-__v');

    if (!restaurant) {
      return res.status(404).json({
        success: false,
        message: 'Restaurant not found',
      });
    }

    res.status(200).json({
      success: true,
      data: {
        restaurant: {
          id: restaurant._id,
          name: restaurant.name,
          description: restaurant.description,
          location: restaurant.location,
          address: restaurant.address,
          latitude: restaurant.latitude,
          longitude: restaurant.longitude,
          email: restaurant.email,
          phone: restaurant.phone,
          website: restaurant.website,
          image: restaurant.image,
          createdAt: restaurant.createdAt,
        },
      },
    });
  } catch (error) {
    console.error('Get Restaurant Error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch restaurant',
      error: error.message,
    });
  }
};

