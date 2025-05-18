import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/menu_provider.dart';

class AddCategoryDialog extends StatefulWidget {
  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final TextEditingController _categoryController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _addCategory() async {
    String categoryName = _categoryController.text.trim();
    if (categoryName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category name cannot be empty')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    await Provider.of<MenuProvider>(context, listen: false)
        .addCategory(name: categoryName);

    setState(() => _isSubmitting = false);
    _categoryController.clear();
    Navigator.pop(context); // Close the dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Category added')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double maxWidth = MediaQuery.of(context).size.width * 0.98;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth, minWidth: 320),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.92),
                  Colors.blue.shade50.withOpacity(0.82),
                  Colors.white.withOpacity(0.92),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.13),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueGrey.withOpacity(0.13),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Add Category',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 21,
                        letterSpacing: 0.2),
                  ),
                  SizedBox(height: 18),
                  TextField(
                    controller: _categoryController,
                    decoration: InputDecoration(
                      labelText: 'Category Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.92),
                    ),
                  ),
                  SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                        child: Text('Cancel', style: TextStyle(fontSize: 16)),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _addCategory,
                        style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(),
                          padding: EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                          backgroundColor: Colors.indigoAccent,
                          foregroundColor: Colors.white,
                          elevation: 2,
                        ),
                        child: _isSubmitting
                            ? SizedBox(
                          height: 16, width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                            : Text('Add', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
