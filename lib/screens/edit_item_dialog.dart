import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/menu_item.dart';
import '../providers/menu_provider.dart';

class EditItemDialog extends StatefulWidget {
  final MenuItem item;
  EditItemDialog({required this.item});

  @override
  State<EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<EditItemDialog> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  String? _imageUrl;
  File? _pickedImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _priceController = TextEditingController(text: widget.item.price.toString());
    _imageUrl = widget.item.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  /// Simulate image upload, return the new image URL.
  Future<String> _uploadImage(File image) async {
    // TODO: Replace with your upload logic (e.g. Firebase Storage)
    // For demo, just use the local path.
    return image.path;
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context, listen: false);
    return AlertDialog(
      title: Text('Edit Menu Item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: _pickedImage != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(_pickedImage!, width: 100, height: 100, fit: BoxFit.cover),
              )
                  : (_imageUrl != null && _imageUrl!.isNotEmpty)
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(_imageUrl!, width: 100, height: 100, fit: BoxFit.cover),
              )
                  : Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.camera_alt, size: 40, color: Colors.grey[500]),
              ),
            ),
            SizedBox(height: 8),
            Text('Tap image to change', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
            SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Menu Name'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Price (RM)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving
              ? null
              : () async {
            String name = _nameController.text.trim();
            double? price = double.tryParse(_priceController.text.trim());
            if (name.isEmpty || price == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Fill in all fields.')),
              );
              return;
            }
            setState(() => _isSaving = true);
            String imageUrl = _imageUrl ?? '';
            if (_pickedImage != null) {
              imageUrl = await _uploadImage(_pickedImage!);
            }
            await menuProvider.updateMenuItem(
              id: widget.item.id,
              name: name,
              price: price,
              imageUrl: imageUrl,
            );
            setState(() => _isSaving = false);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Menu item updated')),
            );
          },
          child: _isSaving
              ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text('Save'),
        ),
      ],
    );
  }
}
