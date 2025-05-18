import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../providers/order_provider.dart';
import '../ui/background.dart';
import '../widgets/animated_web_background.dart';

class CashierScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final orderProv = Provider.of<OrderProvider>(context);

    // Group and merge orders by tableId, sum total and merge items
    final Map<String, List<Order>> tableOrders = {};
    for (final order in orderProv.orders.where((o) => o.status == 'completed')) {
      tableOrders.putIfAbsent(order.tableId, () => []).add(order);
    }

    // Build a list of merged orders by table
    final List<_MergedOrder> mergedOrders = tableOrders.entries.map((entry) {
      final tableId = entry.key;
      final orders = entry.value;

      // Merge items by itemId and sum qty
      final Map<String, OrderItem> itemMap = {};
      for (var order in orders) {
        for (var item in order.items) {
          if (itemMap.containsKey(item.itemId)) {
            itemMap[item.itemId] = itemMap[item.itemId]!.copyWith(
              qty: itemMap[item.itemId]!.qty + item.qty,
            );
          } else {
            itemMap[item.itemId] = item;
          }
        }
      }
      final mergedItems = itemMap.values.toList();
      final total = mergedItems.fold<double>(0, (sum, i) => sum + (i.price * i.qty));
      final allOrderIds = orders.map((o) => o.id).toList();

      return _MergedOrder(
        tableId: tableId,
        items: mergedItems,
        total: total,
        orderIds: allOrderIds,
      );
    }).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Cashier – Pending Payments'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const AnimatedWebBackground(),
          Padding(
            padding: const EdgeInsets.only(top: kToolbarHeight + 18.0),
            child: mergedOrders.isEmpty
                ? Center(
              child: Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                      color: Colors.indigoAccent.withOpacity(0.09), width: 1.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueGrey.withOpacity(0.11),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'No orders awaiting payment',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey[700]),
                ),
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 14),
              itemCount: mergedOrders.length,
              itemBuilder: (context, index) {
                final merged = mergedOrders[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 22),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.orangeAccent.withOpacity(0.14),
                            width: 1.7,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orangeAccent.withOpacity(0.13),
                              blurRadius: 24,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Table ${merged.tableId}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigoAccent,
                                    ),
                                  ),
                                  Text(
                                    'RM ${merged.total.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 7),
                              Divider(height: 8, color: Colors.indigo.withOpacity(0.08)),
                              ...merged.items.map((item) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey[50],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          '${item.name}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blueGrey[900],
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        'x${item.qty}  @ RM ${item.price.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 15.2,
                                          color: Colors.blueGrey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                              SizedBox(height: 18),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => _PaymentDialog(
                                        tableId: merged.tableId,
                                        items: merged.items,
                                        total: merged.total,
                                        orderIds: merged.orderIds,
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.payment, size: 19),
                                  label: Text(
                                    "Tap to process payment",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600, fontSize: 15.5),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[600],
                                    foregroundColor: Colors.white,
                                    shape: StadiumBorder(),
                                    elevation: 2,
                                    padding: EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                                  ),
                                ),
                              )
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

// Model to hold merged table orders
class _MergedOrder {
  final String tableId;
  final List<OrderItem> items;
  final double total;
  final List<String> orderIds;

  _MergedOrder({
    required this.tableId,
    required this.items,
    required this.total,
    required this.orderIds,
  });
}

/// Payment Dialog for merged orders
class _PaymentDialog extends StatefulWidget {
  final String tableId;
  final List<OrderItem> items;
  final double total;
  final List<String> orderIds;

  const _PaymentDialog({
    required this.tableId,
    required this.items,
    required this.total,
    required this.orderIds,
  });

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  final TextEditingController _paidController = TextEditingController();
  double? paidAmount;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _paidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double balance = (paidAmount ?? 0) - widget.total;
    final isEnough = (paidAmount ?? 0) >= widget.total;

    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.97),
                  Colors.blue.shade50.withOpacity(0.82),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.indigo.withOpacity(0.11),
                width: 1.2,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 28),
            constraints: BoxConstraints(maxWidth: 430, minWidth: 330),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Process Payment",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21),
                ),
                SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Table ${widget.tableId}',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.blueGrey[900]),
                    ),
                    Text(
                      'Total: RM ${widget.total.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.green[700]),
                    ),
                  ],
                ),
                SizedBox(height: 14),
                Divider(),
                ...widget.items.map((item) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '${item.name}',
                          style: TextStyle(fontSize: 15.7, color: Colors.blueGrey[900]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'x${item.qty}  @ RM ${item.price.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 15.1, color: Colors.blueGrey[500]),
                      ),
                    ],
                  ),
                )),
                SizedBox(height: 18),
                TextField(
                  controller: _paidController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: "Amount Paid (RM)",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.payments),
                    fillColor: Colors.white.withOpacity(0.95),
                    filled: true,
                  ),
                  onChanged: (v) {
                    setState(() {
                      paidAmount = double.tryParse(v);
                    });
                  },
                ),
                SizedBox(height: 14),
                if (paidAmount != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Balance / Change:",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      Text(
                        "RM ${(balance).toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isEnough ? Colors.teal : Colors.red,
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 26),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                      child: Text("Cancel", style: TextStyle(fontSize: 16)),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton.icon(
                      icon: Icon(Icons.check_circle, size: 19),
                      label: _isSubmitting
                          ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text('Mark Paid', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        shape: StadiumBorder(),
                        padding: EdgeInsets.symmetric(horizontal: 26, vertical: 13),
                        backgroundColor: isEnough ? Colors.indigoAccent : Colors.grey,
                        foregroundColor: Colors.white,
                        elevation: 2,
                      ),
                      onPressed: !isEnough || _isSubmitting
                          ? null
                          : () async {
                        setState(() => _isSubmitting = true);

                        // Mark all orders for this table as paid
                        final orderProv = Provider.of<OrderProvider>(context, listen: false);
                        for (var id in widget.orderIds) {
                          await orderProv.updateOrderStatus(id, 'paid');
                          // Optionally, save profit etc. to Firestore here
                        }

                        setState(() => _isSubmitting = false);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Orders for Table ${widget.tableId} marked as paid. Change: RM ${(balance).toStringAsFixed(2)}')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
