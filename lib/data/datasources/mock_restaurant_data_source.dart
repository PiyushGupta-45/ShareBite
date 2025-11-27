import 'package:food_donation_app/domain/entities/restaurant.dart';

class MockRestaurantDataSource {
  Future<List<Restaurant>> fetchRestaurants() async {
    final restaurants = [
      Restaurant(
        id: 'REST-001',
        name: 'Bloom Bistro',
        location: 'CBD Cluster',
        address: '123 Main Street, CBD Cluster, New Delhi',
        phone: '+91 98765 43210',
        email: 'contact@bloombistro.com',
        latitude: 28.6139,
        longitude: 77.2090,
        image: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400',
        description: 'Fine dining restaurant serving fresh, organic meals',
        website: 'https://bloombistro.com',
      ),
      Restaurant(
        id: 'REST-002',
        name: 'Harvest Farm Co-op',
        location: 'North Agro Belt',
        address: '789 Farm Road, North Agro Belt, New Delhi',
        phone: '+91 98765 43212',
        email: 'info@harvestfarm.com',
        latitude: 28.7041,
        longitude: 77.1025,
        image: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=400',
        description: 'Farm-to-table restaurant with locally sourced ingredients',
        website: 'https://harvestfarm.com',
      ),
      Restaurant(
        id: 'REST-003',
        name: 'Fusion Food Labs',
        location: 'Tech Park',
        address: '555 Innovation Drive, Tech Park, New Delhi',
        phone: '+91 98765 43214',
        email: 'hello@fusionfoodlabs.com',
        latitude: 28.5355,
        longitude: 77.3910,
        image: 'https://images.unsplash.com/photo-1559339352-11d035aa65de?w=400',
        description: 'Modern fusion cuisine with innovative flavors',
        website: 'https://fusionfoodlabs.com',
      ),
      Restaurant(
        id: 'REST-004',
        name: 'Green Garden Cafe',
        location: 'Park Avenue',
        address: '789 Park Avenue, New Delhi',
        phone: '+91 98765 43216',
        email: 'contact@greengardencafe.com',
        latitude: 28.6517,
        longitude: 77.2213,
        image: 'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=400',
        description: 'Vegetarian cafe with organic and healthy options',
        website: 'https://greengardencafe.com',
      ),
      Restaurant(
        id: 'REST-005',
        name: 'City Kitchen',
        location: 'Downtown',
        address: '555 Food Street, Downtown, New Delhi',
        phone: '+91 98765 43218',
        email: 'info@citykitchen.com',
        latitude: 28.6139,
        longitude: 77.2090,
        image: 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400',
        description: 'Traditional cuisine with a modern twist',
        website: 'https://citykitchen.com',
      ),
    ];

    return Future.delayed(const Duration(milliseconds: 300), () => restaurants);
  }
}

