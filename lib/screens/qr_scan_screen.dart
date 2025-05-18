import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScanScreen extends StatefulWidget {
  final void Function(String tableId) onTableIdScanned;
  QRScanScreen({required this.onTableIdScanned});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  bool _scanned = false;
  Timer? _timer;

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return; // Prevent duplicate reads
    final barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
        setState(() => _scanned = true);
        // Flash green overlay for 500ms, then pop
        _timer = Timer(Duration(milliseconds: 500), () {
          widget.onTableIdScanned(barcode.rawValue!);
          if (mounted) Navigator.of(context).pop();
        });
        break;
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double overlayOpacity = _scanned ? 0.6 : 0.0;
    final Color overlayColor = _scanned ? Colors.greenAccent : Colors.transparent;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Scan Table QR'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          MobileScanner(
            fit: BoxFit.cover,
            onDetect: _onDetect,
          ),
          // Soft focus overlay for scan area
          IgnorePointer(
            child: Center(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white70, width: 3.3),
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.black.withOpacity(0.12),
                      Colors.black.withOpacity(0.18),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.21),
                      blurRadius: 25,
                      offset: Offset(0, 8),
                    )
                  ],
                ),
              ),
            ),
          ),
          // Glass info/instruction panel at the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 30, left: 14, right: 14),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 400),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.indigo.withOpacity(0.11), width: 1.3),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 18, horizontal: 22),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.qr_code_scanner, color: Colors.blueAccent, size: 30),
                        SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            _scanned ? 'QR Detected! Redirecting...' : 'Point camera at table QR code',
                            style: TextStyle(
                              color: _scanned ? Colors.green[800] : Colors.blueGrey[900],
                              fontSize: 17.7,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Success overlay
          AnimatedOpacity(
            duration: Duration(milliseconds: 180),
            opacity: overlayOpacity,
            child: Container(
              color: overlayColor,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ],
      ),
    );
  }
}
