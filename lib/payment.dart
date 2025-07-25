import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class Payment extends StatelessWidget {
  const Payment({super.key, required this.company});
  final String? company;

  @override
  Widget build(BuildContext context) => MaterialApp(
        // theme: _buildTheme(),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const PaymentScreen(),
        },
      );
}

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Map<String, dynamic>? paymentIntent;

  @override
  void initState() {
    Stripe.instance.isPlatformPaySupportedListenable.addListener(update);
    super.initState();
  }

  @override
  void dispose() {
    Stripe.instance.isPlatformPaySupportedListenable.removeListener(update);
    super.dispose();
  }

  void update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stripe Payment'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Make Payment'),
          onPressed: () async {
            await makePayment();
          },
        ),
      ),
    );
  }

  Future<void> makePayment() async {
    try {
      paymentIntent = await createPaymentIntent('10', 'USD');
      // await Stripe.instance.createPlatformPayPaymentMethod(
      //     params: const PlatformPayPaymentMethodParams.applePay(
      //         applePayParams: ApplePayParams(cartItems: [
      //   ApplePayCartSummaryItem.immediate(
      //     label: 'Valet Services',
      //     amount: '10',
      //   ),
      // ], merchantCountryCode: 'US', currencyCode: 'USD')));

      //STEP 2: Initialize Payment Sheet
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntent![
                      'client_secret'], //Gotten from payment intent
                  style: ThemeMode.system,
                  merchantDisplayName: 'Curbify'))
          .then((value) {});

      //STEP 3: Display Payment sheet
      displayPaymentSheet();
    } catch (err) {
      throw Exception(err);
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        showDialog(
            context: context,
            builder: (_) => const AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 100.0,
                      ),
                      SizedBox(height: 10.0),
                      Text("Payment Successful!"),
                    ],
                  ),
                ));

        paymentIntent = null;
      }).onError((error, stackTrace) {
        throw Exception(error);
      });
    } on StripeException catch (e) {
      print('Error is:---> $e');
      const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cancel,
                  color: Colors.red,
                ),
                Text("Payment Failed"),
              ],
            ),
          ],
        ),
      );
    } catch (e) {
      print('$e');
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      //Request body
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        // 'automatic_payment_methods': {'enabled': true},
      };
      // Make post request to Stripe
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${dotenv.env['STRIPE_API_KEY']}',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return json.decode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  calculateAmount(String amount) {
    final calculatedAmout = (int.parse(amount)) * 100;
    return calculatedAmout.toString();
  }
}

// override default theme
// ThemeData _buildTheme() {
//   var base = ThemeData.light();
//   return base.copyWith(
//     canvasColor: Colors.transparent,
//     scaffoldBackgroundColor: const Color.fromRGBO(64, 135, 225, 1.0),
//     buttonTheme: const ButtonThemeData(
//       height: 64.0,
//     ),
//     hintColor: Colors.transparent,
//     inputDecorationTheme: const InputDecorationTheme(
//       labelStyle: TextStyle(
//         color: Colors.white,
//       ),
//     ),
//     textTheme: const TextTheme(
//         labelLarge: TextStyle(
//           fontSize: 20.0,
//           fontWeight: FontWeight.w600,
//           color: Colors.white,
//         ),
//         bodyLarge: TextStyle(
//           fontSize: 24.0,
//           fontWeight: FontWeight.w600,
//           color: Colors.white,
//         )),
//     colorScheme: const ColorScheme(
//       brightness: Brightness.light,
//       primary: Color.fromRGBO(64, 135, 225, 1.0),
//       onPrimary: Colors.white,
//       secondary: Colors.grey,
//       onSecondary: Colors.white,
//       error: Colors.red,
//       onError: Colors.white,
//       surface: Colors.white,
//       onSurface: Colors.black,
//     ),
//   );
// }
