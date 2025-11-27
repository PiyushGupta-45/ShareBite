import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_donation_app/core/theme/app_theme.dart';
import 'package:food_donation_app/domain/entities/ngo.dart';
import 'package:food_donation_app/domain/entities/restaurant.dart';
import 'package:food_donation_app/data/datasources/delivery_run_remote_datasource.dart';
import 'package:food_donation_app/presentation/providers/app_providers.dart';
import 'package:food_donation_app/presentation/widgets/app_card.dart';
import 'package:food_donation_app/presentation/widgets/primary_button.dart';
import 'package:food_donation_app/presentation/widgets/secondary_button.dart';

class AcceptDeliveryScreen extends ConsumerStatefulWidget {
  const AcceptDeliveryScreen({
    super.key,
    required this.restaurant,
  });

  final Restaurant restaurant;

  @override
  ConsumerState<AcceptDeliveryScreen> createState() => _AcceptDeliveryScreenState();
}

class _AcceptDeliveryScreenState extends ConsumerState<AcceptDeliveryScreen> {
  NGO? selectedNGO;
  final _mealsController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _pickupTime;
  DateTime? _deliveryTime;
  bool _isLoading = false;

  @override
  void dispose() {
    _mealsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectPickupTime() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _pickupTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _selectDeliveryTime() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _pickupTime ?? DateTime.now().add(const Duration(hours: 2)),
      firstDate: _pickupTime ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _deliveryTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _submitAcceptance() async {
    if (selectedNGO == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an NGO'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_mealsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter number of meals'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_pickupTime == null || _deliveryTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select pickup and delivery times'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authState = ref.read(authProvider);
      final token = authState.token;

      if (token == null) {
        throw Exception('Not authenticated. Please sign in again.');
      }

      final deliveryRunDataSource = DeliveryRunRemoteDataSource();
      await deliveryRunDataSource.acceptDeliveryRun(
        token: token,
        restaurantId: widget.restaurant.id,
        ngoId: selectedNGO!.id,
        pickupTime: _pickupTime!,
        deliveryTime: _deliveryTime!,
        numberOfMeals: int.parse(_mealsController.text),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
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
    final ngos = ref.watch(ngoListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accept Delivery'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Restaurant Info
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Restaurant',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.restaurant.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.restaurant.address,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Select NGO
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select NGO *',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ngos.when(
                    data: (ngoList) {
                      if (ngoList.isEmpty) {
                        return const Text('No NGOs available');
                      }
                      return Column(
                        children: ngoList.map((ngo) {
                          final isSelected = selectedNGO?.id == ngo.id;
                          return InkWell(
                            onTap: () => setState(() => selectedNGO = ngo),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primaryColor.withOpacity(0.1)
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primaryColor
                                      : Colors.grey[300]!,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                                    color: isSelected
                                        ? AppTheme.primaryColor
                                        : Colors.grey[600],
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ngo.name,
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        Text(
                                          ngo.location,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Colors.grey[600],
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Text('Error loading NGOs: $error'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Delivery Details
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delivery Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _mealsController,
                    decoration: const InputDecoration(
                      labelText: 'Number of Meals *',
                      hintText: 'Enter number of meals',
                      prefixIcon: Icon(Icons.restaurant_menu),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _selectPickupTime,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Pickup Time *',
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      child: Text(
                        _pickupTime != null
                            ? '${_pickupTime!.day}/${_pickupTime!.month}/${_pickupTime!.year} ${_pickupTime!.hour.toString().padLeft(2, '0')}:${_pickupTime!.minute.toString().padLeft(2, '0')}'
                            : 'Select pickup time',
                        style: TextStyle(
                          color: _pickupTime != null ? Colors.black : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _selectDeliveryTime,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Delivery Time *',
                        prefixIcon: Icon(Icons.schedule),
                      ),
                      child: Text(
                        _deliveryTime != null
                            ? '${_deliveryTime!.day}/${_deliveryTime!.month}/${_deliveryTime!.year} ${_deliveryTime!.hour.toString().padLeft(2, '0')}:${_deliveryTime!.minute.toString().padLeft(2, '0')}'
                            : 'Select delivery time',
                        style: TextStyle(
                          color: _deliveryTime != null ? Colors.black : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      hintText: 'Add any additional notes',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
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

