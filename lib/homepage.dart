import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
import 'dart:math';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'request.dart';
import 'log.dart';
import 'settings.dart';
import 'theme_provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class Homepage extends StatefulWidget {
  const Homepage({super.key, required this.company});

  final String? company;

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ticket',
      theme: context.watch<ThemeProvider>().themeData,
      home: FormPage(title: '', company: widget.company),
    );
  }
}

class FormPage extends StatefulWidget {
  const FormPage({Key? key, required this.title, required this.company})
      : super(key: key);

  final String title;
  final String? company;

  @override
  FormPageState createState() => FormPageState();
}

class FormPageState extends State<FormPage> {
  static final formKey = GlobalKey<ValetFormState>();
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      ThemeData currentTheme = themeProvider.themeData;
      bool darkMode = currentTheme.brightness == Brightness.dark;
      return DefaultTabController(
        length: 4,
        child: Scaffold(
          backgroundColor: darkMode
              ? const Color.fromARGB(255, 52, 54, 66)
              : const Color.fromARGB(255, 236, 242, 242),
          body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverAppBar(
                      pinned: true,
                      snap: false,
                      floating: true,
                      expandedHeight: 103.0, //133
                      backgroundColor: const Color.fromARGB(255, 7, 152, 241),
                      title: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      bottom: const TabBar(
                        tabs: [
                          Tab(
                            icon: Icon(Icons.add_circle),
                            text: "Ticket",
                          ),
                          Tab(
                            icon: Icon(Icons.find_in_page_sharp),
                            text: "Requests",
                          ),
                          Tab(
                            icon: Icon(Icons.home),
                            text: "Log",
                          ),
                          Tab(
                            icon: Icon(Icons.settings),
                            text: "Settings",
                          ),
                        ],
                        indicatorColor: Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                  ],
              body: TabBarView(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: ValetForm(
                      key: formKey,
                      darkMode: darkMode,
                      company: widget.company,
                    ),
                  ),
                  Request(
                    company: widget.company,
                  ),
                  Log(company: widget.company),
                  Settings(company: widget.company),
                ],
              )),
        ),
      );
    });
  }
}

class ValetForm extends StatefulWidget {
  ValetForm({
    key,
    required this.darkMode,
    required this.company,
  }) : super(key: key);

  bool darkMode;
  final String? company;

  @override
  ValetFormState createState() => ValetFormState();
}

class ValetFormState extends State<ValetForm> {
  final _formKey = GlobalKey<FormState>();
  final _passKey = GlobalKey<FormFieldState>();

  final database = FirebaseDatabase.instance.ref();

  late TwilioFlutter twilioFlutter;

  String _name = '';
  String _number = '';
  String _brand = '';
  String _model = '';
  String _license = '';
  String _randNum = '';
  String _color = '';
  String _parking = '';
  String _selectedTime = '';
  String _replies = '';
  int _TimeListCount = 0;
  bool _nameCheck = false;
  bool _numCheck = false;
  bool _hasBeenPressed1 = false; //for confirmation button
  bool _hasBeenPressed2 = false; //for ticket button
  String _room = 'BLANK';
  Color _buttonColor = const Color.fromARGB(255, 39, 205, 243);

  // For Camera
  bool _front = false;
  bool _back = false;
  bool _left = false;
  bool _right = false;
  late File frontImg = File('');
  late File backImg = File('');
  late File leftImg = File('');
  late File rightImg = File('');
  var frontImageUrl = '';
  var backImageUrl = '';
  var rightImageUrl = '';
  var leftImageUrl = '';
  final frontPicker = ImagePicker();
  final backPicker = ImagePicker();
  final leftPicker = ImagePicker();
  final rightPicker = ImagePicker();
  late BuildContext original;
  bool atLeastOne = false;

  List<DropdownMenuItem<int>> TimeList = [];
  void loadTimeList() {
    TimeList = [];
    TimeList.add(const DropdownMenuItem(
      value: 0,
      child: Text('-Select Time-'),
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

  late TwilioFlutter twilio;

  @override
  void initState() {
    super.initState();

    twilio = TwilioFlutter(
        accountSid: dotenv.env['TWILIO_ACCOUNT_SID']!,
        authToken: dotenv.env['TWILIO_AUTH_TOKEN']!,
        twilioNumber: dotenv.env['TWILIO_NUMBER']!);
  }

  void sendSms(String number, String SmsMessage) async {
    twilio.sendSMS(toNumber: '+1$number', messageBody: SmsMessage);
  }

  void getAllMessages() async {
    _replies = twilio.getSmsList().toString();

    print(_replies);
  }

  void getRandNum() {
    if (_randNum == '') {
      var rndnumber = "";
      var rnd = Random();
      for (var i = 0; i < 6; i++) {
        rndnumber = rndnumber + rnd.nextInt(9).toString();
      }
      _randNum = rndnumber;
    }
  }

  @override
  Widget build(BuildContext context) {
    loadTimeList(); //function
    getRandNum(); // function
    // Build a Form widget using the _formKey we created above
    return Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.zero,
          children: getFormWidget(),
        ));
  }

  List<Widget> getFormWidget() {
    List<Widget> formWidget = [];
    final usersRef = database.child('Users/');

    formWidget.add(
      Container(
        color: widget.darkMode
            ? const Color.fromARGB(255, 52, 54, 66)
            : const Color.fromARGB(255, 236, 242, 242),
        margin: const EdgeInsets.only(top: 20, bottom: 5),
        padding: const EdgeInsets.only(top: 7.5, bottom: 7.5),
        child: Text(
          'Ticket ID: $_randNum',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ),
      ),
    );

    formWidget.add(const SizedBox(height: 20));

    // Define a focus node
    final FocusNode _nameFocusNode = FocusNode();
    _nameFocusNode.addListener(() {
      if (!_nameFocusNode.hasFocus) {
        FocusManager.instance.primaryFocus?.unfocus();
      }
    });

    formWidget.add(
      TextFormField(
        decoration: const InputDecoration(
          labelText: 'Enter Name',
          hintText: 'Name',
        ),
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
          return null;
        },
        focusNode: _nameFocusNode,
      ),
    );

    // Define a focus node
    final FocusNode _roomFocusNode = FocusNode();
    _roomFocusNode.addListener(() {
      if (!_roomFocusNode.hasFocus) {
        // If focus is lost, dismiss the keyboard
        FocusManager.instance.primaryFocus?.unfocus();
      }
    });

    formWidget.add(
      TextFormField(
        decoration: const InputDecoration(
          labelText: 'Enter Room Number(optional)',
          hintText: 'Room',
        ),
        validator: (value) {
          _room = value.toString();
          return null;
        },
        onSaved: (value) {
          _room = value!;
        },
        focusNode: _roomFocusNode,
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
      return null;
    }

    // Define a focus node
    final FocusNode _phoneNumberFocusNode = FocusNode();
    _phoneNumberFocusNode.addListener(() {
      if (!_phoneNumberFocusNode.hasFocus) {
        // If focus is lost, dismiss the keyboard
        FocusManager.instance.primaryFocus?.unfocus();
      }
    });

    formWidget.add(
      TextFormField(
        key: _passKey,
        decoration: const InputDecoration(
          labelText: 'Enter Phone Number',
          hintText: 'Number',
        ),
        keyboardType: TextInputType.number,
        validator: validateNumber,
        onSaved: (value) {
          _number = value!;
        },
        // Assign the focus node
        focusNode: _phoneNumberFocusNode,
      ),
    );

    // Method to upload image to Firebase Storage and get its download URL
    Future<String> uploadImageAndGetUrl(File imageFile) async {
      if (imageFile == File('')) {
        return '';
      } else {
        var imageName = DateTime.now().millisecondsSinceEpoch.toString();
        var storageRef = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('car_images/$imageName.jpg');
        var uploadTask = await storageRef.putFile(imageFile);
        final String downloadUrl = await uploadTask.ref.getDownloadURL();
        return downloadUrl;
      }
    }

    void onPressedSubmit() {
      _formKey.currentState!.validate();

      if (_nameCheck == true && _numCheck == true) {
        setState(() {
          _hasBeenPressed1 = true;
          _buttonColor = const Color.fromARGB(255, 72, 190, 126);
        });

        sendSms(_number,
            "Your car has been parked. Reply with 'car' to this message when you want to get the car back!");
        getAllMessages();
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

    void onPressedSubmit1() async {
      if (_formKey.currentState!.validate() && atLeastOne) {
        _hasBeenPressed2 = true;

        try {
          final guest = database.child('${widget.company}/GuestList/');
          if (_room == '') {
            _room = "BLANK";
          }
          await guest.push().set({
            'Ticket ID': _randNum,
            'Name': _name,
            'Room': _room,
            'Phone': _number,
            'Rate Type': _selectedTime, // change name later
            'Brand': _brand,
            'Model': _model,
            'License': _license,
            'Color': _color,
            'Parking': _parking,
            'Time': DateTime.now().toString(),
            'Status': 'In',
            'Valid Ticket': true,
            'Pending Request': false,
            'Accepted Request': false,
            'Front Image': frontImageUrl.toString(),
            'Back Image': backImageUrl.toString(),
            'Left Image': leftImageUrl.toString(),
            'Right Image': rightImageUrl.toString()
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
                child: Text('Ticket Created', style: TextStyle(fontSize: 20))),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        Future.delayed(const Duration(seconds: 2), () {
          var rndnumber = "";
          var rnd = Random();
          for (var i = 0; i < 6; i++) {
            rndnumber = rndnumber + rnd.nextInt(9).toString();
          }
          setState(() {
            _randNum = rndnumber;
          });
          // Reset fields
          _formKey.currentState?.reset();
        });
      } else {
        setState(() {
          atLeastOne = false;
        });
      }
    }

    final ButtonStyle style2 = ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      textStyle: const TextStyle(fontSize: 17),
      backgroundColor: const Color.fromARGB(255, 72, 190, 126), //103,218,100
    );

    formWidget.add(
      Container(
        height: 42.5,
        // padding: const EdgeInsets.only(top: 10),
        margin: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          onPressed: onPressedSubmit,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            textStyle: const TextStyle(fontSize: 17),
            backgroundColor: _buttonColor,
          ),
          child: const Text('Send Confirmation'),
        ),
      ),
    );

    formWidget.add(const SizedBox(height: 10));

    formWidget.add(DropdownButtonFormField(
      decoration: const InputDecoration(labelText: 'Type'),
      items: TimeList,
      value: _TimeListCount == 0 ? null : _TimeListCount,
      onChanged: (newValue) {
        setState(() {
          if (newValue == 1) {
            _selectedTime = "Hourly";
          }
          if (newValue == 2) {
            _selectedTime = "Overnight";
          }
          if (newValue == 3) {
            _selectedTime = "Restaurant";
          }
        });
      },
      isExpanded: true,
      menuMaxHeight: 800,
    ));

    // Define a focus node
    final FocusNode _brandFocusNode = FocusNode();
    _brandFocusNode.addListener(() {
      if (!_brandFocusNode.hasFocus) {
        // If focus is lost, dismiss the keyboard
        FocusManager.instance.primaryFocus?.unfocus();
      }
    });

    formWidget.add(
      TextFormField(
        decoration: const InputDecoration(
          hintText: 'Brand',
          labelText: 'Enter Brand',
        ),
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
          return null;
        },
        onSaved: (value) {
          _brand = value!;
        },
        // Assign the focus node
        focusNode: _brandFocusNode,
      ),
    );

    // Define a focus node
    final FocusNode _modelFocusNode = FocusNode();
    _modelFocusNode.addListener(() {
      if (!_modelFocusNode.hasFocus) {
        // If focus is lost, dismiss the keyboard
        FocusManager.instance.primaryFocus?.unfocus();
      }
    });

    formWidget.add(
      TextFormField(
        decoration: const InputDecoration(
          hintText: 'Model',
          labelText: 'Enter Model',
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return 'Enter model';
          } else {
            _model = value.toString();
          }
          return null;
        },
        onSaved: (value) {
          _model = value!;
        },
        // Assign the focus node
        focusNode: _modelFocusNode,
      ),
    );

    // Define a focus node
    final FocusNode _licenseFocusNode = FocusNode();
    _licenseFocusNode.addListener(() {
      if (!_licenseFocusNode.hasFocus) {
        // If focus is lost, dismiss the keyboard
        FocusManager.instance.primaryFocus?.unfocus();
      }
    });

    formWidget.add(
      TextFormField(
        decoration: const InputDecoration(
          hintText: 'License',
          labelText: 'Enter License Number',
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return 'Enter license number';
          } else {
            _license = value.toString();
          }
          return null;
        },
        onSaved: (value) {
          _license = value!;
        },
        // Assign the focus node
        focusNode: _licenseFocusNode,
      ),
    );

    // Define a focus node
    final FocusNode _colorFocusNode = FocusNode();
    _colorFocusNode.addListener(() {
      if (!_colorFocusNode.hasFocus) {
        // If focus is lost, dismiss the keyboard
        FocusManager.instance.primaryFocus?.unfocus();
      }
    });

    formWidget.add(TextFormField(
      decoration: const InputDecoration(
        labelText: 'Enter Color',
        hintText: 'Color',
      ),
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
        return null;
      },
      onSaved: (value) {
        _color = value!;
      },
      focusNode: _colorFocusNode,
    ));

    // Define a focus node
    final FocusNode _parkingFocusNode = FocusNode();
    _parkingFocusNode.addListener(() {
      if (!_parkingFocusNode.hasFocus) {
        // If focus is lost, dismiss the keyboard
        FocusManager.instance.primaryFocus?.unfocus();
      }
    });

    formWidget.add(
      TextFormField(
        decoration: const InputDecoration(
            labelText: 'Enter Parking Spot (Optional)', hintText: 'Parking'),
        validator: (value) {
          _parking = value.toString();
          return null;
        },
        onSaved: (value) {
          _parking = value!;
        },
        focusNode: _parkingFocusNode,
      ),
    );

    formWidget.add(const SizedBox(height: 30));

    // ***** CAMERA IMPLEMENTATION *****

    // FRONT
    Future<void> frontCamera(BuildContext context) async {
      var imgCamera = await frontPicker.pickImage(source: ImageSource.camera);
      setState(() {
        frontImg = File(imgCamera!.path);
        _front = true;
        atLeastOne = true;
      });
      frontImageUrl = await uploadImageAndGetUrl(frontImg);
      Navigator.of(context).pop();
    }

    Future<void> frontBuffer(BuildContext context) {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return FutureBuilder<void>(
            future: frontCamera(context), // Pass the context to frontCamera
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return const AlertDialog();
              } else {
                return const Center(
                  child:
                      CircularProgressIndicator(), // Show a loading indicator
                );
              }
            },
          );
        },
      );
    }

    // BACK
    Future<void> backCamera(BuildContext context) async {
      var imgCamera = await backPicker.pickImage(source: ImageSource.camera);
      setState(() {
        backImg = File(imgCamera!.path);
        _back = true;
        atLeastOne = true;
      });
      backImageUrl = await uploadImageAndGetUrl(backImg);
      Navigator.of(context).pop();
    }

    Future<void> backBuffer(BuildContext context) {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return FutureBuilder<void>(
            future: backCamera(context), // Pass the context to frontCamera
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return const AlertDialog();
              } else {
                return const Center(
                  child:
                      CircularProgressIndicator(), // Show a loading indicator
                );
              }
            },
          );
        },
      );
    }

    // LEFT
    Future<void> leftCamera(BuildContext context) async {
      var imgCamera = await leftPicker.pickImage(source: ImageSource.camera);
      setState(() {
        leftImg = File(imgCamera!.path);
        _left = true;
        atLeastOne = true;
      });
      leftImageUrl = await uploadImageAndGetUrl(leftImg);
      Navigator.of(context).pop();
    }

    Future<void> leftBuffer(BuildContext context) {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return FutureBuilder<void>(
            future: leftCamera(context), // Pass the context to frontCamera
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return const AlertDialog();
              } else {
                return const Center(
                  child:
                      CircularProgressIndicator(), // Show a loading indicator
                );
              }
            },
          );
        },
      );
    }

    // RIGHT
    Future<void> rightCamera(BuildContext context) async {
      var imgCamera = await rightPicker.pickImage(source: ImageSource.camera);
      setState(() {
        rightImg = File(imgCamera!.path);
        _right = true;
        atLeastOne = true;
      });
      rightImageUrl = await uploadImageAndGetUrl(rightImg);
      Navigator.of(context).pop();
    }

    Future<void> rightBuffer(BuildContext context) {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return FutureBuilder<void>(
            future: rightCamera(context), // Pass the context to frontCamera
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return const AlertDialog();
              } else {
                return const Center(
                  child:
                      CircularProgressIndicator(), // Show a loading indicator
                );
              }
            },
          );
        },
      );
    }

    formWidget.add(Column(
      children: [
        Container(
          alignment: Alignment.center,
          // margin: const EdgeInsets.only(top: 0),
          child: const Text('Damages',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
        ),
        if (atLeastOne == false) ...[
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(top: 2),
            child: const Text(
              'Must take at least 1 photo',
              style: TextStyle(fontSize: 15, color: Colors.red),
            ),
          ),
        ],
      ],
    ));

    formWidget.add(Row(
      children: [
        if (_front == false) ...[
          Container(
            height: 40,
            width: 135,
            margin: const EdgeInsets.all(20.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 39, 205, 243),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              onPressed: () {
                frontBuffer(context);
              },
              icon: const Icon(Icons.add),
              label: const Text('Front'),
            ),
          ),
        ],
        if (_front == true) ...[
          Container(
            height: 40,
            width: 135,
            margin: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 103, 218, 100),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              onPressed: () {
                original = context;
                showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: const Text('Front Side'),
                    content: Image.file(
                      frontImg,
                      height: 400,
                      width: 500,
                    ),
                    actions: <CupertinoDialogAction>[
                      CupertinoDialogAction(
                        child: const Text('Retake Image'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Future.delayed(
                            const Duration(seconds: 2),
                            (() {
                              frontBuffer(original);
                            }),
                          );
                        },
                      ),
                      CupertinoDialogAction(
                        child: const Text('Exit'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Front - [View]'),
            ),
          ),
        ],
        if (_back == false) ...[
          Container(
            height: 40,
            margin: const EdgeInsets.all(20.0),
            width: 135,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 39, 205, 243),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
              ),
              onPressed: () {
                backBuffer(context);
              },
              icon: const Icon(Icons.add),
              label: const Text('Back'),
            ),
          ),
        ],
        if (_back == true) ...[
          Container(
            height: 40,
            width: 135,
            margin: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 103, 218, 100),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              onPressed: () {
                original = context;
                showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: const Text('Back Side'),
                    content: Image.file(
                      backImg,
                      height: 400,
                      width: 500,
                    ),
                    actions: <CupertinoDialogAction>[
                      CupertinoDialogAction(
                        child: const Text('Retake Image'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Future.delayed(
                            const Duration(seconds: 2),
                            (() {
                              backBuffer(original);
                            }),
                          );
                        },
                      ),
                      CupertinoDialogAction(
                        child: const Text('Exit'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Back - [View]'),
            ),
          ),
        ],
      ],
    ));
    formWidget.add(Row(
      children: [
        if (_left == false) ...[
          Container(
            height: 40,
            width: 135,
            margin: const EdgeInsets.all(20.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 39, 205, 243),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
              ),
              onPressed: () {
                leftBuffer(context);
              },
              icon: const Icon(Icons.add),
              label: const Text('Left'),
            ),
          ),
        ],
        if (_left == true) ...[
          Container(
            height: 40,
            width: 135,
            margin: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 103, 218, 100),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              onPressed: () {
                original = context;
                showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: const Text('Left Side'),
                    content: Image.file(
                      leftImg,
                      height: 400,
                      width: 500,
                    ),
                    actions: <CupertinoDialogAction>[
                      CupertinoDialogAction(
                        child: const Text('Retake Image'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Future.delayed(
                            const Duration(seconds: 2),
                            (() {
                              leftBuffer(original);
                            }),
                          );
                        },
                      ),
                      CupertinoDialogAction(
                        child: const Text('Exit'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Left - [View]'),
            ),
          ),
        ],
        if (_right == false) ...[
          Container(
            height: 40,
            width: 135,
            margin: const EdgeInsets.all(20.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 39, 205, 243),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
              ),
              onPressed: () {
                rightBuffer(context);
              },
              icon: const Icon(Icons.add),
              label: const Text('Right'),
            ),
          ),
        ],
        if (_right == true) ...[
          Container(
            height: 40,
            width: 135,
            margin: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 103, 218, 100),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              onPressed: () {
                original = context;
                showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: const Text('Right Side'),
                    content: Image.file(
                      rightImg,
                      height: 400,
                      width: 500,
                    ),
                    actions: <CupertinoDialogAction>[
                      CupertinoDialogAction(
                        child: const Text('Retake Image'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Future.delayed(
                            const Duration(seconds: 2),
                            (() {
                              rightBuffer(original);
                            }),
                          );
                        },
                      ),
                      CupertinoDialogAction(
                        child: const Text('Exit'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Right - [View]'),
            ),
          ),
        ],
      ],
    ));

    formWidget.add(
      Container(
        height: 45,
        // padding: const EdgeInsets.only(top: 10),
        margin: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          onPressed: onPressedSubmit1,
          style: style2,
          child: const Text('Create Ticket'),
        ),
      ),
    );

    return formWidget;
  }
}
