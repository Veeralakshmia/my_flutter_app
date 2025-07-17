import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/event_service.dart';
import '../models/event.dart';
import 'login_screen.dart';
import 'add_edit_event_screen.dart';
import 'firebase_test_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<EventService>(context, listen: false).fetchEvents();
  }

  void _logout() async {
    await Provider.of<AuthService>(context, listen: false).signOut();
    Provider.of<EventService>(context, listen: false).clearEvents();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  void _addEvent() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditEventScreen()),
    );
    Provider.of<EventService>(context, listen: false).fetchEvents();
  }

  void _editEvent(Event event) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditEventScreen(event: event)),
    );
    Provider.of<EventService>(context, listen: false).fetchEvents();
  }

  void _deleteEvent(String eventId) async {
    await Provider.of<EventService>(context, listen: false).deleteEvent(eventId);
  }

  void _openFirebaseTest() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FirebaseTestScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventService = Provider.of<EventService>(context);
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('My Events'),
        actions: [
          IconButton(
            icon: Icon(Icons.bug_report),
            onPressed: _openFirebaseTest,
            tooltip: 'Test Firebase',
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          if (!authService.isFirebaseAvailable) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              color: Colors.orange.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Demo Mode: Events are stored locally only',
                      style: TextStyle(color: Colors.orange[800], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
          Expanded(
            child: eventService.isLoading
                ? Center(child: CircularProgressIndicator())
                : eventService.events.isEmpty
                    ? Center(child: Text('No events yet. Tap + to add.'))
                    : ListView.builder(
                        itemCount: eventService.events.length,
                        itemBuilder: (context, index) {
                          final event = eventService.events[index];
                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              title: Text(event.title),
                              subtitle: Text(
                                '${event.formattedDate} at ${event.formattedTime}\n${event.location}',
                              ),
                              isThreeLine: true,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () => _editEvent(event),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () => _deleteEvent(event.id!),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEvent,
        child: Icon(Icons.add),
        tooltip: 'Add Event',
      ),
    );
  }
} 