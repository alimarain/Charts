import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_app/presentation/views/controllers/auth_provider.dart';
import '../presentation/views/analytics/analytics_screen.dart';
import '../presentation/views/auth/login_screen.dart';
import '../presentation/views/dashboard/dashboard_screen.dart';
import '../presentation/views/dashboard/product_details_screen.dart';
import '../presentation/views/form/form_screen.dart';
import '../presentation/views/home/home_screen.dart';

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _ref.listen(authProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authProvider);
    final isAuthenticated = authState.isAuthenticated;
    final isLoggingIn = state.matchedLocation == LoginScreen.routePath;

    // Guard 1: Unauthenticated users are redirected to /login
    if (!isAuthenticated) {
      return isLoggingIn ? null : LoginScreen.routePath;
    }

    // Guard 2: Authenticated user targeting /login is redirected to /home
    if (isLoggingIn) {
      return HomeScreen.routePath;
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
      GoRoute(
        path: HomeScreen.routePath,
        name: HomeScreen.routeName,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: DashboardScreen.routePath,
        name: DashboardScreen.routeName,
        builder: (context, state) => const DashboardScreen(),
        routes: [
          GoRoute(
            path: ProductDetailsScreen.routeSubPath,
            name: ProductDetailsScreen.routeName,
            builder: (context, state) {
              final productId = state.pathParameters['id'] ?? 'unknown';
              return ProductDetailsScreen(productId: productId);
            },
          ),
        ],
      ),
      GoRoute(
        path: AnalyticsScreen.routePath,
        name: AnalyticsScreen.routeName,
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: FormScreen.routePath,
        name: FormScreen.routeName,
        builder: (context, state) => const FormScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.uri}'),
      ),
    ),
  );
});