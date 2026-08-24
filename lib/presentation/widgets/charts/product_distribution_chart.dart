import 'package:flutter/material.dart';
import 'package:new_app/app/app_theme.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../domain/entities/analytics.dart';

class ProductDistributionChart extends StatelessWidget {
  const ProductDistributionChart({required this.data, super.key});

  final List<ProductDistributionData> data;

  static const List<Color> _chartPalette = [
    Color(0xFF4F46E5),
    Color(0xFF059669),
    Color(0xFFD97706),
    Color(0xFF0284C7),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
  ];

  @override
  Widget build(BuildContext context) {
    final totalUnits = data.fold<int>(0, (sum, item) => sum + item.count);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.borderColor),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Inventory Allocation',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Stock spread by product lines',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.pie_chart_outline_rounded, size: 20, color: AppTheme.accentColor),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 240,
              child: SfCircularChart(
                margin: EdgeInsets.zero,
                palette: _chartPalette,
                legend: const Legend(
                  isVisible: true,
                  overflowMode: LegendItemOverflowMode.wrap,
                  position: LegendPosition.bottom,
                  textStyle: TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                ),
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  format: 'point.x: point.y units',
                  color: AppTheme.textPrimary,
                  textStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  animationDuration: 250,
                ),
                annotations: <CircularChartAnnotation>[
                  CircularChartAnnotation(
                    widget: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$totalUnits',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const Text(
                          'Total Units',
                          style: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
                series: <CircularSeries<ProductDistributionData, String>>[
                  DoughnutSeries<ProductDistributionData, String>(
                    dataSource: data,
                    xValueMapper: (ProductDistributionData dist, _) => dist.category,
                    yValueMapper: (ProductDistributionData dist, _) => dist.count,
                    dataLabelMapper: (ProductDistributionData dist, _) => '${dist.count}',
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                      textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    innerRadius: '68%',
                    radius: '85%',
                    strokeColor: Colors.white,
                    strokeWidth: 2,
                    animationDuration: 1100,
                    explode: true,
                    explodeGesture: ActivationMode.singleTap,
                    explodeOffset: '12%',
                    explodeIndex: 0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}