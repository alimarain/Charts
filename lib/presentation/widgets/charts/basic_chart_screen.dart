import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/charts/models/chart_config.dart';
import '../../../core/charts/models/chart_data.dart';
import '../../../core/charts/models/chart_type.dart';
import '../../../core/charts/widgets/global_chart_widget.dart';
import '../../../domain/entities/basic_chart_data.dart';
import '../../controllers/analytics_provider.dart';
import '../navigation/app_header.dart';
import 'components/metric_detail_sheet.dart';

class BasicChartScreen extends ConsumerStatefulWidget {
  const BasicChartScreen({super.key});

  static const routeName = 'basic-chart';
  static const routePath = '/basic-chart';

  @override
  ConsumerState<BasicChartScreen> createState() => _BasicChartScreenState();
}

class _BasicChartScreenState extends ConsumerState<BasicChartScreen> {
  bool _isStreamPaused = false;
  List<BasicChartData>? _pausedSnapshot;

  ChartDataPoint _mapToDataPoint(BasicChartData item) {
    return ChartDataPoint(
      label: item.month,
      value: item.sales,
      targetValue: item.target,
      metadata: item,
    );
  }

  @override
  Widget build(BuildContext context) {
    final chartState = ref.watch(basicChartProvider);
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
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _isStreamPaused = !_isStreamPaused;
                                if (_isStreamPaused) {
                                  _pausedSnapshot = chartState.value;
                                }
                              });
                            },
                            icon: Icon(
                              _isStreamPaused
                                  ? Icons.play_arrow_rounded
                                  : Icons.pause_rounded,
                              color: _isStreamPaused
                                  ? const Color(0xFF059669)
                                  : const Color(0xFF6B7280),
                            ),
                            label: Text(
                              _isStreamPaused
                                  ? 'Resume Stream'
                                  : 'Freeze Stream',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _isStreamPaused
                                    ? const Color(0xFF059669)
                                    : const Color(0xFF374151),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GlobalChartWidget<BasicChartData>(
                        data: points,
                        mapper: _mapToDataPoint,
                        isLoading: chartState.isLoading && points.isEmpty,
                        emptyMessage: chartState.hasError
                            ? 'Telemetry error: ${chartState.error}'
                            : 'No telemetry data received from stream.',
                        config: const ChartConfig(
                          chartType: UniversalChartType.area,
                          title: 'Monthly Performance Stream',
                          subtitle: 'Live operational telemetry pushed via WebSockets.',
                          height: 380,
                          enableChartTypeSwitching: true,
                          supportedChartTypes: [
                            UniversalChartType.area,
                            UniversalChartType.column,
                            UniversalChartType.stepLine,
                          ],
                          targetValue: 20000,
                          targetLabel: 'TARGET (20K)',
                          showLegend: false,
                          showTooltip: true,
                          enableExport: true,
                          enableFullscreen: false,
                        ),
                        onPointTap: (index, point) {
                          if (point.metadata is BasicChartData) {
                            MetricDetailSheet.show(
                              context,
                              point.metadata as BasicChartData,
                            );
                          }
                        },
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
}
