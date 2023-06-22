import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageDataSource {
  final fsi = FirebaseStorage.instance;

  Future<String> uploadFile(File file, String refPath) async {
    var fileName = path.basename(file.path);
    final storageRef = fsi.ref().child('$refPath/$fileName');
    final uploadTask = storageRef.putFile(file);
    final taskSnapshot = await uploadTask.whenComplete(() {});
    final url = await taskSnapshot.ref.getDownloadURL();
    return url;
  }

  Future<List<String>> uploadImages(
    List<File> images,
    String refPath,
  ) async {
    if (images.isEmpty) return List.empty();

    List<String> downloadUrls = [];

    await Future.forEach(images, (image) async {
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('$refPath/${getFileName(image)}');
      final UploadTask uploadTask = ref.putFile(image);
      final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
      final url = await taskSnapshot.ref.getDownloadURL();
      downloadUrls.add(url);
    });

    return downloadUrls;
  }

  String getFileName(File file) {
    return file.path.substring(file.path.lastIndexOf("/"));
  }
}
