import 'dart:io' as io;
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<String> uploadMenuImage({
  io.File? imageFile,
  Uint8List? webBytes,
  required String fileName,
}) async {
  final ref = FirebaseStorage.instance.ref().child('menu_images/$fileName');
  UploadTask uploadTask;
  if (kIsWeb && webBytes != null) {
    uploadTask = ref.putData(webBytes);
  } else if (!kIsWeb && imageFile != null) {
    uploadTask = ref.putFile(imageFile);
  } else {
    throw Exception('No image data');
  }
  final snapshot = await uploadTask.whenComplete(() {});
  return await snapshot.ref.getDownloadURL();
}
