import 'package:flutter/material.dart';

import '../../../../domain/entities/analytics.dart';
import '../charts/product_distribution_chart.dart';
import '../charts/sales_overview_chart.dart';

class AnalyticsDualChartRow extends StatelessWidget {
  const AnalyticsDualChartRow({
    super.key,
    required this.currentSales,
    required this.previousSales,
    required this.distribution,
  });

  final List<SalesData> currentSales;
  final List<SalesData> previousSales;
  final List<ProductDistributionData> distribution;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, boxConstraints) {
        final isWide = boxConstraints.maxWidth > 920;

        final revenueChart = SalesOverviewChart(
          data: currentSales,
          previousData: previousSales,
          enableNavigation: true,
        );

        final distributionChart = ProductDistributionChart(
          data: distribution,
          enableNavigation: true,
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: revenueChart),
              const SizedBox(width: 16),
              Expanded(flex: 5, child: distributionChart),
            ],
          );
        }

        return Column(
          children: [
            revenueChart,
            const SizedBox(height: 16),
            distributionChart,
          ],
        );
      },
    );
  }
}
