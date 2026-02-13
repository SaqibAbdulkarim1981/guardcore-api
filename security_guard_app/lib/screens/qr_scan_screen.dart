import 'package:flutter/material.dart';

class QRScanScreen extends StatelessWidget {
  const QRScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // TODO: Integrate QR code scanner
          },
          child: const Text('Scan QR'),
        ),
      ),
    );
  }
}
