import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../providers/order_provider.dart';

/// Screen for kitchen staff to view and update orders.
/// Orders are received in real-time from Firestore via OrderProvider.
class KitchenScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final orderProv = Provider.of<OrderProvider>(context);
    final orders = orderProv.orders;

    // Filter to only show pending orders in the kitchen.
    final pendingOrders = orders.where((o) => o.status == 'pending').toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Kitchen Orders'),
        centerTitle: true,
      ),
      // Show list of pending orders or a message if none
      body: pendingOrders.isEmpty
          ? Center(child: Text('No pending orders'))
          : ListView.builder(
        itemCount: pendingOrders.length,
        itemBuilder: (context, index) {
          Order order = pendingOrders[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Table ${order.tableId}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  // Display each item and quantity in this order
                  ...order.items.map((item) {
                    return Text('${item.name} x${item.qty}');
                  }).toList(),
                  SizedBox(height: 8),
                  // Button to mark this order as completed
                  ElevatedButton(
                    child: Text('Mark Completed'),
                    onPressed: () {
                      orderProv.updateOrderStatus(order.id, 'completed');
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// End of kitchen_screen.dart file.
/// Each order is displayed here; kitchen staff can mark orders as completed.
/// Completed orders will disappear from this list after marking done.
