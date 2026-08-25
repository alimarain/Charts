import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_theme.dart';
import '../../../domain/entities/chart_filter_models.dart';
import '../../controllers/chart_filter_provider.dart';

class ChartFilterBar extends ConsumerWidget {
  const ChartFilterBar({required this.availableCategories, super.key});

  final List<String> availableCategories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(chartFilterProvider);
    final notifier = ref.read(chartFilterProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 18,
                    color: AppTheme.primaryColor,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'ADVANCED ANALYTICS CONTROLS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: notifier.reset,
                icon: const Icon(Icons.refresh_rounded, size: 14),
                label: const Text('Reset', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // 1. Date Range Dropdown
              _FilterDropdown<ChartDatePreset>(
                label: 'Date Range',
                value: filter.datePreset,
                items: const [
                  DropdownMenuItem(
                    value: ChartDatePreset.today,
                    child: Text('Today'),
                  ),
                  DropdownMenuItem(
                    value: ChartDatePreset.yesterday,
                    child: Text('Yesterday'),
                  ),
                  DropdownMenuItem(
                    value: ChartDatePreset.last7Days,
                    child: Text('Last 7 Days'),
                  ),
                  DropdownMenuItem(
                    value: ChartDatePreset.last30Days,
                    child: Text('Last 30 Days'),
                  ),
                  DropdownMenuItem(
                    value: ChartDatePreset.last3Months,
                    child: Text('Last 3 Months'),
                  ),
                  DropdownMenuItem(
                    value: ChartDatePreset.last6Months,
                    child: Text('Last 6 Months'),
                  ),
                  DropdownMenuItem(
                    value: ChartDatePreset.thisYear,
                    child: Text('This Year'),
                  ),
                  DropdownMenuItem(
                    value: ChartDatePreset.custom,
                    child: Text('Custom Range...'),
                  ),
                ],
                onChanged: (val) async {
                  if (val == null) return;
                  if (val == ChartDatePreset.custom) {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2025),
                      lastDate: DateTime(2027),
                      initialDateRange: DateTimeRange(
                        start:
                            filter.startDate ??
                            DateTime.now().subtract(const Duration(days: 7)),
                        end: filter.endDate ?? DateTime.now(),
                      ),
                    );
                    if (picked != null) {
                      notifier.setCustomRange(picked.start, picked.end);
                    }
                  } else {
                    notifier.setDatePreset(val);
                  }
                },
              ),

              // 2. Category Dropdown
              _FilterDropdown<String>(
                label: 'Category',
                value: filter.selectedCategory,
                items: availableCategories
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) notifier.setCategory(val);
                },
              ),

              // 3. Comparison Dropdown
              _FilterDropdown<ComparisonPeriod>(
                label: 'Compare',
                value: filter.comparisonPeriod,
                items: const [
                  DropdownMenuItem(
                    value: ComparisonPeriod.none,
                    child: Text('None'),
                  ),
                  DropdownMenuItem(
                    value: ComparisonPeriod.previousPeriod,
                    child: Text('Previous Period'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) notifier.setComparison(val);
                },
              ),

              // 4. Target Toggle
              FilterChip(
                label: const Text(
                  'Target Goal',
                  style: TextStyle(fontSize: 12),
                ),
                selected: filter.isTargetEnabled,
                onSelected: notifier.toggleTarget,
                selectedColor: AppTheme.primaryLight,
                checkmarkColor: AppTheme.primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }
}
