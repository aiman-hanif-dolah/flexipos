import 'package:flutter/material.dart';
import '../services/nfc_service.dart';
import 'order_screen.dart';

/// Screen for a waiter to assign a table by scanning NFC or QR code.
/// For simplicity, the QR option uses a manual input dialog as a placeholder for scanning.
class TableScanScreen extends StatefulWidget {
  @override
  _TableScanScreenState createState() => _TableScanScreenState();
}

class _TableScanScreenState extends State<TableScanScreen> {
  String _statusMessage = 'No table selected';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Table'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display status or last scanned table ID
            Text(_statusMessage),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Scan NFC Tag'),
              onPressed: () async {
                // Read NFC tag to get table ID
                String? tableId = await NfcService.readNFCTag();
                if (tableId != null) {
                  // Navigate to order screen for this table
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderScreen(tableId: tableId),
                    ),
                  );
                } else {
                  setState(() {
                    _statusMessage = 'NFC read failed or canceled.';
                  });
                }
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('Enter Table ID (QR)'),
              onPressed: () {
                // Show dialog to input table ID manually
                showDialog(
                  context: context,
                  builder: (context) {
                    String inputId = '';
                    return AlertDialog(
                      title: Text('Enter Table ID'),
                      content: TextField(
                        onChanged: (value) => inputId = value,
                        decoration: InputDecoration(hintText: "Table ID"),
                      ),
                      actions: [
                        TextButton(
                          child: Text('Cancel'),
                          onPressed: () => Navigator.pop(context),
                        ),
                        ElevatedButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.pop(context);
                            if (inputId.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OrderScreen(tableId: inputId),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// End of table_scan_screen.dart file.
