import 'dart:io';

abstract class StorageRepository {
  void uploadImage(
    File file, 
    String refPath, {
    Function(String url)? onSuccess,
    Function()? onError,
  });
}
