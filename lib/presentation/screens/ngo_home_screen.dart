import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_donation_app/core/theme/app_theme.dart';
import 'package:food_donation_app/domain/entities/ngo.dart';
import 'package:food_donation_app/presentation/screens/ngo_detail_screen.dart';
import 'package:food_donation_app/presentation/providers/app_providers.dart';

class NgoHomeScreen extends ConsumerStatefulWidget {
  const NgoHomeScreen({super.key});

  @override
  ConsumerState<NgoHomeScreen> createState() => _NgoHomeScreenState();
}

class _NgoHomeScreenState extends ConsumerState<NgoHomeScreen> {
  String? selectedLocation;
  // Mock user location (in a real app, get from GPS)
  final double userLatitude = 28.6139;
  final double userLongitude = 77.2090;

  @override
  Widget build(BuildContext context) {
    final ngoList = ref.watch(ngoListProvider);

    return Scaffold(
      body: ngoList.when(
        data: (ngos) {
          if (ngos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No NGOs found',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            );
          }

          // Filter by location if selected
          final filteredNgos = selectedLocation == null
              ? ngos
              : ngos.where((ngo) => ngo.location == selectedLocation).toList();

          // Sort by distance
          final sortedNgos = List<NGO>.from(filteredNgos)
            ..sort((a, b) {
              final distA = a.distanceFrom(userLatitude, userLongitude);
              final distB = b.distanceFrom(userLatitude, userLongitude);
              return distA.compareTo(distB);
            });

          // Get unique locations for filter
          final locations = ngos.map((ngo) => ngo.location).toSet().toList()..sort();

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(ngoListProvider);
            },
            child: CustomScrollView(
              slivers: [
                // Title Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NGOs Associated with Us',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Discover organizations making a difference in your community',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Location Filter
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _LocationChip(
                            label: 'All',
                            isSelected: selectedLocation == null,
                            onTap: () {
                              setState(() => selectedLocation = null);
                            },
                          ),
                          const SizedBox(width: 8),
                          ...locations.map((location) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _LocationChip(
                                  label: location,
                                  isSelected: selectedLocation == location,
                                  onTap: () {
                                    setState(() => selectedLocation = location);
                                  },
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
                // NGO Grid
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _NgoCard(
                          ngo: sortedNgos[index],
                          userLat: userLatitude,
                          userLon: userLongitude,
                        );
                      },
                      childCount: sortedNgos.length,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Error loading NGOs',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(ngoListProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NgoCard extends StatelessWidget {
  const _NgoCard({required this.ngo});

  final NGO ngo;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => NgoDetailScreen(ngo: ngo),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Main Image
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.3),
                      AppTheme.primaryColor.withOpacity(0.1),
                    ],
                  ),
                ),
                child: Image.network(
                  ngo.mainImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      child: Icon(
                        Icons.restaurant,
                        size: 48,
                        color: AppTheme.primaryColor.withOpacity(0.5),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        strokeWidth: 2,
                      ),
                    );
                  },
                ),
              ),
            ),
            // Name and Tagline
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      ngo.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ngo.tagline,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

