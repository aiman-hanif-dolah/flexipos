import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../models/category.dart';
import '../providers/menu_provider.dart';

class AddItemDialog extends StatefulWidget {
  final String? initialCategoryId;
  AddItemDialog({this.initialCategoryId});

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  File? _imageFile;
  String? _selectedCategoryId;
  bool _isSubmitting = false;

  // Pastel/primary color palette for chips, expand as needed
  final List<Color> chipColors = [
    Colors.indigoAccent,
    Colors.green,
    Colors.deepOrange,
    Colors.teal,
    Colors.amber,
    Colors.purple,
    Colors.cyan,
    Colors.pinkAccent,
    Colors.blue,
    Colors.deepPurple,
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImage(File image) async {
    // Replace this with your actual upload logic if needed.
    return image.path;
  }

  Future<void> _addMenuItem() async {
    String name = _nameController.text.trim();
    double? price = double.tryParse(_priceController.text.trim());
    String? categoryId = _selectedCategoryId;

    if (name.isNotEmpty && price != null && _imageFile != null && categoryId != null) {
      setState(() {
        _isSubmitting = true;
      });

      String imageUrl = await _uploadImage(_imageFile!);

      await Provider.of<MenuProvider>(context, listen: false).addItem(
        categoryId: categoryId,
        name: name,
        price: price,
        imageUrl: imageUrl,
      );

      setState(() {
        _isSubmitting = false;
        _imageFile = null;
        _selectedCategoryId = null;
      });

      _nameController.clear();
      _priceController.clear();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Menu item added')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all fields and select a category')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Category> categories = Provider.of<MenuProvider>(context).categories;
    final double maxHeight = MediaQuery.of(context).size.height * 0.85;
    final double maxWidth = MediaQuery.of(context).size.width * 0.98;

    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            constraints: BoxConstraints(maxHeight: maxHeight, maxWidth: maxWidth, minWidth: 330),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.85),
                  Colors.blue.shade50.withOpacity(0.74),
                  Colors.white.withOpacity(0.76),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueGrey.withOpacity(0.12),
                  blurRadius: 18,
                  offset: Offset(0, 7),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Add Menu Item",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21, letterSpacing: 0.3),
                    ),
                    SizedBox(height: 16),
                    GestureDetector(
                      onTap: _pickImage,
                      child: _imageFile == null
                          ? Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.grey[300]?.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white, width: 2.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueGrey.withOpacity(0.05),
                              blurRadius: 7,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(Icons.camera_alt, size: 38, color: Colors.blueGrey[400]),
                      )
                          : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          _imageFile!,
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap image to pick',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 18),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Menu Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.90),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Price (RM)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.90),
                      ),
                    ),
                    SizedBox(height: 18),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Select Category:',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(categories.length, (i) {
                        final category = categories[i];
                        final selected = _selectedCategoryId == category.id;
                        final chipColor = chipColors[i % chipColors.length];
                        return ChoiceChip(
                          label: Text(
                            category.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: selected ? Colors.white : chipColor,
                              fontSize: 16,
                            ),
                          ),
                          selected: selected,
                          selectedColor: chipColor.withOpacity(0.88),
                          backgroundColor: chipColor.withOpacity(0.13),
                          labelPadding: EdgeInsets.symmetric(horizontal: 19, vertical: 5),
                          shape: StadiumBorder(
                            side: BorderSide(
                              color: selected ? chipColor : chipColor.withOpacity(0.39),
                              width: selected ? 2.3 : 1.1,
                            ),
                          ),
                          onSelected: (_) {
                            setState(() {
                              _selectedCategoryId = category.id;
                            });
                          },
                        );
                      }),
                    ),
                    SizedBox(height: 26),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                          child: Text("Cancel", style: TextStyle(fontSize: 16)),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isSubmitting ? null : _addMenuItem,
                          style: ElevatedButton.styleFrom(
                            shape: StadiumBorder(),
                            padding: EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                            backgroundColor: Colors.indigoAccent,
                            foregroundColor: Colors.white,
                            elevation: 2,
                          ),
                          child: _isSubmitting
                              ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : Text('Add Item', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
