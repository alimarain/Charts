import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../domain/entities/basic_chart_data.dart';
import '../../controllers/analytics_provider.dart';
import '../navigation/app_header.dart';

enum ChartVisualizationType { spline, column, stepLine }

class BasicChartScreen extends ConsumerStatefulWidget {
  const BasicChartScreen({super.key});

  static const routeName = 'basic-chart';
  static const routePath = '/basic-chart';

  @override
  ConsumerState<BasicChartScreen> createState() => _BasicChartScreenState();
}

class _BasicChartScreenState extends ConsumerState<BasicChartScreen> {
  ChartVisualizationType _chartType = ChartVisualizationType.spline;
  bool _isStreamPaused = false;
  List<BasicChartData>? _pausedSnapshot;
  late final TrackballBehavior _trackballBehavior;

  @override
  void initState() {
    super.initState();
    _trackballBehavior = TrackballBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
      tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
      lineType: TrackballLineType.vertical,
      lineColor: const Color(0xFF4F46E5).withValues(alpha: 0.5),
      lineWidth: 1.5,
    );
  }

  void _showPointDetails(BasicChartData point) {
    final variance = point.sales - point.target;
    final isPositive = variance >= 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Metric Details: ${point.month}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPositive ? const Color(0xFFDCFCE7) : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      point.growthTag,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isPositive ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _DetailRow(label: 'Actual Volume', value: 'PKR ${point.sales.toStringAsFixed(0)}'),
              _DetailRow(label: 'Target Baseline', value: 'PKR ${point.target.toStringAsFixed(0)}'),
              _DetailRow(
                label: 'Variance',
                value: '${isPositive ? "+" : ""}PKR ${variance.toStringAsFixed(0)}',
                valueColor: isPositive ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chartState = ref.watch(basicChartProvider);

    // Keep static snapshot if stream inspection is paused
    final points = _isStreamPaused
        ? _pausedSnapshot ?? chartState.value ?? []
        : chartState.value ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: Column(
        children: [
          const AppHeader(title: 'Live Telemetry Monitor'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header & Interactive Controls Strip
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Monthly Performance Stream',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Live operational telemetry pushed via WebSockets.',
                                style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              // Pause / Resume Stream
                              IconButton(
                                tooltip: _isStreamPaused ? 'Resume live updates' : 'Freeze frame for analysis',
                                icon: Icon(
                                  _isStreamPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                                  color: _isStreamPaused ? const Color(0xFF059669) : const Color(0xFF6B7280),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isStreamPaused = !_isStreamPaused;
                                    if (_isStreamPaused) {
                                      _pausedSnapshot = chartState.value;
                                    }
                                  });
                                },
                              ),
                              const SizedBox(width: 8),

                              // Visualization Switcher
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    _TypeButton(
                                      icon: Icons.show_chart_rounded,
                                      isSelected: _chartType == ChartVisualizationType.spline,
                                      onTap: () => setState(() => _chartType = ChartVisualizationType.spline),
                                    ),
                                    _TypeButton(
                                      icon: Icons.bar_chart_rounded,
                                      isSelected: _chartType == ChartVisualizationType.column,
                                      onTap: () => setState(() => _chartType = ChartVisualizationType.column),
                                    ),
                                    _TypeButton(
                                      icon: Icons.stacked_line_chart_rounded,
                                      isSelected: _chartType == ChartVisualizationType.stepLine,
                                      onTap: () => setState(() => _chartType = ChartVisualizationType.stepLine),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Chart Canvas
                      SizedBox(
                        height: 400,
                        child: chartState.when(
                          loading: () => const Center(
                            child: CircularProgressIndicator(color: Color(0xFF1B1638), strokeWidth: 2),
                          ),
                          error: (err, _) => Center(
                            child: Text('Telemetry error: $err', style: const TextStyle(fontSize: 12)),
                          ),
                          data: (_) => SfCartesianChart(
                            trackballBehavior: _trackballBehavior,
                            primaryXAxis: const CategoryAxis(
                              majorGridLines: MajorGridLines(width: 0),
                              labelStyle: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                            ),
                            primaryYAxis: NumericAxis(
                              axisLine: const AxisLine(width: 0),
                              majorGridLines: const MajorGridLines(color: Color(0xFFF3F4F6)),
                              // Visual threshold baseline
                              plotBands: <PlotBand>[
                                PlotBand(
                                  start: 20000,
                                  end: 20000,
                                  borderColor: const Color(0xFFEF4444).withValues(alpha: 0.6),
                                  borderWidth: 1.5,
                                  dashArray: const <double>[4, 4],
                                  text: 'Target Baseline (20K)',
                                  textStyle: const TextStyle(fontSize: 10, color: Color(0xFFEF4444)),
                                  horizontalTextAlignment: TextAnchor.end,
                                ),
                              ],
                            ),
                            series: _buildSeries(points),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<CartesianSeries<BasicChartData, String>> _buildSeries(List<BasicChartData> points) {
    switch (_chartType) {
      case ChartVisualizationType.column:
        return [
          ColumnSeries<BasicChartData, String>(
            dataSource: points,
            xValueMapper: (BasicChartData d, _) => d.month,
            yValueMapper: (BasicChartData d, _) => d.sales,
            pointColorMapper: (BasicChartData d, _) => d.sales >= d.target ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            onPointTap: (ChartPointDetails details) {
              if (details.pointIndex != null) _showPointDetails(points[details.pointIndex!]);
            },
          ),
        ];

      case ChartVisualizationType.stepLine:
        return [
          StepLineSeries<BasicChartData, String>(
            dataSource: points,
            xValueMapper: (BasicChartData d, _) => d.month,
            yValueMapper: (BasicChartData d, _) => d.sales,
            color: const Color(0xFF4F46E5),
            width: 2.5,
            markerSettings: const MarkerSettings(isVisible: true),
            onPointTap: (ChartPointDetails details) {
              if (details.pointIndex != null) _showPointDetails(points[details.pointIndex!]);
            },
          ),
        ];

      case ChartVisualizationType.spline:
        return [
          SplineAreaSeries<BasicChartData, String>(
            dataSource: points,
            xValueMapper: (BasicChartData d, _) => d.month,
            yValueMapper: (BasicChartData d, _) => d.sales,
            gradient: LinearGradient(
              colors: [
                const Color(0xFF4F46E5).withValues(alpha: 0.35),
                const Color(0xFF4F46E5).withValues(alpha: 0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderColor: const Color(0xFF4F46E5),
            borderWidth: 2.5,
            markerSettings: const MarkerSettings(isVisible: true, width: 6, height: 6),
            onPointTap: (ChartPointDetails details) {
              if (details.pointIndex != null) _showPointDetails(points[details.pointIndex!]);
            },
          ),
        ];
    }
  }
}

class _TypeButton extends StatelessWidget {
  const _TypeButton({required this.icon, required this.isSelected, required this.onTap});
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: isSelected ? const Color(0xFF111827) : const Color(0xFF6B7280)),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: valueColor ?? const Color(0xFF111827))),
        ],
      ),
    );
  }
}