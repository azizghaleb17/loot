import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/palette.dart';
import '../../core/widgets/adaptive_scaffold.dart';
import '../../features/account/presentation/account_screen.dart';
import '../../features/auth/presentation/signin_screen.dart';
import '../../features/cart/presentation/cart_screen.dart';
import '../../features/catalog/presentation/age_hub_screen.dart';
import '../../features/catalog/presentation/brand_screen.dart';
import '../../features/catalog/presentation/category_screen.dart';
import '../../features/catalog/presentation/home_screen.dart';
import '../../features/catalog/presentation/product_screen.dart';
import '../../features/checkout/presentation/checkout_screen.dart';
import '../../features/checkout/presentation/gateway_screen.dart';
import '../../features/checkout/presentation/result_screen.dart';
import '../../features/orders/presentation/order_detail_screen.dart';
import '../../features/orders/presentation/orders_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/wishlist/presentation/wishlist_screen.dart';

/// Fast fade over an opaque surface. Flutter web's default zoom transition
/// ghosts the outgoing screen through the incoming one in CanvasKit; painting
/// each page on its own background and cross-fading kills the residue.
CustomTransitionPage<void> _fadePage(
  GoRouterState state,
  Widget child, {
  Color background = AppPalette.cream,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 200),
    reverseTransitionDuration: const Duration(milliseconds: 150),
    child: ColoredBox(color: background, child: child),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (MediaQuery.disableAnimationsOf(context)) return child;
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      );
    },
  );
}

/// Full URL map per spec §1.3 — slug-based, shareable, stable. The same
/// table powers universal/app links in Phase 2 with zero rework.
final appRouter = GoRouter(
  debugLogDiagnostics: false,
  routes: [
    ShellRoute(
      builder: (context, state, child) => AdaptiveScaffold(
        location: state.uri.path,
        child: child,
      ),
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (c, s) => _fadePage(s, const HomeScreen()),
        ),
        GoRoute(
          path: '/age/:ageSlug',
          pageBuilder: (c, s) =>
              _fadePage(s, AgeHubScreen(ageSlug: s.pathParameters['ageSlug']!)),
        ),
        GoRoute(
          path: '/c/:categorySlug',
          pageBuilder: (c, s) => _fadePage(
              s, CategoryScreen(categorySlug: s.pathParameters['categorySlug']!)),
        ),
        GoRoute(
          path: '/b/:brandSlug',
          pageBuilder: (c, s) =>
              _fadePage(s, BrandScreen(brandSlug: s.pathParameters['brandSlug']!)),
        ),
        GoRoute(
          path: '/p/:productSlug',
          pageBuilder: (c, s) => _fadePage(
              s, ProductScreen(productSlug: s.pathParameters['productSlug']!)),
        ),
        GoRoute(
          path: '/search',
          pageBuilder: (c, s) =>
              _fadePage(s, SearchScreen(params: s.uri.queryParameters)),
        ),
        GoRoute(
          path: '/cart',
          pageBuilder: (c, s) => _fadePage(s, const CartScreen()),
        ),
        GoRoute(
          path: '/wishlist',
          pageBuilder: (c, s) => _fadePage(s, const WishlistScreen()),
        ),
        GoRoute(
          path: '/account',
          pageBuilder: (c, s) => _fadePage(s, const AccountScreen()),
        ),
        GoRoute(
          path: '/orders',
          pageBuilder: (c, s) => _fadePage(s, const OrdersScreen()),
        ),
        GoRoute(
          path: '/orders/:id',
          pageBuilder: (c, s) => _fadePage(
              s, OrderDetailScreen(orderNo: s.pathParameters['id']!)),
        ),
      ],
    ),
    // Checkout and auth push over the shell — no tab chrome (trusted mode).
    // They own opaque Scaffolds, so the fade wrapper uses white.
    GoRoute(
      path: '/checkout',
      pageBuilder: (c, s) =>
          _fadePage(s, const CheckoutScreen(), background: AppPalette.white),
    ),
    GoRoute(
      path: '/checkout/pay',
      pageBuilder: (c, s) => _fadePage(
          s, GatewayScreen(orderNo: s.uri.queryParameters['order'] ?? ''),
          background: AppPalette.white),
    ),
    GoRoute(
      path: '/checkout/result',
      pageBuilder: (c, s) => _fadePage(
          s,
          ResultScreen(
            orderNo: s.uri.queryParameters['order'] ?? '',
            failed: s.uri.queryParameters['failed'] == '1',
          ),
          background: AppPalette.white),
    ),
    GoRoute(
      path: '/signin',
      pageBuilder: (c, s) =>
          _fadePage(s, const SignInScreen(), background: AppPalette.white),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('404 — ${state.uri.path}')),
  ),
);
