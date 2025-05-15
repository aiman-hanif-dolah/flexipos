import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/menu_provider.dart';

/// Screen to add a new item under a specific category.
/// Contains form fields for item name and price.
class AddItemScreen extends StatefulWidget {
  final String categoryId;
  AddItemScreen({required this.categoryId});

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  String _itemName = '';
  String _priceText = '';

  @override
  Widget build(BuildContext context) {
    final menuProv = Provider.of<MenuProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Item'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Input for item name
              TextFormField(
                decoration: InputDecoration(labelText: 'Item Name'),
                onSaved: (value) => _itemName = value ?? '',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an item name';
                  }
                  return null;
                },
              ),
              // Input for item price
              TextFormField(
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onSaved: (value) => _priceText = value ?? '',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Save'),
                onPressed: () {
                  // Validate and save form
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Parse price and call provider to add item
                    final price = double.parse(_priceText);
                    menuProv.addItem(widget.categoryId, _itemName, price);
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

/// End of add_item_screen.dart file.
