import 'package:flutter/material.dart';

class AnalyticsPerformanceAuditTable extends StatelessWidget {
  const AnalyticsPerformanceAuditTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            child: Text(
              'Regional Performance Audit',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // Scrollable Table Strip
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 650),
              child: SizedBox(
                width: 720,
                child: Column(
                  children: [
                    // Column Headers
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Text(
                              'DATA CENTER',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF9CA3AF),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'TRAFFIC',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF9CA3AF),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'AVG LATENCY',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF9CA3AF),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'SUCCESS RATE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF9CA3AF),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'UPTIME TREND',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF9CA3AF),
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFE5E7EB)),

                    _DataCenterRow(
                      name: 'US-EAST-01 (Virginia)',
                      traffic: '4.2M req/m',
                      latency: '24ms',
                      rate: '99.99%',
                      rateColor: const Color(0xFF15803D),
                      trendPoints: const [20, 22, 18, 20, 16, 17],
                    ),
                    const Divider(height: 1, color: Color(0xFFE5E7EB)),

                    _DataCenterRow(
                      name: 'EU-WEST-01 (Dublin)',
                      traffic: '3.8M req/m',
                      latency: '31ms',
                      rate: '99.98%',
                      rateColor: const Color(0xFF15803D),
                      trendPoints: const [18, 20, 16, 22, 19, 14],
                    ),
                    const Divider(height: 1, color: Color(0xFFE5E7EB)),

                    _DataCenterRow(
                      name: 'AP-SOUTHEAST-01 (Singapore)',
                      traffic: '2.1M req/m',
                      latency: '42ms',
                      rate: '99.92%',
                      rateColor: const Color(0xFFD97706),
                      trendPoints: const [15, 26, 18, 30, 14, 16],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DataCenterRow extends StatelessWidget {
  const _DataCenterRow({
    required this.name,
    required this.traffic,
    required this.latency,
    required this.rate,
    required this.rateColor,
    required this.trendPoints,
  });

  final String name;
  final String traffic;
  final String latency;
  final String rate;
  final Color rateColor;
  final List<double> trendPoints;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              traffic,
              style: const TextStyle(fontSize: 11, color: Color(0xFF4B5563)),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              latency,
              style: const TextStyle(fontSize: 11, color: Color(0xFF4B5563)),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              rate,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: rateColor,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 70,
                height: 18,
                child: CustomPaint(
                  painter: _AuditSparklinePainter(trendPoints),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuditSparklinePainter extends CustomPainter {
  final List<double> points;
  _AuditSparklinePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF374151)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
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