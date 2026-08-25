enum ChartDatePreset {
  today,
  yesterday,
  last7Days,
  last30Days,
  last3Months,
  last6Months,
  thisYear,
  custom,
}

enum ComparisonPeriod { none, previousPeriod }

class ChartFilterState {
  const ChartFilterState({
    this.datePreset = ChartDatePreset.last30Days,
    this.startDate,
    this.endDate,
    this.selectedCategory = 'All',
    this.comparisonPeriod = ComparisonPeriod.none,
    this.isTargetEnabled = true,
    this.targetRevenue = 500000.0,
  });

  final ChartDatePreset datePreset;
  final DateTime? startDate;
  final DateTime? endDate;
  final String selectedCategory;
  final ComparisonPeriod comparisonPeriod;
  final bool isTargetEnabled;
  final double targetRevenue;

  ChartFilterState copyWith({
    ChartDatePreset? datePreset,
    DateTime? startDate,
    DateTime? endDate,
    String? selectedCategory,
    ComparisonPeriod? comparisonPeriod,
    bool? isTargetEnabled,
    double? targetRevenue,
    bool clearDates = false,
  }) {
    return ChartFilterState(
      datePreset: datePreset ?? this.datePreset,
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
      selectedCategory: selectedCategory ?? this.selectedCategory,
      comparisonPeriod: comparisonPeriod ?? this.comparisonPeriod,
      isTargetEnabled: isTargetEnabled ?? this.isTargetEnabled,
      targetRevenue: targetRevenue ?? this.targetRevenue,
    );
  }
}

class ComputedKpis {
  const ComputedKpis({
    required this.currentRevenue,
    required this.previousRevenue,
    required this.revenueGrowthPercent,
    required this.currentOrders,
    required this.previousOrders,
    required this.ordersGrowthPercent,
    required this.activeSkus,
    required this.targetAchievementPercent,
  });

  final double currentRevenue;
  final double previousRevenue;
  final double revenueGrowthPercent;
  final int currentOrders;
  final int previousOrders;
  final double ordersGrowthPercent;
  final int activeSkus;
  final double targetAchievementPercent;
}
