import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class StorageService {
  final firebase_storage.FirebaseStorage _storage =
      firebase_storage.FirebaseStorage.instance;

  Future<String> uploadImage(File imageFile, String fileName) async {
    try {
      var storageRef = _storage.ref().child(fileName);
      var uploadTask = storageRef.putFile(imageFile);
      var snapshot = await uploadTask.whenComplete(() => null);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      // Error uploading image: e
      return '';
    }
  }
}
