import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
        GoRoute(path: '/', builder: (c, s) => const HomeScreen()),
        GoRoute(
          path: '/age/:ageSlug',
          builder: (c, s) => AgeHubScreen(ageSlug: s.pathParameters['ageSlug']!),
        ),
        GoRoute(
          path: '/c/:categorySlug',
          builder: (c, s) =>
              CategoryScreen(categorySlug: s.pathParameters['categorySlug']!),
        ),
        GoRoute(
          path: '/b/:brandSlug',
          builder: (c, s) => BrandScreen(brandSlug: s.pathParameters['brandSlug']!),
        ),
        GoRoute(
          path: '/p/:productSlug',
          builder: (c, s) =>
              ProductScreen(productSlug: s.pathParameters['productSlug']!),
        ),
        GoRoute(
          path: '/search',
          builder: (c, s) => SearchScreen(params: s.uri.queryParameters),
        ),
        GoRoute(path: '/cart', builder: (c, s) => const CartScreen()),
        GoRoute(path: '/wishlist', builder: (c, s) => const WishlistScreen()),
        GoRoute(path: '/account', builder: (c, s) => const AccountScreen()),
        GoRoute(path: '/orders', builder: (c, s) => const OrdersScreen()),
        GoRoute(
          path: '/orders/:id',
          builder: (c, s) => OrderDetailScreen(orderNo: s.pathParameters['id']!),
        ),
      ],
    ),
    // Checkout and auth push over the shell — no tab chrome (trusted mode).
    GoRoute(path: '/checkout', builder: (c, s) => const CheckoutScreen()),
    GoRoute(
      path: '/checkout/pay',
      builder: (c, s) => GatewayScreen(
        orderNo: s.uri.queryParameters['order'] ?? '',
      ),
    ),
    GoRoute(
      path: '/checkout/result',
      builder: (c, s) => ResultScreen(
        orderNo: s.uri.queryParameters['order'] ?? '',
        failed: s.uri.queryParameters['failed'] == '1',
      ),
    ),
    GoRoute(path: '/signin', builder: (c, s) => const SignInScreen()),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('404 — ${state.uri.path}')),
  ),
);
