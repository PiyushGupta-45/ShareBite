import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_donation_app/presentation/providers/app_providers.dart';
import 'package:food_donation_app/presentation/widgets/section_header.dart';

class VolunteerNetworkScreen extends ConsumerWidget {
  const VolunteerNetworkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(volunteerRequestsProvider);
    final accepted = ref.watch(acceptedRequestsProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: requests.when(
        data: (items) => ListView(
          children: [
            SectionHeader(
              title: 'Share Bites Riders',
              action: Chip(label: Text('${accepted.length} active runs')),
            ),
            ...items.map(
              (request) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            request.id,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Chip(
                            label: Text(
                              request.highPriority ? 'Urgent' : 'Flex',
                            ),
                            avatar: Icon(
                              request.highPriority
                                  ? Icons.flash_on
                                  : Icons.schedule,
                            ),
                            backgroundColor: request.highPriority
                                ? Colors.orange[50]
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Pickup • ${request.pickupPoint}'),
                      Text('Drop-off • ${request.dropOffPoint}'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        children: [
                          InputChip(
                            avatar: const Icon(Icons.inventory),
                            label: Text(request.payloadType),
                          ),
                          InputChip(
                            avatar: const Icon(Icons.route),
                            label: Text('${request.distanceKm} km'),
                          ),
                          InputChip(
                            avatar: const Icon(Icons.timer),
                            label: Text(
                                'Ready by ${TimeOfDay.fromDateTime(request.readyBy).format(context)}'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => ref
                                  .read(acceptedRequestsProvider.notifier)
                                  .toggle(request.id),
                              icon: Icon(accepted.contains(request.id)
                                  ? Icons.check_circle
                                  : Icons.delivery_dining),
                              label: Text(
                                accepted.contains(request.id)
                                    ? 'Release slot'
                                    : 'Accept ride',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.chat_bubble_outline),
                            label: const Text('Ping squad'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const SectionHeader(title: 'Rider heatmap'),
            Container(
              height: 160,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: const Text('Live rider density preview placeholder'),
            ),
          ],
        ),
        error: (error, _) => Center(child: Text('Error: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

