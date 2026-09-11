import 'package:flutter/material.dart';

import '../../core/charts/models/chart_data.dart';
import '../../domain/entities/cashflow_category_transaction.dart';
import '../../domain/entities/cashflow_data.dart';

abstract class CashflowRepository {
  Future<CashflowData> fetchCashflowData({int? year});
}

class ApiCashflowRepository implements CashflowRepository {
  @override
  Future<CashflowData> fetchCashflowData({int? year}) async {
    await Future.delayed(const Duration(milliseconds: 150));

    return const CashflowData(
      chartPoints: [
        ChartDataPoint(label: 'Jan', value: 24450000, secondaryValue: -9880000),
        ChartDataPoint(label: 'Feb', value: 18800000, secondaryValue: -4200000),
        ChartDataPoint(
          label: 'Mar',
          value: 91200000,
          secondaryValue: -14400000,
        ),
        ChartDataPoint(label: 'Apr', value: 4200000, secondaryValue: -850000),
        ChartDataPoint(label: 'May', value: 1600000, secondaryValue: -2900000),
        ChartDataPoint(label: 'June', value: 4800000, secondaryValue: -1500000),
        ChartDataPoint(label: 'Jul', value: 2100000, secondaryValue: -3200000),
        ChartDataPoint(label: 'Aug', value: 3500000, secondaryValue: -1200000),
        ChartDataPoint(label: 'Sep', value: 3900000, secondaryValue: -1800000),
        ChartDataPoint(label: 'Oct', value: 2200000, secondaryValue: -2600000),
        ChartDataPoint(label: 'Nov', value: 3400000, secondaryValue: -1100000),
        ChartDataPoint(label: 'Dec', value: 4600000, secondaryValue: -1950000),
      ],
      moneyIn: [
        CashflowCategoryTransaction(
          category: 'Cash Deposit',
          transactionCount: 25,
          amount: 130000,
          icon: Icons.account_balance_wallet_outlined,
          type: CashflowType.moneyIn,
          iconColor: Color(0xFF009688),
        ),
        CashflowCategoryTransaction(
          category: 'Transfers',
          transactionCount: 25,
          amount: 60000,
          icon: Icons.swap_horiz_rounded,
          type: CashflowType.moneyIn,
          iconColor: Color(0xFF0EA5E9),
        ),
        CashflowCategoryTransaction(
          category: 'Client Invoices',
          transactionCount: 8,
          amount: 67789,
          icon: Icons.receipt_long_outlined,
          type: CashflowType.moneyIn,
          iconColor: Color(0xFF6366F1),
        ),
      ],
      moneyOut: [
        CashflowCategoryTransaction(
          category: 'Grocery & Supplies',
          transactionCount: 18,
          amount: 42500,
          icon: Icons.shopping_basket_outlined,
          type: CashflowType.moneyOut,
          iconColor: Color(0xFFD81B60),
        ),
        CashflowCategoryTransaction(
          category: 'Utility Bills',
          transactionCount: 4,
          amount: 28000,
          icon: Icons.lightbulb_outline_rounded,
          type: CashflowType.moneyOut,
          iconColor: Color(0xFFF59E0B),
        ),
        CashflowCategoryTransaction(
          category: 'Operational Logistics',
          transactionCount: 11,
          amount: 19500,
          icon: Icons.local_shipping_outlined,
          type: CashflowType.moneyOut,
          iconColor: Color(0xFFEF4444),
        ),
      ],
    );
  }
}
