import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../models/menu_item.dart';
import '../providers/menu_provider.dart';
import 'add_item_dialog.dart'; // Import your dialog here

/// Screen to list and add items within a selected category.
/// It shows all existing items under [category] and allows adding new ones.
class CategoryItemsScreen extends StatelessWidget {
  final Category category;

  CategoryItemsScreen({required this.category});

  @override
  Widget build(BuildContext context) {
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
            return Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!;
          if (items.isEmpty) {
            return Center(child: Text('No items in this category yet.'));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (context, index) => Divider(),
            itemBuilder: (context, index) {
              MenuItem item = items[index];
              return ListTile(
                title: Text(item.name),
                subtitle: Text('RM${item.price.toStringAsFixed(2)}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AddItemDialog(initialCategoryId: category.id),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Add Item',
      ),
    );
  }
}
