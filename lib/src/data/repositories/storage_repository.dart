import 'dart:io';

import 'package:pet_match/src/data/datasources/remote/firebase_storage_datasource.dart';
import 'package:pet_match/src/domain/repositories/storage_repository.dart';

class StorageRepositoryImpl implements StorageRepository {
  final FirebaseStorageDataSource dataSource;

  StorageRepositoryImpl(this.dataSource);

  @override
  Future<String> uploadImage(File file, String refPath) async {
    return await dataSource.uploadFile(file, refPath);
  }

  @override
  Future<List<String>> uploadMultipleImages(
      List<File> images, String refPath) async {
    return await dataSource.uploadImages(images, refPath);
  }
}
