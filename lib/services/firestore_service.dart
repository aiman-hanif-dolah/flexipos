import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart' as app;
import '../models/menu_item.dart';
import '../models/order.dart' as app_order;

/// Service class to interact with Firebase Firestore for menu and order data.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection references
  final CollectionReference _categoriesRef = FirebaseFirestore.instance.collection('categories');
  final CollectionReference _itemsRef      = FirebaseFirestore.instance.collection('items');
  final CollectionReference _ordersRef     = FirebaseFirestore.instance.collection('orders');

  /// Adds a new category to Firestore.
  Future<void> addCategory(Map<String, dynamic> categoryData) async {
    await _categoriesRef.add(categoryData);
  }

  /// Adds a new item under a category to Firestore.
  Future<void> addItem(Map<String, dynamic> itemData) async {
    await _itemsRef.add(itemData);
  }

  /// Returns a stream of Category objects from Firestore.
  Stream<List<app.Category>> categoriesStream() {
    return _categoriesRef.snapshots().map(
          (snapshot) => snapshot.docs
          .map((doc) => app.Category.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList(),
    );
  }

  /// Returns a stream of MenuItem objects for a specific category ID.
  Stream<List<MenuItem>> itemsStream(String categoryId) {
    return _itemsRef
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => MenuItem.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList(),
    );
  }

  /// Returns a stream of ALL MenuItem objects (for all categories).
  Stream<List<MenuItem>> allMenuItemsStream() {
    return _itemsRef.snapshots().map(
          (snapshot) => snapshot.docs
          .map((doc) => MenuItem.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList(),
    );
  }

  /// Places a new order into Firestore.
  Future<void> placeOrder(Map<String, dynamic> orderData) async {
    await _ordersRef.add(orderData);
  }

  /// Returns a stream of all orders in Firestore, mapped to your Order model.
  Stream<List<app_order.Order>> ordersStream() {
    return _ordersRef
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => app_order.Order.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList(),
    );
  }

  /// Updates the status of an order in Firestore (e.g. 'completed').
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _ordersRef.doc(orderId).update({'status': status});
  }

  /// Updates both items and total for a specific order.
  Future<void> updateOrderItemsAndTotal(
      String orderId, List<Map<String, dynamic>> items, double total) async {
    await _ordersRef.doc(orderId).update({
      'items': items,
      'total': total,
    });
  }

  /// Assigns a table to an NFC tag UID.
  Future<void> assignTableToTag(String uid, String tableId) async {
    await _db
        .collection('nfc_table_tags')
        .doc(uid)
        .set({'tableId': tableId});
  }

  /// Gets assigned table for a tag UID. Returns null if not assigned.
  Future<String?> getTableForTag(String uid) async {
    var doc = await _db
        .collection('nfc_table_tags')
        .doc(uid)
        .get();
    return doc.exists ? (doc.data()?['tableId'] as String?) : null;
  }

  /// Updates a menu item in Firestore by ID.
  Future<void> updateMenuItem(String id, Map<String, dynamic> data) async {
    await _itemsRef.doc(id).update(data);
  }
}
