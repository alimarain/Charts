import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_app/presentation/views/controllers/product_provider.dart';

import '../../controllers/auth_provider.dart';
import '../analytics/analytics_screen.dart';
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

  static const Color voidColor = Color(0xFF050308);
  static const Color shellColor = Color(0xFF0D0A15);
  static const Color panelColor = Color(0xFF161224);
  static const Color lineColor = Color(0xFF251D3A);
  static const Color lineSoftColor = Color(0xFF1E192B);
  static const Color cyanAccent = Color(0xFF00F2FE);
  static const Color violetAccent = Color(0xFF9D4EDD);
  static const Color ink400 = Color(0xFF8F8A9F);
  static const Color ink500 = Color(0xFF6E6980);
  static const Color ink600 = Color(0xFF4C475A);

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _statusLog = 'Requesting products via Dio client...';
    });

    try {
      final products = await ref.read(productServiceProvider).getProducts();
      setState(() {
        _statusLog =
            'Success! Fetched ${products.length} products.\nCheck console for Dio logs.';
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
    final userName = user?.name ?? 'Marcus Reyes';
    final userRole = user?.role == 'maker' ? 'Creator' : 'Member';
    final hasToken = authState.token != null && authState.token!.isNotEmpty;

    return Scaffold(
      backgroundColor: voidColor,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    violetAccent.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -150,
            child: Container(
              width: 450,
              height: 450,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    cyanAccent.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              _buildSidebar(context, userName, userRole),
              Expanded(
                child: Column(
                  children: [
                    _buildTopHeader(hasToken),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 24.0,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1040),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildFlowstateHero(userName),
                                const SizedBox(height: 48),
                                _buildTodaySection(),
                                const SizedBox(height: 40),
                                _buildDiagnosticsSection(),
                                const SizedBox(height: 32),
                                const Center(
                                  child: Text(
                                    'VIBEFLOW ENTERPRISE RUNTIME · v2.4.0',
                                    style: TextStyle(
                                      color: ink600,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, String userName, String userRole) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = MediaQuery.of(context).size.width > 900;
        final sidebarWidth = isWide ? 240.0 : 72.0;

        return Container(
          width: sidebarWidth,
          decoration: const BoxDecoration(
            color: voidColor,
            border: Border(right: BorderSide(color: lineSoftColor, width: 1)),
          ),
          child: Column(
            children: [
              Container(
                height: 80,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: isWide ? Alignment.centerLeft : Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: panelColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: lineColor),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.bolt_rounded,
                          size: 18,
                          color: cyanAccent,
                        ),
                      ),
                    ),
                    if (isWide) ...[
                      const SizedBox(width: 12),
                      const Text(
                        'VibeFlow',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  children: [
                    _SidebarNavItem(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      isActive: true,
                      isWide: isWide,
                      activeColor: cyanAccent,
                      onTap: () {},
                    ),
                    const SizedBox(height: 4),
                    _SidebarNavItem(
                      icon: Icons.storefront_rounded,
                      label: 'Dashboard',
                      isActive: false,
                      isWide: isWide,
                      activeColor: cyanAccent,
                      onTap: () => context.pushNamed(DashboardScreen.routeName),
                    ),
                    const SizedBox(height: 4),
                    _SidebarNavItem(
                      icon: Icons.insights_rounded,
                      label: 'Charts & Telemetry',
                      isActive: false,
                      isWide: isWide,
                      activeColor: violetAccent,
                      onTap: () => context.pushNamed(AnalyticsScreen.routeName),
                    ),
                    const SizedBox(height: 4),
                    _SidebarNavItem(
                      icon: Icons.assignment_outlined,
                      label: 'Onboarding',
                      isActive: false,
                      isWide: isWide,
                      activeColor: cyanAccent,
                      onTap: () => context.pushNamed(FormScreen.routeName),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: lineSoftColor)),
                ),
                child: Row(
                  mainAxisAlignment: isWide
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: panelColor,
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: cyanAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    if (isWide) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              userRole,
                              style: const TextStyle(
                                color: ink500,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.logout_rounded,
                          size: 16,
                          color: ink500,
                        ),
                        tooltip: 'Sign Out',
                        onPressed: () =>
                            ref.read(authProvider.notifier).logout(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopHeader(bool hasToken) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: voidColor.withValues(alpha: 0.8),
        border: const Border(bottom: BorderSide(color: lineSoftColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: panelColor.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: lineSoftColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: cyanAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: Text(
                        'You usually focus best around this time.',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: ink400, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: hasToken
                      ? const Color(0xFF052E16)
                      : const Color(0xFF450A0A),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: hasToken
                        ? const Color(0xFF166534)
                        : const Color(0xFF991B1B),
                  ),
                ),
                child: Text(
                  hasToken ? 'JWT ACTIVE' : 'NO TOKEN',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: hasToken
                        ? const Color(0xFF4ADE80)
                        : const Color(0xFFF87171),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.logout_rounded, size: 18, color: ink500),
                tooltip: 'Sign Out',
                onPressed: () => ref.read(authProvider.notifier).logout(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFlowstateHero(String userName) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: lineSoftColor),
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [
            panelColor.withValues(alpha: 0.6),
            shellColor.withValues(alpha: 0.8),
            voidColor,
          ],
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Your Flowstate',
            style: TextStyle(
              color: ink400,
              fontSize: 14,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w300,
                color: Colors.white,
                letterSpacing: -1.0,
                height: 1.2,
              ),
              children: [
                TextSpan(text: "You've been in flow for "),
                TextSpan(
                  text: '42 minutes.',
                  style: TextStyle(
                    color: cyanAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: voidColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () => context.pushNamed(DashboardScreen.routeName),
                icon: const Icon(Icons.storefront_rounded, size: 18),
                label: const Text(
                  'Open Dashboard',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: ink400,
                  side: const BorderSide(color: lineSoftColor),
                  backgroundColor: panelColor.withValues(alpha: 0.4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () => context.pushNamed(AnalyticsScreen.routeName),
                icon: const Icon(Icons.insights_rounded, size: 16),
                label: const Text(
                  'Open Charts & Telemetry',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Your creative rhythm at a glance.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: ink500,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => context.pushNamed(DashboardScreen.routeName),
              child: const Text(
                'Open Dashboard →',
                style: TextStyle(
                  color: cyanAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 780;

            final mainCard = _PrimaryFeatureCard(
              onTap: () => context.pushNamed(DashboardScreen.routeName),
            );

            final secondaryStack = Column(
              children: [
                _SecondaryActionTile(
                  icon: Icons.storefront_rounded,
                  accentColor: cyanAccent,
                  title: 'Live Catalog & Filters',
                  subtitle: 'Full scroll preservation & telemetry',
                  tag: 'DASHBOARD',
                  onTap: () => context.pushNamed(DashboardScreen.routeName),
                ),
                const SizedBox(height: 12),
                _SecondaryActionTile(
                  icon: Icons.pie_chart_outline_rounded,
                  accentColor: violetAccent,
                  title: 'Store Analytics',
                  subtitle: 'Syncfusion Cartesian & circular charts',
                  tag: 'ANALYTICS',
                  onTap: () => context.pushNamed(AnalyticsScreen.routeName),
                ),
                const SizedBox(height: 12),
                _SecondaryActionTile(
                  icon: Icons.assignment_rounded,
                  accentColor: cyanAccent,
                  title: 'Multi-Step Onboarding',
                  subtitle: '2-step state preservation form',
                  tag: 'FORM',
                  onTap: () => context.pushNamed(FormScreen.routeName),
                ),
              ],
            );

            if (isDesktop) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 7, child: mainCard),
                  const SizedBox(width: 20),
                  Expanded(flex: 5, child: secondaryStack),
                ],
              );
            } else {
              return Column(
                children: [
                  mainCard,
                  const SizedBox(height: 16),
                  secondaryStack,
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildDiagnosticsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: shellColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: lineSoftColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.terminal_rounded, size: 16, color: cyanAccent),
                  SizedBox(width: 8),
                  Text(
                    'NETWORK & DIO TELEMETRY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: ink400,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: panelColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'MockHttpAdapter',
                  style: TextStyle(fontSize: 10, color: ink500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: voidColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _hasError ? const Color(0xFF7F1D1D) : lineSoftColor,
              ),
            ),
            child: Text(
              _statusLog,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                height: 1.4,
                color: _hasError ? const Color(0xFFFCA5A5) : ink400,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cyanAccent,
                    side: const BorderSide(color: lineColor),
                    backgroundColor: panelColor.withValues(alpha: 0.5),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isLoading ? null : _fetchProducts,
                  icon: _isLoading
                      ? const SizedBox(
                          height: 14,
                          width: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: cyanAccent,
                          ),
                        )
                      : const Icon(Icons.cloud_download_rounded, size: 16),
                  label: const Text(
                    'Test 200 GET',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFF87171),
                    side: const BorderSide(color: lineColor),
                    backgroundColor: panelColor.withValues(alpha: 0.5),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isLoading ? null : _triggerError,
                  icon: const Icon(Icons.warning_amber_rounded, size: 16),
                  label: const Text(
                    'Test 404 Error',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SidebarNavItem extends StatelessWidget {
  const _SidebarNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isWide,
    required this.activeColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final bool isWide;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isWide ? 14 : 0,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF161224).withValues(alpha: 0.8)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isActive ? Border.all(color: const Color(0xFF251D3A)) : null,
        ),
        child: Row(
          mainAxisAlignment: isWide
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? activeColor : const Color(0xFF6E6980),
            ),
            if (isWide) ...[
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : const Color(0xFF8F8A9F),
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PrimaryFeatureCard extends StatelessWidget {
  const _PrimaryFeatureCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF0D0A15),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF1E192B)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00F2FE).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF00F2FE).withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Text(
                      'ACTIVE WORKSPACE',
                      style: TextStyle(
                        color: Color(0xFF00F2FE),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const Text(
                    'Full Catalog',
                    style: TextStyle(color: Color(0xFF6E6980), fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFF161224).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF251D3A)),
                ),
                child: const Center(
                  child: Icon(
                    Icons.storefront_rounded,
                    size: 48,
                    color: Color(0xFF00F2FE),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Live Storefront & Telemetry',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Search, category filters, and product details',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Color(0xFF6E6980), fontSize: 12),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Open',
                        style: TextStyle(
                          color: Color(0xFF00F2FE),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: Color(0xFF00F2FE),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryActionTile extends StatelessWidget {
  const _SecondaryActionTile({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.onTap,
  });

  final IconData icon;
  final Color accentColor;
  final String title;
  final String subtitle;
  final String tag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF0D0A15),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1E192B)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF161224).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF251D3A)),
                ),
                child: Icon(icon, color: accentColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF6E6980),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tag,
                      style: const TextStyle(
                        color: Color(0xFF4C475A),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF6E6980),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
