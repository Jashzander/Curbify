import 'package:curbify/screens/history_screen.dart';
import 'package:curbify/screens/dark_mode_screen.dart';
import 'package:curbify/screens/user_screen.dart';
import 'package:curbify/screens/key_audit_screen.dart';
import 'package:curbify/screens/payment_screen.dart';
import 'package:curbify/screens/out_and_returning_screen.dart';
import 'package:curbify/screens/print_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/settings_view_model.dart';
import '../theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, viewModel, child) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        final darkMode = themeProvider.themeData.brightness == Brightness.dark;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: ListView(
            padding: const EdgeInsets.all(0),
            children: [
              _buildHeader(darkMode),
              const SizedBox(height: 25),
              _buildSettingsItem(context, 'History', darkMode, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HistoryScreen()));
              }),
              const SizedBox(height: 10),
              _buildSettingsItem(context, 'Dark Mode', darkMode, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DarkModeScreen()));
              }),
              const SizedBox(height: 10),
              _buildSettingsItem(context, 'User', darkMode, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UserScreen()));
              }),
              const SizedBox(height: 10),
              _buildSettingsItem(context, 'Key Audit', darkMode, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const KeyAuditScreen()));
              }),
              const SizedBox(height: 10),
              _buildSettingsItem(context, 'Payment', darkMode, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PaymentScreen()));
              }),
              const SizedBox(height: 10),
              _buildSettingsItem(context, 'Out and Returning', darkMode, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const OutAndReturningScreen()));
              }),
              const SizedBox(height: 10),
              _buildSettingsItem(context, 'Print', darkMode, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PrintScreen()));
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool darkMode) {
    return Container(
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
    );
  }

  Widget _buildSettingsItem(
      BuildContext context, String title, bool darkMode, VoidCallback onTap) {
    return ListTile(
      tileColor: darkMode
          ? const Color.fromARGB(44, 193, 196, 244)
          : const Color.fromARGB(255, 232, 232, 232),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: Text(title),
      onTap: onTap,
      trailing: const Icon(Icons.arrow_forward_ios),
    );
  }
}
