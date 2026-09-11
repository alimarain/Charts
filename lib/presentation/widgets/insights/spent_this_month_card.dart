import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SpentThisMonthCard extends StatelessWidget {
  const SpentThisMonthCard({
    super.key,
    required this.amount,
    required this.bills,
    required this.grocery,
    required this.shopping,
    required this.other,
    this.percentageChange = '+5% since last month',
  });

  final double amount;
  final double bills;
  final double grocery;
  final double shopping;
  final double other;
  final String percentageChange;

  // Figma Color Tokens
  static const Color textPrimary = Color(0xFF282828);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color colorBills = Color(0xFF5162B8);
  static const Color colorGrocery = Color(0xFF73B851);
  static const Color colorShopping = Color(0xFFB89951);
  static const Color colorOther = Color(0xFFA0A0A0);

  String _formatAmount(double value) {
    final formatter = NumberFormat('#,##0');
    return 'Rs. ${formatter.format(value.round())}';
  }

  @override
  Widget build(BuildContext context) {
    final total = bills + grocery + shopping + other;

    // Relative flex ratios (ensure each has at least flex 1 if value > 0)
    final billsFlex = total > 0 && bills > 0
        ? (bills / total * 100).round().clamp(1, 100)
        : 0;
    final groceryFlex = total > 0 && grocery > 0
        ? (grocery / total * 100).round().clamp(1, 100)
        : 0;
    final shoppingFlex = total > 0 && shopping > 0
        ? (shopping / total * 100).round().clamp(1, 100)
        : 0;
    final otherFlex = total > 0 && other > 0
        ? (other / total * 100).round().clamp(1, 100)
        : 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Title
          const Text(
            'Spent This Month',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textSecondary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),

          // 2. Main Amount
          Text(
            _formatAmount(amount),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),

          // 3. Subtext
          Text(
            percentageChange,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: textSecondary,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 12),

          // 4. Multi-Segment Progress Bar with gaps
          SizedBox(
            height: 7,
            child: Row(
              children: [
                if (billsFlex > 0)
                  Expanded(
                    flex: billsFlex,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorBills,
                        borderRadius: BorderRadius.circular(3.5),
                      ),
                    ),
                  ),
                if (billsFlex > 0 &&
                    (groceryFlex > 0 || shoppingFlex > 0 || otherFlex > 0))
                  const SizedBox(width: 4),
                if (groceryFlex > 0)
                  Expanded(
                    flex: groceryFlex,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorGrocery,
                        borderRadius: BorderRadius.circular(3.5),
                      ),
                    ),
                  ),
                if (groceryFlex > 0 && (shoppingFlex > 0 || otherFlex > 0))
                  const SizedBox(width: 4),
                if (shoppingFlex > 0)
                  Expanded(
                    flex: shoppingFlex,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorShopping,
                        borderRadius: BorderRadius.circular(3.5),
                      ),
                    ),
                  ),
                if (shoppingFlex > 0 && otherFlex > 0) const SizedBox(width: 4),
                if (otherFlex > 0)
                  Expanded(
                    flex: otherFlex,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorOther,
                        borderRadius: BorderRadius.circular(3.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 5. Legend Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _LegendItem(label: 'Bills', color: colorBills),
              _LegendItem(label: 'Grocery', color: colorGrocery),
              _LegendItem(label: 'Shopping', color: colorShopping),
              _LegendItem(label: 'Other', color: colorOther),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF282828),
          ),
        ),
      ],
    );
  }
}
