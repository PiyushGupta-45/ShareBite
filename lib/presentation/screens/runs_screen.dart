import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_donation_app/core/theme/app_theme.dart';
import 'package:food_donation_app/data/datasources/delivery_run_remote_datasource.dart';
import 'package:food_donation_app/domain/entities/ngo_demand.dart';
import 'package:food_donation_app/presentation/providers/app_providers.dart';
import 'package:food_donation_app/presentation/screens/ride_details_screen.dart';
import 'package:food_donation_app/presentation/widgets/app_card.dart';
import 'package:food_donation_app/presentation/widgets/primary_button.dart';
import 'package:url_launcher/url_launcher.dart';

enum RestaurantFilter {
  all,
  nearby
}

class RunsScreen extends ConsumerStatefulWidget {
  const RunsScreen({super.key});

  @override
  ConsumerState<RunsScreen> createState() => _RunsScreenState();
}

class _RunsScreenState extends ConsumerState<RunsScreen> {
  RestaurantFilter _selectedFilter = RestaurantFilter.all;
  // User location - will be null if not available
  // In a production app, get this from GPS/location services
  double? userLatitude;
  double? userLongitude;

  @override
  Widget build(BuildContext context) {
    final acceptedDemands = ref.watch(acceptedNgoDemandsForVolunteersProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(acceptedNgoDemandsForVolunteersProvider);
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 420;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Restaurant Accepted Deliveries',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _FilterChip(
                          label: 'All',
                          isSelected: _selectedFilter == RestaurantFilter.all,
                          onTap: () => setState(() => _selectedFilter = RestaurantFilter.all),
                        ),
                        _FilterChip(
                          label: '<5 km',
                          isSelected: _selectedFilter == RestaurantFilter.nearby,
                          onTap: () => setState(() => _selectedFilter = RestaurantFilter.nearby),
                        ),
                      ],
                    ),
                    if (!isCompact) const SizedBox.shrink(),
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: acceptedDemands.when(
              data: (demands) {
                var availableDemands = List<NGODemand>.from(demands);

                if (_selectedFilter == RestaurantFilter.nearby &&
                    userLatitude != null &&
                    userLongitude != null) {
                  availableDemands = availableDemands.where((demand) {
                    final lat = demand.ngoLatitude;
                    final lon = demand.ngoLongitude;
                    if (lat == null || lon == null) {
                      return false;
                    }
                    return _calculateVolunteerDistance(lat, lon) < 5;
                  }).toList();
                }

                if (availableDemands.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 80),
                      Icon(Icons.delivery_dining, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          'No accepted restaurant deliveries available',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Only restaurant-accepted NGO demands appear here.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: availableDemands.length,
                  itemBuilder: (context, index) {
                    return _RestaurantAcceptedDemandCard(
                      demand: availableDemands[index],
                      userLat: userLatitude ?? 0.0,
                      userLon: userLongitude ?? 0.0,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Failed to load accepted deliveries: $error',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateVolunteerDistance(double ngoLatitude, double ngoLongitude) {
    if (userLatitude == null || userLongitude == null) {
      return double.infinity;
    }

    const double earthRadius = 6371;
    final double dLat = _toRadians(ngoLatitude - userLatitude!);
    final double dLon = _toRadians(ngoLongitude - userLongitude!);

    final double a = (dLat / 2) * (dLat / 2) +
        math.cos(_toRadians(userLatitude!)) *
            math.cos(_toRadians(ngoLatitude)) *
            (dLon / 2) *
            (dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * (3.141592653589793 / 180);
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryColor,
    );
  }
}

class _RestaurantAcceptedDemandCard extends ConsumerStatefulWidget {
  const _RestaurantAcceptedDemandCard({
    required this.demand,
    required this.userLat,
    required this.userLon,
  });

  final NGODemand demand;
  final double userLat;
  final double userLon;

  @override
  ConsumerState<_RestaurantAcceptedDemandCard> createState() => _RestaurantAcceptedDemandCardState();
}

class _RestaurantAcceptedDemandCardState extends ConsumerState<_RestaurantAcceptedDemandCard> {
  bool _isAccepting = false;

  Future<void> _openGoogleMaps() async {
    final demand = widget.demand;
    if (demand.ngoLatitude != null && demand.ngoLongitude != null) {
      final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${demand.ngoLatitude},${demand.ngoLongitude}',
      );

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch Google Maps';
      }
    }
  }

  double? _calculateDistance() {
    final demand = widget.demand;
    if (demand.ngoLatitude != null && demand.ngoLongitude != null) {
      const double earthRadius = 6371; // Earth's radius in kilometers
      final double dLat = _toRadians(demand.ngoLatitude! - widget.userLat);
      final double dLon = _toRadians(demand.ngoLongitude! - widget.userLon);

      final double a = (dLat / 2) * (dLat / 2) + math.cos(_toRadians(widget.userLat)) * math.cos(_toRadians(demand.ngoLatitude!)) * (dLon / 2) * (dLon / 2);
      final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

      return earthRadius * c;
    }
    return null;
  }

  double _toRadians(double degrees) => degrees * (3.141592653589793 / 180);

  @override
  Widget build(BuildContext context) {
    final demand = widget.demand;
    final distance = _calculateDistance();

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Restaurant Image and Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image/Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.restaurant,
                  color: AppTheme.primaryColor,
                  size: 40,
                ),
              ),
              const SizedBox(width: 12),
              // Restaurant Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Restaurant Name (Top)
                    Text(
                      demand.restaurantName ?? 'Unknown Restaurant',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    // NGO Name (Below)
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            demand.ngoName,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Distance
                    if (distance != null)
                      Row(
                        children: [
                          Icon(Icons.straighten, size: 14, color: AppTheme.primaryColor),
                          const SizedBox(width: 4),
                          Text(
                            '${distance.toStringAsFixed(1)} km away',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    if (demand.description != null && demand.description!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        demand.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: demand.ngoLatitude != null && demand.ngoLongitude != null ? _openGoogleMaps : null,
                  icon: const Icon(Icons.directions, size: 16),
                  label: const Text('Navigate'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: PrimaryButton(
                  label: _isAccepting ? 'Accepting...' : 'Accept',
                  icon: Icons.check_circle,
                  onPressed: _isAccepting
                      ? null
                      : () async {
                          final token = ref.read(authProvider).token;

                          if (token == null) {
                            return;
                          }

                          if (demand.restaurantId == null || demand.restaurantId!.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Restaurant mapping is missing for this ride.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          setState(() {
                            _isAccepting = true;
                          });

                          try {
                            await DeliveryRunRemoteDataSource().acceptDeliveryRun(
                              token: token,
                              restaurantId: demand.restaurantId!,
                              ngoId: demand.ngoId,
                              ngoDemandId: demand.id,
                              pickupTime: demand.requiredBy.subtract(const Duration(hours: 1)),
                              deliveryTime: demand.requiredBy,
                              numberOfMeals: demand.amount,
                              description: demand.description ?? 'Volunteer pickup for ${demand.formattedAmount}',
                            );

                            ref.invalidate(userDeliveryRunsProvider);
                            ref.invalidate(acceptedNgoDemandsForVolunteersProvider);
                            ref.read(navIndexProvider.notifier).state = 2;

                            if (!mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Ride accepted. Opening activity details.'),
                                backgroundColor: Colors.green,
                              ),
                            );

                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const RideDetailsScreen(),
                              ),
                            );
                          } catch (e) {
                            if (!mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to accept ride: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isAccepting = false;
                              });
                            }
                          }
                        },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
