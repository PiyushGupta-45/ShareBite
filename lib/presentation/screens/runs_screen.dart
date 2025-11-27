import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_donation_app/core/theme/app_theme.dart';
import 'package:food_donation_app/domain/entities/restaurant.dart';
import 'package:food_donation_app/presentation/providers/app_providers.dart';
import 'package:food_donation_app/presentation/screens/accept_delivery_screen.dart';
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
  // Mock user location (in a real app, get from GPS)
  final double userLatitude = 28.6139;
  final double userLongitude = 77.2090;

  @override
  Widget build(BuildContext context) {
    final restaurants = ref.watch(restaurantsProvider);

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
                    onTap: () => setState(() => _selectedFilter = RestaurantFilter.nearby),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Restaurants list
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(restaurantsProvider);
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

class _RestaurantCard extends StatelessWidget {
  const _RestaurantCard({
    required this.restaurant,
    required this.userLat,
    required this.userLon,
  });

  final Restaurant restaurant;
  final double userLat;
  final double userLon;

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
                  onPressed: () {
                    Navigator.of(context)
                        .push(
                      MaterialPageRoute(
                        builder: (context) => AcceptDeliveryScreen(restaurant: restaurant),
                      ),
                    )
                        .then((result) {
                      // Refresh restaurant list if delivery was accepted
                      if (result == true) {
                        ref.invalidate(restaurantsProvider);
                      }
                    });
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
