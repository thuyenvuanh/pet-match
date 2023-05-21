import 'dart:io';

abstract class StorageRepository {
  void uploadImage(
    File file,
    String fileName, {
    Function(String url)? onSuccess,
    Function()? onError,
  });

}
