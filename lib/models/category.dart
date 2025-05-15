/// Represents a menu category in the POS system, such as "Beverages" or "Entrees".
/// Each category has a unique Firestore document ID and a display name.
/// The `Category` model includes serialization methods to convert to/from Firestore data.
class Category {
  final String id;
  final String name;

  // Constructor for Category model
  Category({required this.id, required this.name});

  /// Factory constructor to create a Category from Firestore data.
  /// The [data] map contains fields from Firestore, and [documentId] is the Firestore ID.
  factory Category.fromMap(Map<String, dynamic> data, String documentId) {
    return Category(
      id: documentId,
      name: data['name'] ?? '', // Use empty string if 'name' field is missing
    );
  }

  /// Converts this Category object into a map for saving to Firestore.
  /// Only the 'name' field is saved since the document ID is managed by Firestore.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
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
/// This model class ends here (category.dart file).
/// File.
