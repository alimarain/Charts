import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/insights_data.dart';

class InsightsFilterState {
  const InsightsFilterState({required this.accountScope, required this.period});

  final String accountScope;
  final String period;

  InsightsFilterState copyWith({String? accountScope, String? period}) {
    return InsightsFilterState(
      accountScope: accountScope ?? this.accountScope,
      period: period ?? this.period,
    );
  }
}

class InsightsFilterNotifier extends Notifier<InsightsFilterState> {
  @override
  InsightsFilterState build() {
    return const InsightsFilterState(
      accountScope: 'All Accounts',
      period: 'September 2026',
    );
  }

  void setScope(String scope) => state = state.copyWith(accountScope: scope);
  void setPeriod(String period) => state = state.copyWith(period: period);
}

final insightsFilterProvider =
    NotifierProvider<InsightsFilterNotifier, InsightsFilterState>(
      InsightsFilterNotifier.new,
    );

// Service Mock simulating your ASP.NET Web API endpoint
final insightsApiProvider = FutureProvider<InsightsResponseDto>((ref) async {
  final filter = ref.watch(insightsFilterProvider);

  // Simulated latency
  await Future.delayed(const Duration(milliseconds: 400));

  // In production: final response = await dio.get('/api/insights', queryParameters: {'period': filter.period, 'scope': filter.accountScope});
  final Map<String, dynamic> rawJson = {
    "clientId": "CL002",
    "period": filter.period,
    "sections": [
      {
        "sectionName": "Asset Allocation",
        "total": null,
        "fields": [
          {"name": "Accounts Allocation %", "value": 52},
          {"name": "Pots Allocation %", "value": 28},
          {"name": "Mudarabah Allocation %", "value": 20},
        ],
      },
      {
        "sectionName": "Assets",
        "total": 375000,
        "fields": [
          {"name": "Month End Balance Date", "value": "2026-09-30T00:00:00"},
          {"name": "Accounts Balance", "value": 195000},
          {"name": "Accounts Count", "value": 1},
          {"name": "Pots Balance", "value": 105000},
          {"name": "Pots Count", "value": 1},
          {"name": "Mudarabah Balance", "value": 75000},
          {"name": "Mudarabah Count", "value": 1},
          {"name": "Total Owned", "value": 375000},
        ],
      },
      {
        "sectionName": "Cash Flow",
        "total": 191757.5,
        "fields": [
          {"name": "Money In", "value": 270000},
          {"name": "Money In Count", "value": 4},
          {"name": "Money Out", "value": 78242.5},
          {"name": "Money Out Count", "value": 401},
        ],
      },
      {
        "sectionName": "Customer",
        "total": null,
        "fields": [
          {"name": "Client ID", "value": "CL002"},
        ],
      },
      {
        "sectionName": "Profit",
        "total": 826.2,
        "fields": [
          {"name": "Accounts Profit", "value": 450},
          {"name": "Pots Profit", "value": 252},
          {"name": "Mudarabah Profit", "value": 270},
          {"name": "Gross Profit", "value": 972},
          {"name": "Withholding Tax", "value": 145.8},
        ],
      },
      {
        "sectionName": "Spending",
        "total": 78242.5,
        "fields": [
          {"name": "Total Transactions", "value": 401},
          {"name": "Food & Dining", "value": 10587.5},
          {"name": "Grocery", "value": 19565},
          {"name": "Bills & Utilities", "value": 12000},
          {"name": "Shopping", "value": 88865},
          {"name": "Travel & Hotels", "value": 7125},
          {"name": "Transport", "value": 6600},
          {"name": "Healthcare", "value": 2700},
          {"name": "Donations", "value": 2700},
          {"name": "Entertainment", "value": 4275},
          {"name": "Other Spending", "value": 3825},
          {"name": "Total Spent Amount", "value": 78242.5},
        ],
      },
    ],
  };

  return InsightsResponseDto.fromJson(rawJson);
});
