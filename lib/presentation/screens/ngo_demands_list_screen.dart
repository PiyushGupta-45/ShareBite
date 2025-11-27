import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_donation_app/core/theme/app_theme.dart';
import 'package:food_donation_app/domain/entities/ngo_demand.dart';
import 'package:food_donation_app/presentation/providers/app_providers.dart';
import 'package:food_donation_app/presentation/widgets/app_card.dart';
import 'package:food_donation_app/presentation/screens/create_demand_screen.dart';
import 'package:food_donation_app/data/datasources/ngo_demand_remote_datasource.dart';
import 'package:intl/intl.dart';

// Provider for NGO admin's demands
final ngoAdminDemandsProvider = FutureProvider.family<List<NGODemand>, String>((ref, ngoId) async {
  try {
    final authState = ref.watch(authProvider);
    final token = authState.token;

    if (token == null) {
      return <NGODemand>[];
    }

    final dataSource = NgoDemandRemoteDataSource();
    return await dataSource.getDemandsByNGO(token, ngoId);
  } catch (e) {
    print('Error fetching NGO demands: $e');
    return <NGODemand>[];
  }
});

class NgoDemandsListScreen extends ConsumerStatefulWidget {
  const NgoDemandsListScreen({super.key});

  @override
  ConsumerState<NgoDemandsListScreen> createState() => _NgoDemandsListScreenState();
}

class _NgoDemandsListScreenState extends ConsumerState<NgoDemandsListScreen> {
  String? _selectedNgoId;

  @override
  void initState() {
    super.initState();
    // Get first NGO as default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ngos = ref.read(ngoListProvider);
      ngos.whenData((ngoList) {
        if (ngoList.isNotEmpty && _selectedNgoId == null) {
          setState(() {
            _selectedNgoId = ngoList.first.id;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final ngos = ref.watch(ngoListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Demands'),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // NGO Selection
          Padding(
            padding: const EdgeInsets.all(16),
            child: ngos.when(
              data: (ngoList) {
                if (ngoList.isEmpty) {
                  return const Text('No NGOs available');
                }
                if (_selectedNgoId == null && ngoList.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _selectedNgoId = ngoList.first.id;
                    });
                  });
                }
                return DropdownButtonFormField<String>(
                  value: _selectedNgoId,
                  decoration: const InputDecoration(
                    labelText: 'Select NGO',
                    prefixIcon: Icon(Icons.business),
                  ),
                  items: ngoList.map((ngo) {
                    return DropdownMenuItem<String>(
                      value: ngo.id,
                      child: Text(ngo.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedNgoId = value;
                    });
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Error loading NGOs'),
            ),
          ),
          // Demands List
          if (_selectedNgoId != null)
            Expanded(
              child: _DemandsList(
                ngoId: _selectedNgoId!,
                onRefresh: () {
                  ref.invalidate(ngoAdminDemandsProvider(_selectedNgoId!));
                },
              ),
            )
          else
            const Expanded(
              child: Center(
                child: Text('Please select an NGO'),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (_selectedNgoId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select an NGO first'),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }

          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreateDemandScreen(),
            ),
          );

          if (mounted) {
            if (result == true && _selectedNgoId != null) {
              // Refresh the demands list
              ref.invalidate(ngoAdminDemandsProvider(_selectedNgoId!));
              // Also refresh NGO list in case a new one was created
              ref.invalidate(ngoListProvider);
            }
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Demand'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
}

class _DemandsList extends ConsumerWidget {
  const _DemandsList({
    required this.ngoId,
    this.onRefresh,
  });

  final String ngoId;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demands = ref.watch(ngoAdminDemandsProvider(ngoId));

    return demands.when(
      data: (demandsList) {
        if (demandsList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No demands created yet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the + button to create your first demand',
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
            ref.invalidate(ngoAdminDemandsProvider(ngoId));
            onRefresh?.call();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: demandsList.length,
            itemBuilder: (context, index) {
              return _DemandCard(
                demand: demandsList[index],
                onEdit: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CreateDemandScreen(demand: demandsList[index]),
                    ),
                  );
                  if (result == true) {
                    ref.invalidate(ngoAdminDemandsProvider(ngoId));
                  }
                },
                onDelete: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Demand'),
                      content: const Text('Are you sure you want to delete this demand? This action cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    try {
                      final authState = ref.read(authProvider);
                      final token = authState.token;
                      if (token != null) {
                        final dataSource = NgoDemandRemoteDataSource();
                        await dataSource.deleteDemand(token, demandsList[index].id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Demand deleted successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                        ref.invalidate(ngoAdminDemandsProvider(ngoId));
                      }
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
                },
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
              onPressed: () => ref.invalidate(ngoAdminDemandsProvider(ngoId)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DemandCard extends StatelessWidget {
  const _DemandCard({
    required this.demand,
    required this.onEdit,
    required this.onDelete,
  });

  final NGODemand demand;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd/MM/yyyy').format(demand.requiredBy);
    final formattedTime = DateFormat('HH:mm').format(demand.requiredBy);
    final isUrgent = demand.requiredBy.difference(DateTime.now()).inDays < 2;
    final isAccepted = demand.status == 'accepted';

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
                      demand.formattedAmount,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      demand.ngoName,
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
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red, width: 1),
                  ),
                  child: const Text(
                    'URGENT',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (isAccepted)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green, width: 1),
                  ),
                  child: const Text(
                    'ACCEPTED',
                    style: TextStyle(
                      color: Colors.green,
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
                'Required: $formattedDate at $formattedTime',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'Status: ${demand.status.toUpperCase()}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
          if (demand.description != null && demand.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              demand.description!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isAccepted ? null : onEdit,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isAccepted ? null : onDelete,
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    foregroundColor: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
