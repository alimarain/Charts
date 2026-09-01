import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/chart_display_models.dart';

final chartDisplayProvider =
    NotifierProvider<ChartDisplayNotifier, ChartDisplayState>(
      ChartDisplayNotifier.new,
    );

class ChartDisplayNotifier extends Notifier<ChartDisplayState> {
  @override
  ChartDisplayState build() {
    return const ChartDisplayState();
  }

  void setRevenueChartType(RevenueChartType type) {
    state = state.copyWith(revenueChartType: type);
  }

  void setCategoryChartType(CategoryChartType type) {
    state = state.copyWith(categoryChartType: type);
  }

  void setDistributionChartType(DistributionChartType type) {
    state = state.copyWith(distributionChartType: type);
  }

  void setExporting(bool isExporting) {
    state = state.copyWith(isExporting: isExporting);
  }
}
