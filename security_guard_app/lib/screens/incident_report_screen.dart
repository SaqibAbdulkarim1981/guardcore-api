import 'package:flutter/material.dart';

class IncidentReportScreen extends StatelessWidget {
  const IncidentReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Incident Report')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // TODO: Replace with static form fields
            TextField(decoration: const InputDecoration(labelText: 'Incident Details')),
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
