import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view_models/request_view_model.dart';
import 'widgets/request_screen.dart';

class Request extends StatelessWidget {
  const Request({super.key, required this.company});
  final String? company;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RequestViewModel(),
      child: const RequestScreen(),
    );
  }
}
