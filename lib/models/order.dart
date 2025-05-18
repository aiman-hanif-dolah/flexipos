/// Model class for an order placed by a waiter for a specific table.
/// Contains a list of items, table ID, total price, status, and timestamp.
class Order {
  final String id;
  final String tableId;
  final List<OrderItem> items;
  final double total;
  final String status; // e.g. 'pending', 'completed', 'paid', etc.
  final int timestamp; // Unix epoch milliseconds

  Order({
    required this.id,
    required this.tableId,
    required this.items,
    required this.total,
    required this.status,
    required this.timestamp,
  });

  /// Factory constructor to create an Order from Firestore document data.
  factory Order.fromMap(Map<String, dynamic> data, String documentId) {
    var itemsData = data['items'] as List<dynamic>? ?? [];
    List<OrderItem> itemList = itemsData.map((item) => OrderItem.fromMap(item)).toList();
    return Order(
      id: documentId,
      tableId: data['tableId'] ?? '',
      items: itemList,
      total: (data['total'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      timestamp: (data['timestamp'] ?? 0) is int
          ? (data['timestamp'] ?? 0)
          : int.tryParse(data['timestamp'].toString()) ?? 0,
    );
  }

  /// Converts this Order object into a map for saving to Firestore.
  Map<String, dynamic> toMap() {
    return {
      'tableId': tableId,
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
      'status': status,
      'timestamp': timestamp,
    };
  }
}

/// Model class for an item within an order, capturing name, price, and quantity.
class OrderItem {
  final String itemId;
  final String name;
  final double price;
  final int qty;

  OrderItem({
    required this.itemId,
    required this.name,
    required this.price,
    required this.qty,
  });

  /// Creates an OrderItem from Firestore data.
  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
      itemId: data['itemId'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      qty: (data['qty'] ?? 0) is int ? (data['qty'] ?? 0) : int.tryParse(data['qty'].toString()) ?? 0,
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

  /// Allows copying an OrderItem with new values (e.g., updated quantity)
  OrderItem copyWith({
    String? itemId,
    String? name,
    double? price,
    int? qty,
  }) {
    return OrderItem(
      itemId: itemId ?? this.itemId,
      name: name ?? this.name,
      price: price ?? this.price,
      qty: qty ?? this.qty,
    );
  }
}
