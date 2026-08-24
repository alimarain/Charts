import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_app/presentation/views/controllers/auth_provider.dart';
import 'package:new_app/presentation/views/controllers/product_provider.dart';
import '../dashboard/dashboard_screen.dart';
import '../form/form_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  static const routeName = 'home';
  static const routePath = '/home';

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _statusLog = 'Ready to test networking';
  bool _isLoading = false;
  bool _hasError = false;

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _statusLog = 'Requesting products via Dio client...';
    });

    try {
      final products = await ref.read(productServiceProvider).getProducts();
      setState(() {
        _statusLog = 'Success! Fetched ${products.length} products.\nCheck console for Dio logs.';
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _statusLog = 'Error caught: $e';
      });
      developer.log('UI caught error: $e', name: 'HomeScreen');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _triggerError() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _statusLog = 'Triggering 404 test endpoint...';
    });

    try {
      await ref.read(productServiceProvider).simulateError();
    } catch (e) {
      setState(() {
        _hasError = true;
        _statusLog = 'Successfully caught converted ApiException:\n$e';
      });
      developer.log('UI caught converted ApiException: $e', name: 'HomeScreen');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final userName = user?.name ?? 'Demo User';
    final userEmail = user?.email ?? 'user@example.com';
    final hasToken = authState.token != null && authState.token!.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: const Text(
          'Workspace Hub',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFF64748B)),
            tooltip: 'Sign Out',
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Profile Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
                    child: const Icon(Icons.person_rounded, size: 30, color: Color(0xFF2563EB)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userEmail,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: hasToken ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: hasToken ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                hasToken ? Icons.verified_rounded : Icons.warning_amber_rounded,
                                size: 13,
                                color: hasToken ? const Color(0xFF059669) : const Color(0xFFDC2626),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                hasToken ? 'Mock JWT Active' : 'No Token In State',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: hasToken ? const Color(0xFF059669) : const Color(0xFFDC2626),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Main Actions Section
            const Text(
              'APPLICATION FLOW',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF94A3B8),
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),

            // Open Live Dashboard Card Button
            _ActionCard(
              title: 'Open Live Dashboard',
              subtitle: 'Stream catalog, scroll preservation & category filters',
              icon: Icons.storefront_rounded,
              iconColor: const Color(0xFF2563EB),
              badgeColor: const Color(0xFFEFF6FF),
              onTap: () => context.pushNamed(DashboardScreen.routeName),
            ),
            const SizedBox(height: 12),

            // Open Multi-Step Onboarding Form Card Button
            _ActionCard(
              title: 'Open Multi-Step Form',
              subtitle: 'Two-step flow with session state & stream submission',
              icon: Icons.assignment_rounded,
              iconColor: const Color(0xFF7C3AED),
              badgeColor: const Color(0xFFF5F3FF),
              onTap: () => context.pushNamed(FormScreen.routeName),
            ),
            const SizedBox(height: 24),

            // Network Diagnostics Section
            const Text(
              'NETWORK & DIO DIAGNOSTICS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF94A3B8),
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),

            // Diagnostic Output Log Console
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _hasError ? const Color(0xFFFEF2F2) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _hasError ? const Color(0xFFFECACA) : const Color(0xFFCBD5E1),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _hasError ? Icons.error_outline : Icons.terminal_rounded,
                    size: 18,
                    color: _hasError ? const Color(0xFFDC2626) : const Color(0xFF475569),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _statusLog,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        height: 1.4,
                        color: _hasError ? const Color(0xFF991B1B) : const Color(0xFF334155),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2563EB),
                      elevation: 0,
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _isLoading ? null : _fetchProducts,
                    icon: _isLoading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.cloud_download_rounded, size: 18),
                    label: const Text('Test 200 GET', style: TextStyle(fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFDC2626),
                      elevation: 0,
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _isLoading ? null : _triggerError,
                    icon: const Icon(Icons.warning_amber_rounded, size: 18),
                    label: const Text('Test 404 Error', style: TextStyle(fontSize: 13)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Clean Sign Out Button
            Center(
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF64748B),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: () => ref.read(authProvider.notifier).logout(),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Sign Out of Session', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.badgeColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color badgeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }
}