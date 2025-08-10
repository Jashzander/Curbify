import 'package:firebase_database/firebase_database.dart';

class RealtimeDBService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  DatabaseReference get aRef => _db.ref();

  Future<DataSnapshot> getGuestList(String company) async {
    DatabaseEvent event = await _db.ref().child('$company/GuestList/').once();
    return event.snapshot;
  }

  DatabaseReference getGuestListRef(String company) {
    return _db.ref().child('$company/GuestList/');
  }

  Stream<DatabaseEvent> getGuestListStream(String company) {
    return _db.ref().child('$company/GuestList/').onValue;
  }

  Future<void> updateGuest(
      String company, String key, Map<String, Object?> data) {
    return _db.ref().child('$company/GuestList/$key').update(data);
  }
}
