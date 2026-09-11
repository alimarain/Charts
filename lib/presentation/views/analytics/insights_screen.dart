import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/insights_provider.dart';
import '../../widgets/insights/assets_insight_card.dart';
import '../../widgets/insights/card_empty_fallback.dart';
import '../../widgets/insights/insights_header_banner.dart';
import '../../widgets/insights/insights_skeleton_loader.dart';
import '../../widgets/insights/net_cash_flow_insight_card.dart';
import '../../widgets/insights/profit_earned_card.dart';
import '../../widgets/insights/spent_this_month_card.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  static const routeName = 'insights';
  static const routePath = '/insights';

  // Base Figma viewport reference
  static const double _baseWidth = 375.0;
  static const double _baseHeight = 812.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.sizeOf(context);
    final scaleW = screenSize.width / _baseWidth;
    final scaleH = screenSize.height / _baseHeight;

    // Proportional scaling for paddings and gaps
    final horizontalPadding = 16.0 * scaleW;
    final rowGap = 10.0 * scaleH;
    final colGap = 10.0 * scaleW;

    final insightsAsync = ref.watch(insightsApiProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF6347D1),
      body: Container(
        width: screenSize.width,
        height: screenSize.height,
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
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const InsightsHeaderBanner(),
              Expanded(
                child: insightsAsync.when(
                  loading: () => const InsightsSkeletonLoader(),
                  error: (err, _) => Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 32,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Failed to load insights: $err',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: () => ref.refresh(insightsApiProvider),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  data: (data) {
                    final hasSpending = data.getSection('Spending') != null;
                    final hasCashFlow = data.getSection('Cash Flow') != null;
                    final hasProfit = data.getSection('Profit') != null;
                    final hasAssets = data.getSection('Assets') != null;

                    return RefreshIndicator(
                      color: const Color(0xFF6347D1),
                      onRefresh: () async {
                        ref.invalidate(insightsApiProvider);
                        await ref.read(insightsApiProvider.future);
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          0,
                          horizontalPadding,
                          20.0 * scaleH,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Card 1: Spent This Month
                            if (hasSpending)
                              SpentThisMonthCard(
                                amount: data.totalSpent,
                                bills: data.billsSpent,
                                grocery: data.grocerySpent,
                                shopping: data.shoppingSpent,
                                other: data.otherSpent,
                              )
                            else
                              const CardEmptyFallback(
                                title: 'Spent This Month',
                              ),

                            SizedBox(height: rowGap),

                            // Cards 2 & 3: Net Cash Flow and Profit
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: hasCashFlow
                                      ? NetCashFlowInsightCard(
                                          netBalance: data.cashFlowNet,
                                          inflow: data.moneyIn,
                                          outflow: data.moneyOut,
                                        )
                                      : const CardEmptyFallback(
                                          title: 'Net Cash Flow',
                                        ),
                                ),
                                SizedBox(width: colGap),
                                Expanded(
                                  child: hasProfit
                                      ? ProfitEarnedCard(
                                          amount: data.totalProfit,
                                          accountsPercent: data.totalProfit > 0
                                              ? (data.accountsProfit /
                                                    data.totalProfit)
                                              : 0.65,
                                          mudarabahPercent: data.totalProfit > 0
                                              ? (data.mudarabahProfit /
                                                    data.totalProfit)
                                              : 0.35,
                                        )
                                      : const CardEmptyFallback(
                                          title: 'Profit Earned',
                                        ),
                                ),
                              ],
                            ),

                            SizedBox(height: rowGap),

                            // Card 4: Assets
                            if (hasAssets)
                              AssetsInsightCard(
                                totalAssets: data.totalAssets,
                                accountRatio: data.accountsAllocationRatio,
                                mudarabahRatio: data.mudarabahAllocationRatio,
                              )
                            else
                              const CardEmptyFallback(title: 'Assets'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
