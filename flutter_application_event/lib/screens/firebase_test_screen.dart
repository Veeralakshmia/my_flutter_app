import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../services/auth_service.dart';
import '../services/event_service.dart';

class FirebaseTestScreen extends StatefulWidget {
  @override
  _FirebaseTestScreenState createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  String _testResult = '';
  bool _isTesting = false;

  Future<void> _testRealtimeDatabaseConnection() async {
    setState(() {
      _isTesting = true;
      _testResult = 'Testing Firebase Realtime Database connection...\n';
    });

    try {
      final db = FirebaseDatabase.instance.ref();
      // Write test
      await db.child('test_connection').set({'timestamp': DateTime.now().toIso8601String(), 'message': 'RTDB test'});
      _testResult += '✅ RTDB Write: Success\n';
      // Read test
      final snapshot = await db.child('test_connection').get();
      if (snapshot.exists) {
        _testResult += '✅ RTDB Read: Success\n';
      }
      // Clean up
      await db.child('test_connection').remove();
      _testResult += '✅ RTDB Cleanup: Success\n';
      _testResult += '\n🎉 All RTDB tests passed! Your Realtime Database setup is working.';
    } catch (e) {
      _testResult += '\n❌ Error: $e\n';
      _testResult += '\n💡 Please check:\n';
      _testResult += '1. RTDB is enabled in Firebase console\n';
      _testResult += '2. Security rules allow read/write\n';
      _testResult += '3. Internet connection is working\n';
    }

    setState(() {
      _isTesting = false;
    });
  }

  Future<void> _testAuthService() async {
    setState(() {
      _isTesting = true;
      _testResult = 'Testing Auth Service...\n';
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      if (authService.isFirebaseAvailable) {
        _testResult += '✅ Auth Service: Firebase available\n';
        final currentUser = authService.getCurrentUser();
        if (currentUser != null) {
          _testResult += '✅ Current User: ${currentUser.email}\n';
        } else {
          _testResult += 'ℹ️ No user currently signed in\n';
        }
      } else {
        _testResult += '❌ Auth Service: Firebase not available\n';
      }
    } catch (e) {
      _testResult += '❌ Auth Service Error: $e\n';
    }

    setState(() {
      _isTesting = false;
    });
  }

  Future<void> _testEventService() async {
    setState(() {
      _isTesting = true;
      _testResult = 'Testing Event Service...\n';
    });

    try {
      final eventService = Provider.of<EventService>(context, listen: false);
      if (eventService.isFirebaseAvailable) {
        _testResult += '✅ Event Service: Firebase available\n';
        await eventService.fetchEvents();
        _testResult += '✅ Event Fetch: Success\n';
        _testResult += '📊 Events count: ${eventService.events.length}\n';
      } else {
        _testResult += '❌ Event Service: Firebase not available\n';
        _testResult += 'ℹ️ Running in demo mode\n';
      }
    } catch (e) {
      _testResult += '❌ Event Service Error: $e\n';
    }

    setState(() {
      _isTesting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Test'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Firebase Configuration Test',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This screen helps you verify that Firebase is properly configured and working.',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isTesting ? null : _testRealtimeDatabaseConnection,
                    child: Text('Test RTDB'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isTesting ? null : _testAuthService,
                    child: Text('Test Auth'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isTesting ? null : _testEventService,
                    child: Text('Test Events'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _testResult.isEmpty ? 'Click a test button to start...' : _testResult,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Back to App'),
            ),
          ],
        ),
      ),
    );
  }
} 