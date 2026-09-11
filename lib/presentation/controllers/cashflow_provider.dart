import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/repositories/cashflow_repository.dart';
import '../../domain/entities/cashflow_data.dart';

final cashflowRepositoryProvider = Provider<CashflowRepository>((ref) {
  return ApiCashflowRepository();
});

// Provides the asynchronous API state
final cashflowDataProvider = FutureProvider<CashflowData>((ref) async {
  final repo = ref.watch(cashflowRepositoryProvider);
  return repo.fetchCashflowData();
});

// Holds the active interactive point selection index
final selectedCashflowIndexProvider = StateProvider<int>((ref) => -1);