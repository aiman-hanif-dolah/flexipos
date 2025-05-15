import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/menu_provider.dart';

/// Screen to add a new category to the menu.
/// Provides a form where the shop owner can enter a category name.
/// After saving, the new category is added to Firestore via MenuProvider.
class AddCategoryScreen extends StatefulWidget {
  @override
  _AddCategoryScreenState createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  String _categoryName = '';

  @override
  Widget build(BuildContext context) {
    // Access the provider without listening since we'll call methods directly
    final menuProv = Provider.of<MenuProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Category'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Key to identify and validate form
          child: Column(
            children: [
              // Text field to input the category name
              TextFormField(
                decoration: InputDecoration(labelText: 'Category Name'),
                onSaved: (value) => _categoryName = value ?? '',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Save'),
                onPressed: () {
                  // Validate form fields before saving
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Use MenuProvider to add the new category and pop screen
                    menuProv.addCategory(_categoryName);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// End of add_category_screen.dart file.
