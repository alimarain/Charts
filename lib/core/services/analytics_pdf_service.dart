import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../domain/entities/chart_filter_models.dart';
import '../../presentation/controllers/chart_filter_provider.dart';

class AnalyticsPdfService {
  static Future<Uint8List> generatePdfReport({
    required FilteredAnalyticsResult result,
    required ChartFilterState filter,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Report Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'VIBEFLOW ANALYTICS REPORT',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Generated on: ${DateTime.now().toIso8601String().split('T').first}',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                    ),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.blue800),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    'CONFIDENTIAL',
                    style: pw.TextStyle(
                        fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                  ),
                ),
              ],
            ),
            pw.Divider(thickness: 1, color: PdfColors.grey300),
            pw.SizedBox(height: 12),

            // Active Filters Metadata Box
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Date Scope: ${filter.datePreset.name}',
                      style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('Category: ${filter.selectedCategory}',
                      style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('Comparison: ${filter.comparisonPeriod.name}',
                      style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
            ),
            pw.SizedBox(height: 18),

            // KPI Grid Section
            pw.Text('Key Performance Indicators',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headers: ['Metric', 'Current Period', 'Previous Baseline', 'Variance'],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
              cellAlignment: pw.Alignment.centerLeft,
              data: [
                [
                  'Gross Revenue',
                  'Rs. ${result.kpis.currentRevenue.toStringAsFixed(0)}',
                  'Rs. ${result.kpis.previousRevenue.toStringAsFixed(0)}',
                  '${result.kpis.revenueGrowthPercent.toStringAsFixed(1)}%'
                ],
                [
                  'Orders Volume',
                  '${result.kpis.currentOrders}',
                  '${result.kpis.previousOrders}',
                  '${result.kpis.ordersGrowthPercent.toStringAsFixed(1)}%'
                ],
                ['Active Catalog SKUs', '${result.kpis.activeSkus} Units', 'N/A', 'N/A'],
                [
                  'Target Goal Pace',
                  '${result.kpis.targetAchievementPercent.toStringAsFixed(1)}%',
                  'Goal: Rs. ${filter.targetRevenue.toStringAsFixed(0)}',
                  result.kpis.targetAchievementPercent >= 100 ? 'On Track' : 'Lagging'
                ],
              ],
            ),
            pw.SizedBox(height: 20),

            // Revenue Data Table
            pw.Text('Daily Revenue Velocity Breakdown',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headers: ['Day', 'Current Revenue (PKR)', 'Baseline (PKR)'],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
              data: [
                for (int i = 0; i < result.currentSales.length; i++)
                  [
                    result.currentSales[i].label,
                    'Rs. ${result.currentSales[i].value.toStringAsFixed(0)}',
                    i < result.previousSales.length
                        ? 'Rs. ${result.previousSales[i].value.toStringAsFixed(0)}'
                        : '0',
                  ]
              ],
            ),
            pw.SizedBox(height: 20),

            // Department Revenue
            pw.Text('Department Breakdown',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headers: ['Department', 'Sales Volume (PKR)'],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
              data: [
                for (final item in result.categorySales)
                  [item.category, 'Rs. ${item.sales.toStringAsFixed(0)}']
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }
}