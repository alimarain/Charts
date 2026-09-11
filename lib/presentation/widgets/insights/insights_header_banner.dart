import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_app/presentation/widgets/analytics/account_selector_modal.dart';

import '../../controllers/insights_provider.dart';
import 'period_selector_modal.dart';

class InsightsHeaderBanner extends ConsumerWidget {
  const InsightsHeaderBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(insightsFilterProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Navigation Back Button & Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/charts');
                  }
                },
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                ),
              ),
              const SizedBox(width: 14),
              const Text(
                'Insights',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),

        // Dark Banner
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          padding: const EdgeInsets.all(14.0),
          decoration: BoxDecoration(
            color: const Color(0xFF281C64).withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: const Row(
            children: [
              Text('💡', style: TextStyle(fontSize: 18)),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Insights',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Tap the cards below to view details.',
                      style: TextStyle(fontSize: 11, color: Color(0xFFDCD6FA)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Interactive Subtitle Pills Row (Exact Figma styling)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Account Pill
              _HeaderPill(
                label: filter.accountScope,
                showDropdownIcon: true,
                onTap: () {
                  AccountSelectorModal.show(
                    context,
                    currentAccountId: filter.accountScope,
                    onSelected: (account) {
                      ref
                          .read(insightsFilterProvider.notifier)
                          .setScope(account.name);
                    },
                  );
                },
              ),

              // Right: Period Pill
              _HeaderPill(
                label: filter.period,
                showDropdownIcon: false,
                onTap: () {
                  PeriodSelectorModal.show(
                    context,
                    currentPeriod: filter.period,
                    onSelected: (result) {
                      ref
                          .read(insightsFilterProvider.notifier)
                          .setPeriod(result.label);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({
    required this.label,
    required this.onTap,
    this.showDropdownIcon = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool showDropdownIcon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
              if (showDropdownIcon) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
