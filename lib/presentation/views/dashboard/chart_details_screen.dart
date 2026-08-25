import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_app/app/app_theme.dart';

import '../../../domain/entities/chart_interaction.dart';
import '../../controllers/chart_interaction_provider.dart';

class ChartDetailsScreen extends ConsumerWidget {
  const ChartDetailsScreen({this.item, super.key});

  static const routeName = 'chart_details';
  static const routeSubPath = 'details';
  static const routePath = '/charts/details';

  final SelectedChartItem? item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeItem = item ?? ref.watch(chartInteractionProvider).selectedItem;

    if (activeItem == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chart Telemetry')),
        body: const Center(child: Text('No chart point selected.')),
      );
    }

    String screenTitle;
    IconData headerIcon;
    Color themeColor;

    switch (activeItem.chartType) {
      case ChartType.salesOverview:
        screenTitle = 'Revenue Details';
        headerIcon = Icons.trending_up_rounded;
        themeColor = AppTheme.primaryColor;
        break;
      case ChartType.categoryPerformance:
        screenTitle = 'Department Performance';
        headerIcon = Icons.bar_chart_rounded;
        themeColor = AppTheme.secondaryColor;
        break;
      case ChartType.productDistribution:
        screenTitle = 'Inventory Allocation';
        headerIcon = Icons.pie_chart_outline_rounded;
        themeColor = AppTheme.accentColor;
        break;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: Text(screenTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(headerIcon, color: themeColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activeItem.label,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Data Index: #${activeItem.dataIndex + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Metrics Summary Grid
            Row(
              children: [
                Expanded(
                  child: _DetailMetricBox(
                    label: 'Selected Value',
                    value: activeItem.formattedValue,
                    color: themeColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DetailMetricBox(
                    label: 'Status / Metric',
                    value: activeItem.secondaryMetric ?? 'Operational',
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Context Description
            if (activeItem.description != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ANALYTICS CONTEXT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      activeItem.description!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Back Action Button
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Return to Charts'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailMetricBox extends StatelessWidget {
  const _DetailMetricBox({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
