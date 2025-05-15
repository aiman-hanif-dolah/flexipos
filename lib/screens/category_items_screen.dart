import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../models/menu_item.dart';
import '../providers/menu_provider.dart';
import 'add_item_screen.dart';

/// Screen to list and add items within a selected category.
/// It shows all existing items under [category] and allows adding new ones.
class CategoryItemsScreen extends StatelessWidget {
  final Category category;

  CategoryItemsScreen({required this.category});

  @override
  Widget build(BuildContext context) {
    // Use MenuProvider to fetch items stream for this category
    final menuProv = Provider.of<MenuProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Items in ${category.name}'),
      ),
      body: StreamBuilder<List<MenuItem>>(
        stream: menuProv.getItemsForCategory(category.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading items'));
          }
          if (!snapshot.hasData) {
            // Data still loading
            return Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!;
          if (items.isEmpty) {
            // No items to display message
            return Center(child: Text('No items in this category yet.'));
          }
          // List of items with name and price
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (context, index) => Divider(),
            itemBuilder: (context, index) {
              MenuItem item = items[index];
              return ListTile(
                title: Text(item.name),
                subtitle: Text('\$${item.price.toStringAsFixed(2)}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to screen to add a new item in this category
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddItemScreen(categoryId: category.id),
            ),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Add Item',
      ),
    );
  }
}

/// End of category_items_screen.dart file.
/// This screen is part of the menu editing workflow, showing items for a category.
