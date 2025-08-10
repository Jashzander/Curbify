import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view_models/settings_view_model.dart';
import 'widgets/settings_screen.dart';

class Settings extends StatelessWidget {
  const Settings({super.key, required this.company});
  final String? company;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SettingsViewModel(),
      child: const SettingsScreen(),
    );
  }
}
