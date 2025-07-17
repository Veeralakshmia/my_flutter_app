import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/event.dart';

class EventService extends ChangeNotifier {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<Event> _events = [];
  bool _isLoading = false;
  String? _error;
  bool _isFirebaseAvailable = false;

  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isFirebaseAvailable => _isFirebaseAvailable;

  EventService() {
    _initializeFirebase();
  }

  void _initializeFirebase() {
    try {
      _isFirebaseAvailable = true;
    } catch (e) {
      print('Firebase Realtime Database not available: $e');
      _isFirebaseAvailable = false;
    }
  }

  // Get events for current user
  Future<void> fetchEvents() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (!_isFirebaseAvailable) {
        _events = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      final user = _auth.currentUser;
      if (user == null) {
        _events = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      final ref = _database.ref('events');
      final snapshot = await ref.orderByChild('userId').equalTo(user.uid).get();
      _events = [];
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        data.forEach((key, value) {
          _events.add(Event.fromMap(key, Map<String, dynamic>.from(value)));
        });
        _events.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to fetch events: $e';
      notifyListeners();
    }
  }

  // Add new event
  Future<void> addEvent(Event event) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final ref = _database.ref('events').push();
      await ref.set(event.copyWith(id: ref.key, userId: user.uid).toMap());
      await fetchEvents();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to add event: $e';
      notifyListeners();
    }
  }

  // Update event
  Future<void> updateEvent(Event event) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (event.id == null) {
        throw Exception('Event ID is required for update');
      }

      final ref = _database.ref('events/${event.id}');
      await ref.set(event.toMap());
      await fetchEvents();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to update event: $e';
      notifyListeners();
    }
  }

  // Delete event
  Future<void> deleteEvent(String eventId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final ref = _database.ref('events/$eventId');
      await ref.remove();
      await fetchEvents();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to delete event: $e';
      notifyListeners();
    }
  }

  // Get events by date range
  List<Event> getEventsByDateRange(DateTime startDate, DateTime endDate) {
    return _events.where((event) {
      return event.dateTime.isAfter(startDate.subtract(Duration(days: 1))) &&
             event.dateTime.isBefore(endDate.add(Duration(days: 1)));
    }).toList();
  }

  // Get today's events
  List<Event> getTodayEvents() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(Duration(days: 1));
    
    return _events.where((event) {
      return event.dateTime.isAfter(today.subtract(Duration(seconds: 1))) &&
             event.dateTime.isBefore(tomorrow);
    }).toList();
  }

  // Get upcoming events
  List<Event> getUpcomingEvents() {
    return _events.where((event) => event.isUpcoming).toList();
  }

  // Get past events
  List<Event> getPastEvents() {
    return _events.where((event) => event.isPast).toList();
  }

  // Search events by title
  List<Event> searchEvents(String query) {
    if (query.isEmpty) return _events;
    
    return _events.where((event) {
      return event.title.toLowerCase().contains(query.toLowerCase()) ||
             event.description.toLowerCase().contains(query.toLowerCase()) ||
             event.location.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear events (for logout)
  void clearEvents() {
    _events = [];
    _error = null;
    notifyListeners();
  }
} 