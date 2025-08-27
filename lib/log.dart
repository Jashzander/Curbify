import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
//import 'homepage.dart';

class Log extends StatefulWidget {
  const Log({super.key, required this.company});

  final String? company;

  @override
  State<Log> createState() => LogState();
}

class LogState extends State<Log> {
  final database = FirebaseDatabase.instance.ref();
  TextEditingController _searchController = TextEditingController();

  // late Color _cardColor = Colors.transparent;
  // late Color _titleCardColor = Colors.transparent;
  List<Map<dynamic, dynamic>> _guestsList = []; // Store the original list
  List<Map<dynamic, dynamic>> _filteredGuestsList =
      []; // Store the filtered list
  String _selectedSortOption = 'Name'; // Default sorting option

  @override
  initState() {
    super.initState();
    fetchGuestList();
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

  void sortGuestList() {
    setState(() {
      switch (_selectedSortOption) {
        case 'Name':
          _filteredGuestsList = List.from(_guestsList);
          _filteredGuestsList.sort((a, b) => a['Name'].compareTo(b['Name']));
          print('called');
          break;
        case 'TicketID':
          _filteredGuestsList = List.from(_guestsList);
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
          _filteredGuestsList = List.from(_guestsList);
          _filteredGuestsList.sort((a, b) => a['time'].compareTo(b['time']));
          break;
        default:
          _filteredGuestsList = List.from(_guestsList);
          _filteredGuestsList.sort((a, b) => a['Name'].compareTo(b['Name']));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      final DatabaseReference guestRef =
          database.child('${widget.company}/GuestList');
      ThemeData currentTheme = themeProvider.themeData;
      bool darkMode = currentTheme.brightness == Brightness.dark;
      Color? color;
      return Scaffold(
        backgroundColor: darkMode
            ? const Color.fromARGB(255, 52, 54, 66)
            : const Color.fromARGB(255, 236, 242, 242),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                color: darkMode
                    ? const Color.fromARGB(255, 52, 54, 66)
                    : const Color.fromARGB(255, 236, 242, 242),
                padding: const EdgeInsets.fromLTRB(170, 5, 170, 5),
                child: const Text(
                  'Log',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
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
                                  .where((guestRef) =>
                                      guestRef['Name']
                                          .toString()
                                          .toLowerCase()
                                          .contains(value.toLowerCase()) ||
                                      guestRef['Ticket ID']
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
                      if (value['Status'] != 'Out' &&
                          guestEntry['Ticket ID'] == value['Ticket ID']) {
                        listOfGuests
                            .add(MapEntry<dynamic, dynamic>(key, value));
                      }
                    });
                  });

                  return Column(
                    children: listOfGuests.map((guestEntry) {
                      final dynamic key = guestEntry.key;
                      final Map<dynamic, dynamic> guest = guestEntry.value;
                      bool isRoomBlank = guest['Room'] == 'BLANK';
                      Color cardColor = isRoomBlank
                          ? (darkMode
                              ? const Color.fromARGB(116, 239, 234, 85)
                              : const Color.fromARGB(
                                  206, 239, 234, 85)) // BLANK room color
                          : (darkMode
                              ? const Color.fromARGB(44, 193, 196, 244)
                              : const Color.fromARGB(
                                  255, 232, 232, 232)); // Dark mode color
                      // Default color

                      return Card(
                        color: cardColor,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${guest['Name']}',
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    Text(
                                      '${guest['Ticket ID']} ${guest['Room']} ${guest['License']} ${guest['Parking']} ${guest['Brand']} ${guest['Model']} ${guest['Color']} ${guest['Phone']} ${guest['rateType']}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
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
                                                  'Are you sure you want to remove ${guest['Name']} from the system?',
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
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
                                                            .update({
                                                          'Status': 'Out'
                                                        });
                                                        print(
                                                            'Guest status updated successfully.');
                                                      } catch (e) {
                                                        print(
                                                            'Error updating guest status: $e');
                                                      }
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text(
                                                      "Remove",
                                                      style: TextStyle(
                                                          color: Color.fromARGB(
                                                              255,
                                                              255,
                                                              80,
                                                              103)),
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
                                        const Color.fromARGB(255, 223, 69, 97),
                                  ),
                                  child: const Text(
                                    "Remove",
                                    style: TextStyle(
                                      fontSize: 13.0,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 1,
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditPage(
                                              guestKey: key,
                                              company: widget.company),
                                        ),
                                      );
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 18, 185, 172),
                                  ),
                                  child: const Text(
                                    "Edit",
                                    style: TextStyle(
                                      fontSize: 13.0,
                                    ),
                                  ),
                                ),
                              ),
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
        ),
      );
    });
  }
}

class EditPage extends StatefulWidget {
  const EditPage({super.key, required this.guestKey, required this.company});
  final String guestKey;
  final String? company;
  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  static final formKey = GlobalKey<EditFormPageState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Form"),
        backgroundColor: const Color.fromARGB(255, 7, 152, 241),
        // leading: GestureDetector(
        //   onTap: () {
        //     Navigator.pop(context);
        //   },
        //   child: const Icon(
        //     Icons.arrow_back_ios,
        //     color: Colors.white,
        //   ),
        // ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20.0, top: 20.0),
            child: GestureDetector(
                onTap: () {
                  formKey.currentState?.onPressedSave();
                },
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 16),
                )),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: EditFormPage(
            key: formKey, guestKey: widget.guestKey, company: widget.company),
      ),
    );
  }
}

class EditFormPage extends StatefulWidget {
  const EditFormPage(
      {super.key, required this.guestKey, required this.company});

  final String? company;
  final String guestKey;
  @override
  State<EditFormPage> createState() => EditFormPageState();
}

class EditFormPageState extends State<EditFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _passKey = GlobalKey<FormFieldState>();

  // final database = FirebaseDatabase.instance.ref();
  // final guestRef = FirebaseDatabase.instance.ref().child('${widget.company}/GuestList/');

  // late TwilioFlutter twilioFlutter;

  String _name = '';
  String _number = '';
  String _brand = '';
  String _model = '';
  String _license = '';
  String _randNum = '';
  String _color = '';
  String _parking = '';
  String _selectedTime = '';
  String _roomNumber = '';
  // String _replies = '';
  late int _TimeListCount = 0;
  bool _nameCheck = false;
  bool _numCheck = false;
  bool _hasBeenPressed1 = false; //for confirmation button
  bool _hasBeenPressed2 = false; //for ticket button

  List<DropdownMenuItem<int>> TimeList = [];
  void loadTimeList() {
    TimeList = [];
    TimeList.add(const DropdownMenuItem(
      value: 0,
      child: Text(''),
    ));
    TimeList.add(const DropdownMenuItem(
      value: 1,
      child: Text('Hourly'),
    ));
    TimeList.add(const DropdownMenuItem(
      value: 2,
      child: Text('Overnight'),
    ));
    TimeList.add(const DropdownMenuItem(
      value: 3,
      child: Text('Restaurant'),
    ));
  }

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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _parkingController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();

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
              _randNum = guestData['Ticket ID'];
              _nameController.text = guestData['Name'];
              _roomController.text = guestData['Room'];
              _numberController.text = guestData['Phone'];
              _brandController.text = guestData['Brand'];
              _modelController.text = guestData['Model'];
              _licenseController.text = guestData['License'];
              _colorController.text = guestData['Color'];
              _parkingController.text = guestData['Parking'];
              _selectedTime = guestData['Rate Type'];
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
    loadTimeList();
    // Build a Form widget using the _formKey we created above
    return Form(
      key: _formKey,
      child: ListView(
        children: getFormWidget(),
      ),
    );
  }

  List<Widget> getFormWidget() {
    List<Widget> formWidget = [];
    formWidget.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 15, top: 25),
        child: Text(
          'Ticket ID: $_randNum',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            height: 0.1,
          ),
        ),
      ),
    );

    formWidget.add(TextFormField(
      controller: _nameController,
      decoration:
          const InputDecoration(labelText: 'Enter Name', hintText: 'Name'),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter a name';
        }
        Pattern pattern = r'^[a-zA-Z ]+$';
        RegExp regex = RegExp(pattern.toString());

        if (!regex.hasMatch(value.toString())) {
          return 'Enter a valid name';
        } else {
          _nameCheck = true;
          _name = value.toString();
        }
      },
    ));

    formWidget.add(
      TextFormField(
        controller: _roomController,
        decoration: const InputDecoration(
            labelText: 'Enter Room Number', hintText: 'Room'),
        validator: (value) {
          _roomNumber = value.toString();
          return null;
        },
        onSaved: (value) {
          _roomNumber = value!;
        },
      ),
    );

    validateNumber(String? value) {
      if (value!.isEmpty) {
        return 'Please enter phone number';
      }
      Pattern pattern = r'^[0-9]{10}$';
      RegExp regex = RegExp(pattern.toString());
      if (!regex.hasMatch(value.toString())) {
        return 'Enter Valid Number';
      } else {
        _numCheck = true;
        _number = value.toString();
      }
    }

    formWidget.add(TextFormField(
        controller: _numberController,
        decoration: const InputDecoration(
            labelText: 'Enter Phone Number', hintText: 'Number'),
        validator: validateNumber));

    void onPressedSubmit() {
      _formKey.currentState!.validate();
      _formKey.currentState?.save();

      if (_nameCheck == true && _numCheck == true) {
        _hasBeenPressed1 = true;
        // sendSms(_number, "Gang Shit cuh!");
        // getAllMessages();
        final snackBar = SnackBar(
          content: Container(
            margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: const Padding(
                padding: EdgeInsets.fromLTRB(90, 0, 0, 0),
                child:
                    Text('Confirmation Sent', style: TextStyle(fontSize: 20))),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }

    // void onPressedSubmit1() async {
    //   if (_formKey.currentState!.validate()) {
    //     _hasBeenPressed2 = true;

    //     try {
    //       await guest.push().set({
    //   'Ticket ID': _randNum,
    //   'Name': _name,
    //   'Phone': _number,
    //   'rateType': _selectedTime, // change name later
    //   'Brand': _brand,
    //   'Model': _model,
    //   'License': _license,
    //   'Color': _color,
    //   'Parking': _parking,
    //   'time': ServerValue.timestamp,
    //   'Status': 'In',
    //   'Valid Ticket': true,
    //   'Pending Request': false,
    //   'Accepted Request': false,
    // });

    //       print("Guest has been updated!");
    //     } catch (e) {
    //       print('You got an error! $e');
    //     }

    //     final snackBar = SnackBar(
    //       content: Container(
    //         margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
    //         child: const Padding(
    //             padding: EdgeInsets.fromLTRB(100, 0, 0, 0),
    //             child: Text('Ticket Created', style: TextStyle(fontSize: 20))),
    //       ),
    //     );
    //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
    //     Future.delayed(const Duration(seconds: 2), () {
    //       // Phoenix.rebirth(context);
    //     });
    //   }
    // }

    final ButtonStyle style1 = ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      textStyle: const TextStyle(fontSize: 17),
      backgroundColor: _hasBeenPressed1
          ? const Color.fromARGB(255, 166, 166, 166)
          : const Color.fromARGB(255, 39, 205, 243),
    );

    // final ButtonStyle style2 = ElevatedButton.styleFrom(
    //   textStyle: const TextStyle(fontSize: 17),
    //   backgroundColor: _hasBeenPressed2 ? Colors.green : Colors.blue,
    // );

    formWidget.add(Container(
      margin: const EdgeInsets.all(20.0),
      child: ElevatedButton(
        onPressed: onPressedSubmit,
        style: style1,
        child: const Text('Send Confirmation'),
      ),
    ));

    if (_selectedTime == 'Hourly') {
      _TimeListCount = 1;
    }
    if (_selectedTime == 'Overnight') {
      _TimeListCount = 2;
    } else {
      _TimeListCount = 3;
    }

    formWidget.add(DropdownButtonFormField(
      decoration: const InputDecoration(labelText: 'Select Time'),
      hint: const Text('Select Time'),
      items: TimeList,
      value: _TimeListCount,
      onChanged: (value) {
        setState(() {
          if (value == 1) {
            _selectedTime = "Hourly";
          }
          if (value == 2) {
            _selectedTime = "Overnight";
          }
          if (value == 3) {
            _selectedTime = "Restaurant";
          }
        });
      },
      isExpanded: true,
      menuMaxHeight: 800,
    ));

    formWidget.add(TextFormField(
      controller: _brandController,
      decoration:
          const InputDecoration(hintText: 'Brand', labelText: "Enter Brand"),
      // keyboardType: TextInputType.number,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Enter the brand';
        }
        Pattern pattern = r'^[a-zA-Z ]+$';
        RegExp regex = RegExp(pattern.toString());

        if (!regex.hasMatch(value.toString())) {
          return 'Enter a valid brand';
        } else {
          _brand = value.toString();
        }
      },
    ));

    formWidget.add(TextFormField(
      controller: _modelController,
      decoration:
          const InputDecoration(hintText: 'Model', labelText: "Enter Model"),
      // keyboardType: TextInputType.number,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Enter model';
        } else {
          _model = value.toString();
        }
      },
    ));

    formWidget.add(TextFormField(
      controller: _licenseController,
      decoration: const InputDecoration(
          hintText: 'License', labelText: 'Enter License Number'),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Enter license number';
        } else {
          _license = value.toString();
        }
      },
    ));

    formWidget.add(TextFormField(
      controller: _colorController,
      decoration:
          const InputDecoration(labelText: 'Enter Color', hintText: 'Color'),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter color of the car';
        }

        Pattern pattern = r'^[a-zA-Z]+$';
        RegExp regex = RegExp(pattern.toString());

        if (!regex.hasMatch(value.toString())) {
          return 'Enter a valid color';
        } else {
          _color = value.toString();
        }
      },
    ));

    formWidget.add(TextFormField(
      controller: _parkingController,
      decoration: const InputDecoration(
          labelText: 'Enter Parking Spot', hintText: 'Parking'),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter a parking spot';
        }

        Pattern pattern = r'^[a-zA-Z0-9]+$';
        RegExp regex = RegExp(pattern.toString());

        if (!regex.hasMatch(value.toString())) {
          return 'Enter a valid parking spot';
        } else {
          _parking = value.toString();
        }
      },
    ));

    return formWidget;
  }

  void onPressedSave() {
    if (_formKey.currentState!.validate()) {
      _hasBeenPressed2 = true;
      final guestRef =
          FirebaseDatabase.instance.ref().child('${widget.company}/GuestList/');
      try {
        guestRef.child(widget.guestKey).update({
          //'Ticket ID': _randNum,
          'Name': _name,
          'Phone': _number,
          'Rate Type': _selectedTime,
          'Brand': _brand,
          'Room': _roomNumber,
          'Model': _model,
          'License': _license,
          'Color': _color,
          'Parking': _parking,
          //'time': ServerValue.timestamp,
          //'Location': 'Checked in'
        });

        print("Guest has been updated!");
      } catch (e) {
        print('You got an error! $e');
      }

      final snackBar = SnackBar(
        content: Container(
          margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: const Padding(
              padding: EdgeInsets.fromLTRB(100, 0, 0, 0),
              child: Text('Ticket Updated', style: TextStyle(fontSize: 20))),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context);
        // Phoenix.rebirth(context);
      });
    }
  }
}
