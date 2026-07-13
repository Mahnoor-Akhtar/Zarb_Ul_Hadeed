import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

Future<void> saveAndDownloadFile({
  required String filename,
  required Uint8List bytes,
  required String mimeType,
}) async {
  Directory? directory;
  try {
    if (Platform.isAndroid || Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      directory = await getDownloadsDirectory();
    }
  } catch (e) {
    directory = await getApplicationDocumentsDirectory();
  }
  
  directory ??= await getApplicationDocumentsDirectory();
  
  final file = File('${directory.path}/$filename');
  await file.writeAsBytes(bytes, flush: true);
}
