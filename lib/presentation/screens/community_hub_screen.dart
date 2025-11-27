import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_donation_app/core/theme/app_theme.dart';
import 'package:food_donation_app/presentation/providers/app_providers.dart';
import 'package:food_donation_app/presentation/widgets/app_card.dart';
import 'package:food_donation_app/presentation/widgets/secondary_button.dart';

class CommunityHubScreen extends ConsumerWidget {
  const CommunityHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forumPosts = ref.watch(forumPostsProvider);
    final squadAlerts = ref.watch(hungerSquadAlertsProvider);
    final barters = ref.watch(resourceBartersProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(forumPostsProvider);
        ref.invalidate(hungerSquadAlertsProvider);
        ref.invalidate(resourceBartersProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Zero Waste Forums (2 latest posts)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Zero Waste Forums',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to full forums
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            forumPosts.when(
              data: (posts) {
                final latest = posts.take(2).toList();
                if (latest.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'No forum posts yet.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  );
                }
                return Column(
                  children: latest.map((post) => AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              child: Text(post.author[0].toUpperCase()),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.author,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    post.topic,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.thumb_up, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text('${post.upvotes}'),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          post.message,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  )).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),
            // Friendship Lane tips (minimal text)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Friendship Lane Tips',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: AppTheme.accentColor),
                      const SizedBox(width: 8),
                      Text(
                        'Quick Tip',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Always check expiration dates and food quality before accepting donations.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // SOS calls (highest priority first)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SOS Calls',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to all SOS calls
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            squadAlerts.when(
              data: (alerts) {
                // Sort by priority (emergency first)
                final sorted = alerts.toList()
                  ..sort((a, b) => b.isEmergency ? 1 : -1);
                final topPriority = sorted.take(3).toList();

                if (topPriority.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'No SOS calls at the moment.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  );
                }

                return Column(
                  children: topPriority.map((alert) => AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: alert.isEmergency
                                    ? Colors.red[50]
                                    : Colors.orange[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                alert.isEmergency
                                    ? Icons.emergency
                                    : Icons.warning,
                                color: alert.isEmergency
                                    ? Colors.red
                                    : Colors.orange,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    alert.groupName,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    '${alert.location} • ${alert.peopleImpacted} people',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          alert.need,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        SecondaryButton(
                          label: 'Dispatch Aid',
                          icon: Icons.send,
                          onPressed: () {
                            // Handle dispatch
                          },
                        ),
                      ],
                    ),
                  )).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),
            // Resource Barter (simple, two-line cards)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Resource Barter',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to all barters
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            barters.when(
              data: (listings) {
                if (listings.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'No barter listings yet.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  );
                }
                return Column(
                  children: listings.take(3).map((listing) => AppCard(
                    child: Row(
                      children: [
                        Icon(Icons.swap_horiz, color: AppTheme.primaryColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                listing.requester,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Offers: ${listing.offer} • Needs: ${listing.request}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Chip(
                          label: Text(listing.status),
                          backgroundColor: listing.status == 'Open'
                              ? Colors.green[50]
                              : Colors.grey[200],
                        ),
                      ],
                    ),
                  )).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
