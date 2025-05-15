import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/menu_item.dart';
import '../services/firestore_service.dart';

/// Provider for menu-related data and operations.
/// This includes dynamically loaded categories and methods to add new categories/items.
/// It listens to Firestore updates and notifies listeners on changes.
class MenuProvider extends ChangeNotifier {
  final FirestoreService firestoreService;

  // List of categories loaded from Firestore in real-time.
  List<Category> categories = [];

  // Constructor initializes listener for category snapshots.
  MenuProvider({required this.firestoreService}) {
    firestoreService.categoriesStream().listen((categoryList) {
      categories = categoryList;
      notifyListeners(); // Notify UI to rebuild when categories change
    });
  }

  /// Adds a new category with the given [name] to Firestore.
  Future<void> addCategory(String name) async {
    await firestoreService.addCategory({'name': name});
  }

  /// Adds a new menu item under [categoryId] with [name] and [price].
  Future<void> addItem(String categoryId, String name, double price) async {
    await firestoreService.addItem({
      'categoryId': categoryId,
      'name': name,
      'price': price,
    });
  }

  /// Provides a stream of MenuItem objects for the given [categoryId].
  /// Widgets (like category item lists) can use this to display items.
  Stream<List<MenuItem>> getItemsForCategory(String categoryId) {
    return firestoreService.itemsStream(categoryId);
  }
}

/// Example usage in a Flutter widget:
///
/// ```dart
/// final menuProv = Provider.of<MenuProvider>(context);
/// // To add a category:
/// menuProv.addCategory('Desserts');
/// // To add an item:
/// menuProv.addItem(categoryId, 'Cake', 4.50);
/// // Access current categories list:
/// List<Category> cats = menuProv.categories;
/// ```
///
/// End of menu_provider.dart file.
