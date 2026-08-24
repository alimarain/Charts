import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_app/app/app_theme.dart';
import '../controllers/analytics_provider.dart';

class AnalyticsPreviewCard extends ConsumerWidget {
  const AnalyticsPreviewCard({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsState = ref.watch(analyticsProvider);
    final revenue = analyticsState.totalRevenue;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.insights_rounded, color: AppTheme.primaryColor, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          'Store Revenue (Live)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        SizedBox(width: 6),
                        CircleAvatar(radius: 3, backgroundColor: AppTheme.secondaryColor),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      analyticsState.isLoading && analyticsState.data == null
                          ? 'Loading feed...'
                          : 'Rs. ${revenue.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '+14.8% vs last cycle',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.secondaryColor),
                    ),
                  ],
                ),
              ),
              const Row(
                children: [
                  Text(
                    'Full Charts',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 16, color: AppTheme.primaryColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}