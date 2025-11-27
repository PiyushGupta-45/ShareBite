import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_donation_app/presentation/providers/app_providers.dart';
import 'package:food_donation_app/presentation/widgets/section_header.dart';

class LogisticsScreen extends ConsumerWidget {
  const LogisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(logisticsAlertsProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: alerts.when(
        data: (items) {
          return ListView(
            children: [
              const SectionHeader(
                title: 'Geo-fenced alerts',
                action: Chip(label: Text('Live radius monitor')),
              ),
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                  ),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Interactive map placeholder\n(radius pulses + SOS beacons)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              ...items.map(
                (alert) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              alert.donorName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            Chip(
                              label: Text(alert.urgencyTag),
                              avatar: const Icon(Icons.schedule, size: 16),
                              backgroundColor:
                                  alert.requiresRefrigeration ? Colors.red[50] : null,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(alert.location),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            InputChip(
                              label: Text('Radius ${alert.radiusKm} km'),
                              avatar: const Icon(Icons.radar),
                            ),
                            InputChip(
                              label: Text(() {
                                final minutesLeft =
                                    alert.expiry.difference(DateTime.now()).inMinutes;
                                return 'Expires in ${minutesLeft.clamp(0, 120)} min';
                              }()),
                              avatar: const Icon(Icons.hourglass_top),
                            ),
                            if (alert.requiresRefrigeration)
                              const InputChip(
                                label: Text('Cold chain'),
                                avatar: Icon(Icons.ac_unit),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Builder(
                          builder: (context) {
                            final secondsLeft =
                                alert.expiry.difference(DateTime.now()).inSeconds;
                            final urgency =
                                1 - (secondsLeft / const Duration(hours: 2).inSeconds);
                            return LinearProgressIndicator(
                              value: urgency.clamp(0, 1).toDouble(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        error: (error, _) => Center(child: Text('Error: $error')),
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
      ),
    );
  }
}

