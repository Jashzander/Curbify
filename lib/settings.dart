import 'dart:async';
import 'package:pdf/widgets.dart' as pw;
import 'package:firebase_database/firebase_database.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'payment.dart';
import 'login.dart' as login;
// import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
// import 'homepage.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:firebase_core/firebase_core.dart';

class Settings extends StatefulWidget {
  const Settings({super.key, required this.company});

  final String? company;
  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      ThemeData currentTheme = themeProvider.themeData;
      bool darkMode = currentTheme.brightness == Brightness.dark;

      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            Container(
              color: darkMode
                  ? const Color.fromARGB(255, 52, 54, 66)
                  : const Color.fromARGB(255, 236, 242, 242),
              padding: const EdgeInsets.fromLTRB(50, 5, 50, 5),
              child: const Text(
                'Settings',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 25),
            ListTile(
              tileColor: darkMode
                  ? const Color.fromARGB(44, 193, 196, 244)
                  : const Color.fromARGB(255, 232, 232, 232),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: const Text('History'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            History(company: widget.company)));
              },
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
            const SizedBox(height: 10),
            ListTile(
              tileColor: darkMode
                  ? const Color.fromARGB(44, 193, 196, 244)
                  : const Color.fromARGB(255, 232, 232, 232),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: const Text('Dark Mode'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const DarkMode()));
              },
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
            const SizedBox(height: 10),
            ListTile(
              tileColor: darkMode
                  ? const Color.fromARGB(44, 193, 196, 244)
                  : const Color.fromARGB(255, 232, 232, 232),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: const Text('User'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => User(company: widget.company)));
              },
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
            const SizedBox(height: 10),
            ListTile(
              tileColor: darkMode
                  ? const Color.fromARGB(44, 193, 196, 244)
                  : const Color.fromARGB(255, 232, 232, 232),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: const Text('Key Audit'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            KeyAudit(company: widget.company)));
              },
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
            const SizedBox(height: 10),
            ListTile(
              tileColor: darkMode
                  ? const Color.fromARGB(44, 193, 196, 244)
                  : const Color.fromARGB(255, 232, 232, 232),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: const Text('Payment'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Payment(
                              company: widget.company,
                            )));
              },
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
            const SizedBox(height: 10),
            ListTile(
              tileColor: darkMode
                  ? const Color.fromARGB(44, 193, 196, 244)
                  : const Color.fromARGB(255, 232, 232, 232),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: const Text('Out and Returning'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Out(company: widget.company)));
              },
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
            const SizedBox(height: 10),
            ListTile(
              tileColor: darkMode
                  ? const Color.fromARGB(44, 193, 196, 244)
                  : const Color.fromARGB(255, 232, 232, 232),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: const Text('Print'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Print(company: widget.company)));
              },
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          ],
        ),
      );
    });
  }
}

class History extends StatefulWidget {
  const History({super.key, required this.company});

  final String? company;

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final database = FirebaseDatabase.instance.ref();
  final TextEditingController _searchController = TextEditingController();
  List<Map<dynamic, dynamic>> _guestsList = []; // Store the original list
  List<Map<dynamic, dynamic>> _filteredGuestsList =
      []; // Store the filtered list
  String _selectedSortOption = 'Name'; // Default sorting option

  @override
  void initState() {
    super.initState();
    fetchGuestList();
  }

  Future<void> fetchGuestList() async {
    DatabaseEvent event =
        await database.child('${widget.company}/GuestList').once();
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

  void sortGuestList() {
    setState(() {
      switch (_selectedSortOption) {
        case 'Name':
          _filteredGuestsList = _guestsList.toList();
          _filteredGuestsList.sort((a, b) => a['Name'].compareTo(b['Name']));
          break;
        case 'TicketID':
          _filteredGuestsList = _guestsList.toList();
          _filteredGuestsList
              .sort((a, b) => a['Ticket ID'].compareTo(b['Ticket ID']));
          break;
        case 'Hourly':
          _filteredGuestsList = _guestsList
              .where((guest) => guest['rateType'] == 'Hourly')
              .toList();
          break;
        case 'Overnight':
          _filteredGuestsList = _guestsList
              .where((guest) => guest['rateType'] == 'Overnight')
              .toList();
          break;
        case 'Time':
          _filteredGuestsList = _guestsList.toList();
          _filteredGuestsList.sort((a, b) => a['time'].compareTo(b['time']));
          break;
        default:
          _filteredGuestsList = _guestsList.toList();
          _filteredGuestsList.sort((a, b) => a['Name'].compareTo(b['Name']));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseReference guestRef =
        database.child('${widget.company}/GuestList/');
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      ThemeData currentTheme = themeProvider.themeData;
      bool darkMode = currentTheme.brightness == Brightness.dark;
      return Scaffold(
        backgroundColor: darkMode
            ? const Color.fromARGB(255, 52, 54, 66)
            : const Color.fromARGB(255, 236, 242, 242),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 7, 152, 241),
          title: const Text('History'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            const SizedBox(height: 10),
            Container(
              height: 60,
              padding: const EdgeInsets.fromLTRB(10, 15, 10, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: TextField(
                        controller: _searchController,
                        textAlignVertical: TextAlignVertical.bottom,
                        decoration: InputDecoration(
                          hintText: 'Search by Name or Ticket ID',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onChanged: (value) {
                          // Perform search based on the user's input
                          setState(() {
                            _filteredGuestsList = _guestsList
                                .where((guest) =>
                                    guest['Name']
                                        .toString()
                                        .toLowerCase()
                                        .contains(value.toLowerCase()) ||
                                    guest['Ticket ID']
                                        .toString()
                                        .toLowerCase()
                                        .contains(value.toLowerCase()))
                                .toList();
                          });
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: PopupMenuButton(
                      onSelected: (value) {
                        setState(() {
                          _selectedSortOption = value;
                          sortGuestList();
                        });
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'Name',
                          child: Text('Sort by Name'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'TicketID',
                          child: Text('Sort by Ticket ID'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Time',
                          child: Text('Sort by Time Created'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Hourly',
                          child: Text('Filter by Hourly'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Overnight',
                          child: Text('Filter by Overnight'),
                        ),
                      ],
                      icon: const Icon(Icons.sort),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            //**LIST**
            StreamBuilder(
              stream: guestRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  // Handle error
                  return Text('Error: ${snapshot.error}');
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  // Handle loading state
                  return const CircularProgressIndicator();
                }

                if (snapshot.data?.snapshot.value == null) {
                  // Handle empty state
                  return const Text('No data available.');
                }

                final Map<dynamic, dynamic> guestsData =
                    snapshot.data!.snapshot.value as Map<dynamic,
                        dynamic>; // Cast the value to Map<dynamic, dynamic>
                List<MapEntry<dynamic, dynamic>> listOfGuests = [];
                for (var guestEntry in _filteredGuestsList) {
                  guestsData.forEach((key, value) {
                    if (value['Status'] == 'Out' &&
                        guestEntry['Ticket ID'] == value['Ticket ID']) {
                      listOfGuests.add(MapEntry<dynamic, dynamic>(key, value));
                    }
                  });
                }
                return Column(
                  children: listOfGuests.map((guestEntry) {
                    final dynamic key = guestEntry.key;
                    final Map<dynamic, dynamic> guest = guestEntry.value;
                    return TextButton(
                      onPressed: () {
                        setState(() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GuestInfo(
                                  guestKey: key, company: widget.company),
                            ),
                          );
                        });
                      },
                      child: Card(
                        color: darkMode
                            ? const Color.fromARGB(44, 193, 196, 244)
                            : const Color.fromARGB(255, 232, 232, 232),
                        margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Flex(
                            direction: Axis.horizontal,
                            children: [
                              Expanded(
                                flex: 6,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${guest['Name']}',
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    Text(
                                      '${guest['Ticket ID']}, ${guest['License']}, ${guest['Room']}, ${guest['Brand']} ${guest['Model']}, ${guest['Color']}, ${guest['Phone']}, ${guest['rateType']}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              const Expanded(
                                flex: 1,
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            )
          ],
        ),
      );
    });
  }
}

class DarkMode extends StatefulWidget {
  const DarkMode({super.key});

  @override
  State<DarkMode> createState() => _DarkModeState();
}

class _DarkModeState extends State<DarkMode> {
  @override
  Widget build(BuildContext context) {
    // Obtain the ThemeProvider instance
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      ThemeData currentTheme = themeProvider.themeData;
      bool darkMode = currentTheme.brightness == Brightness.dark;

      return Scaffold(
        backgroundColor: darkMode
            ? const Color.fromARGB(255, 52, 54, 66)
            : const Color.fromARGB(255, 236, 242, 242),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 7, 152, 241),
          title: const Text('Dark Mode'),
        ),
        body: Card(
          color: darkMode
              ? const Color.fromARGB(44, 193, 196, 244)
              : const Color.fromARGB(255, 232, 232, 232),
          margin: const EdgeInsets.fromLTRB(10, 35, 10, 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Flex(
              direction: Axis.horizontal,
              children: [
                const Expanded(
                  flex: 5,
                  child: Text(
                    'Dark Mode',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: CupertinoSwitch(
                    value: darkMode,
                    onChanged: (value) {
                      setState(() {
                        if (darkMode) {
                          themeProvider.setTheme(AppTheme.light);
                        } else {
                          themeProvider.setTheme(AppTheme.dark);
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class User extends StatefulWidget {
  const User({super.key, required this.company});
  final String? company;

  @override
  State<User> createState() => _UserState();
}

class _UserState extends State<User> {
  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  late String _username = '';
  late String _company = '';
  late String _password = '';
  late String _email = '';

  Future<void> _fetchUserData() async {
    try {
      final userRef = FirebaseDatabase.instance.ref().child('Users/');
      DatabaseEvent event = await userRef
          .orderByChild('username')
          .equalTo(login.getUserName())
          .once();
      DataSnapshot snapshot = event.snapshot;

      // Fetch the user data
      Map<dynamic, dynamic>? userData = snapshot.value as Map<dynamic, dynamic>;

      // Search for the user with the matching username
      String foundKey = '';
      userData?.forEach((key, value) {
        foundKey = key;
      });

      if (foundKey.isNotEmpty) {
        // Retrieve the email and password for the specified user
        setState(() {
          _username = userData?[foundKey]['username'];
          _company = userData?[foundKey]['company'];
          _email = userData?[foundKey]['email'] ?? 'No email';
          _password = userData?[foundKey]['password'] ?? 'No password';
        });
      } else {
        // Handle the case where the user is not found
        setState(() {
          _email = 'Email not found';
          _password = 'Password not found';
        });
      }
    } catch (error) {
      // Handle any potential errors during data fetching
      print('Error fetching user data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Info'),
        backgroundColor: const Color.fromARGB(255, 7, 152, 241),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(35, 20, 35, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: Text(
                'User: $_username',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Company: $_company',
              style: const TextStyle(
                fontSize: 17,
              ),
            ),
            const Divider(
              color: Colors.black,
              thickness: .5,
            ),
            const SizedBox(height: 20),
            Text(
              'Email: $_email',
              style: const TextStyle(
                fontSize: 17,
              ),
            ),
            const Divider(
              color: Colors.black,
              thickness: .5,
            ),
            const SizedBox(height: 20),
            Text(
              'Password: $_password',
              style: const TextStyle(
                fontSize: 17,
              ),
            ),
            const Divider(
              color: Colors.black,
              thickness: .5,
            ),
            const SizedBox(height: 35),
            SizedBox(
              height: 45,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final guestRef = FirebaseDatabase.instance
                      .ref()
                      .child('${widget.company}/Users/$_username');
                  try {
                    await guestRef.update({'password': '040103'});
                    print('Guest status updated successfully.');
                  } catch (e) {
                    print('Error updating guest status: $e');
                  }
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  textStyle: const TextStyle(fontSize: 17),
                  backgroundColor: const Color.fromARGB(255, 72, 190, 126),
                ),
                child: const Text('Reset Password'),
              ),
            ),
            const SizedBox(height: 35),
            SizedBox(
              height: 45,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  WidgetsFlutterBinding.ensureInitialized();
                  await Firebase
                      .initializeApp(); // Initialize Firebase (before running the app)

                  runApp(
                    RestartWidget(
                      child: ChangeNotifierProvider(
                        create: (_) =>
                            ThemeProvider(), // Initialize the ThemeProvider
                        child: MaterialApp(
                          debugShowCheckedModeBanner: false,
                          home: Phoenix(
                            child: const login.Start(),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  textStyle: const TextStyle(fontSize: 17),
                  backgroundColor: const Color.fromARGB(255, 39, 205, 243),
                ),
                child: const Text('Sign Out'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class KeyAudit extends StatefulWidget {
  const KeyAudit({super.key, required this.company});

  final String? company;

  @override
  State<KeyAudit> createState() => _KeyAuditState();
}

class _KeyAuditState extends State<KeyAudit> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      ThemeData currentTheme = themeProvider.themeData;
      bool darkMode = currentTheme.brightness == Brightness.dark;
      return Scaffold(
        backgroundColor: darkMode
            ? const Color.fromARGB(255, 52, 54, 66)
            : const Color.fromARGB(255, 236, 242, 242),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 7, 152, 241),
          title: const Text('Key Audit'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              Shifts(company: widget.company)));
                },
                child: Card(
                  color: darkMode
                      ? const Color.fromARGB(44, 193, 196, 244)
                      : const Color.fromARGB(255, 232, 232, 232),
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(12, 20, 12, 20),
                    child: Flex(
                      direction: Axis.horizontal,
                      children: [
                        Expanded(
                          flex: 6,
                          child: Text(
                            'Start Key Audit',
                            style: TextStyle(fontSize: 17),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              Dates(company: widget.company)));
                },
                child: Card(
                  color: darkMode
                      ? const Color.fromARGB(44, 193, 196, 244)
                      : const Color.fromARGB(255, 232, 232, 232),
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(12, 20, 12, 20),
                    child: Flex(
                      direction: Axis.horizontal,
                      children: [
                        Expanded(
                          flex: 6,
                          child: Text(
                            'History',
                            style: TextStyle(fontSize: 17),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class Shifts extends StatelessWidget {
  const Shifts({super.key, required this.company});
  final String? company;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      ThemeData currentTheme = themeProvider.themeData;
      bool darkMode = currentTheme.brightness == Brightness.dark;
      return Scaffold(
        backgroundColor: darkMode
            ? const Color.fromARGB(255, 52, 54, 66)
            : const Color.fromARGB(255, 236, 242, 242),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 7, 152, 241),
          title: const Text('Shifts'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: ListView(
            padding: const EdgeInsets.all(0),
            children: [
              const SizedBox(height: 20),
              ListTile(
                tileColor: darkMode
                    ? const Color.fromARGB(44, 193, 196, 244)
                    : const Color.fromARGB(255, 232, 232, 232),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                title: const Text('AM Shift'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              StartKeyAudit(shift: 'AM', company: company)));
                },
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
              const SizedBox(height: 10),
              ListTile(
                tileColor: darkMode
                    ? const Color.fromARGB(44, 193, 196, 244)
                    : const Color.fromARGB(255, 232, 232, 232),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                title: const Text('PM Shift'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              StartKeyAudit(shift: 'PM', company: company)));
                },
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
              const SizedBox(height: 10),
              ListTile(
                tileColor: darkMode
                    ? const Color.fromARGB(44, 193, 196, 244)
                    : const Color.fromARGB(255, 232, 232, 232),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                title: const Text('Overnight Shift'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => StartKeyAudit(
                              shift: 'Overnight', company: company)));
                },
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class StartKeyAudit extends StatefulWidget {
  const StartKeyAudit({super.key, required this.shift, required this.company});

  final String? company;
  final String shift;

  @override
  State<StartKeyAudit> createState() => _StartKeyAuditState();
}

class _StartKeyAuditState extends State<StartKeyAudit> {
  final database = FirebaseDatabase.instance.ref();
  final TextEditingController _searchController = TextEditingController();
  List<Map<dynamic, dynamic>> _guestsList = []; // Store the original list
  List<Map<dynamic, dynamic>> _filteredGuestsList =
      []; //Store the filtered list
  String _selectedSortOption = 'Name'; // Default sorting option

  @override
  void initState() {
    super.initState();
    fetchGuestList();
  }

  bool allSelected = false;
  bool pressed = false;
  List<bool> hasBeenPressed = [];

  Future<void> fetchGuestList() async {
    DatabaseEvent event =
        await database.child('${widget.company}/GuestList').once();
    DataSnapshot snapshot = event.snapshot;
    if (snapshot.value != null) {
      final Map<dynamic, dynamic> guestsMap =
          Map.from(snapshot.value as Map<dynamic, dynamic>);

      setState(() {
        _guestsList = guestsMap.values.toList().cast<Map<dynamic, dynamic>>();
        _filteredGuestsList = _guestsList.toList();
        listOfGuests = getListOfGuests(snapshot);
        hasBeenPressed = List.generate(listOfGuests.length, (index) => false);
      });
    }
  }

  List<MapEntry<dynamic, dynamic>> listOfGuests = [];
  List<MapEntry<dynamic, dynamic>> getListOfGuests(DataSnapshot snapshot) {
    final Map<dynamic, dynamic> guestsData =
        snapshot.value as Map<dynamic, dynamic>;
    List<MapEntry<dynamic, dynamic>> listOfGuests = [];
    _filteredGuestsList.forEach((guestEntry) {
      guestsData.forEach((key, value) {
        if (value['Status'] != 'Out' &&
            guestEntry['Ticket ID'] == value['Ticket ID'] &&
            value['${widget.shift} Key Audit'] != 'Flagged' &&
            value['${widget.shift} Key Audit'] != 'Confirmed') {
          listOfGuests.add(MapEntry<dynamic, dynamic>(key, value));
        }
      });
    });
    return listOfGuests;
  }

  List<String> selectedKeys = [];
  void handleCallback(bool selected, int index) {
    setState(() {
      hasBeenPressed[index] = selected;
      if (selected) {
        // Add the key to the selectedKeys list
        selectedKeys.add(listOfGuests[index].key);
      } else {
        // Remove the key from the selectedKeys list
        selectedKeys.remove(listOfGuests[index].key);
      }
    });
  }

  void sortGuestList() {
    setState(() {
      switch (_selectedSortOption) {
        case 'Name':
          _filteredGuestsList = _guestsList.toList();
          _filteredGuestsList.sort((a, b) => a['Name'].compareTo(b['Name']));
          break;
        case 'TicketID':
          _filteredGuestsList = _guestsList.toList();
          _filteredGuestsList
              .sort((a, b) => a['Ticket ID'].compareTo(b['Ticket ID']));
          break;
        case 'Hourly':
          _filteredGuestsList = _guestsList
              .where((guest) => guest['rateType'] == 'Hourly')
              .toList();
          break;
        case 'Overnight':
          _filteredGuestsList = _guestsList
              .where((guest) => guest['rateType'] == 'Overnight')
              .toList();
          break;
        case 'Time':
          _filteredGuestsList = _guestsList.toList();
          _filteredGuestsList.sort((a, b) => a['Time'].compareTo(b['Time']));
          break;
        default:
          _filteredGuestsList = _guestsList.toList();
          _filteredGuestsList.sort((a, b) => a['Name'].compareTo(b['Name']));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseReference guestRef =
        database.child('${widget.company}/GuestList/');
    final DatabaseReference keyAuditRef =
        database.child('${widget.company}/KeyAudit/');

    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      ThemeData currentTheme = themeProvider.themeData;
      bool darkMode = currentTheme.brightness == Brightness.dark;
      return Scaffold(
        backgroundColor: darkMode
            ? const Color.fromARGB(255, 52, 54, 66)
            : const Color.fromARGB(255, 236, 242, 242),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 7, 152, 241),
          title: const Text('Start Key Audit'),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  height: 60,
                  padding: const EdgeInsets.fromLTRB(10, 15, 10, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: TextField(
                            controller: _searchController,
                            textAlignVertical: TextAlignVertical.bottom,
                            decoration: InputDecoration(
                              hintText: 'Search by Name or Ticket ID',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onChanged: (value) {
                              // Perform search based on the user's input
                              setState(() {
                                _filteredGuestsList = _guestsList
                                    .where((guest) =>
                                        guest['Name']
                                            .toString()
                                            .toLowerCase()
                                            .contains(value.toLowerCase()) ||
                                        guest['Ticket ID']
                                            .toString()
                                            .toLowerCase()
                                            .contains(value.toLowerCase()))
                                    .toList();
                              });
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: PopupMenuButton(
                          onSelected: (value) {
                            setState(() {
                              _selectedSortOption = value;
                              sortGuestList();
                            });
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'Name',
                              child: Text('Sort by Name'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'TicketID',
                              child: Text('Sort by Ticket ID'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'Time',
                              child: Text('Sort by Time Created'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'Hourly',
                              child: Text('Filter by Hourly'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'Overnight',
                              child: Text('Filter by Overnight'),
                            ),
                          ],
                          icon: const Icon(Icons.sort),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                //**LIST**
                SingleChildScrollView(
                  child: StreamBuilder(
                    stream: guestRef.onValue,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        // Handle error
                        return Text('Error: ${snapshot.error}');
                      }

                      if (!snapshot.hasData || snapshot.data == null) {
                        // Handle loading state
                        return const CircularProgressIndicator();
                      }

                      if (snapshot.data?.snapshot.value == null) {
                        // Handle empty state
                        return const Text('No data available.');
                      }

                      // final Map<dynamic, dynamic> guestsData =
                      //     snapshot.data!.snapshot.value as Map<dynamic,
                      //         dynamic>; // Cast the value to Map<dynamic, dynamic>
                      listOfGuests = getListOfGuests(snapshot.data!.snapshot);

                      return Column(
                        children: List.generate(listOfGuests.length, (index) {
                          final Map<dynamic, dynamic> guest =
                              listOfGuests[index].value;
                          final dynamic key = listOfGuests[index].key;

                          return GuestCard(
                            shift: widget.shift,
                            guest: guest,
                            guestKey: key,
                            company: widget.company,
                            selected: (value) {
                              setState(() {
                                handleCallback(value, index);
                              });
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                )
              ],
            ),
            // Positioned(
            //   left: 0,
            //   right: 0,
            //   bottom: 0,
            //   child: Container(
            //     width: double.infinity,
            //     // height: 70,
            //     padding: const EdgeInsets.all(16.0),
            //     child: ElevatedButton(
            //       onPressed: () {
            //         setState(() {
            //           pressed = true;
            //           allSelected =
            //               hasBeenPressed.every((element) => element == true);

            //           if (allSelected) {
            //             for (int i = 0; i < selectedKeys.length; i++) {
            //               keyAuditRef.push().set({
            //                 'Time': DateTime.now().toString(),
            //                 'Shift': widget.shift,
            //                 'Guests': selectedKeys[i],
            //               });
            //             }
            //             final snackBar = SnackBar(
            //               content: Container(
            //                 margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            //                 child: const Text(
            //                   'Key Audit Finished',
            //                   style: TextStyle(fontSize: 20),
            //                   textAlign: TextAlign.center,
            //                 ),
            //               ),
            //             );
            //             ScaffoldMessenger.of(context).showSnackBar(snackBar);
            //           }
            //         });
            //       },
            //       child: const Text(
            //         'Finish Audit',
            //         style: TextStyle(fontSize: 18),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      );
    });
  }
}

class GuestCard extends StatefulWidget {
  const GuestCard(
      {super.key,
      required this.guest,
      required this.selected,
      required this.guestKey,
      required this.shift,
      required this.company});

  final ValueChanged<bool> selected;
  final Map<dynamic, dynamic> guest;
  final dynamic guestKey;
  final String shift;
  final String? company;

  @override
  State<GuestCard> createState() => _GuestCardState();
}

class _GuestCardState extends State<GuestCard> {
  final database = FirebaseDatabase.instance.ref();
  bool hasBeenPressed = false;
  bool confirmed = false;
  bool flagged = false;
  String flagReason = '';
  bool sent = false;

  @override
  initState() {
    super.initState();
    getGuests();
  }

  Future<void> getGuests() async {
    DatabaseReference keyRef = database
        .child('${widget.company}/KeyAudit'); // Use the keyRefKey you've passed

    DatabaseEvent event = await keyRef.once();
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.value != null && snapshot.value is Map) {
      Map<dynamic, dynamic> valueMap = snapshot.value as Map<dynamic, dynamic>;

      valueMap.forEach((key, value) {
        if (value != null) {
          if (value['Guests'] == widget.guestKey) {
            DateTime currentDate = DateTime.now();
            int currentDay = currentDate.day;
            int currentMonth = currentDate.month;
            int currentYear = currentDate.year;
            DateTime dateTime =
                DateTime.fromMillisecondsSinceEpoch(value['Time']);
            int year = dateTime.year;
            int month = dateTime.month;
            int day = dateTime.day;

            if (currentDay == day &&
                currentMonth == month &&
                currentYear == year &&
                value['Shift'] == widget.shift) {
              setState(() {
                // Perform actions based on the condition for each entry
                confirmed =
                    widget.guest['${widget.shift} Key Audit'] == 'Confirmed';
                flagged =
                    widget.guest['${widget.shift} Key Audit'] == 'Flagged';
              });
            }
          }
        }
      });
    }
  }

  Text inOrOutIcon(String status) {
    if (status == 'In') {
      // return const Icon(Icons.check, color: Colors.green);
      return const Text(
        'In',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.green,
        ),
      );
    } else {
      // return const Icon(Icons.close, color: Colors.red);
      return const Text(
        'Returning',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.red,
        ),
      );
    }
  }

  void pressed() {
    setState(() {
      if (confirmed || flagged) {
        hasBeenPressed = true;
      } else {
        hasBeenPressed = false;
      }

      widget.selected(hasBeenPressed);
    });
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseReference guestRef =
        database.child('${widget.company}/GuestList/');
    final DatabaseReference keyAuditRef =
        database.child('${widget.company}/KeyAudit/');

    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      ThemeData currentTheme = themeProvider.themeData;
      bool darkMode = currentTheme.brightness == Brightness.dark;
      return Card(
        shadowColor: flagged
            ? Colors.red
            : confirmed
                ? Colors.green
                : null,
        elevation: 7.0,
        color: darkMode
            ? const Color.fromARGB(255, 64, 66, 81)
            : const Color.fromARGB(255, 232, 232, 232),
        margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.guest['Name']}',
                          style: const TextStyle(fontSize: 24),
                        ),
                        Text(
                          '${widget.guest['Ticket ID']}, ${widget.guest['License']}, ${widget.guest['Parking']}, ${widget.guest['Brand']} ${widget.guest['Model']}, ${widget.guest['Color']}, ${widget.guest['Phone']}, ${widget.guest['rateType']}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: inOrOutIcon('${widget.guest['Status']}'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: flagged
                          ? null
                          : () {
                              setState(() {
                                confirmed = !confirmed;
                                pressed();

                                if (confirmed) {
                                  guestRef.child(widget.guestKey).update({
                                    '${widget.shift} Key Audit': 'Confirmed',
                                  });
                                  keyAuditRef.push().set({
                                    'Guest': widget.guestKey,
                                    'Shift': widget.shift,
                                    'Time': DateTime.now().toString(),
                                  });
                                } else {
                                  guestRef.child(widget.guestKey).update({
                                    '${widget.shift} Key Audit': '',
                                  });
                                }
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: confirmed
                            ? Colors.grey
                            : const Color.fromARGB(255, 18, 185, 172),
                      ),
                      child: confirmed
                          ? const Text(
                              'Confirmed',
                              style: TextStyle(fontSize: 10),
                            )
                          : const Text(
                              "Confirm",
                              style: TextStyle(fontSize: 10),
                            ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      onPressed: confirmed
                          ? null
                          : () {
                              setState(() {
                                flagged = !flagged;
                                pressed();

                                if (flagged) {
                                  // guestRef.child(widget.guestKey).update({
                                  //   'Key Audit': 'Flagged',
                                  //   'Flag Reason': flagReason,
                                  // });
                                  sent = false;
                                } else {
                                  //sent = false;
                                  flagReason = '';
                                  guestRef.child(widget.guestKey).update({
                                    '${widget.shift} Key Audit': '',
                                    '${widget.shift} Flag Reason': '',
                                  });
                                }
                              });
                            },
                      color: Colors.red,
                      icon: const Icon(
                        Icons.flag,
                      ),
                    ),
                  ),
                ],
              ),
              if (flagged && !sent) const SizedBox(height: 20),
              if (flagged && !sent)
                Flex(
                  direction: Axis.horizontal,
                  children: [
                    Expanded(
                      flex: 4,
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            flagReason = value;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'Enter reason...',
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            sent = true;
                            guestRef.child(widget.guestKey).update({
                              '${widget.shift} Key Audit': 'Flagged',
                              '${widget.shift} Flag Reason': flagReason,
                            });
                            keyAuditRef.push().set({
                              'Guest': widget.guestKey,
                              'Shift': widget.shift,
                              'Time': DateTime.now().toString(),
                            });
                          });
                        },
                        icon: const Icon(Icons.send, color: Colors.blue),
                      ),
                    )
                  ],
                ),
            ],
          ),
        ),
      );
    });
  }
}

class Dates extends StatelessWidget {
  const Dates({super.key, required this.company});
  final String? company;
  @override
  Widget build(BuildContext context) {
    DateTime currentDate = DateTime.now();
    DateTime sevenDaysAgo = currentDate.subtract(const Duration(days: 7));
    DateTime sixDaysAgo = currentDate.subtract(const Duration(days: 6));
    DateTime fiveDaysAgo = currentDate.subtract(const Duration(days: 5));
    DateTime fourDaysAgo = currentDate.subtract(const Duration(days: 4));
    DateTime threeDaysAgo = currentDate.subtract(const Duration(days: 3));
    DateTime twoDaysAgo = currentDate.subtract(const Duration(days: 2));
    DateTime oneDaysAgo = currentDate.subtract(const Duration(days: 1));

    String dayOfWeek = getDayOfWeek(sevenDaysAgo.weekday);

    String formattedSevenDaysAgo =
        '${getDayOfWeek(sevenDaysAgo.weekday)} (${getMonth(sevenDaysAgo.month)} ${sevenDaysAgo.day})';
    String formattedSixDaysAgo =
        '${getDayOfWeek(sixDaysAgo.weekday)} (${getMonth(sixDaysAgo.month)} ${sixDaysAgo.day})';
    String formattedFiveDaysAgo =
        '${getDayOfWeek(fiveDaysAgo.weekday)} (${getMonth(fiveDaysAgo.month)} ${fiveDaysAgo.day})';
    String formattedFourDaysAgo =
        '${getDayOfWeek(fourDaysAgo.weekday)} (${getMonth(fourDaysAgo.month)} ${fourDaysAgo.day})';
    String formattedThreeDaysAgo =
        '${getDayOfWeek(threeDaysAgo.weekday)} (${getMonth(threeDaysAgo.month)} ${threeDaysAgo.day})';
    String formattedTwoDaysAgo =
        '${getDayOfWeek(twoDaysAgo.weekday)} (${getMonth(twoDaysAgo.month)} ${twoDaysAgo.day})';
    String formattedOneDaysAgo =
        '${getDayOfWeek(oneDaysAgo.weekday)} (${getMonth(oneDaysAgo.month)} ${oneDaysAgo.day})';
    String formattedCurrentDate =
        '${getDayOfWeek(currentDate.weekday)} (${getMonth(currentDate.month)} ${currentDate.day})';
    List<String> formattedDays = [
      formattedSevenDaysAgo,
      formattedSixDaysAgo,
      formattedFiveDaysAgo,
      formattedFourDaysAgo,
      formattedThreeDaysAgo,
      formattedTwoDaysAgo,
      formattedOneDaysAgo,
      formattedCurrentDate,
    ];

    List<DateTime> days = [
      sevenDaysAgo,
      sixDaysAgo,
      fiveDaysAgo,
      fourDaysAgo,
      threeDaysAgo,
      twoDaysAgo,
      oneDaysAgo,
      currentDate,
    ];
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      ThemeData currentTheme = themeProvider.themeData;
      bool darkMode = currentTheme.brightness == Brightness.dark;

      return Scaffold(
          backgroundColor: darkMode
              ? const Color.fromARGB(255, 52, 54, 66)
              : const Color.fromARGB(255, 236, 242, 242),
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 7, 152, 241),
            title: const Text('History of Key Audit'),
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(12, 22, 12, 12),
            child: Column(
              children: List.generate(days.length, (index) {
                return Container(
                  padding: const EdgeInsets.only(top: 10),
                  child: ListTile(
                    tileColor: darkMode
                        ? const Color.fromARGB(44, 193, 196, 244)
                        : const Color.fromARGB(255, 232, 232, 232),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    title: Text(formattedDays[index]),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HistoryShifts(
                                  day: '${days[index].day}',
                                  month: '${days[index].month}',
                                  year: '${days[index].year}',
                                  company: company)));
                    },
                    trailing: const Icon(Icons.arrow_forward_ios),
                  ),
                );
              }).toList(),
            ),
          ));
    });
  }

  String getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  String getMonth(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'Febuary';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }
}

class HistoryShifts extends StatelessWidget {
  const HistoryShifts(
      {super.key,
      required this.day,
      required this.month,
      required this.year,
      required this.company});

  final String day;
  final String month;
  final String year;
  final String? company;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      ThemeData currentTheme = themeProvider.themeData;
      bool darkMode = currentTheme.brightness == Brightness.dark;
      return Scaffold(
        backgroundColor: darkMode
            ? const Color.fromARGB(255, 52, 54, 66)
            : const Color.fromARGB(255, 236, 242, 242),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 7, 152, 241),
          title: const Text('Shifts'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: ListView(
            padding: const EdgeInsets.all(0),
            children: [
              const SizedBox(height: 20),
              ListTile(
                tileColor: darkMode
                    ? const Color.fromARGB(44, 193, 196, 244)
                    : const Color.fromARGB(255, 232, 232, 232),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                title: const Text('AM Shift'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HistoryKeyAudit(
                                shift: 'AM',
                                day: day,
                                month: month,
                                year: year,
                                company: company,
                              )));
                },
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
              const SizedBox(height: 10),
              ListTile(
                tileColor: darkMode
                    ? const Color.fromARGB(44, 193, 196, 244)
                    : const Color.fromARGB(255, 232, 232, 232),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                title: const Text('PM Shift'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HistoryKeyAudit(
                                shift: 'PM',
                                day: day,
                                month: month,
                                year: year,
                                company: company,
                              )));
                },
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
              const SizedBox(height: 10),
              ListTile(
                tileColor: darkMode
                    ? const Color.fromARGB(44, 193, 196, 244)
                    : const Color.fromARGB(255, 232, 232, 232),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                title: const Text('Overnight Shift'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HistoryKeyAudit(
                                shift: 'Overnight',
                                day: day,
                                month: month,
                                year: year,
                                company: company,
                              )));
                },
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class HistoryKeyAudit extends StatefulWidget {
  const HistoryKeyAudit(
      {super.key,
      required this.shift,
      required this.day,
      required this.month,
      required this.year,
      required this.company});

  final String shift;
  final String day;
  final String month;
  final String year;
  final String? company;

  @override
  State<HistoryKeyAudit> createState() => _HistoryKeyAuditState();
}

class _HistoryKeyAuditState extends State<HistoryKeyAudit> {
  final database = FirebaseDatabase.instance.ref();
  final TextEditingController _searchController = TextEditingController();
  List<Map<dynamic, dynamic>> _guestsList = []; // Store the original list
  List<Map<dynamic, dynamic>> _filteredGuestsList =
      []; //Store the filtered list
  String _selectedSortOption = 'Name';

  @override
  void initState() {
    super.initState();
    fetchGuestList();
  }

  Future<void> fetchGuestList() async {
    DatabaseEvent event =
        await database.child('${widget.company}/GuestList').once();
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

  void sortGuestList() {
    setState(() {
      switch (_selectedSortOption) {
        case 'Name':
          _filteredGuestsList = _guestsList.toList();
          _filteredGuestsList.sort((a, b) => a['Name'].compareTo(b['Name']));
          break;
        case 'TicketID':
          _filteredGuestsList = _guestsList.toList();
          _filteredGuestsList
              .sort((a, b) => a['Ticket ID'].compareTo(b['Ticket ID']));
          break;
        case 'Hourly':
          _filteredGuestsList = _guestsList
              .where((guest) => guest['rateType'] == 'Hourly')
              .toList();
          break;
        case 'Overnight':
          _filteredGuestsList = _guestsList
              .where((guest) => guest['rateType'] == 'Overnight')
              .toList();
          break;
        case 'Time':
          _filteredGuestsList = _guestsList.toList();
          _filteredGuestsList.sort((a, b) => a['Time'].compareTo(b['Time']));
          break;
        default:
          _filteredGuestsList = _guestsList.toList();
          _filteredGuestsList.sort((a, b) => a['Name'].compareTo(b['Name']));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseReference guestRef =
        database.child('${widget.company}/GuestList/');
    final DatabaseReference keyAuditRef =
        database.child('${widget.company}/KeyAudit/');
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      ThemeData currentTheme = themeProvider.themeData;
      bool darkMode = currentTheme.brightness == Brightness.dark;
      return Scaffold(
        backgroundColor: darkMode
            ? const Color.fromARGB(255, 52, 54, 66)
            : const Color.fromARGB(255, 236, 242, 242),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 7, 152, 241),
          title: const Text('History of Key Audit'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            const SizedBox(height: 10),
            Container(
              height: 60,
              padding: const EdgeInsets.fromLTRB(10, 15, 10, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: TextField(
                        controller: _searchController,
                        textAlignVertical: TextAlignVertical.bottom,
                        decoration: InputDecoration(
                          hintText: 'Search by Name or Ticket ID',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onChanged: (value) {
                          // Perform search based on the user's input
                          setState(() {
                            _filteredGuestsList = _guestsList
                                .where((guest) =>
                                    guest['Name']
                                        .toString()
                                        .toLowerCase()
                                        .contains(value.toLowerCase()) ||
                                    guest['Ticket ID']
                                        .toString()
                                        .toLowerCase()
                                        .contains(value.toLowerCase()))
                                .toList();
                          });
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: PopupMenuButton(
                      onSelected: (value) {
                        setState(() {
                          _selectedSortOption = value;
                          sortGuestList();
                        });
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'Name',
                          child: Text('Sort by Name'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'TicketID',
                          child: Text('Sort by Ticket ID'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Time',
                          child: Text('Sort by Time Created'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Hourly',
                          child: Text('Filter by Hourly'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Overnight',
                          child: Text('Filter by Overnight'),
                        ),
                      ],
                      icon: const Icon(Icons.sort),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            //**LIST**
            StreamBuilder(
              stream: keyAuditRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  // Handle error
                  return Text('Error: ${snapshot.error}');
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  // Handle loading state
                  return const CircularProgressIndicator();
                  print("Success 1");
                }

                if (snapshot.data?.snapshot.value == null) {
                  // Handle empty state
                  return const Text('No data available.');
                }

                Map<dynamic, dynamic>? guestsD =
                    snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;
                List<MapEntry<dynamic, dynamic>> listOfGuests = [];
                if (guestsD != null) {
                  guestsD.forEach((key, value) {
                    if (value != null &&
                        value is Map &&
                        value.containsKey('Time') &&
                        value.containsKey('Shift')) {
                      DateTime? dateTime;
                      try {
                        dateTime = DateTime.parse(value['Time']);
                        // print("Success 2");
                      } catch (e) {
                        print("Error parsing date: $e");
                      }
                      if (dateTime != null) {
                        if (value['Shift'] == widget.shift &&
                            dateTime.year.toString() == widget.year &&
                            dateTime.month.toString() == widget.month &&
                            dateTime.day.toString() == widget.day) {
                          if (key != null && value != null) {
                            listOfGuests
                                .add(MapEntry<dynamic, dynamic>(key, value));
                            // print("Success 3");
                          }
                        }
                      }
                    }
                  });
                }

                return Column(
                  children: List.generate(listOfGuests.length, (index) {
                    final Map<dynamic, dynamic> guest =
                        listOfGuests[index].value;
                    final dynamic key = listOfGuests[index].key;

                    return FutureBuilder(
                        future: guestRef.child(guest['Guest']).once(),
                        builder: (context, guestSnapshot) {
                          if (guestSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }

                          if (guestSnapshot.hasError) {
                            return Text('Error: ${guestSnapshot.error}');
                          }

                          final DataSnapshot guestDataSnapshot =
                              guestSnapshot.data!.snapshot;

                          if (!guestSnapshot.hasData ||
                              guestDataSnapshot.value == null) {
                            return Text('No data available.');
                          }

                          final Map<dynamic, dynamic> guestData =
                              guestDataSnapshot.value as Map<dynamic, dynamic>;

                          return Card(
                            color: darkMode
                                ? const Color.fromARGB(44, 193, 196, 244)
                                : const Color.fromARGB(255, 232, 232, 232),
                            margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                children: [
                                  Flex(
                                    direction: Axis.horizontal,
                                    children: [
                                      Expanded(
                                        flex: 6,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${guestData['Name']}',
                                              style:
                                                  const TextStyle(fontSize: 24),
                                            ),
                                            Text(
                                              '${guestData['Ticket ID']}, ${guestData['License']}, ${guestData['Parking']}, ${guestData['Brand']} ${guestData['Model']}, ${guestData['Color']}, ${guestData['Phone']}, ${guestData['rateType']}, ${guestData['${widget.shift} Flag Reason']}',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                          flex: 1,
                                          child: Icon(
                                            guestData['${widget.shift} Key Audit'] ==
                                                    'Confirmed'
                                                ? Icons.check
                                                : Icons.flag,
                                            color: guestData[
                                                        '${widget.shift} Key Audit'] ==
                                                    'Confirmed'
                                                ? Colors.green
                                                : Colors.red,
                                          )),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                  }).toList(),
                );
              },
            ),
          ],
        ),
      );
    });
  }
}

class Report extends StatefulWidget {
  const Report({super.key});

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      ThemeData currentTheme = themeProvider.themeData;
      bool darkMode = currentTheme.brightness == Brightness.dark;
      return Scaffold(
        backgroundColor: darkMode
            ? const Color.fromARGB(255, 52, 54, 66)
            : const Color.fromARGB(255, 236, 242, 242),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 7, 152, 241),
          title: const Text('Report'),
        ),
        body: const Center(
          child: Text('Report'),
        ),
      );
    });
  }
}

class Out extends StatefulWidget {
  const Out({super.key, required this.company});

  final String? company;

  @override
  State<Out> createState() => _OutState();
}

class _OutState extends State<Out> {
  final database = FirebaseDatabase.instance.ref();
  final TextEditingController _searchController = TextEditingController();
  // late Color _cardColor = Colors.transparent;
  // late Color _titleCardColor = Colors.transparent;
  List<Map<dynamic, dynamic>> _guestsList = []; // Store the original list
  List<Map<dynamic, dynamic>> _filteredGuestsList =
      []; // Store the filtered list
  String _selectedSortOption = 'Name'; // Default sorting option

  // @override
  // void didChangeDependencies() {
  //   if (Theme.of(context).brightness == Brightness.light) {
  //     _cardColor = const Color.fromARGB(255, 232, 232, 232);
  //     _titleCardColor = const Color.fromARGB(255, 221, 227, 227);
  //   } else {
  //     _cardColor = const Color.fromARGB(44, 193, 196, 244);
  //     _titleCardColor = const Color.fromARGB(255, 67, 69, 81);
  //   }
  //   super.didChangeDependencies();
  // }

  @override
  void initState() {
    super.initState();
    fetchGuestList();
  }

  Future<void> fetchGuestList() async {
    DatabaseEvent event =
        await database.child('${widget.company}/GuestList').once();
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

  void sortGuestList() {
    setState(() {
      switch (_selectedSortOption) {
        case 'Name':
          _filteredGuestsList = _guestsList.toList();
          _filteredGuestsList.sort((a, b) => a['Name'].compareTo(b['Name']));
          break;
        case 'TicketID':
          _filteredGuestsList = _guestsList.toList();
          _filteredGuestsList
              .sort((a, b) => a['Ticket ID'].compareTo(b['Ticket ID']));
          break;
        case 'Hourly':
          _filteredGuestsList = _guestsList
              .where((guest) => guest['rateType'] == 'Hourly')
              .toList();
          break;
        case 'Overnight':
          _filteredGuestsList = _guestsList
              .where((guest) => guest['rateType'] == 'Overnight')
              .toList();
          break;
        case 'Time':
          _filteredGuestsList = _guestsList.toList();
          _filteredGuestsList.sort((a, b) => a['time'].compareTo(b['time']));
          break;
        default:
          _filteredGuestsList = _guestsList.toList();
          _filteredGuestsList.sort((a, b) => a['Name'].compareTo(b['Name']));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseReference guestRef =
        database.child('${widget.company}/GuestList/');
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      ThemeData currentTheme = themeProvider.themeData;
      bool darkMode = currentTheme.brightness == Brightness.dark;
      return Scaffold(
        backgroundColor: darkMode
            ? const Color.fromARGB(255, 52, 54, 66)
            : const Color.fromARGB(255, 236, 242, 242),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 7, 152, 241),
          title: const Text('Out And Returning'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            // const SizedBox(height: 20),
            // Container(
            //   color: darkMode ? const Color.fromARGB(255, 67, 69, 81) : const Color.fromARGB(255, 221, 227, 227),
            //   padding: const EdgeInsets.fromLTRB(170, 5, 170, 5),
            //   child: const Text(
            //     'Log',
            //     style: TextStyle(
            //       fontSize: 26,
            //       fontWeight: FontWeight.w600,
            //     ),
            //   ),
            // ),
            const SizedBox(height: 10),
            Container(
              height: 60,
              padding: const EdgeInsets.fromLTRB(10, 15, 10, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: TextField(
                        controller: _searchController,
                        textAlignVertical: TextAlignVertical.bottom,
                        decoration: InputDecoration(
                          hintText: 'Search by Name or Ticket ID',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onChanged: (value) {
                          // Perform search based on the user's input
                          setState(() {
                            _filteredGuestsList = _guestsList
                                .where((guest) =>
                                    guest['Name']
                                        .toString()
                                        .toLowerCase()
                                        .contains(value.toLowerCase()) ||
                                    guest['Ticket ID']
                                        .toString()
                                        .toLowerCase()
                                        .contains(value.toLowerCase()))
                                .toList();
                          });
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: PopupMenuButton(
                      onSelected: (value) {
                        setState(() {
                          _selectedSortOption = value;
                          sortGuestList();
                        });
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'Name',
                          child: Text('Sort by Name'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'TicketID',
                          child: Text('Sort by Ticket ID'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Time',
                          child: Text('Sort by Time Created'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Hourly',
                          child: Text('Filter by Hourly'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Overnight',
                          child: Text('Filter by Overnight'),
                        ),
                      ],
                      icon: const Icon(Icons.sort),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            //**LIST**
            StreamBuilder(
              stream: guestRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  // Handle error
                  return Text('Error: ${snapshot.error}');
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  // Handle loading state
                  return const CircularProgressIndicator();
                }

                if (snapshot.data?.snapshot.value == null) {
                  // Handle empty state
                  return const Text('No data available.');
                }

                final Map<dynamic, dynamic> guestsData =
                    snapshot.data!.snapshot.value as Map<dynamic,
                        dynamic>; // Cast the value to Map<dynamic, dynamic>
                List<MapEntry<dynamic, dynamic>> listOfGuests = [];
                _filteredGuestsList.forEach((guestEntry) {
                  guestsData.forEach((key, value) {
                    if (value['Status'] == 'Out' &&
                        guestEntry['Ticket ID'] == value['Ticket ID']) {
                      listOfGuests.add(MapEntry<dynamic, dynamic>(key, value));
                    }
                  });
                });
                return Column(
                  children: listOfGuests.map((guestEntry) {
                    final dynamic key = guestEntry.key;
                    final Map<dynamic, dynamic> guest = guestEntry.value;
                    return Card(
                      color: darkMode
                          ? const Color.fromARGB(44, 193, 196, 244)
                          : const Color.fromARGB(255, 232, 232, 232),
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
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${guest['Name']}',
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  Text(
                                    '${guest['Ticket ID']}, ${guest['License']}, ${guest['Parking']}, ${guest['Brand']} ${guest['Model']}, ${guest['Color']}, ${guest['Phone']}, ${guest['rateType']}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: ListView(
                                          shrinkWrap: true,
                                          children: <Widget>[
                                            const SizedBox(height: 20),
                                            Center(
                                              child: Text(
                                                'Do you want to update ${guest['Name']}\'s status to \'In house\'?',
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      Navigator.pop(context);
                                                    });
                                                  },
                                                  child: const Text("Cancel"),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    try {
                                                      await guestRef
                                                          .child(key)
                                                          .update(
                                                              {'Status': 'In'});
                                                      print(
                                                          'Guest status updated successfully.');
                                                    } catch (e) {
                                                      print(
                                                          'Error updating guest status: $e');
                                                    }
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text(
                                                    "In",
                                                    style: TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 255, 80, 103)),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 18, 185, 172),
                                ),
                                child: const Text("Update"),
                              ),
                            ),
                            // const SizedBox(width: 10),
                            // Expanded(
                            //   flex: 1,
                            //   child: ElevatedButton(
                            //     onPressed: () {
                            //       // setState(() {
                            //       //   Navigator.push(
                            //       //     context,
                            //       //     MaterialPageRoute(
                            //       //       builder: (context) =>
                            //       //           EditPage(guestKey: key),
                            //       //     ),
                            //       //   );
                            //       // });
                            //     },
                            //     style: ElevatedButton.styleFrom(
                            //       backgroundColor:
                            //           const Color.fromARGB(255, 18, 185, 172),
                            //     ),
                            //     child: const Text("Edit"),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            )
          ],
        ),
      );
    });
  }
}

class GuestInfo extends StatefulWidget {
  const GuestInfo({super.key, required this.guestKey, required this.company});

  final String guestKey;
  final String? company;

  @override
  State<GuestInfo> createState() => _GuestInfoState();
}

class _GuestInfoState extends State<GuestInfo> {
  final database = FirebaseDatabase.instance.ref();
  // final guestRef = FirebaseDatabase.instance.ref().child('${widget.company}/GuestList/');

  @override
  void initState() {
    super.initState();
    // Fetch the existing guest details using the guestKey, and populate the text fields
    _fetchGuestDetails();
  }

  @override
  void dispose() {
    _guestDataSubscription?.cancel();
    super.dispose();
  }

  late String _ticketID = '';
  late String _name = '';
  late String _room = '';
  late String _number = '';
  late String _brand = '';
  late String _model = '';
  late String _license = '';
  late String _color = '';
  late String _parking = '';
  late String _selectedTime = '';

  StreamSubscription<DatabaseEvent>? _guestDataSubscription;
  Future<void> _fetchGuestDetails() async {
    try {
      final guestRef =
          FirebaseDatabase.instance.ref().child('${widget.company}/GuestList/');
      _guestDataSubscription =
          guestRef.child(widget.guestKey).onValue.listen((event) {
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic>? guestData = event.snapshot.value as Map?;
          if (guestData != null) {
            setState(() {
              _ticketID = guestData['Ticket ID'];
              _name = guestData['Name'];
              _room = guestData['Room'];
              _number = guestData['Phone'];
              _brand = guestData['Brand'];
              _model = guestData['Model'];
              _license = guestData['License'];
              _color = guestData['Color'];
              _parking = guestData['Parking'];
              _selectedTime = guestData['rateType'];
            });
          }
        }
      });
    } catch (e) {
      print('Error fetching guest details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guest Info'),
        backgroundColor: const Color.fromARGB(255, 7, 152, 241),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(35, 20, 35, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: Text(
                'Ticket ID: $_ticketID',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Name: $_name',
              style: const TextStyle(
                fontSize: 17,
              ),
            ),
            const Divider(
              color: Colors.black,
              thickness: .5,
            ),
            const SizedBox(height: 20),
            Text(
              'Room: $_room',
              style: const TextStyle(
                fontSize: 17,
              ),
            ),
            const Divider(
              color: Colors.black,
              thickness: .5,
            ),
            const SizedBox(height: 20),
            Text(
              'Phone Number: $_number',
              style: const TextStyle(
                fontSize: 17,
              ),
            ),
            const Divider(
              color: Colors.black,
              thickness: .5,
            ),
            const SizedBox(height: 20),
            Text(
              'Selected Time: $_selectedTime',
              style: const TextStyle(
                fontSize: 17,
              ),
            ),
            const Divider(
              color: Colors.black,
              thickness: .5,
            ),
            const SizedBox(height: 20),
            Text(
              'Brand: $_brand',
              style: const TextStyle(
                fontSize: 17,
              ),
            ),
            const Divider(
              color: Colors.black,
              thickness: .5,
            ),
            const SizedBox(height: 20),
            Text(
              'Model: $_model',
              style: const TextStyle(
                fontSize: 17,
              ),
            ),
            const Divider(
              color: Colors.black,
              thickness: .5,
            ),
            const SizedBox(height: 20),
            Text(
              'License: $_license',
              style: const TextStyle(
                fontSize: 17,
              ),
            ),
            const Divider(
              color: Colors.black,
              thickness: .5,
            ),
            const SizedBox(height: 20),
            Text(
              'Parking: $_parking',
              style: const TextStyle(
                fontSize: 17,
              ),
            ),
            const Divider(
              color: Colors.black,
              thickness: .5,
            ),
            const SizedBox(height: 20),
            const Text(
              'Paid via: ',
              style: TextStyle(
                fontSize: 17,
              ),
            ),
            const Divider(
              color: Colors.black,
              thickness: .5,
            ),
            const SizedBox(height: 20),
            const Text(
              'Paid Amount: ',
              style: TextStyle(
                fontSize: 17,
              ),
            ),
            const Divider(
              color: Colors.black,
              thickness: .5,
            ),
            //CAME AT...LEAVE AT..
            const SizedBox(height: 35),
            SizedBox(
              height: 45,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final guestRef = FirebaseDatabase.instance
                      .ref()
                      .child('${widget.company}/GuestList/');
                  try {
                    await guestRef
                        .child(widget.guestKey)
                        .update({'Status': 'In'});
                    print('Guest status updated successfully.');
                  } catch (e) {
                    print('Error updating guest status: $e');
                  }
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  textStyle: const TextStyle(fontSize: 17),
                  backgroundColor: const Color.fromARGB(255, 72, 190, 126),
                ),
                child: const Text('Reissue Ticket'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Print extends StatefulWidget {
  const Print({super.key, required this.company});
  final String? company;

  @override
  _PrintState createState() => _PrintState();
}

class _PrintState extends State<Print> {
  late pw.Document pdf = pw.Document();
  bool initPDF = false;
  final database = FirebaseDatabase.instance.ref();
  List<Map<dynamic, dynamic>> _guestsList = []; // Store the original list
  List<Map<dynamic, dynamic>> _filteredGuestsList =
      []; // Store the filtered list

  @override
  void initState() {
    super.initState();
    fetchGuestList();
  }

  Future<void> fetchGuestList() async {
    DatabaseEvent event =
        await database.child('${widget.company}/GuestList').once();
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

  // Function to generate PDF
  void generatePDF() async {
    List<Map<dynamic, dynamic>> _filteredDateGuestsList = [];
    var hourlyCount = 0;
    var overnightCount = 0;
    var totalCars = 0;
    for (var guestEntry in _filteredGuestsList) {
      DateTime dateTime = DateTime.parse(guestEntry['Time']);
      String dateString = DateFormat('MM/dd/yyyy').format(dateTime);
      if (dateString == DateFormat('MM/dd/yyyy').format(DateTime.now())) {
        if (guestEntry['rateType'] == 'Overnight') {
          overnightCount++;
        }
        if (guestEntry['rateType'] == 'Hourly') {
          hourlyCount++;
        }
        _filteredDateGuestsList.add(guestEntry);
        totalCars++;
      }
    }
    initPDF = true;
    pdf = pw.Document();
    // Add content to the PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Valet Report (${DateFormat('M/d/yyyy').format(DateTime.now())}):',
                style:
                    pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>[
                    'Name',
                    'Type',
                    'Punched In',
                    'Status',
                    'Make',
                    'Model',
                    'Color',
                    'License Plate',
                    'Ticket id',
                    'Payment'
                  ],
                  ..._filteredDateGuestsList.map((item) => [
                        item['Name'].toString(),
                        item['rateType'].toString(),
                        DateFormat('HH:mm')
                            .format(DateTime.parse(item['Time']))
                            .toString(),
                        item['Status'].toString(),
                        item['Brand'].toString(),
                        item['Model'].toString(),
                        item['Color'].toString(),
                        item['License'].toString(),
                        item['Ticket ID'].toString(),
                        item['Room'].toString(),
                      ]),
                ],
                columnWidths: {
                  0: pw.FlexColumnWidth(1),
                  1: pw.FlexColumnWidth(1),
                  2: pw.FlexColumnWidth(1),
                  3: pw.FlexColumnWidth(1),
                  4: pw.FlexColumnWidth(1.25),
                  5: pw.FlexColumnWidth(1.25),
                  6: pw.FlexColumnWidth(1),
                  7: pw.FlexColumnWidth(1.25),
                  8: pw.FlexColumnWidth(1),
                  9: pw.FlexColumnWidth(1),
                },
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Number of Hourly: $hourlyCount',
                            textAlign: pw.TextAlign.left),
                        pw.Text(
                          'Number of Overnights: $overnightCount',
                          textAlign: pw.TextAlign.right,
                        ),
                        pw.Text(
                          'Total Cars: $totalCars',
                          textAlign: pw.TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    pw.RichText.debug = true;
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Preview'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: generatePDF,
              child: const Text('Generate PDF'),
            ),
            if (initPDF)
              Expanded(
                child: PdfPreview(
                  build: (format) => pdf.save(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class RestartWidget extends StatefulWidget {
  final Widget child;

  const RestartWidget({Key? key, required this.child}) : super(key: key);

  static void restartApp(BuildContext context) {
    final _RestartWidgetState state =
        context.findAncestorStateOfType<_RestartWidgetState>()!;
    state.restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}
