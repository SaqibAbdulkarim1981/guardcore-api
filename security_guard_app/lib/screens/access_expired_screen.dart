import 'package:flutter/material.dart';

class AccessExpiredScreen extends StatelessWidget {
  const AccessExpiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.lock, size: 64, color: Colors.red),
            SizedBox(height: 20),
            Text('You do not have access to the app anymore.', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
