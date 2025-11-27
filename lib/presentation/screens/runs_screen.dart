import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_donation_app/core/theme/app_theme.dart';
import 'package:food_donation_app/presentation/providers/app_providers.dart';
import 'package:food_donation_app/presentation/widgets/app_card.dart';
import 'package:food_donation_app/presentation/widgets/primary_button.dart';
import 'package:food_donation_app/presentation/widgets/secondary_button.dart';

enum RunFilter { all, urgent, flex, nearby, tonight }

class RunsScreen extends ConsumerStatefulWidget {
  const RunsScreen({super.key});

  @override
  ConsumerState<RunsScreen> createState() => _RunsScreenState();
}

class _RunsScreenState extends ConsumerState<RunsScreen> {
  RunFilter _selectedFilter = RunFilter.all;

  @override
  Widget build(BuildContext context) {
    final alerts = ref.watch(logisticsAlertsProvider);

    return Column(
      children: [
        // Filter chips
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _selectedFilter == RunFilter.all,
                  onTap: () => setState(() => _selectedFilter = RunFilter.all),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Urgent',
                  isSelected: _selectedFilter == RunFilter.urgent,
                  onTap: () => setState(() => _selectedFilter = RunFilter.urgent),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Flex',
                  isSelected: _selectedFilter == RunFilter.flex,
                  onTap: () => setState(() => _selectedFilter = RunFilter.flex),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: '<5 km',
                  isSelected: _selectedFilter == RunFilter.nearby,
                  onTap: () => setState(() => _selectedFilter = RunFilter.nearby),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Tonight',
                  isSelected: _selectedFilter == RunFilter.tonight,
                  onTap: () => setState(() => _selectedFilter = RunFilter.tonight),
                ),
              ],
            ),
          ),
        ),
        // Runs list
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(logisticsAlertsProvider);
            },
            child: alerts.when(
              data: (items) {
                final filtered = _filterRuns(items);
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No runs found',
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
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _RunCard(run: filtered[index]);
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
                    Text('Error loading runs'),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref.invalidate(logisticsAlertsProvider),
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

  List<dynamic> _filterRuns(List<dynamic> runs) {
    final now = DateTime.now();
    final tonight = DateTime(now.year, now.month, now.day, 23, 59);

    switch (_selectedFilter) {
      case RunFilter.all:
        return runs;
      case RunFilter.urgent:
        return runs.where((r) =>
            r.urgencyTag.contains('Urgent') ||
            r.urgencyTag.contains('Flash') ||
            r.expiry.difference(now).inMinutes < 60).toList();
      case RunFilter.flex:
        return runs.where((r) => r.expiry.difference(now).inHours > 4).toList();
      case RunFilter.nearby:
        return runs.where((r) => r.radiusKm < 5).toList();
      case RunFilter.tonight:
        return runs.where((r) => r.expiry.isBefore(tonight)).toList();
    }
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

class _RunCard extends StatelessWidget {
  const _RunCard({required this.run});

  final dynamic run;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeLeft = run.expiry.difference(now);
    final isUrgent = timeLeft.inMinutes < 60;

    return AppCard(
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
                      run.donorName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${run.location} → Drop Point',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              if (isUrgent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'URGENT',
                    style: TextStyle(
                      color: AppTheme.accentColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _InfoChip(
                icon: Icons.access_time,
                label: _formatDuration(timeLeft),
                color: isUrgent ? AppTheme.accentColor : AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              _InfoChip(
                icon: Icons.straighten,
                label: '${run.radiusKm.toStringAsFixed(1)} km',
                color: AppTheme.primaryColor,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'Accept Run',
                  onPressed: () {
                    // Handle accept
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Accepted run from ${run.donorName}')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              SecondaryButton(
                label: 'Ping Squad',
                icon: Icons.group,
                isCompact: true,
                onPressed: () {
                  // Handle ping squad
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return 'Expired';
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
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

