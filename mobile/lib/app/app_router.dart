import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/application/auth_provider.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/coupons/presentation/coupons_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/home/presentation/home_shell.dart';
import '../features/invoices/presentation/invoice_apply_page.dart';
import '../features/invoices/presentation/invoices_page.dart';
import '../features/license/presentation/license_page.dart';
import '../features/locations/presentation/locations_page.dart';
import '../features/messages/presentation/messages_page.dart';
import '../features/orders/presentation/order_confirm_page.dart';
import '../features/orders/presentation/order_detail_page.dart';
import '../features/orders/presentation/orders_page.dart';
import '../features/orders/presentation/pay_result_page.dart';
import '../features/orders/presentation/pickup_page.dart';
import '../features/orders/presentation/return_page.dart';
import '../features/profile/presentation/profile_page.dart';
import '../features/profile/presentation/settings_page.dart';
import '../features/rental/presentation/quote_page.dart';
import '../features/rental/presentation/rental_dates_page.dart';
import '../features/splash/presentation/splash_page.dart';
import '../features/tickets/presentation/ticket_create_page.dart';
import '../features/tickets/presentation/tickets_page.dart';
import '../features/vehicles/presentation/vehicle_detail_page.dart';
import '../features/vehicles/presentation/vehicles_page.dart';
import '../features/violations/presentation/violation_detail_page.dart';
import '../features/violations/presentation/violations_page.dart';
import 'router_refresh.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = RouterRefreshNotifier(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final authed = ref.read(authProvider) != null;
      final loc = state.matchedLocation;
      const publicRoutes = ['/splash', '/login'];
      if (publicRoutes.contains(loc)) {
        if (authed && loc == '/login') return '/home';
        return null;
      }
      if (!authed) return '/login';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => HomeShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (_, __) => const HomePage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/orders', builder: (_, __) => const OrdersPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
          ]),
        ],
      ),
      GoRoute(parentNavigatorKey: _rootKey, path: '/vehicles', builder: (_, __) => const VehiclesPage()),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/vehicle/:id',
        builder: (_, s) => VehicleDetailPage(vehicleId: s.pathParameters['id']!),
      ),
      GoRoute(parentNavigatorKey: _rootKey, path: '/locations', builder: (_, __) => const LocationsPage()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/rental/dates', builder: (_, __) => const RentalDatesPage()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/quote', builder: (_, __) => const QuotePage()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/order/confirm', builder: (_, __) => const OrderConfirmPage()),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/pay-result',
        builder: (_, s) => PayResultPage(orderId: s.uri.queryParameters['id'] ?? ''),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/order/:id/pickup',
        builder: (_, s) => PickupPage(orderId: s.pathParameters['id']!),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/order/:id/return',
        builder: (_, s) => ReturnPage(orderId: s.pathParameters['id']!),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/order/:id',
        builder: (_, s) => OrderDetailPage(orderId: s.pathParameters['id']!),
      ),
      GoRoute(parentNavigatorKey: _rootKey, path: '/license', builder: (_, __) => const DriverLicensePage()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/violations', builder: (_, __) => const ViolationsPage()),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/violation/:id',
        builder: (_, s) => ViolationDetailPage(violationId: s.pathParameters['id']!),
      ),
      GoRoute(parentNavigatorKey: _rootKey, path: '/invoices', builder: (_, __) => const InvoicesPage()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/invoices/apply', builder: (_, __) => const InvoiceApplyPage()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/coupons', builder: (_, __) => const CouponsPage()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/tickets', builder: (_, __) => const TicketsPage()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/ticket/create', builder: (_, __) => const TicketCreatePage()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/messages', builder: (_, __) => const MessagesPage()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/settings', builder: (_, __) => const SettingsPage()),
    ],
  );
});
