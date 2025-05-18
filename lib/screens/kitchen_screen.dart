import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../providers/order_provider.dart';
import '../ui/background.dart';
// Use your background widget here

class KitchenScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final orderProv = Provider.of<OrderProvider>(context);
    final orders = orderProv.orders;

    // Show only pending orders for the kitchen
    final pendingOrders = orders.where((o) => o.status == 'pending').toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Kitchen Orders'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Premium animated background
          const AnimatedWebBackground(),
          Padding(
            padding: const EdgeInsets.only(top: kToolbarHeight + 18),
            child: pendingOrders.isEmpty
                ? Center(
              child: Container(
                padding: EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.17),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                      color: Colors.indigoAccent.withOpacity(0.12),
                      width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueGrey.withOpacity(0.10),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'No pending orders',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey[800]),
                ),
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 18, horizontal: 18),
              itemCount: pendingOrders.length,
              itemBuilder: (context, index) {
                final order = pendingOrders[index];
                final orderTime = DateTime.fromMillisecondsSinceEpoch(
                    order.timestamp ?? DateTime.now().millisecondsSinceEpoch);
                final formattedTime =
                    "${orderTime.hour.toString().padLeft(2, '0')}:${orderTime.minute.toString().padLeft(2, '0')}";
                return Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.88),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.indigo.withOpacity(0.12),
                            width: 1.1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepOrange.withOpacity(0.09),
                              blurRadius: 16,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 18, horizontal: 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.table_restaurant,
                                      color: Colors.deepOrange, size: 25),
                                  SizedBox(width: 9),
                                  Text(
                                    "Table ${order.tableId}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.deepOrange[700],
                                      letterSpacing: 0.7,
                                    ),
                                  ),
                                  Spacer(),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time,
                                          color: Colors.indigo[400], size: 20),
                                      SizedBox(width: 3),
                                      Text(
                                        formattedTime,
                                        style: TextStyle(
                                            fontSize: 15.2,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.blueGrey[700]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Divider(),
                              ...order.items.map((item) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 3),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          "${item.name}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.blueGrey[900],
                                              fontSize: 16.1),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        "x${item.qty}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.indigo[600],
                                            fontSize: 15.6),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "Total: ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blueGrey[700],
                                        fontSize: 15.3),
                                  ),
                                  Text(
                                    "RM ${order.total.toStringAsFixed(2)}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[800],
                                        fontSize: 16.2),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  icon: Icon(Icons.check_circle_outline,
                                      color: Colors.white),
                                  label: Text(
                                    'Mark Completed',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[700],
                                    foregroundColor: Colors.white,
                                    shape: StadiumBorder(),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 28, vertical: 12),
                                    elevation: 3,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => _ConfirmMarkCompletedDialog(
                                          order: order,
                                          onConfirm: () async {
                                            await orderProv.updateOrderStatus(
                                                order.id, 'completed');
                                            Navigator.of(context).pop();
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                              content: Text(
                                                  "Order for Table ${order.tableId} marked as completed!"),
                                            ));
                                          }),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmMarkCompletedDialog extends StatelessWidget {
  final Order order;
  final VoidCallback onConfirm;

  const _ConfirmMarkCompletedDialog({required this.order, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white.withOpacity(0.94),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.deepOrange, size: 44),
            SizedBox(height: 14),
            Text(
              "Mark Order as Completed?",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.deepOrange[800],
              ),
            ),
            SizedBox(height: 10),
            Text(
              "This will move Table ${order.tableId}'s order to the cashier for payment.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.5, color: Colors.blueGrey[700]),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text("Cancel"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                SizedBox(width: 10),
                ElevatedButton.icon(
                  icon: Icon(Icons.check, size: 20),
                  label: Text("Yes, Complete"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    shape: StadiumBorder(),
                  ),
                  onPressed: onConfirm,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
