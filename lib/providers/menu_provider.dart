import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/menu_item.dart';
import '../services/firestore_service.dart';

/// Provider for menu-related data and operations.
/// Dynamically loads categories and menu items, and supports adding new categories/items with images.
/// Notifies listeners on Firestore changes for real-time UI updates.
class MenuProvider extends ChangeNotifier {
  final FirestoreService firestoreService;

  // List of categories loaded from Firestore in real-time.
  List<Category> categories = [];

  // List of all menu items loaded from Firestore in real-time.
  List<MenuItem> menuItems = [];

  MenuProvider({required this.firestoreService}) {
    // Listen for real-time updates to categories
    firestoreService.categoriesStream().listen((categoryList) {
      categories = List<Category>.from(categoryList);
      notifyListeners();
    });
    // Listen for real-time updates to menu items (all items, not per-category)
    firestoreService.allMenuItemsStream().listen((menuItemList) {
      menuItems = List<MenuItem>.from(menuItemList);
      notifyListeners();
    });
  }

  /// Adds a new category with the given [name] and optional [imageUrl] to Firestore.
  Future<void> addCategory({required String name, String? imageUrl}) async {
    final data = <String, dynamic>{'name': name};
    if (imageUrl != null && imageUrl.isNotEmpty) {
      data['imageUrl'] = imageUrl;
    }
    await firestoreService.addCategory(data);
  }

  /// Adds a new menu item under [categoryId] with [name], [price], and [imageUrl].
  Future<void> addItem({
    required String categoryId,
    required String name,
    required double price,
    required String imageUrl,
  }) async {
    await firestoreService.addItem({
      'categoryId': categoryId,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
    });
  }

  /// Provides a stream of MenuItem objects for the given [categoryId].
  Stream<List<MenuItem>> getItemsForCategory(String categoryId) {
    return firestoreService.itemsStream(categoryId);
  }

  /// Returns a list of MenuItems for a given category (from memory).
  List<MenuItem> getItemsListForCategory(String categoryId) {
    return menuItems.where((item) => item.categoryId == categoryId).toList();
  }

  /// Updates a menu item with new data.
  Future<void> updateMenuItem({
    required String id,
    required String name,
    required double price,
    required String imageUrl,
  }) async {
    await firestoreService.updateMenuItem(id, {
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
    });
  }
}
