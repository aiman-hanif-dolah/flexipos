import 'package:nfc_manager/nfc_manager.dart';

/// Service class for NFC operations (Android only).
class NfcService {
  /// Starts an NFC session and reads the first text record from a tag.
  /// Returns the text content or null if not found.
  static Future<String?> readNFCTag() async {
    String? result;
    // Check if NFC is available on device
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      print('NFC not available');
      return null;
    }
    await NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      // Attempt to parse NDEF data from the tag
      final ndef = Ndef.from(tag);
      if (ndef != null) {
        // Read the NDEF message
        NdefMessage message = await ndef.read();
        if (message.records.isNotEmpty) {
          // Assuming first record contains text payload
          final NdefRecord record = message.records.first;
          final payload = record.payload;
          // payload format: [status byte, language code, text]
          if (payload.length > 3) {
            // Decode text content after the language code
            result = String.fromCharCodes(payload.sublist(3));
          }
        }
      }
      // Stop the session after reading
      await NfcManager.instance.stopSession();
    });
    return result;
  }

  /// Writes a text record containing [tableId] to an NFC tag.
  /// The [tableId] is the identifier (e.g., table number) to encode on the tag.
  static Future<void> writeNFCTag(String tableId) async {
    await NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      final ndef = Ndef.from(tag);
      if (ndef == null) {
        print('NDEF not supported on this tag');
      } else {
        try {
          // Create an NDEF message with a text record
          NdefMessage message = NdefMessage([
            NdefRecord.createText(tableId),
          ]);
          // Write the message to the tag
          await ndef.write(message);
          print('NFC write successful: $tableId');
        } catch (e) {
          print('Error writing to NFC tag: $e');
        }
      }
      // Always stop the session after attempt
      await NfcManager.instance.stopSession();
    });
  }
}

/// End of nfc_service.dart
