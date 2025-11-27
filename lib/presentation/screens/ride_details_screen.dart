import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_donation_app/core/theme/app_theme.dart';
import 'package:food_donation_app/domain/entities/delivery_run.dart';
import 'package:food_donation_app/presentation/widgets/app_card.dart';

class RideDetailsScreen extends ConsumerStatefulWidget {
  const RideDetailsScreen({super.key});

  @override
  ConsumerState<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends ConsumerState<RideDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mock data for accepted and completed rides
    final acceptedRides = _getAcceptedRides();
    final completedRides = _getCompletedRides();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Details'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Accepted'),
            Tab(text: 'Completed'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRidesList(acceptedRides, 'accepted'),
          _buildRidesList(completedRides, 'completed'),
        ],
      ),
    );
  }

  Widget _buildRidesList(List<DeliveryRun> rides, String status) {
    if (rides.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No $status rides yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              status == 'accepted'
                  ? 'Accept a run to see it here'
                  : 'Complete a run to see it here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh logic here
        setState(() {});
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rides.length,
        itemBuilder: (context, index) {
          return _RideCard(run: rides[index], status: status);
        },
      ),
    );
  }

  List<DeliveryRun> _getAcceptedRides() {
    final now = DateTime.now();
    return [
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
        status: 'accepted',
        description: 'Fresh prepared meals from lunch service',
        urgencyTag: 'Urgent',
      ),
    ];
  }

  List<DeliveryRun> _getCompletedRides() {
    final now = DateTime.now();
    return [
      DeliveryRun(
        id: 'RUN-004',
        restaurantId: 'REST-004',
        restaurantName: 'Green Garden Cafe',
        restaurantLocation: 'Park Avenue',
        restaurantAddress: '789 Park Avenue, New Delhi',
        restaurantLatitude: 28.5355,
        restaurantLongitude: 77.3910,
        restaurantPhone: '+91 98765 43216',
        ngoId: 'NGO-004',
        ngoName: 'Helping Hands',
        ngoLocation: 'Suburb',
        ngoAddress: '321 Help Street, Suburb, New Delhi',
        ngoLatitude: 28.6517,
        ngoLongitude: 77.2213,
        ngoPhone: '+91 98765 43217',
        pickupTime: now.subtract(const Duration(days: 1, hours: 2)),
        deliveryTime: now.subtract(const Duration(days: 1)),
        numberOfMeals: 40,
        status: 'completed',
        description: 'Completed delivery',
        urgencyTag: 'Flex',
      ),
      DeliveryRun(
        id: 'RUN-005',
        restaurantId: 'REST-005',
        restaurantName: 'City Kitchen',
        restaurantLocation: 'Downtown',
        restaurantAddress: '555 Food Street, Downtown, New Delhi',
        restaurantLatitude: 28.6139,
        restaurantLongitude: 77.2090,
        restaurantPhone: '+91 98765 43218',
        ngoId: 'NGO-005',
        ngoName: 'Food Bank',
        ngoLocation: 'Central',
        ngoAddress: '888 Central Road, New Delhi',
        ngoLatitude: 28.7041,
        ngoLongitude: 77.1025,
        ngoPhone: '+91 98765 43219',
        pickupTime: now.subtract(const Duration(days: 2, hours: 3)),
        deliveryTime: now.subtract(const Duration(days: 2, hours: 1)),
        numberOfMeals: 60,
        status: 'completed',
        description: 'Completed delivery',
        urgencyTag: 'Urgent',
      ),
    ];
  }
}

class _RideCard extends StatelessWidget {
  const _RideCard({
    required this.run,
    required this.status,
  });

  final DeliveryRun run;
  final String status;

  @override
  Widget build(BuildContext context) {
    final isCompleted = status == 'completed';
    final dateTime = isCompleted ? run.deliveryTime : run.pickupTime;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      run.restaurantName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.arrow_forward, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            run.ngoName,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.withOpacity(0.1)
                      : AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isCompleted ? 'Completed' : 'Accepted',
                  style: TextStyle(
                    color: isCompleted ? Colors.green[700] : AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _InfoChip(
                icon: Icons.restaurant_menu,
                label: '${run.numberOfMeals} meals',
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              _InfoChip(
                icon: Icons.straighten,
                label: '${run.distanceKm.toStringAsFixed(1)} km',
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              _InfoChip(
                icon: Icons.access_time,
                label: _formatDateTime(dateTime),
                color: AppTheme.accentColor,
              ),
            ],
          ),
          if (run.description != null && run.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              run.description!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

