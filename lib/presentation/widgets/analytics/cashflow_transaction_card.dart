import 'package:flutter/material.dart';
import '../../../domain/entities/cashflow_category_transaction.dart';

class CashflowTransactionCard extends StatelessWidget {
  const CashflowTransactionCard({
    super.key,
    required this.item,
    this.onTap,
  });

  final CashflowCategoryTransaction item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isMoneyIn = item.type == CashflowType.moneyIn;
    final defaultAccent = isMoneyIn ? const Color(0xFF009688) : const Color(0xFFD81B60);
    final accentColor = item.iconColor ?? defaultAccent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon
              Icon(
                item.icon,
                size: 18,
                color: accentColor,
              ),
              const SizedBox(width: 10),

              // Title & Transaction Count
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.category,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.transactionCount} Transactions',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),

              // Amount (+Rs. 130,000 / -Rs. 42,500)
              Text(
                '${isMoneyIn ? '+Rs. ' : '-Rs. '}${item.formattedAmount.replaceAll('Rs. ', '')}',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}