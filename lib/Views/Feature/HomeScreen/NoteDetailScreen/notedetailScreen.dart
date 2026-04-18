import 'package:flutter/material.dart';
import 'package:notesave/Views/Base/AppText/appText.dart';

class NoteDetailsScreen extends StatelessWidget {
  final String id;
  final String title;
  final String description;

  const NoteDetailsScreen({
    super.key,
    required this.id,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Note Details"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            AppText(
              title,
              fontSize: 22,
               fontWeight: FontWeight.bold,
              ),

            const SizedBox(height: 12),


            AppText(
              description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}