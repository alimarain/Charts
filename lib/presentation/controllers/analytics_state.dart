import '../../domain/entities/analytics.dart';

enum AnalyticsPeriod {
  sevenDays,
  thirtyDays,
  ninetyDays,
}

enum AnalyticsStatus {
  loading,
  ready,
  error,
}

class AnalyticsState {
  const AnalyticsState({
    this.status = AnalyticsStatus.loading,
    this.period = AnalyticsPeriod.sevenDays,
    this.data,
    this.errorMessage,
  });

  final AnalyticsStatus status;
  final AnalyticsPeriod period;
  final AnalyticsData? data;
  final String? errorMessage;

  bool get isLoading => status == AnalyticsStatus.loading;
  bool get isReady => status == AnalyticsStatus.ready && data != null;
  bool get isError => status == AnalyticsStatus.error;

  double get totalRevenue =>
      data?.categorySales.fold(0.0, (acc, item) => (acc ?? 0.0) + item.sales) ?? 0.0;

  int get totalInventoryCount =>
      data?.distribution.fold(0, (acc, item) => (acc ?? 0) + item.count) ?? 0;

  AnalyticsState copyWith({
    AnalyticsStatus? status,
    AnalyticsPeriod? period,
    AnalyticsData? data,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AnalyticsState(
      status: status ?? this.status,
      period: period ?? this.period,
      data: data ?? this.data,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}