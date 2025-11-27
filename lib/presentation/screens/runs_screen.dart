import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_donation_app/core/theme/app_theme.dart';
import 'package:food_donation_app/domain/entities/restaurant.dart';
import 'package:food_donation_app/domain/entities/ngo_demand.dart';
import 'package:food_donation_app/presentation/providers/app_providers.dart';
import 'package:food_donation_app/presentation/screens/accept_delivery_screen.dart';
import 'package:food_donation_app/presentation/widgets/app_card.dart';
import 'package:food_donation_app/presentation/widgets/primary_button.dart';
import 'package:intl/intl.dart';
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
  // Mock user location (in a real app, get from GPS)
  final double userLatitude = 28.6139;
  final double userLongitude = 77.2090;

  @override
  Widget build(BuildContext context) {
    final restaurants = ref.watch(restaurantsProvider);
    final acceptedDemands = ref.watch(acceptedNgoDemandsForVolunteersProvider);

    return Column(
      children: [
        // Title and Filter
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Restaurant Partners',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
              ),
              Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    isSelected: _selectedFilter == RestaurantFilter.all,
                    onTap: () => setState(() => _selectedFilter = RestaurantFilter.all),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: '<5 km',
                    isSelected: _selectedFilter == RestaurantFilter.nearby,
                    onTap: () => setState(() => _selectedFilter == RestaurantFilter.nearby),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Restaurant Accepted Demands Section (for volunteers)
        acceptedDemands.when(
          data: (demands) {
            if (demands.isNotEmpty) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Restaurant Accepted Deliveries',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: demands.length,
                        itemBuilder: (context, index) {
                          return _RestaurantAcceptedDemandCard(
                            demand: demands[index],
                            userLat: userLatitude,
                            userLon: userLongitude,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        // Restaurants list
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(restaurantsProvider);
              ref.invalidate(acceptedNgoDemandsForVolunteersProvider);
            },
            child: restaurants.when(
              data: (items) {
                // Filter by location if selected
                final filtered = _selectedFilter == RestaurantFilter.nearby ? items.where((r) => r.distanceFrom(userLatitude, userLongitude) < 5).toList() : items;

                // Sort by distance
                final sorted = List<Restaurant>.from(filtered)
                  ..sort((a, b) {
                    final distA = a.distanceFrom(userLatitude, userLongitude);
                    final distB = b.distanceFrom(userLatitude, userLongitude);
                    return distA.compareTo(distB);
                  });

                if (sorted.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.restaurant, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No restaurants found',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different filter',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: sorted.length,
                  itemBuilder: (context, index) {
                    return _RestaurantCard(
                      restaurant: sorted[index],
                      userLat: userLatitude,
                      userLon: userLongitude,
                      onDeliveryAccepted: () {
                        ref.invalidate(restaurantsProvider);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    const Text('Error loading restaurants'),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref.invalidate(restaurantsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
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
  bool _isAccepted = false;

  @override
  Widget build(BuildContext context) {
    final demand = widget.demand;
    final formattedDate = DateFormat('dd/MM/yyyy').format(demand.requiredBy);
    final formattedTime = DateFormat('HH:mm').format(demand.requiredBy);

    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 12),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Name (Top)
            Row(
              children: [
                Icon(Icons.restaurant, color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    demand.restaurantName ?? 'Unknown Restaurant',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // NGO Name (Below)
            Row(
              children: [
                Icon(Icons.business, color: Colors.grey[600], size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    demand.ngoName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              demand.formattedAmount,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '$formattedDate at $formattedTime',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
            const Spacer(),
            const SizedBox(height: 12),
            if (!_isAccepted)
              PrimaryButton(
                label: 'Accept Delivery',
                icon: Icons.check_circle,
                onPressed: () async {
                  // Show NGO location after accepting
                  if (demand.ngoLocation != null || demand.ngoAddress != null) {
                    final location = demand.ngoAddress ?? demand.ngoLocation ?? 'Location not available';
                    final lat = demand.ngoLatitude;
                    final lon = demand.ngoLongitude;

                    if (mounted) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delivery Accepted!'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'NGO Location:',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(location),
                              if (lat != null && lon != null) ...[
                                const SizedBox(height: 16),
                                OutlinedButton.icon(
                                  onPressed: () async {
                                    final url = Uri.parse(
                                      'https://www.google.com/maps/search/?api=1&query=$lat,$lon',
                                    );
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url, mode: LaunchMode.externalApplication);
                                    }
                                  },
                                  icon: const Icon(Icons.directions, size: 16),
                                  label: const Text('Navigate to NGO'),
                                ),
                              ],
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                setState(() {
                                  _isAccepted = true;
                                });
                                // Refresh the list
                                ref.invalidate(acceptedNgoDemandsForVolunteersProvider);
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  } else {
                    setState(() {
                      _isAccepted = true;
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Delivery accepted!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                    ref.invalidate(acceptedNgoDemandsForVolunteersProvider);
                  }
                },
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Accepted',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  const _RestaurantCard({
    required this.restaurant,
    required this.userLat,
    required this.userLon,
    required this.onDeliveryAccepted,
  });

  final Restaurant restaurant;
  final double userLat;
  final double userLon;
  final VoidCallback onDeliveryAccepted;

  Future<void> _openGoogleMaps() async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${restaurant.latitude},${restaurant.longitude}&query_place_id=${restaurant.name}',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch Google Maps';
    }
  }

  @override
  Widget build(BuildContext context) {
    final distance = restaurant.distanceFrom(userLat, userLon);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Restaurant Image and Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: restaurant.image != null && restaurant.image!.isNotEmpty
                    ? Image.network(
                        restaurant.image!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 100,
                            height: 100,
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            child: Icon(
                              Icons.restaurant,
                              color: AppTheme.primaryColor,
                              size: 40,
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 100,
                        height: 100,
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        child: Icon(
                          Icons.restaurant,
                          color: AppTheme.primaryColor,
                          size: 40,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              // Restaurant Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            restaurant.location,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
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
                    if (restaurant.description != null && restaurant.description!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        restaurant.description!,
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
                  onPressed: _openGoogleMaps,
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
                  label: 'Accept',
                  icon: Icons.check_circle,
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AcceptDeliveryScreen(restaurant: restaurant),
                      ),
                    );
                    // Refresh restaurant list if delivery was accepted
                    if (result == true) {
                      onDeliveryAccepted();
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
