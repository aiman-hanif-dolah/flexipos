import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/category.dart' as app;
import '../models/menu_item.dart';
import '../services/firestore_service.dart';

class MenuProvider extends ChangeNotifier {
  final FirestoreService firestoreService;

  List<app.Category> categories = [];
  List<MenuItem> menuItems = [];

  MenuProvider({required this.firestoreService}) {
    firestoreService.categoriesStream().listen((catList) {
      categories = catList.cast<app.Category>();
      notifyListeners();
    });

    firestoreService.allMenuItemsStream().listen((itemList) {
      menuItems = itemList;
      notifyListeners();
    });
  }

  Future<void> addCategory({
    required String name,
    String? imageUrl,
  }) async {
    final data = <String, dynamic>{'name': name};
    if (imageUrl != null && imageUrl.isNotEmpty) {
      data['imageUrl'] = imageUrl;
    }
    await firestoreService.addCategory(data);
  }

  Future<void> addItem({
    required String categoryId,
    required String name,
    required double price,
    required String imageUrl,
  }) {
    return firestoreService.addItem({
      'categoryId': categoryId,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
    });
  }

  Stream<List<MenuItem>> getItemsForCategory(String categoryId) {
    return firestoreService.itemsStream(categoryId);
  }

  List<MenuItem> getItemsListForCategory(String categoryId) {
    return menuItems.where((i) => i.categoryId == categoryId).toList();
  }

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
}
