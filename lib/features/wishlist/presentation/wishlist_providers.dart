import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

const _wishlistBoxName = 'wishlist';

/// Guest wishlist: a set of product slugs in Hive. Merged into the server
/// wishlist on sign-in when the Supabase backend is wired (spec §2.3).
class WishlistNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    final raw = Hive.box(_wishlistBoxName).get('slugs', defaultValue: <dynamic>[]) as List;
    return raw.cast<String>().toSet();
  }

  void toggle(String slug) {
    final next = {...state};
    if (!next.remove(slug)) next.add(slug);
    state = next;
    Hive.box(_wishlistBoxName).put('slugs', next.toList());
  }

  bool contains(String slug) => state.contains(slug);
}

final wishlistProvider =
    NotifierProvider<WishlistNotifier, Set<String>>(WishlistNotifier.new);
