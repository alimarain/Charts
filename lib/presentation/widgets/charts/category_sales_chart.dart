import 'package:flutter/material.dart';
import 'package:new_app/app/app_theme.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../domain/entities/analytics.dart';

class CategorySalesChart extends StatelessWidget {
  const CategorySalesChart({required this.data, super.key});

  final List<CategorySalesData> data;

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
                      'Category Breakdown',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Gross volume per department',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.bar_chart_rounded, size: 20, color: AppTheme.secondaryColor),
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
                  labelStyle: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                  labelIntersectAction: AxisLabelIntersectAction.rotate45,
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
                  format: 'point.x: Rs.point.y',
                  color: AppTheme.textPrimary,
                  textStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  animationDuration: 250,
                ),
                series: <CartesianSeries<CategorySalesData, String>>[
                  ColumnSeries<CategorySalesData, String>(
                    name: 'Revenue',
                    dataSource: data,
                    xValueMapper: (CategorySalesData item, _) => item.category,
                    yValueMapper: (CategorySalesData item, _) => item.sales,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    animationDuration: 1000,
                    animationDelay: 200,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF059669),
                        Color(0xFF34D399),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
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