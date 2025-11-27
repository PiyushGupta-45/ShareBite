import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_donation_app/presentation/providers/app_providers.dart';
import 'package:food_donation_app/presentation/widgets/impact_card.dart';
import 'package:food_donation_app/presentation/widgets/section_header.dart';

class GamificationScreen extends ConsumerWidget {
  const GamificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(gamificationStatsProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: stats.when(
        data: (value) => ListView(
          children: [
            const SectionHeader(title: 'Impact dashboard'),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 220,
                  child: ImpactCard(
                    label: 'CO₂ saved',
                    value: '${value.co2SavedKg.toStringAsFixed(1)} kg',
                    subtitle: 'Equivalent to 48 trees / year',
                    icon: Icons.cloud_done,
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: ImpactCard(
                    label: 'Meals served',
                    value: value.mealsServed.toString(),
                    subtitle: 'Across metro & peri-urban belts',
                    icon: Icons.restaurant,
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: ImpactCard(
                    label: 'Active streak',
                    value: '${value.activeStreakDays} days',
                    subtitle: 'Keep momentum for bonus multipliers',
                    icon: Icons.local_fire_department,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SectionHeader(
              title: 'Badges earned',
              action: Chip(
                label: Text('${value.badges.length} unlocked'),
              ),
            ),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: value.badges
                  .map(
                    (badge) => Chip(
                      avatar: const Icon(Icons.shield_moon),
                      label: Text(badge),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Leaderboards'),
            ...value.leaderboard.map(
              (entry) => Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text('#${entry.rank}')),
                  title: Text(entry.user),
                  subtitle: Text('${entry.mealsServed} meals impact'),
                  trailing: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Applaud'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Impact pulse'),
            Container(
              height: 160,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: const Text(
                'Graph placeholder for CO₂ vs meals served trends',
              ),
            ),
          ],
        ),
        error: (error, _) => Center(child: Text('Error: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

