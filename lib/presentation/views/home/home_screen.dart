import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/auth_provider.dart';
import '../../controllers/home_telemetry_controller.dart';
import '../../widgets/home/home_kpi_grid.dart';
import '../../widgets/home/home_portfolio_banner.dart';
import '../../widgets/home/home_resource_ledger.dart';
import '../../widgets/home/home_telemetry_console.dart';
import '../../widgets/navigation/app_header.dart';
import '../../widgets/navigation/app_sidebar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  static const routeName = 'home';
  static const routePath = '/home';

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final telemetryState = ref.watch(homeTelemetryProvider);
    final telemetryNotifier = ref.read(homeTelemetryProvider.notifier);

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
                            statusLog: telemetryState.statusLog,
                            hasError: telemetryState.hasError,
                            isLoading: telemetryState.isLoading,
                            onTestGet: telemetryNotifier.fetchProducts,
                            onTestError: telemetryNotifier.triggerError,
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
