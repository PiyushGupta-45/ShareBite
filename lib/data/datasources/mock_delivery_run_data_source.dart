import 'package:food_donation_app/domain/entities/delivery_run.dart';

class MockDeliveryRunDataSource {
  Future<List<DeliveryRun>> fetchDeliveryRuns() async {
    final now = DateTime.now();
    
    final runs = [
      DeliveryRun(
        id: 'RUN-001',
        restaurantId: 'REST-001',
        restaurantName: 'Bloom Bistro',
        restaurantLocation: 'CBD Cluster',
        restaurantAddress: '123 Main Street, CBD Cluster, New Delhi',
        restaurantLatitude: 28.6139,
        restaurantLongitude: 77.2090,
        restaurantPhone: '+91 98765 43210',
        ngoId: 'NGO-001',
        ngoName: 'Hope Foundation',
        ngoLocation: 'Downtown',
        ngoAddress: '456 Charity Lane, Downtown, New Delhi',
        ngoLatitude: 28.7041,
        ngoLongitude: 77.1025,
        ngoPhone: '+91 98765 43211',
        pickupTime: now.add(const Duration(minutes: 30)),
        deliveryTime: now.add(const Duration(hours: 2)),
        numberOfMeals: 50,
        status: 'pending',
        description: 'Fresh prepared meals from lunch service',
        urgencyTag: 'Urgent',
      ),
      DeliveryRun(
        id: 'RUN-002',
        restaurantId: 'REST-002',
        restaurantName: 'Harvest Farm Co-op',
        restaurantLocation: 'North Agro Belt',
        restaurantAddress: '789 Farm Road, North Agro Belt, New Delhi',
        restaurantLatitude: 28.7041,
        restaurantLongitude: 77.1025,
        restaurantPhone: '+91 98765 43212',
        ngoId: 'NGO-002',
        ngoName: 'Food for All',
        ngoLocation: 'Sector 5',
        ngoAddress: '321 Service Road, Sector 5, New Delhi',
        ngoLatitude: 28.6139,
        ngoLongitude: 77.2090,
        ngoPhone: '+91 98765 43213',
        pickupTime: now.add(const Duration(hours: 1)),
        deliveryTime: now.add(const Duration(hours: 4)),
        numberOfMeals: 75,
        status: 'pending',
        description: 'Fresh produce and vegetables',
        urgencyTag: 'Flex',
      ),
      DeliveryRun(
        id: 'RUN-003',
        restaurantId: 'REST-003',
        restaurantName: 'Fusion Food Labs',
        restaurantLocation: 'Tech Park',
        restaurantAddress: '555 Innovation Drive, Tech Park, New Delhi',
        restaurantLatitude: 28.5355,
        restaurantLongitude: 77.3910,
        restaurantPhone: '+91 98765 43214',
        ngoId: 'NGO-003',
        ngoName: 'Community Kitchen',
        ngoLocation: 'Old City',
        ngoAddress: '888 Heritage Street, Old City, New Delhi',
        ngoLatitude: 28.6517,
        ngoLongitude: 77.2213,
        ngoPhone: '+91 98765 43215',
        pickupTime: now.add(const Duration(minutes: 15)),
        deliveryTime: now.add(const Duration(hours: 1, minutes: 30)),
        numberOfMeals: 30,
        status: 'pending',
        description: 'Hot meals from dinner service',
        urgencyTag: 'Urgent',
      ),
    ];
    
    return Future.delayed(const Duration(milliseconds: 300), () => runs);
  }
}

