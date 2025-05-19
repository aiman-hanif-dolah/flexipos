import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/menu_provider.dart';
import '../models/category.dart';
import '../models/menu_item.dart';
import '../ui/background.dart';
import 'add_category_screen.dart';
import 'add_item_dialog.dart';
import 'edit_item_dialog.dart';
import '../widgets/animated_web_background.dart';

class MenuEditorScreen extends StatelessWidget {
  const MenuEditorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Menu Editor'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const AnimatedWebBackground(),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(36),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(36),
                        border: Border.all(color: Colors.blue.withOpacity(0.10), width: 1.4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueGrey.withOpacity(0.10),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Top action buttons
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.23),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              margin: const EdgeInsets.only(bottom: 20),
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.category),
                                      label: const Text('Add Category'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.indigoAccent,
                                        foregroundColor: Colors.white,
                                        shape: const StadiumBorder(),
                                        elevation: 2,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => AddCategoryDialog(),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.add_box),
                                      label: const Text('Add Menu Item'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        shape: const StadiumBorder(),
                                        elevation: 2,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => AddItemDialog(),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(),

                            // Category expansion + items
                            ...menuProvider.categories.map((Category category) {
                              final List<MenuItem> items = menuProvider.getItemsListForCategory(category.id);

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Card(
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                  color: Colors.white.withOpacity(0.76),
                                  child: ExpansionTile(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                    collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                    title: Row(
                                      children: [
                                        if (category.imageUrl != null && category.imageUrl!.startsWith('http'))
                                          Padding(
                                            padding: const EdgeInsets.only(right: 8.0),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: Image.network(
                                                category.imageUrl!,
                                                width: 36,
                                                height: 36,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        Text(
                                          category.name,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.blueGrey[900],
                                          ),
                                        ),
                                      ],
                                    ),
                                    children: items.isNotEmpty
                                        ? items.map((MenuItem item) {
                                      // Determine if URL is valid
                                      final bool hasValidImage = item.imageUrl.startsWith('http');
                                      final Widget rawLeading = hasValidImage
                                          ? ClipRRect(
                                        borderRadius: BorderRadius.circular(7),
                                        child: Image.network(
                                          item.imageUrl,
                                          width: 42,
                                          height: 42,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                          : Icon(Icons.fastfood, color: Colors.grey[400], size: 42);

                                      return Card(
                                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                        child: ListTile(
                                          contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                                          leading: SizedBox(
                                            width: 56,
                                            child: Center(child: rawLeading),
                                          ),
                                          title: Text(
                                            item.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          subtitle: Text('RM${item.price.toStringAsFixed(2)}'),
                                          trailing: IconButton(
                                            icon: const Icon(Icons.edit, size: 24),
                                            color: Colors.indigo,
                                            tooltip: 'Edit',
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (_) => EditItemDialog(item: item),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    }).toList()
                                        : [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        child: Text(
                                          'No items in this category',
                                          style: TextStyle(color: Colors.grey[600]),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
