import 'package:get/get.dart';

import '../../network/repositories/wishlist_repository.dart';

class WishlistController extends GetxController {
  WishlistController(this._repository);

  final WishlistRepository _repository;

  final RxSet<String> wishlistItems = <String>{}.obs;
  final RxSet<String> loadingItems = <String>{}.obs;
  final RxInt changeVersion = 0.obs;

  bool isWishlisted(String type, String itemId) {
    final String? key = _safeKey(type, itemId);
    if (key == null) {
      return false;
    }
    return wishlistItems.contains(key);
  }

  bool isToggling(String type, String itemId) {
    final String? key = _safeKey(type, itemId);
    if (key == null) {
      return false;
    }
    return loadingItems.contains(key);
  }

  void seedWishlist({
    required String type,
    required String itemId,
    required bool isWishlisted,
  }) {
    if (!isWishlisted) {
      return;
    }

    final String? key = _safeKey(type, itemId);
    if (key == null) {
      return;
    }

    if (wishlistItems.contains(key)) {
      return;
    }

    wishlistItems.add(key);
  }

  Future<void> toggleWishlist({
    required String type,
    required String itemId,
  }) async {
    final String? key = _safeKey(type, itemId);
    if (key == null) {
      return;
    }

    if (loadingItems.contains(key)) {
      return;
    }

    final bool wasWishlisted = wishlistItems.contains(key);

    if (wasWishlisted) {
      wishlistItems.remove(key);
    } else {
      wishlistItems.add(key);
    }

    loadingItems.add(key);

    try {
      final result = await _repository.toggleWishlist(
        type: type.trim().toLowerCase(),
        itemId: itemId.trim(),
      );

      result.fold(
        (failure) {
          if (wasWishlisted) {
            wishlistItems.add(key);
          } else {
            wishlistItems.remove(key);
          }
        },
        (success) {
          final String message = success.message.toLowerCase();
          if (message.contains('remove')) {
            wishlistItems.remove(key);
          } else if (message.contains('add')) {
            wishlistItems.add(key);
          }
        },
      );
    } catch (_) {
      if (wasWishlisted) {
        wishlistItems.add(key);
      } else {
        wishlistItems.remove(key);
      }
    } finally {
      loadingItems.remove(key);
      changeVersion.value++;
    }
  }

  void syncFromFetchedItems(Iterable<String> keys, {required String type}) {
    final String normalizedType = type.trim().toLowerCase();
    if (normalizedType.isEmpty) {
      return;
    }

    final Set<String> fetchedKeys = keys
        .map((key) => key.trim().toLowerCase())
        .where((key) => key.startsWith('${normalizedType}_'))
        .toSet();

    final List<String> existingKeysOfType = wishlistItems
        .where((key) => key.startsWith('${normalizedType}_'))
        .toList();

    for (final String key in existingKeysOfType) {
      if (!fetchedKeys.contains(key)) {
        wishlistItems.remove(key);
      }
    }

    wishlistItems.addAll(fetchedKeys);
  }

  String _key(String type, String itemId) {
    return '${type.trim().toLowerCase()}_${itemId.trim()}';
  }

  String? _safeKey(String type, String itemId) {
    final String normalizedType = type.trim().toLowerCase();
    final String normalizedId = itemId.trim();

    if (normalizedType.isEmpty || normalizedId.isEmpty) {
      return null;
    }

    return _key(normalizedType, normalizedId);
  }
}
