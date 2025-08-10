import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addDocument(
      String collection, String docId, Map<String, dynamic> data) async {
    await _db.collection(collection).doc(docId).set(data);
  }

  Future<void> deleteDocumentsWithField(
      String collection, String field, dynamic value) async {
    final QuerySnapshot snapshot =
        await _db.collection(collection).where(field, isEqualTo: value).get();

    final List<Future<void>> deleteFutures = [];
    for (final DocumentSnapshot doc in snapshot.docs) {
      deleteFutures.add(doc.reference.delete());
    }
    await Future.wait(deleteFutures);
  }

  Stream<QuerySnapshot> getMessagesStream() {
    return _db.collection('messages').snapshots();
  }
}
