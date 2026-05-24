import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_donation_app/core/theme/app_theme.dart';
import 'package:food_donation_app/presentation/providers/app_providers.dart';

class CreateVoucherScreen extends ConsumerStatefulWidget {
  const CreateVoucherScreen({super.key});

  @override
  ConsumerState<CreateVoucherScreen> createState() => _CreateVoucherScreenState();
}

class _CreateVoucherScreenState extends ConsumerState<CreateVoucherScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _codeController = TextEditingController();
  final _pointsController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _discountController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _codeController.dispose();
    _pointsController.dispose();
    _descriptionController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final token = ref.read(authProvider).token;
    if (token == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await ref.read(voucherRemoteDataSourceProvider).createVoucher(
            token: token,
            title: _titleController.text.trim(),
            code: _codeController.text.trim().toUpperCase(),
            pointsRequired: int.parse(_pointsController.text.trim()),
            description: _descriptionController.text.trim(),
            discountValue: _discountController.text.trim(),
          );

      ref.invalidate(activeVouchersProvider);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voucher created successfully.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create voucher: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Voucher'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Voucher title'),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Enter voucher title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Voucher code'),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Enter voucher code' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pointsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Points required'),
                validator: (value) {
                  final points = int.tryParse(value ?? '');
                  if (points == null || points <= 0) {
                    return 'Enter valid points';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _discountController,
                decoration: const InputDecoration(
                  labelText: 'Voucher value',
                  hintText: 'Example: 20% OFF or Rs.100 OFF',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(_isSaving ? 'Creating...' : 'Create Voucher'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
