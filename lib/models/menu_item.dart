/// Model class for a menu item in a category, e.g. "Coffee" or "Pizza".
/// Each MenuItem has a unique ID, a reference to its category ID, a name, a price, and an image URL.
class MenuItem {
  final String id;
  final String categoryId;
  final String name;
  final double price;
  final String imageUrl; // Image (Firebase Storage URL or local path)

  // Constructor for MenuItem model
  MenuItem({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  /// Factory constructor to create a MenuItem from Firestore data.
  /// The [data] map contains fields and [documentId] is the Firestore document ID.
  factory MenuItem.fromMap(Map<String, dynamic> data, String documentId) {
    return MenuItem(
      id: documentId,
      categoryId: data['categoryId'] ?? '', // The ID of the parent category
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(), // Ensure price is double
      imageUrl: data['imageUrl'] ?? '', // Image URL, default to empty string if not present
    );
  }

  /// Converts this MenuItem into a map for saving to Firestore.
  /// The document ID is not included in the map since it is assigned by Firestore.
  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
    };
  }
}

/// Example usage:
/// var menuItem = MenuItem(id: '', categoryId: 'cat123', name: 'Coffee', price: 2.99, imageUrl: 'https://...jpg');
/// FirestoreService().addItem(menuItem.toMap());
/// The new item will appear in the category 'cat123' and display its image.

/// End of menu_item.dart model file.
