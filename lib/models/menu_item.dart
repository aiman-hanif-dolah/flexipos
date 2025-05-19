/// lib/models/menu_item.dart

/// Model class for a menu item in a category, e.g. "Coffee" or "Pizza".
/// Each MenuItem has:
///  • a unique Firestore document ID (`id`)
///  • the parent category's ID (`categoryId`)
///  • the item's display name (`name`)
///  • the item's price (`price`)
///  • an image URL (`imageUrl`)
class MenuItem {
  /// Firestore document ID
  final String id;

  /// ID of the category this item belongs to
  final String categoryId;

  /// Display name
  final String name;

  /// Price in your local currency
  final double price;

  /// URL to an image (could be Firebase Storage URL or http(s) link)
  final String imageUrl;

  /// Standard constructor
  const MenuItem({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  /// Creates a MenuItem from Firestore data.
  factory MenuItem.fromMap(Map<String, dynamic> data, String documentId) {
    return MenuItem(
      id: documentId,
      categoryId: data['categoryId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      price: (data['price'] as num? ?? 0).toDouble(),
      imageUrl: data['imageUrl'] as String? ?? '',
    );
  }

  /// Converts this MenuItem into a map for saving/updating in Firestore.
  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  /// Returns a copy of this MenuItem with the given fields replaced.
  /// Allows calls like:
  ///   item.copyWith(name: "New Name", price: 3.50)
  MenuItem copyWith({
    String? id,
    String? categoryId,
    String? name,
    double? price,
    String? imageUrl,
  }) {
    return MenuItem(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
