import 'dart:io';
import 'dart:developer' as dev;

// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageDataSource {
  final fsi = FirebaseStorage.instance;

  void uploadFile(
    File file, 
    String refPath, {
    Function(String url)? onSuccess,
    Function()? onError,
  }) async {
    var fileName = path.basename(file.path);
    final storageRef = fsi.ref().child('$refPath/$fileName');
    final uploadTask = storageRef.putFile(file);
    uploadTask.snapshotEvents.listen((task) async {
      switch (task.state) {
        case TaskState.paused:
          dev.log("Upload is paused.");
          break;
        case TaskState.running:
          final progress = 100.0 * (task.bytesTransferred / task.totalBytes);
          dev.log('Uploaded $progress');
          break;
        case TaskState.success:
          if (onSuccess != null) {
            await onSuccess(await storageRef.getDownloadURL());
          } else {
            dev.log('no onSuccess callback defined');
          }
          break;
        case TaskState.canceled:
          dev.log("Upload was canceled");
          break;
        case TaskState.error:
          if (onError != null) {
            await onError();
          } else {
            dev.log('no onError callback defined');
          }
          dev.log("Upload failed");
          break;
      }
    });
  }
}
