import 'dart:math';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'homepage.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:mailer/mailer.dart';

// import 'package:twilio_dart_api/models/credential.dart';

class Start extends StatelessWidget {
  const Start({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Flex(
          direction: Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUp()),
                );
              },
              child: const SizedBox(
                width: 180,
                child: Text(
                  'Sign up',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                );
              },
              child: const SizedBox(
                width: 180,
                child: Text(
                  'Login',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

String username = '';

class _LoginState extends State<Login> {
  final database = FirebaseDatabase.instance.ref();
  bool passwordOrUsername = false;
  bool passwordVisible = true;
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late String company;

  @override
  Widget build(BuildContext context) {
    final DatabaseReference userRef = database.child('Users/');

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(40, 60, 40, 0),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: -10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 200),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(-1.0, 0.0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        );
                      },
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return const Start();
                      },
                    ),
                  );
                },
              ),
            ),
            Center(
              child: Flex(
                direction: Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                  const SizedBox(height: 50),
                  if (passwordOrUsername)
                    const Text(
                      'Incorrect username or password',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  if (passwordOrUsername) const SizedBox(height: 5),
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Username',
                    ),
                  ),
                  const SizedBox(height: 25),
                  TextField(
                    obscureText: passwordVisible,
                    controller: passwordController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            passwordVisible = !passwordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ForgotPassword()));
                    },
                    child: const Text(
                      'Forgot your password?',
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      username = usernameController.text;
                      String password = passwordController.text;

                      try {
                        DatabaseEvent event = await userRef
                            .orderByChild('username')
                            .equalTo(username)
                            .once();
                        DataSnapshot snapshot = event.snapshot;

                        if (snapshot.value != null) {
                          // Username exists in the database
                          // Collecting keys from the snapshot
                          List<String> keys = [];
                          Map<dynamic, dynamic>? values =
                              snapshot.value as Map<dynamic, dynamic>?;

                          if (values != null) {
                            values.forEach((key, value) {
                              keys.add(key.toString());
                            });

                            if (keys.isNotEmpty) {
                              String userKey =
                                  keys.first; // Assuming there's only one match
                              if (values[userKey]['password'] == password) {
                                company = values[userKey]['company'];
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Homepage(
                                            company: company,
                                          )),
                                );
                              } else {
                                // Password is incorrect
                                // Handle the case where the password is incorrect
                                setState(() {
                                  passwordOrUsername = true;
                                });
                              }
                            }
                          }
                        } else {
                          // Username doesn't exist in the database
                          // Handle the case where the username is not found
                          setState(() {
                            passwordOrUsername = true;
                          });
                        }
                      } catch (error) {
                        print("Error retrieving data: $error");
                        // Handle the error
                      }
                    },
                    child: const SizedBox(
                      width: 200,
                      child: Text(
                        'Login',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

getUserName() {
  return username;
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final database = FirebaseDatabase.instance.ref();
  bool sentEmail = false;
  bool emailPresent = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  String verificationCode = '';
  String email = '';

  String generateRandomString() {
    const chars = "0123456789";
    Random random = Random();
    String result = "";

    for (int i = 0; i < 6; i++) {
      int index = random.nextInt(chars.length);
      result += chars[index];
    }

    return result;
  }

  void sendEmail(String recipientEmail, String verificationCode) async {
    String username = 'jashitandryan@gmail.com'; //Your Email
    String password =
        'lqtfnjweouxglsha'; // 16 Digits App Password Generated From Google Account

    final smtpServer = gmail(username, password);
    // Use the SmtpServer class to configure an SMTP server:
    // final smtpServer = SmtpServer('smtp.domain.com');
    // See the named arguments of SmtpServer for further configuration
    // options.

    // Create our message.
    final message = Message()
          ..from = Address(username, 'Curbify LLC.')
          ..recipients.add(recipientEmail)
          // ..ccRecipients.addAll(['abc@gmail.com', 'xyz@gmail.com']) // For Adding Multiple Recipients
          // ..bccRecipients.add(Address('a@gmail.com')) For Binding Carbon Copy of Sent Email
          ..subject = 'Confirmation'
          ..text =
              'This is a test email to confirm that your email is valid. Your verifcation coede is $verificationCode.'
        // ..html = "<h1>Test</h1>\n<p>Hey! Here's some HTML content</p>"; // For Adding Html in email
        // ..attachments = [
        //   FileAttachment(File('image.png'))  //For Adding Attachments
        //     ..location = Location.inline
        //     ..cid = '<myimg@3.141>'
        // ]
        ;

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: $sendReport');
    } on MailerException catch (e) {
      print('Message not sent.');
      print(e.message);
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseReference userRef = database.child('Users/');
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(40, 60, 40, 0),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: -10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 200),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(-1.0, 0.0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        );
                      },
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return const Login();
                      },
                    ),
                  );
                },
              ),
            ),
            Flex(
              direction: Axis.vertical,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Find your account',
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Enter the email associated with your account',
                  style: TextStyle(
                    color: Color.fromARGB(255, 131, 131, 131),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                  ),
                ),
                const SizedBox(height: 25),
                if (!sentEmail)
                  ElevatedButton(
                    onPressed: () async {
                      email = emailController.text;

                      try {
                        DatabaseEvent event = await userRef
                            .orderByChild('email')
                            .equalTo(email)
                            .once();
                        DataSnapshot snapshot = event.snapshot;

                        if (snapshot.value != null) {
                          // Username exists in the database
                          verificationCode = generateRandomString();
                          sendEmail(email, verificationCode);
                          setState(() {
                            sentEmail = true;
                          });
                        } else {
                          // Username doesn't exist in the database
                          setState(() {
                            emailPresent = false;
                          });
                        }
                      } catch (error) {
                        print("Error retrieving data: $error");
                        // Handle the error
                      }
                    },
                    child: const Text('Next'),
                  ),
                if (sentEmail)
                  const Text(
                    'An email has been sent to your email address with a verification code',
                    style: TextStyle(
                      color: Color.fromARGB(255, 131, 131, 131),
                    ),
                  ),
                if (sentEmail) const SizedBox(height: 20),
                if (sentEmail)
                  TextField(
                    controller: codeController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Verification code',
                    ),
                  ),
                if (sentEmail) const SizedBox(height: 20),
                if (sentEmail)
                  ElevatedButton(
                    onPressed: () {
                      if (verificationCode == codeController.text) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ResetPassword(email: email)),
                        );
                      }
                    },
                    child: const Text('Next'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ResetPassword extends StatefulWidget {
  ResetPassword({super.key, required this.email});

  String email;

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final database = FirebaseDatabase.instance.ref();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool match = true;
  bool passwordVisible1 = true;
  bool passwordVisible2 = true;
  @override
  Widget build(BuildContext context) {
    final DatabaseReference userRef = database.child('Users/');
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(40, 60, 40, 0),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: -10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 200),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(-1.0, 0.0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        );
                      },
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return const Start();
                      },
                    ),
                  );
                },
              ),
            ),
            Flex(
              direction: Axis.vertical,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Create a New Password',
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
                if (!match) const SizedBox(height: 10),
                if (!match)
                  const Text(
                    'Your passwords must be match',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                const SizedBox(height: 20),
                TextField(
                  obscureText: passwordVisible1,
                  controller: passwordController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(passwordVisible1
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          passwordVisible1 = !passwordVisible1;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  obscureText: passwordVisible1,
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Confirm Password',
                    suffixIcon: IconButton(
                      icon: Icon(passwordVisible2
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          passwordVisible2 = !passwordVisible2;
                        });
                      },
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String confirmPassword = confirmPasswordController.text;
                    String password = passwordController.text;

                    try {
                      DatabaseEvent event = await userRef
                          .orderByChild('email')
                          .equalTo(widget.email)
                          .once();
                      DataSnapshot snapshot = event.snapshot;

                      if (snapshot.value != null) {
                        // Username exists in the database
                        // Collecting keys from the snapshot
                        List<String> keys = [];
                        Map<dynamic, dynamic>? values =
                            snapshot.value as Map<dynamic, dynamic>?;

                        if (values != null) {
                          values.forEach((key, value) {
                            keys.add(key.toString());
                          });

                          if (keys.isNotEmpty) {
                            String userKey =
                                keys.first; // Assuming there's only one match
                            // ...
                            // Rest of your logic here
                            if (confirmPassword == password) {
                              // Create a map with user information
                              Map<String, dynamic> userData = {
                                'password': password,
                              };
                              // Set the user data under the generated user ID
                              await userRef.child(userKey).update(userData);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPassword()),
                              );
                            } else {
                              setState(() {
                                match = false;
                              });
                            }
                          }
                        }
                      }
                      // else {}
                    } catch (error) {
                      print("Error retrieving data: $error");
                    }
                  },
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final database = FirebaseDatabase.instance.ref();
  bool credentials = true;

  @override
  Widget build(BuildContext context) {
    final DatabaseReference userRef = database.child('Users/');
    TextEditingController companyController = TextEditingController();
    TextEditingController userIdController = TextEditingController();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(40, 60, 40, 0),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: -10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 200),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(-1.0, 0.0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        );
                      },
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return const Start();
                      },
                    ),
                  );
                },
              ),
            ),
            Flex(
              direction: Axis.vertical,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'New Valet',
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 50),
                if (!credentials)
                  const Text(
                    'Invalid Company Name or User ID',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                if (!credentials) const SizedBox(height: 5),
                TextField(
                  controller: companyController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Company Name',
                  ),
                ),
                const SizedBox(height: 25),
                TextField(
                  controller: userIdController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'User ID',
                  ),
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () async {
                    /*{
                    String username = usernameController.text;
                    String password = passwordController.text;

                    try {
                      DatabaseEvent event = await userRef.orderByChild('username').equalTo(username).once();
                      DataSnapshot snapshot = event.snapshot;

                      if (snapshot.value != null) {
                        // Username exists in the database
                        // Collecting keys from the snapshot
                        List<String> keys = [];
                        Map<dynamic, dynamic>? values = snapshot.value as Map<dynamic, dynamic>?;

                        if (values != null) {
                          values.forEach((key, value) {
                            keys.add(key.toString());
                          });

                          if (keys.isNotEmpty) {
                            String userKey = keys.first; // Assuming there's only one match
                            // ...
                            // Rest of your logic here
                            if(values[userKey]['password'] == password) {
                              company = values[userKey]['company'];
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Homepage(company: company,)),
                              );
                            } else {
                              // Password is incorrect
                              // Handle the case where the password is incorrect
                              setState(() {
                                passwordOrUsername = true;
                              });
                            }
                          }
                        } */
                    String companyName = companyController.text;
                    String userId = userIdController.text;

                    try {
                      DatabaseEvent event = await userRef.child(userId).once();
                      DataSnapshot snapshot = event.snapshot;
                      String? company;
                      if (snapshot.value != null &&
                          companyName.isNotEmpty &&
                          userId.isNotEmpty) {
                        Map<dynamic, dynamic>? userData =
                            snapshot.value as Map<dynamic, dynamic>?;
                        if (userData != null) {
                          company = userData['company'] as String?;
                        }
                        if (companyName == company) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Credentials(
                                    userId: userId, company: company)),
                          );
                        }
                      } else {
                        setState(() {
                          print(credentials);
                          credentials = false;
                          print(credentials);
                        });
                      }
                    } catch (error) {
                      print("Error retrieving data: $error");
                      // Handle the error
                    }
                  },
                  child: const SizedBox(
                    width: 200,
                    child: Text(
                      'Next',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Credentials extends StatefulWidget {
  const Credentials({super.key, required this.userId, required this.company});

  final String? company;
  final String userId;

  @override
  State<Credentials> createState() => _CredentialsState();
}

class _CredentialsState extends State<Credentials> {
  final database = FirebaseDatabase.instance.ref();
  bool empty = true;
  bool matchingPassword = true;
  bool passwordVisible1 = true;
  bool passwordVisible2 = true;

  @override
  Widget build(BuildContext context) {
    final DatabaseReference userRef = database.child('Users/');
    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(40, 60, 40, 0),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: -10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 200),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(-1.0, 0.0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        );
                      },
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return const SignUp();
                      },
                    ),
                  );
                },
              ),
            ),
            Flex(
              direction: Axis.vertical,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Credentials',
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 50),
                if (!empty)
                  const Text(
                    'Please fill out all fields',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                if (!matchingPassword && empty)
                  const Text(
                    'Passwords do not match',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                if (!empty || !matchingPassword) const SizedBox(height: 5),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter Username',
                  ),
                ),
                const SizedBox(height: 25),
                TextField(
                  obscureText: passwordVisible1,
                  controller: passwordController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Enter New Password',
                    suffixIcon: IconButton(
                      icon: Icon(passwordVisible1
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          passwordVisible1 = !passwordVisible1;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                TextField(
                  obscureText: passwordVisible2,
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Confirm Password',
                    suffixIcon: IconButton(
                      icon: Icon(passwordVisible2
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          passwordVisible2 = !passwordVisible2;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () async {
                    String username = usernameController.text;
                    String password = passwordController.text;
                    String confirmPassword = confirmPasswordController.text;

                    if (username.isEmpty ||
                        password.isEmpty ||
                        confirmPassword.isEmpty) {
                      setState(() {
                        empty = false;
                      });
                    } else if (password != confirmPassword) {
                      setState(() {
                        empty = true;
                        matchingPassword = false;
                      });
                    } else {
                      try {
                        // Create a map with user information
                        Map<String, dynamic> userData = {
                          'username': username,
                          'password': password,
                        };

                        // Set the user data under the generated user ID
                        await userRef.child(widget.userId).update(userData);

                        // Navigate to the next screen after saving the user data
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Homepage(
                                    company: widget.company,
                                  )),
                        );
                      } catch (error) {
                        print("Error saving user data: $error");
                        setState(() {
                          empty = false;
                        });
                      }
                    }

                    // try {
                    //   DatabaseEvent event = await userRef.child(userId).once();
                    //   DataSnapshot snapshot = event.snapshot;

                    //   if (snapshot.value != null && companyName.isNotEmpty && userId.isNotEmpty) {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(builder: (context) => const Credentials()),
                    //     );
                    //   } else {

                    //     setState(() {print(credentials);
                    //       credentials = false;
                    //       print(credentials);
                    //     });
                    //   }
                    // } catch (error) {
                    //   print("Error retrieving data: $error");
                    //   // Handle the error
                    // }
                  },
                  child: const SizedBox(
                    width: 200,
                    child: Text(
                      'Next',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
