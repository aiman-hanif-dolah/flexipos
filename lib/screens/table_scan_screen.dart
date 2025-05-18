import 'dart:io';
import 'dart:ui';
import 'package:flexipos/screens/qr_print_dialog.dart';
import 'package:flexipos/screens/qr_scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import '../ui/background.dart';
import 'order_screen.dart';
import '../services/firestore_service.dart';
import '../widgets/animated_web_background.dart'; // Use your animated or premium background

class TableScanScreen extends StatefulWidget {
  @override
  _TableScanScreenState createState() => _TableScanScreenState();
}

class _TableScanScreenState extends State<TableScanScreen> {
  String _statusMessage = 'No table selected';
  String? _selectedTableNumber; // 1-10 as string

  final FirestoreService firestoreService = FirestoreService();

  void _onOkPressed() {
    String? tableId = _selectedTableNumber;
    if (tableId == null || tableId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a Table Number')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderScreen(tableId: tableId),
      ),
    );
  }

  Future<void> _assignTableToTag() async {
    String? tableId = _selectedTableNumber;
    if (tableId == null || tableId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a Table Number to assign')),
      );
      return;
    }
    setState(() {
      _statusMessage = 'Tap NFC tag to assign table...';
    });
    try {
      NFCTag tag = await FlutterNfcKit.poll();
      String uid = tag.id ?? "";
      if (uid.isEmpty) throw Exception("Failed to read UID");
      await firestoreService.assignTableToTag(uid, tableId);
      await FlutterNfcKit.finish();
      setState(() {
        _statusMessage = 'Table $tableId assigned to tag ($uid)!';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Table $tableId assigned to tag!')),
      );
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to assign: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to assign tag.')),
      );
    }
  }

  Future<void> _scanNfcTag() async {
    setState(() {
      _statusMessage = 'Tap NFC tag to scan...';
    });
    try {
      NFCTag tag = await FlutterNfcKit.poll();
      String uid = tag.id ?? "";
      if (uid.isEmpty) throw Exception("Failed to read UID");
      String? tableId = await firestoreService.getTableForTag(uid);
      await FlutterNfcKit.finish();
      if (tableId != null && tableId.isNotEmpty) {
        setState(() {
          _statusMessage = 'Table $tableId scanned (from tag $uid)!';
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderScreen(tableId: tableId),
          ),
        );
      } else {
        setState(() {
          _statusMessage = 'Tag not assigned to any table!';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tag not assigned to any table!')),
        );
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Scan failed: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scan failed or canceled.')),
      );
    }
  }

  Future<void> _scanQrTable(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => QRScanScreen(
        onTableIdScanned: (String tableId) {
          setState(() {
            _statusMessage = 'Scanned QR for Table $tableId';
            _selectedTableNumber = tableId;
          });
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => OrderScreen(tableId: tableId)),
          );
        },
      )),
    );
  }

  Future<void> _showGenerateQrDialog() async {
    showDialog(
      context: context,
      builder: (_) => QRPrintDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth = MediaQuery.of(context).size.width * 0.95;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background
          const AnimatedWebBackground(), // import your background widget here!
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 50.0, horizontal: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(38),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
                    child: Container(
                      width: cardWidth,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.23),
                        borderRadius: BorderRadius.circular(38),
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.12),
                          width: 1.7,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.09),
                            blurRadius: 26,
                            offset: Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Status Message
                            Text(
                              _statusMessage,
                              style: TextStyle(
                                fontSize: 17.5,
                                color: Colors.blueGrey[900]?.withOpacity(0.85),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                                shadows: [
                                  Shadow(
                                    blurRadius: 3,
                                    color: Colors.white.withOpacity(0.14),
                                    offset: Offset(1, 2),
                                  )
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 24),
                            Text(
                              'Select Table Number',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo[700],
                                letterSpacing: 0.6,
                                shadows: [
                                  Shadow(
                                    blurRadius: 4,
                                    color: Colors.white.withOpacity(0.13),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: 18),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 18,
                              runSpacing: 18,
                              children: List.generate(10, (index) {
                                final tableNumber = (index + 1).toString();
                                final selected = _selectedTableNumber == tableNumber;
                                return AnimatedContainer(
                                  duration: Duration(milliseconds: 180),
                                  curve: Curves.easeInOut,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: selected ? Colors.blue : Colors.white,
                                      foregroundColor: selected ? Colors.white : Colors.blueGrey[800],
                                      shadowColor: Colors.blue.withOpacity(selected ? 0.20 : 0),
                                      elevation: selected ? 6 : 1.5,
                                      padding: EdgeInsets.symmetric(horizontal: 28, vertical: 22),
                                      shape: CircleBorder(
                                        side: BorderSide(
                                            color: selected ? Colors.blue : Colors.blueGrey[100]!, width: selected ? 2.5 : 1.2),
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _selectedTableNumber = tableNumber;
                                      });
                                    },
                                    child: Text(
                                      tableNumber,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            SizedBox(height: 36),
                            // Actions
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildActionButton(
                                  context,
                                  icon: Icons.playlist_add_check,
                                  label: 'OK',
                                  color: Colors.indigo,
                                  onPressed: _onOkPressed,
                                ),
                                SizedBox(height: 14),
                                _buildActionButton(
                                  context,
                                  icon: Icons.qr_code_scanner,
                                  label: 'Scan Table QR',
                                  color: Colors.amber[800]!,
                                  onPressed: () => _scanQrTable(context),
                                ),
                                SizedBox(height: 14),
                                _buildActionButton(
                                  context,
                                  icon: Icons.print,
                                  label: 'Generate Table QR Codes',
                                  color: Colors.orange,
                                  onPressed: _showGenerateQrDialog,
                                ),
                                SizedBox(height: 14),
                                _buildActionButton(
                                  context,
                                  icon: Icons.nfc,
                                  label: 'Scan NFC Tag',
                                  color: Colors.deepPurple,
                                  onPressed: _scanNfcTag,
                                ),
                                SizedBox(height: 14),
                                _buildActionButton(
                                  context,
                                  icon: Icons.edit,
                                  label: 'Assign Table to NFC Tag',
                                  color: Colors.teal,
                                  onPressed: _assignTableToTag,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context,
      {required IconData icon, required String label, required Color color, required VoidCallback onPressed}) {
    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 22),
        label: Text(
          label,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: 0.6),
        ),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.89),
          foregroundColor: Colors.white,
          shape: StadiumBorder(),
          elevation: 3,
          shadowColor: color.withOpacity(0.17),
        ),
      ),
    );
  }
}
