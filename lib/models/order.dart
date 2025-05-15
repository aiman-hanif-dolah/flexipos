/// Model class for an order placed by a waiter for a specific table.
/// Contains a list of items, table ID, total price, and status.
class Order {
  final String id;
  final String tableId;
  final List<OrderItem> items;
  final double total;
  final String status; // e.g. 'pending', 'completed'

  // Constructor for Order
  Order({
    required this.id,
    required this.tableId,
    required this.items,
    required this.total,
    required this.status,
  });

  /// Factory constructor to create an Order from Firestore data.
  factory Order.fromMap(Map<String, dynamic> data, String documentId) {
    var itemsData = data['items'] as List<dynamic>? ?? [];
    List<OrderItem> itemList = itemsData.map((item) {
      return OrderItem.fromMap(item);
    }).toList();
    return Order(
      id: documentId,
      tableId: data['tableId'] ?? '',
      items: itemList,
      total: (data['total'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
    );
  }

  /// Converts this Order object into a map for saving to Firestore.
  Map<String, dynamic> toMap() {
    return {
      'tableId': tableId,
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
      'status': status,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }
}

/// Model class for an item within an order, capturing quantity.
class OrderItem {
  final String itemId;
  final String name;
  final double price;
  final int qty;

  // Constructor for OrderItem
  OrderItem({
    required this.itemId,
    required this.name,
    required this.price,
    required this.qty,
  });

  /// Factory constructor to create an OrderItem from a map.
  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
      itemId: data['itemId'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      qty: (data['qty'] ?? 0) is int ? (data['qty'] as int) : int.parse(data['qty'].toString()),
    );
  }

  /// Converts this OrderItem into a map for Firestore storage.
  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'name': name,
      'price': price,
      'qty': qty,
    };
  }
}

/// End of order.dart model file.
