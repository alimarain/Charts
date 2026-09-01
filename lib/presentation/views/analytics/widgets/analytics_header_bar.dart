import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/analytics_export_service.dart';
import '../../../../domain/entities/chart_filter_models.dart';
import '../../../controllers/auth_provider.dart';
import '../../../controllers/chart_filter_provider.dart';

class AnalyticsHeaderBar extends ConsumerWidget {
  const AnalyticsHeaderBar({
    super.key,
    this.showMenuButton = false,
    this.onMenuTap,
  });

  final bool showMenuButton;
  final VoidCallback? onMenuTap;

  Future<void> _handleGlobalExport(
    String type,
    BuildContext context,
    WidgetRef ref,
  ) async {
    final scaffold = ScaffoldMessenger.of(context);
    final filteredResult = ref.read(filteredAnalyticsProvider);
    final filter = ref.read(chartFilterProvider);

    if (filteredResult == null || !filteredResult.hasData) {
      scaffold.showSnackBar(
        const SnackBar(content: Text('No data available to export.')),
      );
      return;
    }

    try {
      if (type == 'pdf') {
        scaffold.showSnackBar(
          const SnackBar(content: Text('Generating executive PDF report...')),
        );
        await AnalyticsExportService.exportAndSharePdf(
          result: filteredResult,
          filter: filter,
        );
      } else if (type == 'csv') {
        scaffold.showSnackBar(
          const SnackBar(content: Text('Exporting analytics CSV data...')),
        );
        await AnalyticsExportService.exportAndShareCsv(
          result: filteredResult,
          filter: filter,
        );
      }
    } catch (e) {
      scaffold.showSnackBar(SnackBar(content: Text('Export error: $e')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final filter = ref.watch(chartFilterProvider);
    final notifier = ref.read(chartFilterProvider.notifier);
    final userName = authState.user?.name ?? 'Marcus Vance';

    return Column(
      children: [
        // Top Global Bar
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          child: Row(
            children: [
              if (showMenuButton) ...[
                IconButton(
                  icon: const Icon(Icons.menu_rounded, color: Color(0xFF1B1638)),
                  onPressed: onMenuTap,
                ),
                const SizedBox(width: 4),
              ],
              const Text(
                'Telemetry & Performance',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6B7280),
                ),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.ios_share_rounded,
                  size: 18,
                  color: Color(0xFF6B7280),
                ),
                tooltip: 'Export Reports',
                onSelected: (val) => _handleGlobalExport(val, context, ref),
                itemBuilder: (ctx) => const [
                  PopupMenuItem(
                    value: 'pdf',
                    child: Row(
                      children: [
                        Icon(
                          Icons.picture_as_pdf_outlined,
                          color: Colors.red,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text('Export PDF Report', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'csv',
                    child: Row(
                      children: [
                        Icon(
                          Icons.table_chart_outlined,
                          color: Colors.green,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text('Export Clean CSV', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 14,
                backgroundColor: const Color(0xFF1B1638),
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Title + Presets Responsive Layout
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 700;

              final titleSection = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Performance Analytics',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Deep dive into operational metrics and system velocity.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                  ),
                ],
              );

              final controlsSection = Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _PresetPill(
                          label: '1D',
                          isSelected: filter.datePreset == ChartDatePreset.today,
                          onTap: () => notifier.setDatePreset(ChartDatePreset.today),
                        ),
                        _PresetPill(
                          label: '7D',
                          isSelected: filter.datePreset == ChartDatePreset.last7Days,
                          onTap: () => notifier.setDatePreset(ChartDatePreset.last7Days),
                        ),
                        _PresetPill(
                          label: '30D',
                          isSelected: filter.datePreset == ChartDatePreset.last30Days,
                          onTap: () => notifier.setDatePreset(ChartDatePreset.last30Days),
                        ),
                        _PresetPill(
                          label: '1Y',
                          isSelected: filter.datePreset == ChartDatePreset.thisYear,
                          onTap: () => notifier.setDatePreset(ChartDatePreset.thisYear),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF111827),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2025),
                        lastDate: DateTime(2027),
                        initialDateRange: DateTimeRange(
                          start: filter.startDate ?? DateTime.now().subtract(const Duration(days: 7)),
                          end: filter.endDate ?? DateTime.now(),
                        ),
                      );
                      if (picked != null) {
                        notifier.setCustomRange(picked.start, picked.end);
                      }
                    },
                    icon: const Icon(Icons.calendar_today_outlined, size: 12),
                    label: const Text('Custom Date', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ],
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleSection,
                    const SizedBox(height: 12),
                    controlsSection,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: titleSection),
                  controlsSection,
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PresetPill extends StatelessWidget {
  const _PresetPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1B1638) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}