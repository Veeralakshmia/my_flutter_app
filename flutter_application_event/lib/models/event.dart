class Event {
  final String? id;
  final String title;
  final String description;
  final DateTime dateTime;
  final String location;
  final bool isReminderSet;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.location,
    this.isReminderSet = false,
    required this.userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now() {
    // Validate required fields
    if (title.trim().isEmpty) {
      throw ArgumentError('Title cannot be empty');
    }
    if (userId.trim().isEmpty) {
      throw ArgumentError('UserId cannot be empty');
    }
  }

  // Convert Event to Map for Realtime Database
  Map<String, dynamic> toMap() {
    return {
      'title': title.trim(),
      'description': description.trim(),
      'dateTime': dateTime.toIso8601String(),
      'location': location.trim(),
      'isReminderSet': isReminderSet,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create Event from RTDB map
  factory Event.fromMap(String id, Map<String, dynamic> map) {
    return Event(
      id: id,
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      dateTime: map['dateTime'] != null ? DateTime.parse(map['dateTime']) : DateTime.now(),
      location: map['location']?.toString() ?? '',
      isReminderSet: map['isReminderSet'] as bool? ?? false,
      userId: map['userId']?.toString() ?? '',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : DateTime.now(),
    );
  }

  // Create a copy of Event with updated fields
  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    String? location,
    bool? isReminderSet,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      isReminderSet: isReminderSet ?? this.isReminderSet,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Check if event is today
  bool get isToday {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  // Check if event is upcoming (future date)
  bool get isUpcoming {
    return dateTime.isAfter(DateTime.now());
  }

  // Check if event is past
  bool get isPast {
    return dateTime.isBefore(DateTime.now());
  }

  // Get formatted date string
  String get formattedDate {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  // Get formatted time string
  String get formattedTime {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Get full formatted date and time
  String get formattedDateTime {
    return '${formattedDate} at ${formattedTime}';
  }

  // Get relative time (e.g., "in 2 hours", "2 hours ago")
  String get relativeTime {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.inDays > 0) {
      return 'in ${difference.inDays} day${difference.inDays == 1 ? '' : 's'}';
    } else if (difference.inHours > 0) {
      return 'in ${difference.inHours} hour${difference.inHours == 1 ? '' : 's'}';
    } else if (difference.inMinutes > 0) {
      return 'in ${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'}';
    } else if (difference.inMinutes < 0) {
      final absDifference = difference.abs();
      if (absDifference.inDays > 0) {
        return '${absDifference.inDays} day${absDifference.inDays == 1 ? '' : 's'} ago';
      } else if (absDifference.inHours > 0) {
        return '${absDifference.inHours} hour${absDifference.inHours == 1 ? '' : 's'} ago';
      } else {
        return '${absDifference.inMinutes} minute${absDifference.inMinutes == 1 ? '' : 's'} ago';
      }
    } else {
      return 'now';
    }
  }

  @override
  String toString() {
    return 'Event(id: $id, title: $title, dateTime: $dateTime, location: $location, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Event && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 