import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/analytics_provider.dart';
import '../charts/category_sales_chart.dart';
import '../charts/product_distribution_chart.dart';
import '../charts/sales_overview_chart.dart';
import '../common/app_card.dart';
import '../common/app_state_views.dart';

class AnalyticsSection extends ConsumerWidget {
  const AnalyticsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsState = ref.watch(analyticsProvider);

    if (analyticsState.isLoading && analyticsState.data == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: AppCard(padding: EdgeInsets.all(24), child: AppLoadingView()),
      );
    }

    if (analyticsState.isError && analyticsState.data == null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: AppCard(
          padding: EdgeInsets.all(16),
          child: AppErrorView(
            message:
                analyticsState.errorMessage ?? 'Analytics telemetry offline',
            onRetry: () => ref.read(analyticsProvider.notifier).retry(),
            retryLabel: 'Retry',
          ),
        ),
      );
    }

    final data = analyticsState.data;
    if (data == null) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'STORE TELEMETRY & ANALYTICS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 1.1,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      children: [
                        CircleAvatar(
                          radius: 3,
                          backgroundColor: Color(0xFF2563EB),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Live Stream',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (isWide) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: SalesOverviewChart(data: data.weeklySales)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CategorySalesChart(data: data.categorySales),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ProductDistributionChart(data: data.distribution),
              ] else ...[
                SalesOverviewChart(data: data.weeklySales),
                const SizedBox(height: 12),
                CategorySalesChart(data: data.categorySales),
                const SizedBox(height: 12),
                ProductDistributionChart(data: data.distribution),
              ],
            ],
          ),
        );
      },
    );
  }
}
