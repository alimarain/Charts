import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_app/data/datasources/analytics/realtime_analytics_service.dart';

import '../../core/network/dio_client.dart';
import '../../core/storage/token_storage.dart';
import '../../data/datasources/analytics/api_analytics_service.dart';
import '../../domain/entities/analytics.dart';
import '../../domain/entities/basic_chart_data.dart'; 

// --- API & REAL-TIME SERVICES ---

final analyticsApiServiceProvider = Provider<ApiAnalyticsService>((ref) {
  return ApiAnalyticsService(ref.watch(dioProvider));
});

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

final realtimeAnalyticsServiceProvider = Provider<RealtimeAnalyticsService>((ref) {
  final service = RealtimeAnalyticsService(ref.watch(tokenStorageProvider));
  service.connect();
  ref.onDispose(() => service.dispose());
  return service;
});

// Reactive Telemetry Stream Provider
final realtimeAnalyticsStreamProvider = StreamProvider<AnalyticsData>((ref) {
  final service = ref.watch(realtimeAnalyticsServiceProvider);
  return service.telemetryStream;
});

// --- STATE DEFINITION ---

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

// --- RIVERPOD 3.X NOTIFIER ---

class AnalyticsNotifier extends Notifier<AnalyticsState> {
  StreamSubscription<AnalyticsData>? _streamSub;

  @override
  AnalyticsState build() {
    // Clean up active subscriptions on provider disposal
    ref.onDispose(() {
      _streamSub?.cancel();
    });

    // 1. Initial REST data load
    Future.microtask(() => loadAnalytics());

    // 2. Subscribe to the real-time stream service
    final realtimeService = ref.watch(realtimeAnalyticsServiceProvider);
    _streamSub?.cancel();
    _streamSub = realtimeService.telemetryStream.listen(
      (liveUpdate) {
        state = state.copyWith(
          data: liveUpdate,
          isLoading: false,
          isError: false,
          errorMessage: null,
        );
      },
      onError: (err) {
        state = state.copyWith(
          isError: true,
          errorMessage: err.toString(),
        );
      },
    );

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

// Stream provider for the basic chart channel
final basicChartStreamProvider = StreamProvider<List<BasicChartData>>((ref) {
  final service = ref.watch(realtimeAnalyticsServiceProvider);
  return service.basicChartStream;
});

// Real-time dynamic notifier for BasicChart
class BasicChartNotifier extends AsyncNotifier<List<BasicChartData>> {
  StreamSubscription<List<BasicChartData>>? _sub;

  @override
  Future<List<BasicChartData>> build() async {
    ref.onDispose(() => _sub?.cancel());

    // 1. Subscribe to real-time incoming points
    final realtimeService = ref.watch(realtimeAnalyticsServiceProvider);
    _sub?.cancel();
    _sub = realtimeService.basicChartStream.listen(
      (livePoints) {
        state = AsyncData(livePoints);
      },
      onError: (err, stack) {
        state = AsyncError(err, stack);
      },
    );

    // 2. Fetch initial baseline via REST API
    return ref.read(analyticsApiServiceProvider).getBasicMonthlySales();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(analyticsApiServiceProvider).getBasicMonthlySales(),
    );
  }
}

final basicChartProvider =
    AsyncNotifierProvider<BasicChartNotifier, List<BasicChartData>>(
  BasicChartNotifier.new,
);