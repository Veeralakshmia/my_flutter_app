import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(Duration(seconds: 2));
    
    if (!mounted) return;
    
    final authService = Provider.of<AuthService>(context, listen: false);
    
    // Check if Firebase is available
    if (!authService.isFirebaseAvailable) {
      // Show a dialog informing user about Firebase unavailability
      if (mounted) {
        _showFirebaseUnavailableDialog();
      }
      return;
    }
    
    if (authService.isAuthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  void _showFirebaseUnavailableDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Firebase Configuration Required'),
          content: Text(
            'This app requires Firebase to be properly configured. '
            'Please check your Firebase configuration and try again.\n\n'
            'For now, you can continue with a demo mode that uses local storage.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
              child: Text('Continue in Demo Mode'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text('Event Reminder', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
} 