import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/analytics.dart';
import '../../domain/entities/chart_filter_models.dart';
import 'analytics_provider.dart';

final chartFilterProvider =
    NotifierProvider<ChartFilterNotifier, ChartFilterState>(
      ChartFilterNotifier.new,
    );

class ChartFilterNotifier extends Notifier<ChartFilterState> {
  @override
  ChartFilterState build() {
    final now = DateTime.now();
    return ChartFilterState(
      datePreset: ChartDatePreset.last30Days,
      startDate: now.subtract(const Duration(days: 30)),
      endDate: now,
    );
  }

  void setDatePreset(ChartDatePreset preset) {
    final now = DateTime.now();
    DateTime? start;
    DateTime? end = now;

    switch (preset) {
      case ChartDatePreset.today:
        start = DateTime(now.year, now.month, now.day);
        break;
      case ChartDatePreset.yesterday:
        start = DateTime(now.year, now.month, now.day - 1);
        end = DateTime(now.year, now.month, now.day - 1, 23, 59, 59);
        break;
      case ChartDatePreset.last7Days:
        start = now.subtract(const Duration(days: 7));
        break;
      case ChartDatePreset.last30Days:
        start = now.subtract(const Duration(days: 30));
        break;
      case ChartDatePreset.last3Months:
        start = DateTime(now.year, now.month - 3, now.day);
        break;
      case ChartDatePreset.last6Months:
        start = DateTime(now.year, now.month - 6, now.day);
        break;
      case ChartDatePreset.thisYear:
        start = DateTime(now.year, 1, 1);
        break;
      case ChartDatePreset.custom:
        start = state.startDate ?? now.subtract(const Duration(days: 7));
        end = state.endDate ?? now;
        break;
    }

    state = state.copyWith(datePreset: preset, startDate: start, endDate: end);
  }

  void setCustomRange(DateTime start, DateTime end) {
    state = state.copyWith(
      datePreset: ChartDatePreset.custom,
      startDate: start,
      endDate: end,
    );
  }

  void setCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setComparison(ComparisonPeriod comparison) {
    state = state.copyWith(comparisonPeriod: comparison);
  }

  void toggleTarget(bool enabled) {
    state = state.copyWith(isTargetEnabled: enabled);
  }

  void reset() {
    final now = DateTime.now();
    state = ChartFilterState(
      datePreset: ChartDatePreset.last30Days,
      startDate: now.subtract(const Duration(days: 30)),
      endDate: now,
      selectedCategory: 'All',
      comparisonPeriod: ComparisonPeriod.none,
      isTargetEnabled: true,
      targetRevenue: 500000.0,
    );
  }
}

// -------------------------------------------------------------
// Filtered Analytics Data Provider
// -------------------------------------------------------------
  class FilteredAnalyticsResult {
    const FilteredAnalyticsResult({
      required this.currentSales,
      required this.previousSales,
      required this.categorySales,
      required this.distribution,
      required this.kpis,
      required this.categories,
      required this.hasData,
    });

    final List<SalesData> currentSales;
    final List<SalesData> previousSales;
    final List<CategorySalesData> categorySales;
    final List<ProductDistributionData> distribution;
    final ComputedKpis kpis;
    final List<String> categories;
    final bool hasData;
  }

final filteredAnalyticsProvider = Provider<FilteredAnalyticsResult?>((ref) {
  final analyticsState = ref.watch(analyticsProvider);
  final filter = ref.watch(chartFilterProvider);

  final rawData = analyticsState.data;
  if (rawData == null) return null;

  final allCategories = [
    'All',
    ...rawData.categorySales.map((e) => e.category).toSet(),
  ];

  // 1. Filter Category Sales
  final filteredCategories = filter.selectedCategory == 'All'
      ? rawData.categorySales : rawData.categorySales.where(
        (e) => e.category == filter.selectedCategory)
            .toList();

  // 2. Filter Inventory Distribution
  final filteredDist = filter.selectedCategory == 'All'
      ? rawData.distribution
      : rawData.distribution
            .where((e) => e.category == filter.selectedCategory)
            .toList();

  // 3. Scale sales volume based on category and date filter presets
  double scaleFactor = 1.0;
  if (filter.selectedCategory != 'All') {
    scaleFactor *= 0.35;
  }
  switch (filter.datePreset) {
    case ChartDatePreset.today:
      scaleFactor *= 0.15;
      break;
    case ChartDatePreset.yesterday:
      scaleFactor *= 0.14;
      break;
    case ChartDatePreset.last7Days:
      scaleFactor *= 0.45;
      break;
    case ChartDatePreset.last30Days:
      scaleFactor *= 1.0;
      break;
    case ChartDatePreset.last3Months:
      scaleFactor *= 2.2;
      break;
    case ChartDatePreset.last6Months:
      scaleFactor *= 3.8;
      break;
    case ChartDatePreset.thisYear:
      scaleFactor *= 5.0;
      break;
    case ChartDatePreset.custom:
      if (filter.startDate != null && filter.endDate != null) {
        final days = filter.endDate!.difference(filter.startDate!)
            .inDays.clamp(1, 365);scaleFactor *= (days / 30.0);
      }
      break;
  }

  final currentSales = rawData.salesData.map((e) {
    return SalesData(
      label: e.label,
      value: (e.value * scaleFactor).roundToDouble(),
    );
  }).toList();

  // 4. Calculate Comparison Dataset (Previous Period baseline)
  final previousSales = rawData.salesData.map((e) {
    return SalesData(
      label: e.label,
      value: (e.value * scaleFactor * 0.85).roundToDouble(),
    );
  }).toList();

  final currentRev = currentSales.fold<double>(0.0, (s, e) => s + e.value);
  final prevRev = previousSales.fold<double>(0.0, (s, e) => s + e.value);
  final revGrowth = prevRev > 0
      ? (((currentRev - prevRev) / prevRev) * 100)
      : 0.0;

  final currentOrders = (rawData.totalOrders * scaleFactor).round();
  final prevOrders = (currentOrders * 0.88).round();
  final orderGrowth = prevOrders > 0
      ? (((currentOrders - prevOrders) / prevOrders) * 100)
      : 0.0;

  final activeSkus = filteredDist.fold<int>(0, (s, e) => s + e.count);
  final achievement = filter.targetRevenue > 0
      ? ((currentRev / filter.targetRevenue) * 100)
      : 0.0;

  final kpis = ComputedKpis(
    currentRevenue: currentRev,
    previousRevenue: prevRev,
    revenueGrowthPercent: revGrowth,
    currentOrders: currentOrders,
    previousOrders: prevOrders,
    ordersGrowthPercent: orderGrowth,
    activeSkus: activeSkus,
    targetAchievementPercent: achievement,
  );

  return FilteredAnalyticsResult(
    currentSales: currentSales,
    previousSales: previousSales,
    categorySales: filteredCategories,
    distribution: filteredDist,
    kpis: kpis,
    categories: allCategories,
    hasData: currentSales.isNotEmpty && filteredCategories.isNotEmpty,
  );
});
