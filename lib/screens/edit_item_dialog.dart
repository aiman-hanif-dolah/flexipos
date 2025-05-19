// lib/screens/edit_item_dialog.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/menu_item.dart';
import '../providers/menu_provider.dart';

class EditItemDialog extends StatefulWidget {
  final MenuItem item;
  const EditItemDialog({Key? key, required this.item}) : super(key: key);

  @override
  _EditItemDialogState createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<EditItemDialog> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  Uint8List? _pickedImageBytes;
  final ImagePicker _picker = ImagePicker();
  io.File? _pickedImageFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _priceController =
        TextEditingController(text: widget.item.price.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
      if (file == null) return;
      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        setState(() {
          _pickedImageBytes = bytes;
          _pickedImageFile = null;
        });
      } else {
        setState(() {
          _pickedImageFile = io.File(file.path);
          _pickedImageBytes = null;
        });
      }
    } catch (e) {
      debugPrint('📸 pick image error: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    final menuProv = Provider.of<MenuProvider>(context, listen: false);

    ImageProvider? previewImage;
    if (_pickedImageBytes != null) {
      previewImage = MemoryImage(_pickedImageBytes!);
    } else if (widget.item.imageUrl.toLowerCase().startsWith('http')) {
      previewImage = NetworkImage(widget.item.imageUrl);
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Edit Menu Item',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // tappable avatar
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                backgroundImage: previewImage,
                child: previewImage == null
                    ? const Icon(Icons.camera_alt,
                    size: 36, color: Colors.grey)
                    : null,
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Price (RM)'),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  child: const Text('Save'),
                  onPressed: () async {
                    final newName = _nameController.text.trim();
                    final newPrice = double.tryParse(_priceController.text) ?? widget.item.price;

                    var newImageUrl = widget.item.imageUrl;

                    if (kIsWeb && _pickedImageBytes != null) {
                      // Web: upload bytes
                      newImageUrl = await uploadMenuImage(
                        webBytes: _pickedImageBytes!,
                        fileName: 'menu_${widget.item.id}_${DateTime.now().millisecondsSinceEpoch}',
                      );
                    } else if (!kIsWeb && _pickedImageFile != null) {
                      // Mobile: upload file
                      newImageUrl = await uploadMenuImage(
                        imageFile: _pickedImageFile!,
                        fileName: 'menu_${widget.item.id}_${DateTime.now().millisecondsSinceEpoch}',
                      );
                    }

                    // build updated object
                    final updated = widget.item.copyWith(
                      name: newName,
                      price: newPrice,
                      imageUrl: newImageUrl,
                    );

                    await menuProv.updateMenuItem(updated);

                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
