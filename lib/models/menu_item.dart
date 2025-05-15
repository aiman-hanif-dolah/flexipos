/// Model class for a menu item in a category, e.g. "Coffee" or "Pizza".
/// Each MenuItem has a unique ID, a reference to its category ID, a name, and a price.
class MenuItem {
  final String id;
  final String categoryId;
  final String name;
  final double price;

  // Constructor for MenuItem model
  MenuItem({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.price,
  });

  /// Factory constructor to create a MenuItem from Firestore data.
  /// The [data] map contains fields and [documentId] is the Firestore document ID.
  factory MenuItem.fromMap(Map<String, dynamic> data, String documentId) {
    return MenuItem(
      id: documentId,
      categoryId: data['categoryId'] ?? '', // The ID of the parent category
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(), // Ensure price is double
    );
  }

  /// Converts this MenuItem into a map for saving to Firestore.
  /// Fields include categoryId, name, and price.
  /// The document ID is not included in the map since it is assigned by Firestore.
  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'name': name,
      'price': price,
    };
  }
}

/// Example usage and note:
/// - Use MenuItem.toMap() to send data to Firestore under the 'items' collection.
/// - In the app, items are displayed within their category sections for selection.
///
/// Example code:
/// ```dart
/// var menuItem = MenuItem(id: '', categoryId: 'cat123', name: 'Coffee', price: 2.99);
/// FirestoreService().addItem(menuItem.toMap());
/// ```
/// The new item will appear in the category 'cat123'.
/// End of menu_item.dart model file.
