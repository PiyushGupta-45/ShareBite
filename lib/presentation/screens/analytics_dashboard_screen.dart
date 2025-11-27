import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_donation_app/presentation/providers/app_providers.dart';
import 'package:food_donation_app/presentation/widgets/impact_card.dart';
import 'package:food_donation_app/presentation/widgets/section_header.dart';

class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insights = ref.watch(analyticsInsightsProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: insights.when(
        data: (items) => ListView(
          children: [
            const SectionHeader(title: 'Waste intelligence panel'),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: items
                  .map(
                    (insight) => SizedBox(
                      width: 240,
                      child: ImpactCard(
                        label: insight.metric,
                        value: '${insight.value} ${insight.unit}',
                        subtitle: insight.description,
                        icon: Icons.trending_up,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Waste pattern timeline'),
            Container(
              height: 220,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(.15),
                    Theme.of(context).colorScheme.tertiary.withOpacity(.15),
                  ],
                ),
              ),
              child: const Text(
                'Multi-series chart placeholder (donor waste vs recovered).',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(
                title: 'Optimization recommendations',
                action: Chip(label: Text('AI foresight beta'))),
            ...items.map(
              (insight) => ListTile(
                leading: const Icon(Icons.auto_graph),
                title: Text(insight.description),
                subtitle: Text(
                    'Trend: ${insight.trendPercent > 0 ? '+' : ''}${insight.trendPercent.toStringAsFixed(1)}%'),
                trailing: Icon(
                  insight.trendPercent >= 0 ? Icons.north_east : Icons.south_east,
                  color: insight.trendPercent >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ),
          ],
        ),
        error: (error, _) => Center(child: Text('Error: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

