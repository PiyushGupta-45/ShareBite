import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_donation_app/core/theme/app_theme.dart';
import 'package:food_donation_app/data/datasources/ngo_remote_datasource.dart';
import 'package:food_donation_app/presentation/providers/app_providers.dart';
import 'package:food_donation_app/presentation/widgets/app_card.dart';
import 'package:food_donation_app/presentation/widgets/primary_button.dart';
import 'package:food_donation_app/presentation/widgets/secondary_button.dart';

class AddNgoScreen extends ConsumerStatefulWidget {
  const AddNgoScreen({super.key});

  @override
  ConsumerState<AddNgoScreen> createState() => _AddNgoScreenState();
}

class _AddNgoScreenState extends ConsumerState<AddNgoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _taglineController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _taglineController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _imageUrlController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _submitForm(WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) {
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

      final ngoDataSource = NgoRemoteDataSource();
      await ngoDataSource.createNGO(
        token: token,
        name: _nameController.text.trim(),
        tagline: _taglineController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        address: _addressController.text.trim(),
        latitude: double.parse(_latitudeController.text.trim()),
        longitude: double.parse(_longitudeController.text.trim()),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        website: _websiteController.text.trim().isNotEmpty
            ? _websiteController.text.trim()
            : null,
        mainImage: _imageUrlController.text.trim().isNotEmpty
            ? _imageUrlController.text.trim()
            : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('NGO added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add NGO'),
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
                      'NGO Information',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'NGO Name *',
                        hintText: 'Enter NGO name',
                        prefixIcon: Icon(Icons.business),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter NGO name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _taglineController,
                      decoration: const InputDecoration(
                        labelText: 'Tagline *',
                        hintText: 'Enter a short tagline',
                        prefixIcon: Icon(Icons.tag),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter tagline';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description *',
                        hintText: 'Enter NGO description',
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Image URL',
                        hintText: 'Enter image URL',
                        prefixIcon: Icon(Icons.image),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Information',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email *',
                        hintText: 'Enter email address',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone *',
                        hintText: 'Enter phone number',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _websiteController,
                      decoration: const InputDecoration(
                        labelText: 'Website',
                        hintText: 'Enter website URL',
                        prefixIcon: Icon(Icons.language),
                      ),
                      keyboardType: TextInputType.url,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location Information',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location/Area *',
                        hintText: 'e.g., Downtown, Sector 5',
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter location';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Full Address *',
                        hintText: 'Enter complete address',
                        prefixIcon: Icon(Icons.home),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _latitudeController,
                            decoration: const InputDecoration(
                              labelText: 'Latitude *',
                              hintText: 'e.g., 28.6139',
                              prefixIcon: Icon(Icons.map),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              final lat = double.tryParse(value);
                              if (lat == null || lat < -90 || lat > 90) {
                                return 'Invalid latitude';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _longitudeController,
                            decoration: const InputDecoration(
                              labelText: 'Longitude *',
                              hintText: 'e.g., 77.2090',
                              prefixIcon: Icon(Icons.map),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              final lon = double.tryParse(value);
                              if (lon == null || lon < -180 || lon > 180) {
                                return 'Invalid longitude';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: _isLoading ? 'Adding...' : 'Add NGO',
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

