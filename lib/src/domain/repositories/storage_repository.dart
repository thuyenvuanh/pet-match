import 'dart:io';

abstract class StorageRepository {
  Future<String> uploadImage(File file, String refPath);

  Future<List<String>> uploadMultipleImages(
    List<File> images,
    String refPath,
  );
}
