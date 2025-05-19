import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/order.dart';

/// OrderProvider manages real-time orders for FlexiPOS using Firestore.
/// It merges items into an existing unpaid order for the same table
/// and notifies listeners when the Firestore stream emits updates.
class OrderProvider extends ChangeNotifier {
  final FirestoreService firestoreService;

  /// The live list of all orders.
  List<Order> orders = [];

  OrderProvider({required this.firestoreService}) {
    // Listen to incoming order list snapshots
    firestoreService.ordersStream().listen((dynamic orderList) {
      orders = List<Order>.from(orderList);
      notifyListeners();
    });
  }

  /// Returns the active (unpaid and not completed) order for [tableId], or null.
  Order? getActiveOrderForTable(String tableId) {
    try {
      return orders.firstWhere((order) =>
      order.tableId == tableId &&
          order.status != 'completed' &&
          order.status != 'paid');
    } catch (_) {
      return null;
    }
  }

  /// Creates a new order or appends [newItems] to an existing active order.
  Future<void> addOrUpdateOrder(
      String tableId, List<OrderItem> newItems) async {
    final activeOrder = getActiveOrderForTable(tableId);

    if (activeOrder != null) {
      // Merge quantities
      final merged = List<OrderItem>.from(activeOrder.items);
      for (final newItem in newItems) {
        final idx = merged.indexWhere((i) => i.itemId == newItem.itemId);
        if (idx >= 0) {
          merged[idx] = merged[idx]
              .copyWith(qty: merged[idx].qty + newItem.qty);
        } else {
          merged.add(newItem);
        }
      }
      final newTotal = merged.fold<double>(
          0, (sum, item) => sum + item.price * item.qty);

      await firestoreService.updateOrderItemsAndTotal(
        activeOrder.id,
        merged.map((i) => i.toMap()).toList(),
        newTotal,
      );
    } else {
      // Build new order payload
      final total = newItems.fold<double>(
          0, (sum, item) => sum + item.price * item.qty);

      final orderData = <String, dynamic>{
        'tableId': tableId,
        'items': newItems.map((i) => i.toMap()).toList(),
        'total': total,
        'status': 'pending',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      await firestoreService.placeOrder(orderData);
    }
  }

  /// Updates the status field of the order document.
  Future<void> updateOrderStatus(String orderId, String status) async {
    await firestoreService.updateOrderStatus(orderId, status);
  }
}
