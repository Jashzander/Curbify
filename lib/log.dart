import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view_models/log_view_model.dart';
import 'widgets/log_screen.dart';

class Log extends StatelessWidget {
  const Log({super.key, required this.company});
  final String? company;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LogViewModel(company!),
      child: const LogScreen(),
    );
  }
}
