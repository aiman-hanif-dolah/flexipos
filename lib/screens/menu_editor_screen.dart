import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/menu_provider.dart';
import '../models/category.dart';
import 'add_category_screen.dart';
import 'category_items_screen.dart';

/// Screen for creating and listing menu categories.
/// This screen shows a list of existing categories (via MenuProvider) and
/// provides a button to add a new category.
/// Tapping a category will navigate to a screen showing items in that category.
class MenuEditorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Use MenuProvider to get current list of categories
    final menuProv = Provider.of<MenuProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Menu Editor'),
        centerTitle: true,
      ),
      // ListView of categories; each ListTile leads to category's items
      body: ListView.separated(
        itemCount: menuProv.categories.length,
        separatorBuilder: (context, index) => Divider(height: 1),
        itemBuilder: (context, index) {
          Category cat = menuProv.categories[index];
          return ListTile(
            title: Text(cat.name),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to screen for items in this category
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoryItemsScreen(category: cat),
                ),
              );
            },
          );
        },
      ),
      // Floating button to add a new category
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddCategoryScreen()),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Add Category',
      ),
    );
  }
}

/// End of menu_editor_screen.dart file.
/// This screen is part of the POS menu editing workflow.
/// Additional UI customization can be implemented by editing this file if needed.
