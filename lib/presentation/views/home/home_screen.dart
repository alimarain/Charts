import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_app/presentation/controllers/product_provider.dart';

import '../../controllers/auth_provider.dart';
import '../../widgets/navigation/app_header.dart';
import '../../widgets/navigation/app_sidebar.dart';
import 'widgets/home_kpi_grid.dart';
import 'widgets/home_portfolio_banner.dart';
import 'widgets/home_resource_ledger.dart';
import 'widgets/home_telemetry_console.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  static const routeName = 'home';
  static const routePath = '/home';

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
        _statusLog =
            'Success! Fetched ${products.length} products from backend API.\nCheck console for Dio logs.';
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
      ref.read(productServiceProvider).simulateError();
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
    final userRole = user?.role == 'maker' ? 'Maker' : 'User';
    final hasToken = authState.token != null && authState.token!.isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xFFF8F9FC),
          drawer: isDesktop
              ? null
              : Drawer(
                  child: AppSidebar(
                    currentRoute: '/home',
                    hasToken: hasToken,
                    userRole: userRole,
                    isMobileDrawer: true,
                  ),
                ),
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isDesktop)
                AppSidebar(
                  currentRoute: '/home',
                  hasToken: hasToken,
                  userRole: userRole,
                ),
              Expanded(
                child: Column(
                  children: [
                    AppHeader(
                      showMenuButton: !isDesktop,
                      onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 28.0 : 16.0,
                          vertical: 20.0,
                        ),
                        children: [
                          const HomePortfolioBanner(),
                          const SizedBox(height: 20),
                          const HomeKpiGrid(),
                          const SizedBox(height: 20),
                          const HomeResourceLedger(),
                          const SizedBox(height: 20),
                          HomeTelemetryConsole(
                            statusLog: _statusLog,
                            hasError: _hasError,
                            isLoading: _isLoading,
                            onTestGet: _fetchProducts,
                            onTestError: _triggerError,
                          ),
                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}