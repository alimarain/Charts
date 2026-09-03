import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'product_provider.dart';

class HomeTelemetryState {
  const HomeTelemetryState({
    this.statusLog = 'Ready to test networking',
    this.isLoading = false,
    this.hasError = false,
  });

  final String statusLog;
  final bool isLoading;
  final bool hasError;

  HomeTelemetryState copyWith({
    String? statusLog,
    bool? isLoading,
    bool? hasError,
  }) {
    return HomeTelemetryState(
      statusLog: statusLog ?? this.statusLog,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
    );
  }
}

class HomeTelemetryNotifier extends Notifier<HomeTelemetryState> {
  @override
  HomeTelemetryState build() => const HomeTelemetryState();

  Future<void> fetchProducts() async {
    state = state.copyWith(
      isLoading: true,
      hasError: false,
      statusLog: 'Requesting products via Dio client...',
    );

    try {
      final products = await ref.read(productServiceProvider).getProducts();
      state = state.copyWith(
        isLoading: false,
        statusLog:
            'Success! Fetched ${products.length} products from backend API.\nCheck console for Dio logs.',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        statusLog: 'Error caught: $e',
      );
      developer.log('UI caught error: $e', name: 'HomeTelemetry');
    }
  }

  Future<void> triggerError() async {
    state = state.copyWith(
      isLoading: true,
      hasError: false,
      statusLog: 'Triggering 404 test endpoint...',
    );

    try {
      // simulateError() returns synchronous void (no await needed)
      ref.read(productServiceProvider).simulateError();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        statusLog: 'Successfully caught converted ApiException:\n$e',
      );
      developer.log(
        'UI caught converted ApiException: $e',
        name: 'HomeTelemetry',
      );
    }
  }
}

final homeTelemetryProvider =
    NotifierProvider<HomeTelemetryNotifier, HomeTelemetryState>(
      HomeTelemetryNotifier.new,
    );
