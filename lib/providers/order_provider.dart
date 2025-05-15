import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/order.dart';

/// OrderProvider is a ChangeNotifier that manages the lifecycle of orders in the
/// Tech Ventura FlexiPOS system. It listens to a stream of order data from Firebase
/// Firestore, applies safe type conversion to ensure a strongly typed List<Order>,
/// and notifies registered listeners whenever there is a change in the order list.
/// Additionally, it provides methods to place new orders and update the status of
/// existing orders in a type-safe manner.
///
/// Key functionalities:
/// 1. Real-time synchronization of order data via FirestoreService.ordersStream()
/// 2. Strongly typed conversion from dynamic lists to List<Order> to prevent
///    type mismatches and runtime errors.
/// 3. placeOrder() aggregates order items, calculates the total price, and submits
///    the structured order data to Firestore.
/// 4. updateOrderStatus() updates an existing order's status field with the
///    provided status string, such as 'completed'.
///
/// Usage:
/// ```dart
/// final orderProvider = OrderProvider(firestoreService: myFirestoreService);
/// // Subscribe to orderProvider.orders in a widget tree using Provider:
/// List<Order> currentOrders = Provider.of<OrderProvider>(context).orders;
///
/// // Place an order:
/// List<OrderItem> items = [
///   OrderItem(itemId: 'id1', name: 'Coffee', price: 2.50, qty: 1)
/// ];
/// await orderProvider.placeOrder('Table1', items);
///
/// // Update an order status:
/// await orderProvider.updateOrderStatus(orderId, 'completed');
/// ```
///
/// This implementation resolves the type mismatch error by explicitly converting
/// the dynamic list produced by the Firestore stream into a List<Order> using the
/// List<Order>.from() constructor, ensuring compile-time type safety and preserving
/// the integrity of your data model.

class OrderProvider extends ChangeNotifier {
  /// FirestoreService instance for database operations.
  final FirestoreService firestoreService;

  /// In-memory cache of orders, kept in sync with Firestore.
  List<Order> orders = [];

  /// Constructor sets up a real-time listener on the Firestore orders collection.
  /// The callback receives a dynamic List from the stream; we convert it safely
  /// into List<Order> via List<Order>.from(...) to avoid assignment errors.
  OrderProvider({required this.firestoreService}) {
    firestoreService.ordersStream().listen((dynamic orderList) {
      // Safely cast the incoming dynamic list to a List<Order>.
      // This avoids "List<dynamic> can't be assigned to List<Order>" errors.
      orders = List<Order>.from(orderList);
      notifyListeners(); // Trigger UI updates or other listeners.
    });
  }

  /// Places an order for [tableId] with the provided [orderItems].
  /// Calculates the total price by summing item.price * item.qty.
  /// Constructs a map matching the Firestore schema and writes it.
  Future<void> placeOrder(String tableId, List<OrderItem> orderItems) async {
    // Aggregate total price across all items.
    double totalPrice = 0;
    for (final item in orderItems) {
      totalPrice += item.price * item.qty;
    }

    // Convert each OrderItem to a JSON-ready map.
    final List<Map<String, dynamic>> itemsData =
    orderItems.map((item) => item.toMap()).toList();

    // Build the full order payload.
    final Map<String, dynamic> orderData = {
      'tableId': tableId,
      'items': itemsData,
      'total': totalPrice,
      'status': 'pending',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    // Write the order document to Firestore.
    await firestoreService.placeOrder(orderData);
  }

  /// Updates the status of an existing order document in Firestore.
  /// [orderId] is the document ID; [status] could be 'completed', 'canceled', etc.
  Future<void> updateOrderStatus(String orderId, String status) async {
    await firestoreService.updateOrderStatus(orderId, status);
  }
}
