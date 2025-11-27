import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_donation_app/core/theme/app_theme.dart';
import 'package:food_donation_app/domain/entities/ngo_demand.dart';
import 'package:food_donation_app/presentation/providers/app_providers.dart';
import 'package:food_donation_app/presentation/widgets/app_card.dart';
import 'package:food_donation_app/presentation/widgets/primary_button.dart';
import 'package:food_donation_app/presentation/widgets/secondary_button.dart';
import 'package:food_donation_app/data/datasources/ngo_demand_remote_datasource.dart';

final ngoDemandsProvider = FutureProvider<List<NGODemand>>((ref) async {
  try {
    final authState = ref.watch(authProvider);
    final token = authState.token;

    if (token == null) {
      return <NGODemand>[];
    }

    final dataSource = NgoDemandRemoteDataSource();
    return await dataSource.getAllDemands(token);
  } catch (e) {
    print('Error fetching NGO demands: $e');
    return <NGODemand>[];
  }
});

class NgoNeedsScreen extends ConsumerWidget {
  const NgoNeedsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demands = ref.watch(ngoDemandsProvider);
    final authState = ref.watch(authProvider);
    final token = authState.token;

    return Scaffold(
      body: demands.when(
        data: (demandsList) {
          if (demandsList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No NGO needs at the moment',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back later for new requests',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(ngoDemandsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: demandsList.length,
              itemBuilder: (context, index) {
                final demand = demandsList[index];
                return _DemandCard(
                  demand: demand,
                  onAccept: token != null
                      ? () async {
                          try {
                            final dataSource = NgoDemandRemoteDataSource();
                            await dataSource.acceptDemand(token, demand.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Demand accepted! It will now appear in volunteer section.'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                            ref.invalidate(ngoDemandsProvider);
                            ref.invalidate(acceptedNgoDemandsProvider);
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      : null,
                  onIgnore: token != null
                      ? () async {
                          try {
                            final dataSource = NgoDemandRemoteDataSource();
                            await dataSource.ignoreDemand(token, demand.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Demand ignored'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                            ref.invalidate(ngoDemandsProvider);
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      : null,
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              const Text('Error loading demands'),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(ngoDemandsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemandCard extends StatelessWidget {
  const _DemandCard({
    required this.demand,
    this.onAccept,
    this.onIgnore,
  });

  final NGODemand demand;
  final VoidCallback? onAccept;
  final VoidCallback? onIgnore;

  @override
  Widget build(BuildContext context) {
    final isUrgent = demand.requiredBy.difference(DateTime.now()).inDays < 2;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
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
                      demand.ngoName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      demand.formattedAmount,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              if (isUrgent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red, width: 1),
                  ),
                  child: Text(
                    'URGENT',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'Required by: ${_formatDateTime(demand.requiredBy)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                demand.formattedDate,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isUrgent ? Colors.red : Colors.grey[600],
                      fontWeight: isUrgent ? FontWeight.bold : FontWeight.normal,
                    ),
              ),
            ],
          ),
          if (demand.description != null && demand.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              demand.description!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: 'Ignore',
                  icon: Icons.close,
                  onPressed: onIgnore,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: PrimaryButton(
                  label: 'Accept',
                  icon: Icons.check_circle,
                  onPressed: onAccept,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

