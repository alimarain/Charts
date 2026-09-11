import '../../core/charts/models/chart_data.dart';
import 'cashflow_category_transaction.dart';

class CashflowData {
  const CashflowData({
    required this.chartPoints,
    required this.moneyIn,
    required this.moneyOut,
  });

  final List<ChartDataPoint> chartPoints;
  final List<CashflowCategoryTransaction> moneyIn;
  final List<CashflowCategoryTransaction> moneyOut;

  factory CashflowData.empty() {
    return const CashflowData(chartPoints: [], moneyIn: [], moneyOut: []);
  }

  factory CashflowData.fromJson(Map<String, dynamic> json) {
    return CashflowData(
      chartPoints: (json['chartPoints'] as List<dynamic>? ?? [])
          .map(
            (e) => ChartDataPoint.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
      moneyIn: (json['moneyIn'] as List<dynamic>? ?? [])
          .map(
            (e) => CashflowCategoryTransaction.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
      moneyOut: (json['moneyOut'] as List<dynamic>? ?? [])
          .map(
            (e) => CashflowCategoryTransaction.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chartPoints': chartPoints.map((e) => e.toJson()).toList(),
      'moneyIn': moneyIn.map((e) => e.toJson()).toList(),
      'moneyOut': moneyOut.map((e) => e.toJson()).toList(),
    };
  }

  CashflowData copyWith({
    List<ChartDataPoint>? chartPoints,
    List<CashflowCategoryTransaction>? moneyIn,
    List<CashflowCategoryTransaction>? moneyOut,
  }) {
    return CashflowData(
      chartPoints: chartPoints ?? this.chartPoints,
      moneyIn: moneyIn ?? this.moneyIn,
      moneyOut: moneyOut ?? this.moneyOut,
    );
  }
}
