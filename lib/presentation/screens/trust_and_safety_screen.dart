import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_donation_app/presentation/providers/app_providers.dart';
import 'package:food_donation_app/presentation/widgets/primary_button.dart';
import 'package:image_picker/image_picker.dart';

class TrustAndSafetyScreen extends ConsumerStatefulWidget {
  const TrustAndSafetyScreen({super.key});

  @override
  ConsumerState<TrustAndSafetyScreen> createState() =>
      _TrustAndSafetyScreenState();
}

class _TrustAndSafetyScreenState extends ConsumerState<TrustAndSafetyScreen> {
  final otpController = TextEditingController();
  int _currentStep = 0;

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final capture = await picker.pickImage(
      source: ImageSource.camera,
      maxHeight: 1024,
      maxWidth: 1024,
    );
    if (capture != null) {
      ref.read(pickedImagePathProvider.notifier).state = capture.path;
    }
  }

  @override
  Widget build(BuildContext context) {
    final checklist = ref.watch(freshnessChecklistProvider);
    final selections = ref.watch(checklistStateProvider);
    final pickedImage = ref.watch(pickedImagePathProvider);
    final handshake = ref.watch(handshakeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Check'),
        elevation: 0,
      ),
      body: checklist.when(
        data: (items) {
          final steps = _buildSteps(items, selections, pickedImage, handshake);
          final allCompleted = _allStepsCompleted(
            items,
            selections,
            pickedImage,
            handshake,
          );

          return Column(
            children: [
              Expanded(
                child: Stepper(
                  currentStep: _currentStep,
                  onStepContinue: () {
                    if (_currentStep < steps.length - 1) {
                      setState(() => _currentStep++);
                    }
                  },
                  onStepCancel: () {
                    if (_currentStep > 0) {
                      setState(() => _currentStep--);
                    }
                  },
                  steps: steps,
                ),
              ),
              if (allCompleted)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: PrimaryButton(
                    label: 'Safety Check Complete → Start Pickup',
                    icon: Icons.check_circle,
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Safety check complete! Ready to start pickup.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text('Error loading checklist'),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(freshnessChecklistProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Step> _buildSteps(
    List<dynamic> items,
    Map<String, bool> selections,
    String? pickedImage,
    dynamic handshake,
  ) {
    return [
      // Step 1: Capture donor images
      Step(
        title: const Text('Capture Donor Images'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Take photos of the donation location and items.'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Capture Image'),
            ),
            if (pickedImage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Image captured successfully'),
                  ],
                ),
              ),
            ],
          ],
        ),
        isActive: _currentStep >= 0,
        state: pickedImage != null
            ? StepState.complete
            : _currentStep == 0
                ? StepState.indexed
                : StepState.disabled,
      ),
      // Step 2: Temperature log
      Step(
        title: const Text('Temperature Log'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Record the temperature of perishable items.'),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Temperature logged'),
              value: selections['Temperature log'] ?? false,
              onChanged: (value) {
                ref.read(checklistStateProvider.notifier).toggle(
                      items.firstWhere(
                        (item) => item.label == 'Temperature log',
                        orElse: () => items.first,
                      ),
                      value,
                    );
              },
            ),
          ],
        ),
        isActive: _currentStep >= 1,
        state: (selections['Temperature log'] ?? false)
            ? StepState.complete
            : _currentStep == 1
                ? StepState.indexed
                : StepState.disabled,
      ),
      // Step 3: Smell/texture check
      Step(
        title: const Text('Smell & Texture Check'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Verify food quality through smell and texture.'),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Smell check passed'),
              value: selections['Smell check'] ?? false,
              onChanged: (value) {
                ref.read(checklistStateProvider.notifier).toggle(
                      items.firstWhere(
                        (item) => item.label.contains('Smell'),
                        orElse: () => items.first,
                      ),
                      value,
                    );
              },
            ),
            SwitchListTile(
              title: const Text('Texture check passed'),
              value: selections['Texture check'] ?? false,
              onChanged: (value) {
                ref.read(checklistStateProvider.notifier).toggle(
                      items.firstWhere(
                        (item) => item.label.contains('Texture'),
                        orElse: () => items.first,
                      ),
                      value,
                    );
              },
            ),
          ],
        ),
        isActive: _currentStep >= 2,
        state: (selections['Smell check'] ?? false) &&
                (selections['Texture check'] ?? false)
            ? StepState.complete
            : _currentStep == 2
                ? StepState.indexed
                : StepState.disabled,
      ),
      // Step 4: Allergen/label check
      Step(
        title: const Text('Allergen & Label Check'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Verify allergen information and labels are visible.'),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Allergen check completed'),
              value: selections['Allergen check'] ?? false,
              onChanged: (value) {
                ref.read(checklistStateProvider.notifier).toggle(
                      items.firstWhere(
                        (item) => item.label.contains('Allergen'),
                        orElse: () => items.first,
                      ),
                      value,
                    );
              },
            ),
          ],
        ),
        isActive: _currentStep >= 3,
        state: (selections['Allergen check'] ?? false)
            ? StepState.complete
            : _currentStep == 3
                ? StepState.indexed
                : StepState.disabled,
      ),
      // Step 5: Waiver acknowledgment
      Step(
        title: const Text('Waiver Acknowledgment'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Acknowledge the liability waiver.'),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('I acknowledge the waiver'),
              value: handshake.waiverSigned,
              onChanged: (value) {
                if (value) {
                  ref.read(handshakeProvider.notifier).signWaiver();
                }
              },
            ),
          ],
        ),
        isActive: _currentStep >= 4,
        state: handshake.waiverSigned
            ? StepState.complete
            : _currentStep == 4
                ? StepState.indexed
                : StepState.disabled,
      ),
      // Step 6: Handover OTP verification
      Step(
        title: const Text('Handover OTP Verification'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Generate and verify OTP for handover.'),
            const SizedBox(height: 16),
            if (handshake.generatedOtp == null)
              ElevatedButton.icon(
                onPressed: () =>
                    ref.read(handshakeProvider.notifier).generateOtp(),
                icon: const Icon(Icons.qr_code_2),
                label: const Text('Generate OTP'),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('OTP: ${handshake.generatedOtp}'),
                    const SizedBox(height: 12),
                    TextField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Enter OTP to verify',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) =>
                          ref.read(handshakeProvider.notifier).verifyOtp(value),
                    ),
                    if (handshake.otpVerified) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            SizedBox(width: 8),
                            Text('OTP verified'),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
        isActive: _currentStep >= 5,
        state: handshake.otpVerified
            ? StepState.complete
            : _currentStep == 5
                ? StepState.indexed
                : StepState.disabled,
      ),
      // Step 7: Photo verification
      Step(
        title: const Text('Photo Verification'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Take a final verification photo at handover.'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Capture Verification Photo'),
            ),
            if (pickedImage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Verification photo captured'),
                  ],
                ),
              ),
            ],
          ],
        ),
        isActive: _currentStep >= 6,
        state: pickedImage != null
            ? StepState.complete
            : _currentStep == 6
                ? StepState.indexed
                : StepState.disabled,
      ),
    ];
  }

  bool _allStepsCompleted(
    List<dynamic> items,
    Map<String, bool> selections,
    String? pickedImage,
    dynamic handshake,
  ) {
    return pickedImage != null &&
        (selections['Temperature log'] ?? false) &&
        (selections['Smell check'] ?? false) &&
        (selections['Texture check'] ?? false) &&
        (selections['Allergen check'] ?? false) &&
        handshake.waiverSigned &&
        handshake.otpVerified;
  }
}
