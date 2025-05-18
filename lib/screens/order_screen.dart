import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../models/menu_item.dart';
import '../models/order.dart';
import '../providers/menu_provider.dart';
import '../providers/order_provider.dart';
import '../ui/background.dart';
import '../widgets/animated_web_background.dart'; // Make sure this is in your widgets

class OrderScreen extends StatefulWidget {
  final String tableId;
  OrderScreen({required this.tableId});

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  // Key: menuItem.id, Value: OrderItem (with qty)
  final Map<String, OrderItem> _orderItems = {};

  @override
  Widget build(BuildContext context) {
    final menuProv = Provider.of<MenuProvider>(context);
    final orderProv = Provider.of<OrderProvider>(context, listen: false);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Order for Table ${widget.tableId}'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Premium animated background
          Positioned.fill(child: const AnimatedWebBackground()),

          Padding(
            padding: EdgeInsets.only(top: kToolbarHeight + 18),
            child: Column(
              children: [
                // MENU DISPLAY (categories & items)
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    itemCount: menuProv.categories.length,
                    itemBuilder: (ctx, idx) {
                      final Category cat = menuProv.categories[idx];
                      final List<MenuItem> items = menuProv.getItemsListForCategory(cat.id);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.14),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.blue.withOpacity(0.09), width: 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueAccent.withOpacity(0.09),
                                    blurRadius: 11,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ExpansionTile(
                                tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                leading: cat.imageUrl != null && cat.imageUrl!.isNotEmpty
                                    ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(cat.imageUrl!,
                                      width: 38, height: 38, fit: BoxFit.cover),
                                )
                                    : Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.40), // semi-transparent badge
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.deepOrange.withOpacity(0.21),
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.lunch_dining, // or your preferred category icon
                                    size: 28,
                                    color: Colors.deepOrange, // or Colors.teal[600], or Colors.white, try and see
                                    shadows: [
                                      Shadow(
                                        blurRadius: 7,
                                        color: Colors.orange.withOpacity(0.48),
                                        offset: Offset(1, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                title: Text(
                                  cat.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.blueGrey[900],
                                    fontSize: 18.5,
                                  ),
                                ),
                                children: items.isNotEmpty
                                    ? items.map((item) => _MenuItemTile(
                                  item: item,
                                  currentQty: _orderItems[item.id]?.qty ?? 0,
                                  onQtyChanged: (qty) {
                                    setState(() {
                                      if (qty > 0) {
                                        _orderItems[item.id] = OrderItem(
                                          itemId: item.id,
                                          name: item.name,
                                          price: item.price,
                                          qty: qty,
                                        );
                                      } else {
                                        _orderItems.remove(item.id);
                                      }
                                    });
                                  },
                                ))
                                    .toList()
                                    : [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 7),
                                    child: Text('No items in this category',
                                        style: TextStyle(color: Colors.grey[600])),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // ORDER SUMMARY CARD
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 250),
                  child: _orderItems.isNotEmpty
                      ? _OrderSummaryCard(
                    key: ValueKey(_orderItems.length),
                    orderItems: _orderItems,
                    onChanged: () => setState(() {}),
                  )
                      : SizedBox(height: 8),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.send_rounded, size: 22),
                      label: Text("Send Order"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _orderItems.isEmpty ? Colors.grey : Colors.teal,
                        foregroundColor: Colors.white,
                        shape: StadiumBorder(),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        elevation: 2,
                      ),
                      onPressed: _orderItems.isEmpty
                          ? null
                          : () async {
                        await orderProv.addOrUpdateOrder(
                          widget.tableId,
                          _orderItems.values.toList(),
                        );
                        setState(() {
                          _orderItems.clear();
                        });
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text('Order Sent!'),
                            content: Text(
                                'Order for Table ${widget.tableId} has been sent to kitchen.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).popUntil((route) => route.isFirst);
                                },
                                child: Text("Back to Main Menu"),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Menu item tile with image, price, and quantity controls (inline)
class _MenuItemTile extends StatelessWidget {
  final MenuItem item;
  final int currentQty;
  final ValueChanged<int> onQtyChanged;

  const _MenuItemTile({
    required this.item,
    required this.currentQty,
    required this.onQtyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: currentQty > 0 ? Colors.teal.withOpacity(0.32) : Colors.grey.withOpacity(0.07),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.tealAccent.withOpacity(0.03),
            blurRadius: 9,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          item.imageUrl.isNotEmpty
              ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(item.imageUrl, width: 46, height: 46, fit: BoxFit.cover),
          )
              : Icon(Icons.fastfood, size: 36, color: Colors.teal[100]),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.5, color: Colors.teal[900])),
                SizedBox(height: 1),
                Text('RM${item.price.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.teal[700], fontSize: 14.2)),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove_circle, color: Colors.red[400]),
                onPressed: currentQty > 0 ? () => onQtyChanged(currentQty - 1) : null,
              ),
              Container(
                width: 32,
                alignment: Alignment.center,
                child: Text('$currentQty',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.5,
                        color: currentQty > 0 ? Colors.teal[900] : Colors.grey[400])),
              ),
              IconButton(
                icon: Icon(Icons.add_circle, color: Colors.green[400]),
                onPressed: () => onQtyChanged(currentQty + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Order summary glass card with inline controls
class _OrderSummaryCard extends StatelessWidget {
  final Map<String, OrderItem> orderItems;
  final VoidCallback onChanged;
  const _OrderSummaryCard({Key? key, required this.orderItems, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double total = orderItems.values.fold(0, (sum, i) => sum + i.price * i.qty);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.teal.withOpacity(0.13), width: 1),
              boxShadow: [
                BoxShadow(color: Colors.teal.withOpacity(0.10), blurRadius: 12, offset: Offset(0, 4)),
              ],
            ),
            padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Current Order", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.5)),
                SizedBox(height: 7),
                ...orderItems.values.map((orderItem) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(orderItem.name, overflow: TextOverflow.ellipsis)),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove_circle, color: Colors.red[400], size: 22),
                              onPressed: orderItem.qty > 1
                                  ? () {
                                orderItems[orderItem.itemId] =
                                    orderItem.copyWith(qty: orderItem.qty - 1);
                                onChanged();
                              }
                                  : null,
                            ),
                            Text('${orderItem.qty}', style: TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: Icon(Icons.add_circle, color: Colors.green[400], size: 22),
                              onPressed: () {
                                orderItems[orderItem.itemId] =
                                    orderItem.copyWith(qty: orderItem.qty + 1);
                                onChanged();
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline, color: Colors.grey[700], size: 20),
                              onPressed: () {
                                orderItems.remove(orderItem.itemId);
                                onChanged();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total:', style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold)),
                    Text('RM${total.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal[900])),
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
