import NGO from '../models/NGO.js';

// Create NGO (Admin only)
export const createNGO = async (req, res) => {
  try {
    const {
      name,
      tagline,
      description,
      mainImage,
      images,
      location,
      address,
      latitude,
      longitude,
      email,
      phone,
      website,
    } = req.body;

    // Validation
    if (!name || !tagline || !description || !location || !address || !email || !phone) {
      return res.status(400).json({
        success: false,
        message: 'Please provide all required fields: name, tagline, description, location, address, email, phone',
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
        message: 'Only admins can create NGOs',
      });
    }

    // Create NGO
    const ngo = await NGO.create({
      name,
      tagline,
      description,
      mainImage: mainImage || '',
      images: images || [],
      location,
      address,
      latitude: parseFloat(latitude),
      longitude: parseFloat(longitude),
      email: email.toLowerCase(),
      phone,
      website: website || '',
      createdBy: req.user._id,
    });

    res.status(201).json({
      success: true,
      message: 'NGO created successfully',
      data: {
        ngo: {
          id: ngo._id,
          name: ngo.name,
          tagline: ngo.tagline,
          description: ngo.description,
          mainImage: ngo.mainImage,
          images: ngo.images,
          location: ngo.location,
          address: ngo.address,
          latitude: ngo.latitude,
          longitude: ngo.longitude,
          email: ngo.email,
          phone: ngo.phone,
          website: ngo.website,
          createdAt: ngo.createdAt,
        },
      },
    });
  } catch (error) {
    console.error('Create NGO Error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create NGO',
      error: error.message,
    });
  }
};

// Get all NGOs
export const getAllNGOs = async (req, res) => {
  try {
    const ngos = await NGO.find().sort({ createdAt: -1 }).select('-__v');

    res.status(200).json({
      success: true,
      data: {
        ngos: ngos.map((ngo) => ({
          id: ngo._id,
          name: ngo.name,
          tagline: ngo.tagline,
          description: ngo.description,
          mainImage: ngo.mainImage,
          images: ngo.images,
          location: ngo.location,
          address: ngo.address,
          latitude: ngo.latitude,
          longitude: ngo.longitude,
          email: ngo.email,
          phone: ngo.phone,
          website: ngo.website,
          createdAt: ngo.createdAt,
        })),
      },
    });
  } catch (error) {
    console.error('Get NGOs Error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch NGOs',
      error: error.message,
    });
  }
};

// Get single NGO by ID
export const getNGOById = async (req, res) => {
  try {
    const { id } = req.params;

    const ngo = await NGO.findById(id).select('-__v');

    if (!ngo) {
      return res.status(404).json({
        success: false,
        message: 'NGO not found',
      });
    }

    res.status(200).json({
      success: true,
      data: {
        ngo: {
          id: ngo._id,
          name: ngo.name,
          tagline: ngo.tagline,
          description: ngo.description,
          mainImage: ngo.mainImage,
          images: ngo.images,
          location: ngo.location,
          address: ngo.address,
          latitude: ngo.latitude,
          longitude: ngo.longitude,
          email: ngo.email,
          phone: ngo.phone,
          website: ngo.website,
          createdAt: ngo.createdAt,
        },
      },
    });
  } catch (error) {
    console.error('Get NGO Error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch NGO',
      error: error.message,
    });
  }
};

