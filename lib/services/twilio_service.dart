import 'package:twilio_flutter/twilio_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TwilioService {
  TwilioService._internal() {
    _twilio = TwilioFlutter(
      accountSid: dotenv.env['TWILIO_ACCOUNT_SID']!,
      authToken: dotenv.env['TWILIO_AUTH_TOKEN']!,
      twilioNumber: dotenv.env['TWILIO_NUMBER']!,
    );
  }

  static final TwilioService _instance = TwilioService._internal();

  factory TwilioService() => _instance;

  late final TwilioFlutter _twilio;

  Future<void> sendSms(
      {required String toNumber, required String message}) async {
    try {
      await _twilio.sendSMS(toNumber: '+1$toNumber', messageBody: message);
    } catch (e) {
      // ignore: avoid_print
      print('Twilio sendSms error: $e');
    }
  }

  Future<String> fetchAllMessages() async {
    try {
      final msgs = await _twilio.getSmsList();
      return msgs.toString();
    } catch (e) {
      // ignore: avoid_print
      print('Twilio getSmsList error: $e');
      return '';
    }
  }
}
