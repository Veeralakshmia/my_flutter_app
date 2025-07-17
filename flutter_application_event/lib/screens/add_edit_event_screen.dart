import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';
import 'package:firebase_database/firebase_database.dart';

class AddEditEventScreen extends StatefulWidget {
  final Event? event;
  AddEditEventScreen({this.event});

  @override
  State<AddEditEventScreen> createState() => _AddEditEventScreenState();
}

class _AddEditEventScreenState extends State<AddEditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late DateTime _dateTime;
  late String _location;
  bool _isReminderSet = false;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    _title = e?.title ?? '';
    _description = e?.description ?? '';
    _dateTime = e?.dateTime ?? DateTime.now().add(Duration(hours: 1));
    _location = e?.location ?? '';
    _isReminderSet = e?.isReminderSet ?? false;
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { 
      _loading = true; 
      _error = null; 
    });
    _formKey.currentState!.save();
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final eventService = Provider.of<EventService>(context, listen: false);
      String userId;
      if (authService.isFirebaseAvailable && authService.isAuthenticated) {
        userId = authService.user!.uid;
      } else {
        userId = 'demo_user_123';
      }
      final event = Event(
        id: widget.event?.id,
        title: _title,
        description: _description,
        dateTime: _dateTime,
        location: _location,
        isReminderSet: _isReminderSet,
        userId: userId,
      );
      print('Attempting to save event: ' + event.toString());
      if (widget.event == null) {
        await eventService.addEvent(event);
        print('✅ Event added successfully');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Event saved successfully!'), backgroundColor: Colors.green),
          );
        }
      } else {
        await eventService.updateEvent(event);
        print('✅ Event updated successfully');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Event updated successfully!'), backgroundColor: Colors.green),
          );
        }
      }
      try {
        if (_isReminderSet) {
          await NotificationService.scheduleEventReminder(event);
          print('✅ Reminder scheduled');
        } else {
          await NotificationService.cancelEventReminder(event);
          print('✅ Reminder cancelled');
        }
      } catch (e) {
        print('⚠️ Notification service error: $e');
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      print('❌ Error saving event: $e');
      setState(() { _error = 'Failed to save event: $e'; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save event: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() { _loading = false; });
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    if (time == null) return;
    setState(() {
      _dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? 'Add Event' : 'Edit Event'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (!authService.isFirebaseAvailable) ...[
                Container(
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Demo Mode: Events will be stored locally only',
                          style: TextStyle(color: Colors.orange[800], fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(
                  labelText: 'Title *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a title' : null,
                onSaved: (v) => _title = v!.trim(),
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onSaved: (v) => _description = v ?? '',
              ),
              SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text('Date & Time *'),
                  subtitle: Text(
                    DateFormat('EEEE, MMMM d, yyyy – HH:mm').format(_dateTime),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Icon(Icons.calendar_today, color: Colors.blue[600]),
                  onTap: _pickDateTime,
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _location,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
                onSaved: (v) => _location = v ?? '',
              ),
              SizedBox(height: 16),
              SwitchListTile(
                value: _isReminderSet,
                onChanged: (v) => setState(() => _isReminderSet = v),
                title: Text('Set Reminder'),
                subtitle: Text('Get notified before the event'),
                activeColor: Colors.blue[600],
              ),
              SizedBox(height: 24),
              if (_error != null) ...[
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(color: Colors.red[800]),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
              ],
              _loading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        widget.event == null ? 'Add Event' : 'Save Changes',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
} 