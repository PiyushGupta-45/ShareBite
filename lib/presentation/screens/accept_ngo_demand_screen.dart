import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_donation_app/core/theme/app_theme.dart';
import 'package:food_donation_app/domain/entities/ngo_demand.dart';
import 'package:food_donation_app/presentation/providers/app_providers.dart';
import 'package:food_donation_app/presentation/widgets/app_card.dart';
import 'package:food_donation_app/presentation/widgets/primary_button.dart';
import 'package:food_donation_app/presentation/widgets/secondary_button.dart';
import 'package:food_donation_app/data/datasources/delivery_run_remote_datasource.dart';
import 'package:intl/intl.dart';

class AcceptNgoDemandScreen extends ConsumerStatefulWidget {
  const AcceptNgoDemandScreen({
    super.key,
    required this.demand,
  });

  final NGODemand demand;

  @override
  ConsumerState<AcceptNgoDemandScreen> createState() => _AcceptNgoDemandScreenState();
}

class _AcceptNgoDemandScreenState extends ConsumerState<AcceptNgoDemandScreen> {
  bool _isLoading = false;

  Future<void> _submitAcceptance() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authState = ref.read(authProvider);
      final token = authState.token;

      if (token == null) {
        throw Exception('Not authenticated. Please sign in again.');
      }

      // Create delivery run from NGO demand
      final deliveryRunDataSource = DeliveryRunRemoteDataSource();
      await deliveryRunDataSource.acceptDeliveryRun(
        token: token,
        restaurantId: '', // No restaurant for NGO demands
        ngoId: widget.demand.ngoId,
        pickupTime: widget.demand.requiredBy.subtract(const Duration(hours: 1)), // Pickup 1 hour before required
        deliveryTime: widget.demand.requiredBy,
        numberOfMeals: widget.demand.amount,
        description: widget.demand.description ?? 'NGO Demand: ${widget.demand.formattedAmount}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery run accepted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh delivery runs
        ref.invalidate(userDeliveryRunsProvider);
        ref.invalidate(acceptedNgoDemandsProvider);
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final demand = widget.demand;
    final formattedDate = DateFormat('dd/MM/yyyy').format(demand.requiredBy);
    final formattedTime = DateFormat('HH:mm').format(demand.requiredBy);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accept NGO Demand'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // NGO Info
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NGO',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    demand.ngoName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Demand Details
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Demand Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(
                    icon: Icons.restaurant_menu,
                    label: 'Amount',
                    value: demand.formattedAmount,
                  ),
                  const Divider(),
                  _InfoRow(
                    icon: Icons.calendar_today,
                    label: 'Required Date',
                    value: formattedDate,
                  ),
                  const Divider(),
                  _InfoRow(
                    icon: Icons.access_time,
                    label: 'Required Time',
                    value: formattedTime,
                  ),
                  if (demand.description != null && demand.description!.isNotEmpty) ...[
                    const Divider(),
                    _InfoRow(
                      icon: Icons.description,
                      label: 'Description',
                      value: demand.description!,
                    ),
                  ],
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Delivery must be completed by the date and time specified above.',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: _isLoading ? 'Accepting...' : 'Accept Delivery',
              onPressed: _isLoading ? null : _submitAcceptance,
            ),
            const SizedBox(height: 12),
            SecondaryButton(
              label: 'Cancel',
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
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

