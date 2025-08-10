import 'dart:async';
import 'package:flutter/material.dart';

class Timers extends StatefulWidget {
  final String initialElapsedString;

  const Timers({super.key, required this.initialElapsedString});

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
    if (parts.isNotEmpty) hours = int.parse(parts[0]);
    if (parts.length > 1) minutes = int.parse(parts[1]);
    if (parts.length > 2) seconds = int.parse(parts[2].split('.')[0]);
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
    );
  }
}
