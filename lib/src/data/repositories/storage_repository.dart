import 'dart:io';

import 'package:pet_match/src/data/datasources/remote/firebase_storage_datasource.dart';
import 'package:pet_match/src/domain/repositories/storage_repository.dart';

class StorageRepositoryImpl implements StorageRepository {
  final FirebaseStorageDataSource dataSource;

  StorageRepositoryImpl(this.dataSource);

  @override
  void uploadImage(
    File file,
    String refPath, {
    Function(String url)? onSuccess,
    Function()? onError,
  }) {
    dataSource.uploadFile(
      file,
      refPath,
      onError: onError,
      onSuccess: onSuccess,
    );
  }
}
