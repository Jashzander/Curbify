// contains DB functions
import 'package:cloud_firestore/cloud_firestore.dart';

var db = FirebaseFirestore.instance;

//PUT a new document with a randomly generated ID
void addValue(ticketID, document) async {
  // input template:
  // final user = <String, dynamic>{
  //   "first": "Haashim",
  //   "last": "Lovelace",
  //   "born": 1815
  // };

  db.collection("ticket").doc(ticketID).set(document);
}
