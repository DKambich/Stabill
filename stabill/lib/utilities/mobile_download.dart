import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

Future<void> downloadFile(String fileName, String fileContents) async {
  const String exportPath = '/storage/emulated/0/Download/Stabill/Exports';
  // Check if the app has permission to export the file
  if (await Permission.storage.request().isGranted &&
      await Permission.manageExternalStorage.request().isGranted) {
    // Create a the file
    final File file = File('$exportPath/$fileName');
    file.createSync(recursive: true);
    // Create the CSV from the Account data and write it to the file
    file.writeAsStringSync(fileContents);
  }
}
