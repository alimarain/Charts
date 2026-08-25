import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/analytics/analytics_service.dart';
import 'analytics_state.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

final analyticsProvider = NotifierProvider<AnalyticsNotifier, AnalyticsState>(
  () {
    return AnalyticsNotifier();
  },
);

class AnalyticsNotifier extends Notifier<AnalyticsState> {
  StreamSubscription<dynamic>? _subscription;

  @override
  AnalyticsState build() {
    ref.onDispose(() {
      _subscription?.cancel();
    });

    Future.microtask(() => _startStream());
    return const AnalyticsState(status: AnalyticsStatus.loading);
  }

  void _startStream() {
    _subscription?.cancel();
    if (state.data == null) {
      state = state.copyWith(status: AnalyticsStatus.loading, clearError: true);
    }

    final service = ref.read(analyticsServiceProvider);

    _subscription = service
        .watchAnalytics(state.period)
        .listen(
          (analyticsData) {
            state = state.copyWith(
              status: AnalyticsStatus.ready,
              data: analyticsData,
              clearError: true,
            );
          },
          onError: (dynamic error) {
            state = state.copyWith(
              status: AnalyticsStatus.error,
              errorMessage: 'Unable to connect to live telemetry: $error',
            );
          },
        );
  }

  void setPeriod(AnalyticsPeriod period) {
    if (state.period != period) {
      state = state.copyWith(period: period, status: AnalyticsStatus.loading);
      _startStream();
    }
  }

  void retry() {
    _startStream();
  }
}
