import 'package:food_donation_app/domain/entities/ngo.dart';

class MockNgoDataSource {
  Future<List<NGO>> fetchNGOs() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      NGO(
        id: '1',
        name: 'Food for All',
        tagline: 'Fighting hunger, one meal at a time',
        mainImage: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400',
        images: [
          'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800',
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
          'https://images.unsplash.com/photo-1469571486292-0ba58a3f068b?w=800',
        ],
        description: 'Food for All is a non-profit organization dedicated to eliminating hunger in our communities. We work with local restaurants, grocery stores, and volunteers to rescue surplus food and distribute it to those in need. Our mission is to ensure no one goes to bed hungry.',
        location: 'Downtown District',
        latitude: 28.6139,
        longitude: 77.2090,
      ),
      NGO(
        id: '2',
        name: 'Share Bites Foundation',
        tagline: 'Connecting surplus food with those who need it',
        mainImage: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
        images: [
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
          'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800',
          'https://images.unsplash.com/photo-1469571486292-0ba58a3f068b?w=800',
        ],
        description: 'Share Bites Foundation bridges the gap between food waste and food insecurity. We partner with businesses to rescue perfectly good food that would otherwise be discarded, and deliver it to shelters, food banks, and community centers.',
        location: 'North Sector',
        latitude: 28.7041,
        longitude: 77.1025,
      ),
      NGO(
        id: '3',
        name: 'Community Kitchen',
        tagline: 'Serving hot meals with heart',
        mainImage: 'https://images.unsplash.com/photo-1469571486292-0ba58a3f068b?w=400',
        images: [
          'https://images.unsplash.com/photo-1469571486292-0ba58a3f068b?w=800',
          'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800',
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
        ],
        description: 'Community Kitchen provides nutritious, hot meals to individuals and families facing food insecurity. Our volunteer chefs and kitchen staff prepare meals daily, ensuring everyone in our community has access to healthy food.',
        location: 'East Side',
        latitude: 28.5355,
        longitude: 77.3910,
      ),
      NGO(
        id: '4',
        name: 'Green Plate Initiative',
        tagline: 'Sustainable food, sustainable future',
        mainImage: 'https://images.unsplash.com/photo-1556910103-1c02745aae4d?w=400',
        images: [
          'https://images.unsplash.com/photo-1556910103-1c02745aae4d?w=800',
          'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800',
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
        ],
        description: 'Green Plate Initiative focuses on sustainable food practices while addressing hunger. We rescue organic and locally-sourced food, reduce food waste, and educate communities about sustainable eating habits.',
        location: 'West Park',
        latitude: 28.6139,
        longitude: 77.1025,
      ),
      NGO(
        id: '5',
        name: 'Hope Meals',
        tagline: 'Bringing hope through food',
        mainImage: 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400',
        images: [
          'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=800',
          'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800',
          'https://images.unsplash.com/photo-1469571486292-0ba58a3f068b?w=800',
        ],
        description: 'Hope Meals delivers nutritious meals and food packages to families, seniors, and individuals experiencing food insecurity. We believe that access to healthy food is a basic human right and work tirelessly to ensure no one is left behind.',
        location: 'South Central',
        latitude: 28.4089,
        longitude: 77.3178,
      ),
      NGO(
        id: '6',
        name: 'Neighbor\'s Table',
        tagline: 'Feeding our neighbors, building community',
        mainImage: 'https://images.unsplash.com/photo-1559339352-11d035aa65de?w=400',
        images: [
          'https://images.unsplash.com/photo-1559339352-11d035aa65de?w=800',
          'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800',
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
        ],
        description: 'Neighbor\'s Table creates a sense of community while addressing food insecurity. We organize community meals, food distribution events, and connect neighbors with resources. Together, we build a stronger, more caring community.',
        location: 'Central Plaza',
        latitude: 28.7041,
        longitude: 77.2090,
      ),
    ];
  }
}

