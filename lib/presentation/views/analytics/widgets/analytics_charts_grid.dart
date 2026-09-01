import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../presentation/widgets/charts/product_distribution_chart.dart';
import '../../../../presentation/widgets/charts/sales_overview_chart.dart';
import '../../../controllers/chart_filter_provider.dart';

class AnalyticsChartsGrid extends ConsumerWidget {
  const AnalyticsChartsGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredResult = ref.watch(filteredAnalyticsProvider);
    if (filteredResult == null) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 920;

        final throughputChart = SalesOverviewChart(
          data: filteredResult.currentSales,
          previousData: filteredResult.previousSales,
          enableNavigation: true,
        );

        final sideStack = Column(
          children: [
            // Error / Inventory Distribution Donut
            ProductDistributionChart(
              data: filteredResult.distribution,
              enableNavigation: true,
            ),
            const SizedBox(height: 14),

            // Cache Hit Rate KPI Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cache Hit Rate',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: const [
                      Text(
                        '98.4%',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF111827),
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '+0.2%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 38,
                    child: CustomPaint(
                      painter: _HitRateWavePainter(),
                      size: Size.infinite,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

        if (isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: throughputChart),
              const SizedBox(width: 16),
              Expanded(flex: 4, child: sideStack),
            ],
          );
        }

        return Column(
          children: [
            throughputChart,
            const SizedBox(height: 16),
            sideStack,
          ],
        );
      },
    );
  }
}

class _HitRateWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final List<double> points = [28, 22, 24, 29, 21, 19, 17, 10, 4];
    final dx = size.width / (points.length - 1);

    for (int i = 0; i < points.length; i++) {
      final x = i * dx;
      final y = points[i];
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}