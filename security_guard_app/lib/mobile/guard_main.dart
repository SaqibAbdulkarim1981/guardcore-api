import 'package:flutter/material.dart';
import 'screens/guard_login.dart';
import 'screens/guard_home.dart';
import 'screens/qr_scanner.dart';
import 'screens/activity_report_form.dart';
import 'screens/incident_report_form.dart';
import 'screens/guard_password_reset.dart';
import 'screens/guard_access_expired.dart';

class GuardMobileApp extends StatelessWidget {
  const GuardMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GuardCore',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const GuardLoginScreen(),
        '/home': (context) => const GuardHomeScreen(),
        '/qr-scanner': (context) => const QRScannerScreen(),
        '/activity-report': (context) => const ActivityReportFormScreen(),
        '/incident-report': (context) => const IncidentReportFormScreen(),
        '/password-reset': (context) => const GuardPasswordResetScreen(),
        '/access-expired': (context) => const GuardAccessExpiredScreen(),
      },
    );
  }
}
