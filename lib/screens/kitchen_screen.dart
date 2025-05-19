import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../providers/order_provider.dart';
import '../ui/background.dart';

class KitchenScreen extends StatefulWidget {
  const KitchenScreen({Key? key}) : super(key: key);

  @override
  _KitchenScreenState createState() => _KitchenScreenState();
}

class _KitchenScreenState extends State<KitchenScreen> {
  Future<bool?> _showConfirmDialog(BuildContext ctx, Order order) {
    return showDialog<bool>(
      context: ctx,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: Colors.white.withOpacity(0.94),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.deepOrange, size: 44),
                const SizedBox(height: 14),
                Text(
                  "Mark Order as Completed?",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.deepOrange[800],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "This will move Table ${order.tableId}'s order to the cashier for payment.",
                  textAlign: TextAlign.center,
                  style:
                  TextStyle(fontSize: 16.5, color: Colors.blueGrey[700]),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: const Text("Cancel"),
                      onPressed: () => Navigator.of(dialogCtx).pop(false),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check, size: 20),
                      label: const Text("Yes, Complete"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () => Navigator.of(dialogCtx).pop(true),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _markCompletedAndNotify(
      BuildContext ctx,
      String orderId,
      String tableId,
      ) async {
    await Provider.of<OrderProvider>(ctx, listen: false)
        .updateOrderStatus(orderId, 'completed');

    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text("Order for Table $tableId marked as completed!"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Kitchen Orders'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const AnimatedWebBackground(),
          Padding(
            padding: const EdgeInsets.only(top: kToolbarHeight + 18),
            child: Consumer<OrderProvider>(
              builder: (ctx, provider, _) {
                final pending = provider.orders
                    .where((o) => o.status == 'pending')
                    .toList();
                if (pending.isEmpty) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.17),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.indigoAccent.withOpacity(0.12),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueGrey.withOpacity(0.10),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        'No pending orders',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding:
                  const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
                  itemCount: pending.length,
                  itemBuilder: (ctx, i) {
                    final order = pending[i];
                    final orderTime = DateTime.fromMillisecondsSinceEpoch(
                      order.timestamp ??
                          DateTime.now().millisecondsSinceEpoch,
                    );
                    final formattedTime =
                        "${orderTime.hour.toString().padLeft(2, '0')}:${orderTime.minute.toString().padLeft(2, '0')}";

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: BackdropFilter(
                          filter:
                          ImageFilter.blur(sigmaX: 20, sigmaY: 20),
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
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 18, horizontal: 18),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.table_restaurant,
                                          color: Colors.deepOrange, size: 25),
                                      const SizedBox(width: 9),
                                      Text(
                                        "Table ${order.tableId}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Colors.deepOrange[700],
                                          letterSpacing: 0.7,
                                        ),
                                      ),
                                      const Spacer(),
                                      Row(
                                        children: [
                                          Icon(Icons.access_time,
                                              color: Colors.indigo[400],
                                              size: 20),
                                          const SizedBox(width: 3),
                                          Text(
                                            formattedTime,
                                            style: TextStyle(
                                              fontSize: 15.2,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.blueGrey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Divider(),
                                  ...order.items.map((item) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 3),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              item.name,
                                              style: TextStyle(
                                                fontWeight:
                                                FontWeight.w500,
                                                color:
                                                Colors.blueGrey[900],
                                                fontSize: 16.1,
                                              ),
                                              overflow:
                                              TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            "x${item.qty}",
                                            style: TextStyle(
                                              fontWeight:
                                              FontWeight.w600,
                                              color: Colors.indigo[600],
                                              fontSize: 15.6,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "Total: ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blueGrey[700],
                                          fontSize: 15.3,
                                        ),
                                      ),
                                      Text(
                                        "RM ${order.total.toStringAsFixed(2)}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green[800],
                                          fontSize: 16.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton.icon(
                                      icon: Icon(
                                        Icons.check_circle_outline,
                                        color: Colors.white,
                                      ),
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
                                        padding: EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                                        elevation: 3,
                                      ),
                                      onPressed: () async {
                                        final bool? confirmed = await _showConfirmDialog(context, order);
                                        if (confirmed == true) {
                                          await _markCompletedAndNotify(
                                            context,
                                            order.id,
                                            order.tableId,
                                          );
                                        }
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
