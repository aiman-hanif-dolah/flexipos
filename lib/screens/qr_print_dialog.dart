import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class QRPrintDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<String> tableNumbers = List.generate(10, (i) => (i + 1).toString());
    final double maxHeight = MediaQuery.of(context).size.height * 0.65;

    return Dialog(
      backgroundColor: Colors.white.withOpacity(0.94),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        padding: const EdgeInsets.all(22.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'QR Codes for All Tables',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: tableNumbers.length,
                itemBuilder: (context, index) {
                  final tableId = tableNumbers[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          color: Colors.white,
                          child: QrImageView(
                            data: tableId,
                            version: QrVersions.auto,
                            size: 84,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        SizedBox(width: 18),
                        Text(
                          'Table $tableId',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(width: 12),
                        IconButton(
                          icon: Icon(Icons.share, color: Colors.blue),
                          tooltip: "Share/Save QR",
                          onPressed: () async {
                            await _shareQrAsImage(context, tableId);
                          },
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                child: Text("Close"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _shareQrAsImage(BuildContext context, String tableId) async {
    try {
      final qrValidationResult = QrValidator.validate(
        data: tableId,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );
      final qrCode = qrValidationResult.qrCode;
      final painter = QrPainter.withQr(
        qr: qrCode!,
        color: const Color(0xFF000000),
        emptyColor: const Color(0xFFFFFFFF),
        gapless: true,
      );
      final picData = await painter.toImageData(400);
      final bytes = picData!.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/table_${tableId}_qr.png').create();
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'QR code for Table $tableId',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to share QR: $e")),
      );
    }
  }
}
