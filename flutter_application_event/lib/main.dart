import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/event_service.dart';
import 'services/notification_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
    print('📱 Project ID: ${DefaultFirebaseOptions.currentPlatform.projectId}');
    print('🌐 API Key: ${DefaultFirebaseOptions.currentPlatform.apiKey}');
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
    print('💡 Make sure you have enabled Firebase services in the console');
    // Continue without Firebase - the app will still work with local storage
  }
  
  // Initialize notifications with error handling
  try {
    await NotificationService.initialize();
    print('✅ Notifications initialized successfully');
  } catch (e) {
    print('❌ Notification initialization failed: $e');
  }
  
  // Request permissions with error handling
  try {
    if (!kIsWeb) {
      await Permission.notification.request();
      // Only request calendar permission on mobile platforms
      if (Platform.isAndroid || Platform.isIOS) {
        await Permission.calendarWriteOnly.request();
      }
    }
    print('✅ Permissions requested successfully');
  } catch (e) {
    print('❌ Permission request failed: $e');
  }
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => EventService()),
      ],
      child: MaterialApp(
        title: 'Event Reminder',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: Colors.blue[600],
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
