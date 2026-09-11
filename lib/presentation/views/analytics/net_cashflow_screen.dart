import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/cashflow_category_transaction.dart';
import '../../controllers/cashflow_provider.dart';
import '../../widgets/analytics/cashflow_transaction_card.dart';
import '../../widgets/charts/net_balance_win_loss_card.dart';

class NetCashflowScreen extends ConsumerWidget {
  const NetCashflowScreen({super.key});

  static const routeName = 'net-cashflow';
  static const routePath = '/net-cashflow';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cashflowAsync = ref.watch(cashflowDataProvider);
    final selectedIndex = ref.watch(selectedCashflowIndexProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.35, 0.75, 1.0],
            colors: [
              Color(0xFF6347D1),
              Color(0xFF755CE0),
              Color(0xFFCDC8EB),
              Color(0xFFE8E5F4),
            ],
          ),
        ),
        child: SafeArea(
          child: cashflowAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            error: (err, _) => Center(
              child: Text(
                'Failed to load cashflow data: $err',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            data: (data) {
              final points = data.chartPoints;
              final activeIndex = (selectedIndex >= 0 && selectedIndex < points.length)
                  ? selectedIndex
                  : (points.isNotEmpty ? points.length - 1 : 0);

              final selectedPoint = points.isNotEmpty ? points[activeIndex] : null;
              final monthLabel = selectedPoint != null
                  ? '${selectedPoint.label} 2026'
                  : 'Cashflow Overview';

              return Column(
                children: [
                  _ScreenHeader(monthLabel: monthLabel),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 820),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              NetBalanceWinLossCard(
                                dataPoints: points,
                                selectedIndex: activeIndex,
                                onPointSelected: (index) {
                                  ref.read(selectedCashflowIndexProvider.notifier).state = index;
                                },
                              ),
                              const SizedBox(height: 24),
                              _Section(title: 'Money In', items: data.moneyIn),
                              const SizedBox(height: 18),
                              _Section(title: 'Money Out', items: data.moneyOut),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ScreenHeader extends StatelessWidget {
  const _ScreenHeader({required this.monthLabel});
  final String monthLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => context.canPop() ? context.pop() : context.go('/charts'),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.18)),
              ),
              const SizedBox(width: 16),
              const Text(
                'Net Cashflow',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 56.0, top: 2.0),
            child: Text(
              monthLabel,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFFE0D8FF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.items});

  final String title;
  final List<CashflowCategoryTransaction> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E1B4B),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 10),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: CashflowTransactionCard(item: item),
          ),
        ),
      ],
    );
  }
}