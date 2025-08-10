import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/realtimedb_service.dart';
import '../services/twilio_service.dart';

class RequestViewModel extends ChangeNotifier {
  final TwilioService _twilioService = TwilioService();
  final FirestoreService _firestoreService = FirestoreService();
  final RealtimeDBService _realtimeDBService = RealtimeDBService();

  final List<String> _cars = [];
  List<Map<dynamic, dynamic>> _guestsList = [];
  List<Map<dynamic, dynamic>> _filteredGuestsList = [];
  final Stopwatch _stopwatch = Stopwatch();

  List<String> get cars => _cars;
  List<Map<dynamic, dynamic>> get guestsList => _guestsList;
  List<Map<dynamic, dynamic>> get filteredGuestsList => _filteredGuestsList;
  Stopwatch get stopwatch => _stopwatch;

  Stream<QuerySnapshot> get messagesStream =>
      _firestoreService.getMessagesStream();

  Stream<DatabaseEvent> getGuestListStream(String company) =>
      _realtimeDBService.getGuestListStream(company);

  Future<void> fetchGuestList(String company) async {
    DataSnapshot snapshot = await _realtimeDBService.getGuestList(company);
    if (snapshot.value != null) {
      final Map<dynamic, dynamic> guestsMap =
          Map.from(snapshot.value as Map<dynamic, dynamic>);
      _guestsList = guestsMap.values.toList().cast<Map<dynamic, dynamic>>();
      _filteredGuestsList = _guestsList.toList();
      notifyListeners();
    }
  }

  void updateCars(List<DocumentSnapshot> messages) {
    _cars.clear();
    for (var messager in messages) {
      if (messager['body'].toLowerCase().contains('car')) {
        String phone = messager['from'].substring(2, 12);
        if (!_cars.contains(phone)) {
          _cars.add(phone);
        }
      }
    }
    notifyListeners();
  }

  void updatePendingRequest(String company, String key) {
    _realtimeDBService.updateGuest(company, key, {'Pending Request': true});
  }

  void acceptRequest(String company, String key, String phone) {
    _stopwatch.stop();
    _realtimeDBService.updateGuest(company, key, {
      'Pending Request': false,
      'Accepted Request': true,
      'Wait Time': _stopwatch.elapsed.toString(),
    });
    _firestoreService.deleteDocumentsWithField('messages', 'from', "+1$phone");
    notifyListeners();
  }

  String sanitizeKey(String key) {
    return key.replaceAll(RegExp(r'[.#$/\[\]]'), '_');
  }

  void sendSms(String number, String message) {
    _twilioService.sendSms(toNumber: number, message: message);
  }
}
