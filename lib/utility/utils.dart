import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class Utils{
  static Future<File> saveImage(takenImagePath) async {
    try {
      final File originalFile = File(takenImagePath);
      final File newFile = await _localFile;
      return originalFile.copy(newFile.path);
    } catch (e) {
      print("Error saving image: $e");
      rethrow;
    }
  }


  static Future<File> get _localFile async {
    final path = await _localPath;
    // Use a timestamp or random number to generate a unique file name
    String fileName = 'saved_image_${DateTime.now().millisecondsSinceEpoch}.png';
    return File('$path/$fileName');
  }

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<String> get _externalPath async {
    final directory = await getExternalStorageDirectory();
    return directory!.path;
  }


  static Future<void> saveFileToExternalStorage(String takenImagePath) async {
    try {
      final String path = await _externalPath;
      final File originalFile = File(takenImagePath);
      final String fileName = 'saved_image_${DateTime.now().millisecondsSinceEpoch}.png';
      final File newFile = File('$path/$fileName');

      await originalFile.copy(newFile.path);
      print("File saved at ${newFile.path}");
    } catch (e) {
      print("Error: $e");
    }
  }

  static Future<Map<String, dynamic>> saveImageToGallery(String filePath) async {
    try {
      final File file = File(filePath);
      final Uint8List bytes = await file.readAsBytes();
      const platform = MethodChannel('mediastore');

      final int? mediaId = await platform.invokeMethod('saveImageToGallery', {'bytes': bytes, 'fileName': file.uri.pathSegments.last});
      if (mediaId == null) throw 'Failed to get media ID';

      return {
        'filePath': 'content://media/external/images/media/$mediaId',
        'errorMessage': null,
        'isSuccess': true,
      };
    } catch (e) {
      return {
        'filePath': null,
        'errorMessage': e.toString(),
        'isSuccess': false,
      };
    }
  }

}