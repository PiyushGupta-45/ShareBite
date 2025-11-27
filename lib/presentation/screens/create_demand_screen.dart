import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_donation_app/core/theme/app_theme.dart';
import 'package:food_donation_app/data/datasources/ngo_demand_remote_datasource.dart';
import 'package:food_donation_app/presentation/providers/app_providers.dart';
import 'package:food_donation_app/presentation/widgets/app_card.dart';
import 'package:food_donation_app/presentation/widgets/primary_button.dart';
import 'package:food_donation_app/presentation/widgets/secondary_button.dart';
import 'package:food_donation_app/domain/entities/ngo_demand.dart';
import 'package:intl/intl.dart';

class CreateDemandScreen extends ConsumerStatefulWidget {
  const CreateDemandScreen({super.key, this.demand});

  final NGODemand? demand; // If provided, we're editing

  @override
  ConsumerState<CreateDemandScreen> createState() => _CreateDemandScreenState();
}

class _CreateDemandScreenState extends ConsumerState<CreateDemandScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedUnit = 'meals';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedNgoId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill form if editing
    if (widget.demand != null) {
      final demand = widget.demand!;
      _amountController.text = demand.amount.toString();
      _selectedUnit = demand.unit;
      _selectedDate = demand.requiredBy;
      _selectedTime = TimeOfDay.fromDateTime(demand.requiredBy);
      _descriptionController.text = demand.description ?? '';
      _selectedNgoId = demand.ngoId;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      _selectTime();
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _submitForm(WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date and time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.demand == null && _selectedNgoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an NGO'),
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

      // Combine date and time
      final requiredBy = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final dataSource = NgoDemandRemoteDataSource();

      if (widget.demand != null) {
        // Update existing demand
        await dataSource.updateDemand(
          token: token,
          demandId: widget.demand!.id,
          amount: int.parse(_amountController.text.trim()),
          unit: _selectedUnit,
          requiredBy: requiredBy,
          description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Demand updated successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          await Future.delayed(const Duration(milliseconds: 500));

          if (mounted) {
            Navigator.of(context).pop(true);
          }
        }
      } else {
        // Create new demand
        final ngoId = _selectedNgoId ?? widget.demand?.ngoId;
        if (ngoId == null) {
          throw Exception('NGO ID is required');
        }

        await dataSource.createDemand(
          token: token,
          ngoId: ngoId,
          amount: int.parse(_amountController.text.trim()),
          unit: _selectedUnit,
          requiredBy: requiredBy,
          description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
        );

        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Demand created successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Wait a bit for the snackbar to show, then pop
          await Future.delayed(const Duration(milliseconds: 500));

          if (mounted) {
            Navigator.of(context).pop(true);
          }
        }
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
    final ngoList = ref.watch(ngoListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.demand != null ? 'Edit Demand' : 'Create Demand'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Demand Information',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                    ),
                    const SizedBox(height: 16),
                    // NGO Selection (disabled if editing)
                    ngoList.when(
                      data: (ngos) {
                        if (ngos.isEmpty) {
                          return const Text('No NGOs available');
                        }
                        return DropdownButtonFormField<String>(
                          value: _selectedNgoId,
                          decoration: const InputDecoration(
                            labelText: 'Select NGO *',
                            prefixIcon: Icon(Icons.business),
                          ),
                          items: ngos.map((ngo) {
                            return DropdownMenuItem<String>(
                              value: ngo.id,
                              child: Text(ngo.name),
                            );
                          }).toList(),
                          onChanged: widget.demand != null
                              ? null // Disable if editing
                              : (value) {
                                  setState(() {
                                    _selectedNgoId = value;
                                  });
                                },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select an NGO';
                            }
                            return null;
                          },
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (_, __) => const Text('Error loading NGOs'),
                    ),
                    const SizedBox(height: 16),
                    // Amount
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount *',
                        hintText: 'Enter amount',
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter amount';
                        }
                        final amount = int.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Unit
                    DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      decoration: const InputDecoration(
                        labelText: 'Unit *',
                        prefixIcon: Icon(Icons.scale),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'meals', child: Text('Meals')),
                        DropdownMenuItem(value: 'kg', child: Text('Kilograms')),
                        DropdownMenuItem(value: 'plates', child: Text('Plates')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedUnit = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // Date and Time
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _selectDate,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Required Date *',
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                _selectedDate != null ? DateFormat('dd/MM/yyyy').format(_selectedDate!) : 'Select date',
                                style: TextStyle(
                                  color: _selectedDate != null ? Colors.black : Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: _selectedDate != null ? _selectTime : null,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Required Time *',
                                prefixIcon: Icon(Icons.access_time),
                              ),
                              child: Text(
                                _selectedTime != null ? _selectedTime!.format(context) : 'Select time',
                                style: TextStyle(
                                  color: _selectedTime != null ? Colors.black : Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_selectedDate != null && _selectedTime != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Required by: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)} at ${_selectedTime!.format(context)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        hintText: 'Add any additional details',
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: _isLoading ? (widget.demand != null ? 'Updating...' : 'Creating...') : (widget.demand != null ? 'Update Demand' : 'Create Demand'),
                onPressed: _isLoading ? null : () => _submitForm(ref),
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
      ),
    );
  }
}
