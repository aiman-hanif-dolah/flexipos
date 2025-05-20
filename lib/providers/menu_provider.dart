import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/category.dart' as app;
import '../models/menu_item.dart';
import '../services/firestore_service.dart';

/// A high-throughput provider orchestrating CRUD operations for menu data.
class MenuProvider extends ChangeNotifier {
  final FirestoreService firestoreService;

  /// Live cache of categories.
  List<app.Category> categories = [];

  /// Live cache of menu items.
  List<MenuItem> menuItems = [];

  MenuProvider({required this.firestoreService}) {
    // Stream subscription for real-time categories ingestion
    firestoreService.categoriesStream().listen((catList) {
      categories = catList.cast<app.Category>();
      notifyListeners();
    });

    // Stream subscription for real-time menu items ingestion
    firestoreService.allMenuItemsStream().listen((itemList) {
      menuItems = itemList;
      notifyListeners();
    });
  }

  /// Creates a new category in Firestore.
  Future<void> addCategory({
    required String name,
    String? imageUrl,
  }) async {
    debugPrint('➕ addCategory → name=$name');
    final payload = <String, dynamic>{'name': name};
    if (imageUrl != null && imageUrl.isNotEmpty) {
      payload['imageUrl'] = imageUrl;
    }
    await firestoreService.addCategory(payload);
  }

  /// Creates a new menu item under a specific category.
  Future<void> addItem({
    required String categoryId,
    required String name,
    required double price,
    required String imageUrl,
  }) async {
    debugPrint('➕ addItem → categoryId=$categoryId, name=$name');
    final payload = <String, dynamic>{
      'categoryId': categoryId,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
    };
    await firestoreService.addItem(payload);
  }

  /// Returns a live stream of menu items filtered by [categoryId].
  Stream<List<MenuItem>> getItemsForCategory(String categoryId) {
    return firestoreService.itemsStream(categoryId);
  }

  /// Returns the current cache of menu items filtered by [categoryId].
  List<MenuItem> getItemsListForCategory(String categoryId) {
    return menuItems.where((i) => i.categoryId == categoryId).toList();
  }

  /// Publishes updates to an existing menu item.
  Future<void> updateMenuItem(MenuItem item) async {
    debugPrint('📝 updateMenuItem → id=${item.id}');
    await firestoreService.updateMenuItem(item.id, item.toMap());

    final idx = menuItems.indexWhere((i) => i.id == item.id);
    if (idx >= 0) {
      menuItems[idx] = item;
      notifyListeners();
      debugPrint('✅ Local cache updated for id=${item.id}');
    } else {
      debugPrint('⚠️ Could not find item locally for id=${item.id}');
    }
  }

  /// Deletes a menu item both in Firestore and local cache.
  Future<void> deleteMenuItem(String itemId) async {
    debugPrint('🗑 deleteMenuItem → id=$itemId');
    try {
      await firestoreService.deleteMenuItem(itemId);
      final idx = menuItems.indexWhere((i) => i.id == itemId);
      if (idx >= 0) {
        menuItems.removeAt(idx);
        notifyListeners();
        debugPrint('✅ Removed item from local cache id=$itemId');
      }
    } catch (e) {
      debugPrint('⚠️ Error deleting menu item id=$itemId: $e');
      rethrow;
    }
  }

  /// Deletes a category and all its associated items in Firestore and local cache.
  Future<void> deleteCategory(String categoryId) async {
    debugPrint('🗑 deleteCategory → id=$categoryId');
    try {
      // Remove category document
      await firestoreService.deleteCategory(categoryId);

      // Purge from local cache: categories and orphaned items
      categories.removeWhere((c) => c.id == categoryId);
      menuItems.removeWhere((i) => i.categoryId == categoryId);
      notifyListeners();
      debugPrint('✅ Removed category and its items from local cache id=$categoryId');
    } catch (e) {
      debugPrint('⚠️ Error deleting category id=$categoryId: $e');
      rethrow;
    }
  }
}