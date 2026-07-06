import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/cart/presentation/cart_providers.dart';
import '../l10n/l10n.dart';
import '../theme/palette.dart';
import '../theme/tokens.dart';

/// One wrapper owns the navigation morph (spec §3.3):
/// bottom nav bar <600 · top app bar with inline nav links ≥1024.
class AdaptiveScaffold extends ConsumerWidget {
  const AdaptiveScaffold({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  static const _tabs = ['/', '/search', '/cart', '/wishlist', '/account'];

  int get _currentIndex {
    if (location == '/') return 0;
    for (var i = 1; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final width = MediaQuery.sizeOf(context).width;
    final cartCount = ref.watch(cartCountProvider);
    final labels = [
      l10n.navHome,
      l10n.navSearch,
      l10n.navCart,
      l10n.navWishlist,
      l10n.navAccount,
    ];

    if (Layout.isDesktop(width)) {
      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 72,
          title: Row(
            children: [
              _Wordmark(onTap: () => context.go('/')),
              const SizedBox(width: Gap.xxl),
              for (var i = 0; i < _tabs.length; i++)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: Gap.sm),
                  child: _TopNavLink(
                    label: labels[i],
                    selected: _currentIndex == i,
                    badge: i == 2 ? cartCount : 0,
                    onTap: () => context.go(_tabs[i]),
                  ),
                ),
            ],
          ),
        ),
        body: child,
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => context.go(_tabs[i]),
        backgroundColor: AppPalette.white,
        indicatorColor: AppPalette.sky,
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.storefront_outlined),
              selectedIcon: const Icon(Icons.storefront_rounded),
              label: labels[0]),
          NavigationDestination(
              icon: const Icon(Icons.search_rounded), label: labels[1]),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              backgroundColor: AppPalette.coral,
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              backgroundColor: AppPalette.coral,
              child: const Icon(Icons.shopping_bag_rounded),
            ),
            label: labels[2],
          ),
          NavigationDestination(
              icon: const Icon(Icons.favorite_outline_rounded),
              selectedIcon: const Icon(Icons.favorite_rounded),
              label: labels[3]),
          NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: const Icon(Icons.person_rounded),
              label: labels[4]),
        ],
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: Corners.buttonRadius,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
            horizontal: Gap.sm, vertical: Gap.xs),
        child: Row(
          children: [
            const Text('🧸', style: TextStyle(fontSize: 26)),
            const SizedBox(width: Gap.sm),
            Text(
              context.l10n.appName,
              style: Theme.of(context)
                  .textTheme
                  .displayMedium
                  ?.copyWith(color: AppPalette.coral, fontSize: 26),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopNavLink extends StatelessWidget {
  const _TopNavLink({
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge = 0,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: Corners.buttonRadius,
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(
            horizontal: Gap.lg, vertical: Gap.sm),
        decoration: BoxDecoration(
          color: selected ? AppPalette.sky : Colors.transparent,
          borderRadius: Corners.buttonRadius,
        ),
        child: Badge(
          isLabelVisible: badge > 0,
          label: Text('$badge'),
          backgroundColor: AppPalette.coral,
          offset: const Offset(12, -8),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected ? AppPalette.teal : AppPalette.ink,
                ),
          ),
        ),
      ),
    );
  }
}
