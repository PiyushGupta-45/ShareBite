import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_donation_app/core/theme/app_theme.dart';
import 'package:food_donation_app/presentation/providers/app_providers.dart';
import 'package:food_donation_app/presentation/screens/ride_details_screen.dart';
import 'package:food_donation_app/presentation/widgets/app_card.dart';
import 'package:food_donation_app/presentation/widgets/primary_button.dart';

class ImpactScreen extends ConsumerWidget {
  const ImpactScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(gamificationStatsProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(gamificationStatsProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: stats.when(
          data: (data) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // User Info Card
              if (user != null) _UserInfoCard(user: user),
              const SizedBox(height: 16),
              // Hero Stats Card
              _HeroStatsCard(stats: data),
              const SizedBox(height: 24),
              // Ride Details Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PrimaryButton(
                  label: 'Ride Details',
                  icon: Icons.directions_car,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const RideDetailsScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              // Badges
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Badges',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              _BadgesSection(badges: data.badges),
              const SizedBox(height: 24),
              // Leaderboard
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Leaderboard',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              _LeaderboardSection(leaderboard: data.leaderboard),
              const SizedBox(height: 32),
            ],
          ),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text('Error loading activity data'),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => ref.invalidate(gamificationStatsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UserInfoCard extends StatelessWidget {
  const _UserInfoCard({required this.user});

  final dynamic user;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppTheme.primaryColor,
            backgroundImage: user.picture != null && user.picture!.isNotEmpty
                ? NetworkImage(user.picture!)
                : null,
            child: user.picture == null || user.picture!.isEmpty
                ? Text(
                    user.name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStatsCard extends StatelessWidget {
  const _HeroStatsCard({required this.stats});

  final dynamic stats;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          // CO₂ Saved
          _StatItem(
            icon: Icons.eco,
            label: 'CO₂ Saved',
            value: '${stats.co2SavedKg.toStringAsFixed(1)} kg',
            color: Colors.green,
          ),
          const Divider(height: 32),
          // Meals Served
          _StatItem(
            icon: Icons.restaurant,
            label: 'Meals Served',
            value: '${stats.mealsServed}',
            color: AppTheme.primaryColor,
          ),
          const Divider(height: 32),
          // Streak
          _StatItem(
            icon: Icons.local_fire_department,
            label: 'Streak',
            value: '${stats.activeStreakDays} days',
            color: AppTheme.accentColor,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BadgesSection extends StatelessWidget {
  const _BadgesSection({required this.badges});

  final List<String> badges;

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'No badges yet. Complete runs to earn badges!',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: badges.length,
        itemBuilder: (context, index) {
          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    color: AppTheme.primaryColor,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  badges[index],
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LeaderboardSection extends StatelessWidget {
  const _LeaderboardSection({required this.leaderboard});

  final List<dynamic> leaderboard;

  @override
  Widget build(BuildContext context) {
    final top3 = leaderboard.take(3).toList();

    if (top3.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'No leaderboard data yet.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      );
    }

    return Column(
      children: top3.asMap().entries.map((entry) {
        final index = entry.key;
        final entryData = entry.value;
        return AppCard(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              // Rank
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: index == 0
                      ? Colors.amber[100]
                      : index == 1
                          ? Colors.grey[200]
                          : Colors.brown[100],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: index == 0
                          ? Colors.amber[900]
                          : index == 1
                              ? Colors.grey[800]
                              : Colors.brown[900],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entryData.user,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${entryData.mealsServed} meals served',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              // Trophy icon for #1
              if (index == 0)
                Icon(
                  Icons.emoji_events,
                  color: Colors.amber[700],
                  size: 24,
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

