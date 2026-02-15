import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:window_manager/window_manager.dart';

// Admin screens
import 'screens/login.dart';
import 'screens/dashboard.dart';
import 'screens/users.dart';
import 'screens/create_user.dart';
import 'screens/locations.dart';
import 'screens/reports.dart';
import 'screens/settings.dart';

// Mobile Guard App
import 'mobile/guard_main.dart';

// Services
import 'services/mock_service.dart';
import 'services/firebase_service.dart';
import 'services/api_service.dart';

// Toggle this to switch between Admin App and Guard Mobile App
const bool USE_MOBILE_APP = true; // Set to true for mobile guard app, false for admin app

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure window for desktop (only if not mobile app)
  if (!USE_MOBILE_APP) {
    await windowManager.ensureInitialized();
  
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1920, 1080),
      maximumSize: Size(1920, 1080),
      center: true,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.maximize();
    });
  }
  
  runApp(const SecurityGuardApp());
}

class SecurityGuardApp extends StatelessWidget {
  const SecurityGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MockService()),
        Provider(create: (_) => FirebaseService()),
        ChangeNotifierProvider(create: (_) => ApiService()),
      ],
      child: FutureBuilder(
        future: Firebase.initializeApp().then((_) => true).catchError((_) => false),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(body: Center(child: CircularProgressIndicator())),
            );
          }
          
          // Return either Mobile App or Admin App based on configuration
          if (USE_MOBILE_APP) {
            return const GuardMobileApp();
          }
          
          return MaterialApp(
            title: 'GuardCore v1.0.0.0',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
            ),
            home: const LoginScreen(),
            routes: {
              '/dashboard': (c) => const DashboardScreen(),
              '/users': (c) => const UsersScreen(),
              '/create-user': (c) => const CreateUserScreen(),
              '/locations': (c) => const LocationsScreen(),
              '/reports': (c) => const ReportsScreen(),
              '/settings': (c) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}
