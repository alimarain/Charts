import 'package:flutter/material.dart';

enum CashflowType {
  moneyIn,
  moneyOut,
}

class CashflowCategoryTransaction {
  const CashflowCategoryTransaction({
    required this.category,
    required this.transactionCount,
    required this.amount,
    required this.type,
    this.icon = Icons.receipt_long_outlined,
    this.iconColor,
  });

  final String category;
  final int transactionCount;
  final double amount;
  final CashflowType type;
  final IconData icon;
  final Color? iconColor;

  String get formattedAmount {
    final formatted = amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    return 'Rs. $formatted';
  }

  factory CashflowCategoryTransaction.fromJson(Map<String, dynamic> json) {
    // 1. Parse Color from Hex String or Int Code
    Color? parsedColor;
    if (json['iconColor'] is String) {
      final hex = (json['iconColor'] as String).replaceAll('#', '');
      if (hex.length == 6) {
        parsedColor = Color(int.parse('0xFF$hex'));
      } else if (hex.length == 8) {
        parsedColor = Color(int.parse('0x$hex'));
      }
    } else if (json['iconColor'] is int) {
      parsedColor = Color(json['iconColor'] as int);
    }

    final categoryName = json['category'] as String? ?? '';
    final iconKey = json['iconKey'] as String? ?? categoryName;

    return CashflowCategoryTransaction(
      category: categoryName,
      transactionCount: (json['transactionCount'] as num?)?.toInt() ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: (json['type'] as String? ?? '').toLowerCase() == 'moneyout'
          ? CashflowType.moneyOut
          : CashflowType.moneyIn,
      icon: _resolveConstantIcon(iconKey),
      iconColor: parsedColor,
    );
  }

  /// Maps identifiers directly to compile-time constant IconData definitions
  static IconData _resolveConstantIcon(String key) {
    switch (key.trim()) {
      case 'cash_deposit':
      case 'Cash Deposit':
        return Icons.account_balance_wallet_outlined;
      case 'transfers':
      case 'Transfers':
      case 'Direct Bank Transfer':
        return Icons.swap_horiz_rounded;
      case 'invoices':
      case 'Client Invoices':
        return Icons.receipt_long_outlined;
      case 'groceries':
      case 'Grocery & Supplies':
        return Icons.shopping_basket_outlined;
      case 'utilities':
      case 'Utility Bills':
        return Icons.lightbulb_outline_rounded;
      case 'logistics':
      case 'Operational Logistics':
        return Icons.local_shipping_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'transactionCount': transactionCount,
      'amount': amount,
      'type': type.name,
      if (iconColor != null)
        'iconColor': '#${iconColor!.toARGB32().toRadixString(16).padLeft(8, '0')}',
    };
  }

  CashflowCategoryTransaction copyWith({
    String? category,
    int? transactionCount,
    double? amount,
    CashflowType? type,
    IconData? icon,
    Color? iconColor,
  }) {
    return CashflowCategoryTransaction(
      category: category ?? this.category,
      transactionCount: transactionCount ?? this.transactionCount,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
    );
  }
}