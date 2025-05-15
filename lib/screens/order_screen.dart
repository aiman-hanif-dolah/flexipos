import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../models/menu_item.dart';
import '../models/order.dart';
import '../providers/menu_provider.dart';
import '../providers/order_provider.dart';

/// Screen for placing an order for a specific table.
/// Lists menu categories and items; allows adding items to the current order.
class OrderScreen extends StatefulWidget {
  final String tableId;
  OrderScreen({required this.tableId});

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  // Map to keep track of items and their quantities
  final Map<String, OrderItem> _orderItems = {};

  @override
  Widget build(BuildContext context) {
    final menuProv = Provider.of<MenuProvider>(context);
    final orderProv = Provider.of<OrderProvider>(context, listen: false);

    // Build a list of expansion tiles for each category
    List<Widget> categoryTiles = [];
    for (Category cat in menuProv.categories) {
      categoryTiles.add(
        ExpansionTile(
          title: Text(cat.name),
          children: [
            StreamBuilder<List<MenuItem>>(
              stream: menuProv.getItemsForCategory(cat.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final items = snapshot.data!;
                return Column(
                  children: items.map((item) {
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text('\$${item.price.toStringAsFixed(2)}'),
                      trailing: IconButton(
                        icon: Icon(Icons.add_shopping_cart),
                        onPressed: () {
                          // Add item to order or increment quantity
                          setState(() {
                            if (_orderItems.containsKey(item.id)) {
                              _orderItems[item.id] =
                                  OrderItem(itemId: item.id, name: item.name, price: item.price, qty: _orderItems[item.id]!.qty + 1);
                            } else {
                              _orderItems[item.id] = OrderItem(itemId: item.id, name: item.name, price: item.price, qty: 1);
                            }
                          });
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Table ${widget.tableId} Order'),
      ),
      body: Column(
        children: [
          // Menu categories and items list
          Expanded(
            child: ListView(children: categoryTiles),
          ),
          Divider(),
          // Selected items summary
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  'Current Order:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                // List each selected item with qty
                ..._orderItems.values.map((orderItem) {
                  return Text('${orderItem.name} x${orderItem.qty}');
                }).toList(),
                if (_orderItems.isEmpty) Text('No items added'),
                SizedBox(height: 8),
                ElevatedButton(
                  child: Text('Send Order'),
                  onPressed: _orderItems.isEmpty
                      ? null
                      : () {
                    // Place the order using provider
                    orderProv.placeOrder(widget.tableId, _orderItems.values.toList());
                    // Confirmation message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Order sent to kitchen')),
                    );
                    // Return to main menu (pop all the way)
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// End of order_screen.dart file.
