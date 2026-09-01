import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../../data/datasources/analytics/api_analytics_service.dart';
import '../../domain/entities/analytics.dart';
import '../../domain/entities/basic_chart_data.dart';

final analyticsApiServiceProvider = Provider<ApiAnalyticsService>((ref) {
  return ApiAnalyticsService(ref.watch(dioProvider));
});

class AnalyticsState {
  final AnalyticsData? data;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;

  const AnalyticsState({
    this.data,
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
  });

  double get totalRevenue => data?.totalSales ?? 0.0;
  bool get hasData => data != null;

  AnalyticsState copyWith({
    AnalyticsData? data,
    bool? isLoading,
    bool? isError,
    String? errorMessage,
  }) {
    return AnalyticsState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AnalyticsNotifier extends Notifier<AnalyticsState> {
  @override
  AnalyticsState build() {
    // Trigger on next microtask so provider finishes initial registration
    Future.microtask(() => loadAnalytics());
    return const AnalyticsState(isLoading: true);
  }

  Future<void> loadAnalytics() async {
    state = state.copyWith(isLoading: true, isError: false, errorMessage: null);
    try {
      final result = await ref.read(analyticsApiServiceProvider).getAnalytics();
      state = AnalyticsState(data: result, isLoading: false, isError: false);
    } catch (e) {
      state = AnalyticsState(
        data: state.data,
        isLoading: false,
        isError: true,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> refresh() async => loadAnalytics();
  Future<void> retry() async => loadAnalytics();
}

final analyticsProvider = NotifierProvider<AnalyticsNotifier, AnalyticsState>(
  AnalyticsNotifier.new,
);

final basicChartProvider = FutureProvider<List<BasicChartData>>((ref) async {
  return ref.watch(analyticsApiServiceProvider).getBasicMonthlySales();
});