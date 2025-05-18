import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/order.dart';

/// OrderProvider manages real-time orders for FlexiPOS using Firestore.
/// It appends new items to the same table's unpaid order, instead of creating duplicates.
/// Provides strong type safety and UI notification via ChangeNotifier.
class OrderProvider extends ChangeNotifier {
  final FirestoreService firestoreService;

  /// All orders, live synced with Firestore.
  List<Order> orders = [];

  /// Listen to Firestore changes.
  OrderProvider({required this.firestoreService}) {
    firestoreService.ordersStream().listen((dynamic orderList) {
      orders = List<Order>.from(orderList);
      notifyListeners();
    });
  }

  /// Get the active (unpaid) order for a table, if any.
  Order? getActiveOrderForTable(String tableId) {
    try {
      return orders.firstWhere((order) => order.tableId == tableId && order.status != 'completed' && order.status != 'paid');
    } catch (e) {
      return null;
    }
  }

  /// Add or update an order: if an unpaid order for the table exists, append items to it.
  Future<void> addOrUpdateOrder(String tableId, List<OrderItem> newItems) async {
    Order? activeOrder = getActiveOrderForTable(tableId);

    if (activeOrder != null) {
      // Merge items: increase qty if item already exists
      List<OrderItem> mergedItems = List<OrderItem>.from(activeOrder.items);

      for (final newItem in newItems) {
        final idx = mergedItems.indexWhere((i) => i.itemId == newItem.itemId);
        if (idx >= 0) {
          mergedItems[idx] = mergedItems[idx].copyWith(qty: mergedItems[idx].qty + newItem.qty);
        } else {
          mergedItems.add(newItem);
        }
      }

      double newTotal = 0;
      for (final item in mergedItems) {
        newTotal += item.price * item.qty;
      }

      // Update Firestore order document
      await firestoreService.updateOrderItemsAndTotal(
        activeOrder.id,
        mergedItems.map((i) => i.toMap()).toList(),
        newTotal,
      );
    } else {
      // Create a new order
      double total = 0;
      for (final item in newItems) {
        total += item.price * item.qty;
      }

      final Map<String, dynamic> orderData = {
        'tableId': tableId,
        'items': newItems.map((item) => item.toMap()).toList(),
        'total': total,
        'status': 'pending',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      await firestoreService.placeOrder(orderData);
    }
  }

  /// Change order status (e.g. to 'completed', 'paid', 'canceled').
  Future<void> updateOrderStatus(String orderId, String status) async {
    await firestoreService.updateOrderStatus(orderId, status);
  }
}
