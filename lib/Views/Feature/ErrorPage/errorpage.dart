import 'package:flutter/material.dart';
import 'package:notesave/Views/Base/AppText/appText.dart';

class ErrorPage extends StatefulWidget {
  const ErrorPage({super.key});

  @override
  State<ErrorPage> createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage>{


  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          AppText("Error"),
        ],
      ),
    );
  }
}
