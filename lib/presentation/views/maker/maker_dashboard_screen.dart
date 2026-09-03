import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_app/presentation/controllers/maker_provider.dart';
import 'package:new_app/presentation/widgets/maker/maker_product_card.dart';

import '../../controllers/auth_provider.dart';
import '../../widgets/common/app_state_views.dart';
import 'maker_forms_screen.dart';

class MakerDashboardScreen extends ConsumerWidget {
  const MakerDashboardScreen({super.key});

  static const routeName = 'maker_dashboard';
  static const routePath = '/maker-dashboard';

  IconData _resolveIcon(String iconName) {
    switch (iconName) {
      case 'account_balance':
        return Icons.account_balance_rounded;
      case 'shield':
        return Icons.shield_outlined;
      case 'verified_user':
        return Icons.verified_user_outlined;
      default:
        return Icons.business_center_outlined;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final productsAsync = ref.watch(makerProductsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              'Logged in as ${authState.user?.name ?? "applicant"}',
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF4F46E5)),
            tooltip: 'Reload Catalog',
            onPressed: () => ref.read(makerProductsProvider.notifier).refresh(),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFF64748B)),
            tooltip: 'Sign Out',
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: productsAsync.when(
        loading: () => const AppLoadingView(color: Color(0xFF4F46E5)),
        error: (err, _) => AppErrorView(
          message: 'Could not load products: $err',
          onRetry: () => ref.read(makerProductsProvider.notifier).refresh(),
        ),
        data: (products) {
          if (products.isEmpty) {
            return const AppEmptyScopeView(
              message: 'No active underwriting products available.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: products.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              if (index == 0) {
                return const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AVAILABLE WORKFLOWS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 1.1,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Select a product to initiate field applications',
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    ),
                    SizedBox(height: 12),
                  ],
                );
              }

              final product = products[index - 1];
              return MakerProductCard(
                product: product,
                icon: _resolveIcon(product.iconName),
                onTap: () {
                  context.pushNamed(
                    MakerFormsScreen.routeName,
                    pathParameters: {'productId': product.id},
                    extra: product.name,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
