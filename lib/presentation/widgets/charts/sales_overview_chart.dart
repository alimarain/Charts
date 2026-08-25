import 'package:flutter/material.dart';
import 'package:new_app/app/app_theme.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../domain/entities/analytics.dart';

class SalesOverviewChart extends StatelessWidget {
  const SalesOverviewChart({required this.data, super.key});

  final List<SalesData> data;

  @override
  Widget build(BuildContext context) {
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
                      'Revenue Velocity',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Daily gross sales performance',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.trending_up_rounded, size: 20, color: AppTheme.primaryColor),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: SfCartesianChart(
                plotAreaBorderWidth: 0,
                margin: EdgeInsets.zero,
                primaryXAxis: const CategoryAxis(
                  majorGridLines: MajorGridLines(width: 0),
                  axisLine: AxisLine(width: 0.5, color: AppTheme.borderColor),
                  labelStyle: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
                primaryYAxis: const NumericAxis(
                  axisLine: AxisLine(width: 0),
                  majorGridLines: MajorGridLines(
                    dashArray: [4, 4],
                    color: AppTheme.borderColor,
                    width: 0.8,
                  ),
                  labelFormat: 'Rs.{value}',
                  labelStyle: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                ),
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  header: '',
                  canShowMarker: true,
                  format: 'point.x: Rs.point.y',
                  color: AppTheme.textPrimary,
                  textStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  animationDuration: 300,
                ),
                series: <CartesianSeries<SalesData, String>>[
                  SplineAreaSeries<SalesData, String>(
                    name: 'Revenue',
                    dataSource: data,
                    xValueMapper: (SalesData sales, _) => sales.label,
                    yValueMapper: (SalesData sales, _) => sales.value,
                    borderColor: AppTheme.primaryColor,
                    borderWidth: 2.5,
                    animationDuration: 1200,
                    animationDelay: 100,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor.withValues(alpha: 0.35),
                        AppTheme.primaryColor.withValues(alpha: 0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    markerSettings: const MarkerSettings(
                      isVisible: true,
                      height: 6,
                      width: 6,
                      shape: DataMarkerType.circle,
                      color: AppTheme.primaryColor,
                      borderColor: Colors.white,
                      borderWidth: 2,
                    ),
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