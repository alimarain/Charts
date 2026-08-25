import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_app/presentation/widgets/charts/fullscreen_chart_screen.dart';

import '../domain/entities/chart_interaction.dart';
import '../features/maker/dynamic_form_screen.dart';
import '../features/maker/maker_dashboard_screen.dart';
import '../features/maker/maker_forms_screen.dart';
import '../presentation/controllers/auth_provider.dart';
import '../presentation/views/analytics/analytics_screen.dart';
import '../presentation/views/auth/login_screen.dart';
import '../presentation/views/dashboard/chart_details_screen.dart';
import '../presentation/views/form/form_screen.dart';
import '../presentation/views/home/home_screen.dart';

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _ref.listen(authProvider, (_, _) => notifyListeners());
  }

  final Ref _ref;

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authProvider);
    final isAuthenticated = authState.isAuthenticated;
    final userRole = authState.user?.role;
    final isLoggingIn = state.matchedLocation == LoginScreen.routePath;

    if (!isAuthenticated) {
      return isLoggingIn ? null : LoginScreen.routePath;
    }

    if (isLoggingIn) {
      return userRole == 'maker'
          ? MakerDashboardScreen.routePath
          : HomeScreen.routePath;
    }

    if (state.matchedLocation == '/dashboard') {
      return AnalyticsScreen.routePath;
    }

    final isMakerRoute = state.matchedLocation.startsWith('/maker');
    if (isMakerRoute && userRole != 'maker') {
      return HomeScreen.routePath;
    }

    final isNormalUserRoute = state.matchedLocation == HomeScreen.routePath ||
        state.matchedLocation.startsWith(AnalyticsScreen.routePath) ||
        state.matchedLocation == FormScreen.routePath;
    if (isNormalUserRoute && userRole == 'maker') {
      return MakerDashboardScreen.routePath;
    }

    return null;
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final routerNotifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: LoginScreen.routePath,
    refreshListenable: routerNotifier,
    redirect: routerNotifier.redirect,
    routes: [
      GoRoute(
        path: LoginScreen.routePath,
        name: LoginScreen.routeName,
        builder: (context, state) => const LoginScreen(),
      ),

      // --- NORMAL USER FLOW ---
      GoRoute(
        path: HomeScreen.routePath,
        name: HomeScreen.routeName,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AnalyticsScreen.routePath,
        name: AnalyticsScreen.routeName,
        builder: (context, state) => const AnalyticsScreen(),
        routes: [
          GoRoute(
            path: ChartDetailsScreen.routeSubPath,
            name: ChartDetailsScreen.routeName,
            builder: (context, state) {
              final item = state.extra as SelectedChartItem?;
              return ChartDetailsScreen(item: item);
            },
          ),
          GoRoute(
            path: FullscreenChartScreen.routeSubPath,
            name: FullscreenChartScreen.routeName,
            builder: (context, state) {
              final chartId = state.pathParameters['chartId'] ?? 'sales_overview_chart';
              return FullscreenChartScreen(chartId: chartId);
            },
          ),
        ],
      ),
      GoRoute(
        path: FormScreen.routePath,
        name: FormScreen.routeName,
        builder: (context, state) => const FormScreen(),
      ),

      // --- MAKER WORKFLOW ---
      GoRoute(
        path: MakerDashboardScreen.routePath,
        name: MakerDashboardScreen.routeName,
        builder: (context, state) => const MakerDashboardScreen(),
        routes: [
          GoRoute(
            path: MakerFormsScreen.routeSubPath,
            name: MakerFormsScreen.routeName,
            builder: (context, state) {
              final productId = state.pathParameters['productId'] ?? '';
              final productName = state.extra as String?;
              return MakerFormsScreen(
                productId: productId,
                productName: productName,
              );
            },
          ),
          GoRoute(
            path: DynamicFormScreen.routeSubPath,
            name: DynamicFormScreen.routeName,
            builder: (context, state) {
              final formId = state.pathParameters['formId'] ?? '';
              final formTitle = state.extra as String?;
              return DynamicFormScreen(formId: formId, formTitle: formTitle);
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.uri}'),
      ),
    ),
  );
});