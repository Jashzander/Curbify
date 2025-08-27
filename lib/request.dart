import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
// import 'package:intl/intl.dart';
import 'payment.dart';
import 'theme_provider.dart';

class Request extends StatefulWidget {
  const Request({super.key, required this.company});
  final String? company;

  @override
  State<Request> createState() => _RequestState();
}

class _RequestState extends State<Request> {
  final database = FirebaseDatabase.instance.ref();
  List<String> cars = [];
  final stopwatch = Stopwatch();
  final now = DateTime.now();
  late final TwilioFlutter twilio;

  // Delete Messages
  Future<void> deleteDocumentsWithField(String field, dynamic value) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('messages')
        .where(field, isEqualTo: "+1$value")
        .get();

    final List<Future<void>> deleteFutures = [];
    for (final DocumentSnapshot doc in snapshot.docs) {
      deleteFutures.add(doc.reference.delete());
    }
    await Future.wait(deleteFutures);
  }

  List<Map<dynamic, dynamic>> _guestsList = []; // Store the original list
  List<Map<dynamic, dynamic>> _filteredGuestsList = [];

  @override
  void initState() {
    super.initState();
    fetchGuestList();
    // Initialize Twilio here with proper error handling
    try {
      twilio = TwilioFlutter(
        accountSid: const String.fromEnvironment('TWILIO_ACCOUNT_SID',
            defaultValue: ''),
        authToken:
            const String.fromEnvironment('TWILIO_AUTH_TOKEN', defaultValue: ''),
        twilioNumber:
            const String.fromEnvironment('TWILIO_NUMBER', defaultValue: ''),
      );
    } catch (e) {
      print('Failed to initialize Twilio: $e');
    }
  }

  Future<void> fetchGuestList() async {
    DatabaseEvent event =
        await database.child('${widget.company}/GuestList/').once();
    DataSnapshot snapshot = event.snapshot;
    if (snapshot.value != null) {
      final Map<dynamic, dynamic> guestsMap =
          Map.from(snapshot.value as Map<dynamic, dynamic>);

      setState(() {
        _guestsList = guestsMap.values.toList().cast<Map<dynamic, dynamic>>();
        _filteredGuestsList = _guestsList.toList();
      });
    }
  }

  String sanitizeKey(String key) {
    return key.replaceAll(RegExp(r'[.#$/\[\]]'), '_');
  }

  @override
  Widget build(BuildContext context) {
    void sendSms(String number, String smsMessage) async {
      try {
        await twilio.sendSMS(toNumber: '+1$number', messageBody: smsMessage);
      } catch (e) {
        print('Failed to send SMS: $e');
      }
    }

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final DatabaseReference guestRef =
            database.child('${widget.company}/GuestList/');
        // final DatabaseReference waitTimes =
        //     database.child('${widget.company}/Wait Time');
        // String formatter = DateFormat('yMd').format(now);
        ThemeData currentTheme = themeProvider.themeData;
        bool darkMode = currentTheme.brightness == Brightness.dark;

        return Column(
          children: [
            const SizedBox(height: 20),
            Container(
              color: darkMode
                  ? const Color.fromARGB(255, 52, 54, 66)
                  : const Color.fromARGB(255, 236, 242, 242),
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 80),
              child: const Text(
                'Pending Requests',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('messages')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  List<DocumentSnapshot> messages = snapshot.data!.docs;
                  cars.clear();
                  for (var messager in messages) {
                    if (messager['body'].toLowerCase().contains('car')) {
                      String phone = messager['from'].substring(2, 12);
                      if (!cars.contains(phone)) {
                        cars.add(phone);
                        print('Car found: $phone');
                      }
                    }
                  }

                  print('Cars list: $cars');

                  return StreamBuilder(
                    stream: guestRef.onValue,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      if (!snapshot.hasData || snapshot.data == null) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.data?.snapshot.value == null) {
                        // Handle empty state
                        return const Text('No data available.');
                      }

                      final Map<dynamic, dynamic> guestsData = snapshot
                          .data!.snapshot.value as Map<dynamic, dynamic>;
                      List<MapEntry<dynamic, dynamic>> listOfGuests = [];

                      _filteredGuestsList.forEach((guestEntry) {
                        guestsData.forEach((key, value) {
                          if (value['Status'] != 'Out' &&
                              guestEntry['Ticket ID'] == value['Ticket ID']) {
                            listOfGuests
                                .add(MapEntry<dynamic, dynamic>(key, value));
                          }
                        });
                      });

                      return ListView.builder(
                        itemCount: listOfGuests.length,
                        itemBuilder: (context, index) {
                          final dynamic key = listOfGuests[index].key;
                          final Map<dynamic, dynamic> guest =
                              listOfGuests[index].value;
                          bool validTicket = guest['Valid Ticket'];
                          bool acceptedRequest = guest['Accepted Request'];
                          bool pendingRequest = guest['Pending Request'];
                          String phone = guest['Phone'].toString();

                          for (int i = 0; i < cars.length; i++) {
                            if (phone == cars[i] &&
                                validTicket &&
                                !acceptedRequest) {
                              guestRef
                                  .child(sanitizeKey(key))
                                  .update({'Pending Request': true});
                              cars[i] = '';
                              print('Pending request updated for $phone');
                              break;
                            }
                          }

                          if (pendingRequest && !acceptedRequest) {
                            stopwatch.start();
                            return Card(
                              // color: darkMode
                              //     ? const Color.fromARGB(44, 193, 196, 244)
                              //     : const Color.fromARGB(255, 232, 232, 232),
                              color: darkMode
                                  ? (stopwatch.elapsed.inMinutes < 5
                                      ? Colors.green.shade900
                                      : (stopwatch.elapsed.inMinutes < 10
                                          ? Colors.orange.shade900
                                          : Colors.red.shade900))
                                  : (stopwatch.elapsed.inMinutes < 5
                                      ? Colors.green
                                      : (stopwatch.elapsed.inMinutes < 10
                                          ? Colors.orange
                                          : Colors.red)),
                              margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Flex(
                                  direction: Axis.horizontal,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${guest['Name']}',
                                            style:
                                                const TextStyle(fontSize: 24),
                                          ),
                                          Text(
                                            '${guest['Parking']} ${guest['Brand']} ${guest['Model']} ${guest['Color']} ${guest['License']}',
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      flex: 1,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            stopwatch.stop();
                                            guestRef
                                                .child(sanitizeKey(key))
                                                .update({
                                              'Pending Request': false,
                                              'Accepted Request': true,
                                              'Wait Time':
                                                  stopwatch.elapsed.toString()
                                            });
                                            deleteDocumentsWithField(
                                                'from', phone);
                                            print(
                                                'Request accepted for $phone');
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                        ),
                                        child: const Text("Accept"),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              // color: darkMode
              //     ? const Color.fromARGB(44, 193, 196, 244)
              //     : const Color.fromARGB(255, 232, 232, 232),
              color: darkMode
                  ? (stopwatch.elapsed.inMinutes < 5
                      ? Colors.green.shade900
                      : (stopwatch.elapsed.inMinutes < 10
                          ? Colors.orange.shade900
                          : Colors.red.shade900))
                  : (stopwatch.elapsed.inMinutes < 5
                      ? Colors.green
                      : (stopwatch.elapsed.inMinutes < 10
                          ? Colors.orange
                          : Colors.red)),
              padding: const EdgeInsets.fromLTRB(80, 5, 80, 5),
              child: const Text('Accepted Requests',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                  )),
            ),
            Expanded(
              flex: 1,
              child: StreamBuilder(
                stream: guestRef
                    .orderByChild('Accepted Request')
                    .equalTo(true)
                    .onValue,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.data?.snapshot.value == null) {
                    // Handle empty state
                    return const Text('No data available.');
                  }

                  final Map<dynamic, dynamic> guestsData =
                      snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  List<MapEntry<dynamic, dynamic>> listOfGuests = [];

                  guestsData.forEach((key, value) {
                    listOfGuests.add(MapEntry<dynamic, dynamic>(key, value));
                  });

                  return ListView.builder(
                    itemCount: listOfGuests.length,
                    itemBuilder: (context, index) {
                      final dynamic key = listOfGuests[index].key;
                      final Map<dynamic, dynamic> guest =
                          listOfGuests[index].value;
                      bool acceptedRequest = guest['Accepted Request'];
                      bool pendingRequest = guest['Pending Request'];

                      void promptRoomNumber() {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            TextEditingController roomController =
                                TextEditingController();
                            return AlertDialog(
                              title: const Text("Enter Room Number"),
                              content: TextField(
                                controller: roomController,
                                decoration: const InputDecoration(
                                    hintText: "Room Number"),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    guest['Room'] = roomController.text;
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Submit"),
                                ),
                              ],
                            );
                          },
                        );
                      }

                      void redirectToSquare() {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Payment(
                                      company: widget.company,
                                    )));
                      }

                      void handleDoneButton() {
                        String guestWaitTime = guest['Wait Time'];
                        if (guest['Rate Type'] == 'Overnight') {
                          // Step 3
                          if (guest['Room'] == 'BLANK') {
                            // Step 4
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title:
                                      const Text("Checking Out or Returning?"),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text(
                                                    "Select an Option"),
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        // Skip logic
                                                        stopwatch.stop();
                                                        sendSms(
                                                            guest['Phone']
                                                                .toString(),
                                                            "Thanks for using Curbify! Please fill out this survey. Your feedback matters https://docs.google.com/forms/d/e/1FAIpQLScMb-HM_4-vBCYUVHNyCG5MBuQVRZGO0w9GhiQficnu35LU1g/viewform");
                                                        guestRef
                                                            .child(sanitizeKey(
                                                                key))
                                                            .update({
                                                          'Accepted Request':
                                                              false,
                                                          'Status': 'Out',
                                                          'Valid Ticket': false,
                                                          'Wait Time': stopwatch
                                                                  .elapsed
                                                                  .toString() +
                                                              guestWaitTime,
                                                          'Room': 'N/A',
                                                          'Amount': 'N/A'
                                                        });
                                                      },
                                                      child: const Text("Skip"),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        stopwatch.stop();
                                                        sendSms(
                                                            guest['Phone']
                                                                .toString(),
                                                            "Thanks for using Curbify! Please fill out this survey. Your feedback matters https://docs.google.com/forms/d/e/1FAIpQLScMb-HM_4-vBCYUVHNyCG5MBuQVRZGO0w9GhiQficnu35LU1g/viewform");
                                                        guestRef
                                                            .child(sanitizeKey(
                                                                key))
                                                            .update({
                                                          'Accepted Request':
                                                              false,
                                                          'Status': 'Out',
                                                          'Valid Ticket': false,
                                                          'Wait Time': stopwatch
                                                                  .elapsed
                                                                  .toString() +
                                                              guestWaitTime,
                                                          'Room': 'Square'
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                        redirectToSquare();
                                                      },
                                                      child:
                                                          const Text("Payment"),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        stopwatch.stop();
                                                        sendSms(
                                                            guest['Phone']
                                                                .toString(),
                                                            "Thanks for using Curbify! Please fill out this survey. Your feedback matters https://docs.google.com/forms/d/e/1FAIpQLScMb-HM_4-vBCYUVHNyCG5MBuQVRZGO0w9GhiQficnu35LU1g/viewform");
                                                        guestRef
                                                            .child(sanitizeKey(
                                                                key))
                                                            .update({
                                                          'Accepted Request':
                                                              false,
                                                          'Status': 'Out',
                                                          'Valid Ticket': false,
                                                          'Wait Time': stopwatch
                                                                  .elapsed
                                                                  .toString() +
                                                              guestWaitTime,
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                        promptRoomNumber();
                                                      },
                                                      child: const Text("Room"),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: const Text("Checking Out"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text(
                                                    "Select an Option"),
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        stopwatch.stop();
                                                        sendSms(
                                                            guest['Phone']
                                                                .toString(),
                                                            "Thanks for using Curbify! Please fill out this survey. Your feedback matters https://docs.google.com/forms/d/e/1FAIpQLScMb-HM_4-vBCYUVHNyCG5MBuQVRZGO0w9GhiQficnu35LU1g/viewform");
                                                        Navigator.of(context)
                                                            .pop();
                                                        // Skip logic
                                                        guestRef
                                                            .child(sanitizeKey(
                                                                key))
                                                            .update({
                                                          'Accepted Request':
                                                              false,
                                                          'Status': 'Returning',
                                                          'Wait Time': stopwatch
                                                                  .elapsed
                                                                  .toString() +
                                                              guestWaitTime,
                                                        });
                                                      },
                                                      child: const Text("Skip"),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        stopwatch.stop();
                                                        sendSms(
                                                            guest['Phone']
                                                                .toString(),
                                                            "Thanks for using Curbify! Please fill out this survey. Your feedback matters https://docs.google.com/forms/d/e/1FAIpQLScMb-HM_4-vBCYUVHNyCG5MBuQVRZGO0w9GhiQficnu35LU1g/viewform");
                                                        guestRef
                                                            .child(sanitizeKey(
                                                                key))
                                                            .update({
                                                          'Accepted Request':
                                                              false,
                                                          'Status': 'Returning',
                                                          'Wait Time': stopwatch
                                                                  .elapsed
                                                                  .toString() +
                                                              guestWaitTime,
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                        promptRoomNumber();
                                                      },
                                                      child: const Text("Room"),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: const Text("Returning"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          } else {
                            // Room is not blank
                            if (guest['Status'] == 'Checking Out') {
                              stopwatch.stop();
                              sendSms(guest['Phone'].toString(),
                                  "Thanks for using Curbify! Please fill out this survey. Your feedback matters https://docs.google.com/forms/d/e/1FAIpQLScMb-HM_4-vBCYUVHNyCG5MBuQVRZGO0w9GhiQficnu35LU1g/viewform");
                              guestRef.child(sanitizeKey(key)).update({
                                'Accepted Request': false,
                                'Status': 'Out',
                                'Valid Ticket': false,
                                'Wait Time': stopwatch.elapsed.toString() +
                                    guestWaitTime,
                              });
                            } else if (guest['Status'] == 'Returning') {
                              stopwatch.stop();
                              sendSms(guest['Phone'].toString(),
                                  "Thanks for using Curbify! Please fill out this survey. Your feedback matters https://docs.google.com/forms/d/e/1FAIpQLScMb-HM_4-vBCYUVHNyCG5MBuQVRZGO0w9GhiQficnu35LU1g/viewform");
                              guestRef.child(sanitizeKey(key)).update({
                                'Accepted Request': false,
                                'Status': 'Returning',
                                'Wait Time': stopwatch.elapsed.toString() +
                                    guestWaitTime,
                              });
                            }
                          }
                        } else {
                          // Step 2: hourly rate
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Select an Option"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ElevatedButton(
                                      onPressed: () {
                                        stopwatch.stop();
                                        sendSms(guest['Phone'].toString(),
                                            "Thanks for using Curbify! Please fill out this survey. Your feedback matters https://docs.google.com/forms/d/e/1FAIpQLScMb-HM_4-vBCYUVHNyCG5MBuQVRZGO0w9GhiQficnu35LU1g/viewform");
                                        Navigator.of(context).pop();
                                        // Skip logic
                                        guestRef
                                            .child(sanitizeKey(key))
                                            .update({
                                          'Accepted Request': false,
                                          'Status': 'Out',
                                          'Valid Ticket': false,
                                          'Wait Time':
                                              stopwatch.elapsed.toString() +
                                                  guestWaitTime,
                                          'Room': 'N/A',
                                          'Amount': 'N/A'
                                        });
                                      },
                                      child: const Text("Skip"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        stopwatch.stop();
                                        sendSms(guest['Phone'].toString(),
                                            "Thanks for using Curbify! Please fill out this survey. Your feedback matters https://docs.google.com/forms/d/e/1FAIpQLScMb-HM_4-vBCYUVHNyCG5MBuQVRZGO0w9GhiQficnu35LU1g/viewform");
                                        guestRef
                                            .child(sanitizeKey(key))
                                            .update({
                                          'Accepted Request': false,
                                          'Status': 'Out',
                                          'Valid Ticket': false,
                                          'Wait Time':
                                              stopwatch.elapsed.toString() +
                                                  guestWaitTime,
                                          'Room': 'Square'
                                        });
                                        Navigator.of(context).pop();
                                        redirectToSquare();
                                      },
                                      child: const Text("Square"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        stopwatch.stop();
                                        sendSms(guest['Phone'].toString(),
                                            "Thanks for using Curbify! Please fill out this survey. Your feedback matters https://docs.google.com/forms/d/e/1FAIpQLScMb-HM_4-vBCYUVHNyCG5MBuQVRZGO0w9GhiQficnu35LU1g/viewform");
                                        guestRef
                                            .child(sanitizeKey(key))
                                            .update({
                                          'Accepted Request': false,
                                          'Status': 'Out',
                                          'Valid Ticket': false,
                                          'Wait Time':
                                              stopwatch.elapsed.toString() +
                                                  guestWaitTime,
                                        });
                                        Navigator.of(context).pop();
                                        promptRoomNumber();
                                      },
                                      child: const Text("Room"),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        }
                      }

                      if (acceptedRequest && !pendingRequest) {
                        stopwatch.start();
                        return Card(
                          color: darkMode
                              ? const Color.fromARGB(44, 193, 196, 244)
                              : const Color.fromARGB(255, 232, 232, 232),
                          margin: const EdgeInsets.fromLTRB(
                              10, 5, 10, 5), // Reduced margin
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Flex(
                              direction: Axis.horizontal,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${guest['Name']}',
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                      Text(
                                        '${guest['Phone']} ${guest['Parking']} ${guest['Brand']} ${guest['Model']} ${guest['Color']} ${guest['License']}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                    flex: 1,
                                    child: Timers(
                                        initialElapsedString:
                                            guest['Wait Time'].toString())),
                                Expanded(
                                  flex: 1,
                                  child: ElevatedButton(
                                    onPressed: handleDoneButton,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                    child: const Text("Done"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// Timer
class Timers extends StatefulWidget {
  final String initialElapsedString;

  Timers({super.key, required this.initialElapsedString});

  @override
  State<Timers> createState() => _TimersState();
}

class _TimersState extends State<Timers> {
  late Stopwatch stopwatch;
  Timer? timer;
  late Duration initialElapsed;

  @override
  void initState() {
    super.initState();
    stopwatch = Stopwatch();
    initialElapsed = parseDuration(widget.initialElapsedString);
    startTimer();
  }

  Duration parseDuration(String durationString) {
    List<String> parts = durationString.split(':');
    int hours = 0;
    int minutes = 0;
    int seconds = 0;
    if (parts.length > 0) hours = int.parse(parts[0]);
    if (parts.length > 1) minutes = int.parse(parts[1]);
    if (parts.length > 2) seconds = int.parse(parts[2]);
    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }

  void updateTime() {
    setState(() {});
  }

  void startTimer() {
    stopwatch.start();
    timer = Timer.periodic(const Duration(seconds: 1), (_) => updateTime());
  }

  void stopTimer() {
    stopwatch.stop();
    timer?.cancel();
  }

  @override
  void dispose() {
    stopwatch.stop();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalElapsedMinutes =
        stopwatch.elapsed.inMinutes + initialElapsed.inMinutes;
    return Text(
      "$totalElapsedMinutes min",
      textAlign: TextAlign.center,
      // style: TextStyle(
      //   color: getColor(totalElapsedMinutes),
      // )
    );
  }
}
