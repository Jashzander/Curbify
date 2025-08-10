import 'package:flutter/material.dart';

class OutAndReturningScreen extends StatelessWidget {
  const OutAndReturningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Out and Returning'),
      ),
      body: const Center(
        child: Text('Out and Returning Screen'),
      ),
    );
  }
}
