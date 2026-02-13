import 'package:flutter/material.dart';

class ActivityReportScreen extends StatelessWidget {
  const ActivityReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity Report')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // TODO: Replace with static form fields
            TextField(decoration: const InputDecoration(labelText: 'Activity Details')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Submit to backend
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
