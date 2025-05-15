import 'package:flutter/material.dart';
import 'menu_editor_screen.dart';
import 'table_scan_screen.dart';
import 'kitchen_screen.dart';

/// MainMenu is the landing screen after app launch (no login required).
/// The user chooses one of three roles:
///   - Menu Editor: allows shops to create/edit categories and items dynamically.
///   - Waiter Interface: scan table NFC/QR and place orders.
///   - Kitchen Interface: display incoming orders to kitchen staff.
/// Each selection navigates to the corresponding screen via Navigator.
/// Note: No authentication is implemented, so all roles are freely accessible.
class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('POS Main Menu'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Navigate to the menu editor screen for admin tasks
            ElevatedButton(
              child: Text('Menu Editor'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MenuEditorScreen()),
                );
              },
            ),
            SizedBox(height: 16),
            // Navigate to the waiter interface (table scan and order)
            ElevatedButton(
              child: Text('Waiter Interface'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TableScanScreen()),
                );
              },
            ),
            SizedBox(height: 16),
            // Navigate to the kitchen interface (order list)
            ElevatedButton(
              child: Text('Kitchen Interface'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => KitchenScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// End of main_menu.dart file.
