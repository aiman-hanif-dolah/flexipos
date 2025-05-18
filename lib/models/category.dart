/// Represents a menu category in the POS system, such as "Beverages" or "Entrees".
/// Each category has a unique Firestore document ID and a display name.
/// The Category model includes serialization methods to convert to/from Firestore data.
class Category {
  final String id;
  final String name;
  final String? imageUrl; // Optional: you can use for category icon/thumbnails

  // Constructor for Category model
  Category({
    required this.id,
    required this.name,
    this.imageUrl,
  });

  /// Factory constructor to create a Category from Firestore data.
  /// The [data] map contains fields from Firestore, and [documentId] is the Firestore ID.
  factory Category.fromMap(Map<String, dynamic> data, String documentId) {
    return Category(
      id: documentId,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'], // Will be null if not present
    );
  }

  /// Converts this Category object into a map for saving to Firestore.
  /// Only the 'name' and (if provided) 'imageUrl' fields are saved.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }
}

/// Example usage in code:
///
/// ```dart
/// // Creating a new category and adding to Firestore
/// var newCategory = Category(id: '', name: 'Desserts');
/// FirestoreService().addCategory(newCategory.toMap());
/// ```
///
/// Categories are displayed in both the menu editor and waiter UI as section headers.
/// End of category.dart model file.
