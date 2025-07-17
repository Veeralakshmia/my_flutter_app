# Data Storage Guide for Event Reminder App

## 📊 **Data Storage Overview**

Your Event Reminder app uses a **hybrid storage system** that works in both online (Firebase) and offline (local) modes.

---

## 🗂️ **Where Data is Stored**

### **1. Firebase Cloud Firestore (Online Storage)**
**Location**: Google Cloud (Firebase Console)
**Status**: Primary storage when Firebase is configured

#### **Collections Structure:**
```
firestore/
├── events/
│   ├── {eventId}/
│   │   ├── title: "Meeting with Client"
│   │   ├── description: "Discuss project requirements"
│   │   ├── dateTime: Timestamp
│   │   ├── location: "Conference Room A"
│   │   ├── isReminderSet: true
│   │   ├── userId: "user_123_uid"
│   │   ├── createdAt: Timestamp
│   │   └── updatedAt: Timestamp
│   └── {eventId2}/
│       └── ...
└── users/ (if you add user profiles later)
    └── {userId}/
        └── ...
```

#### **Access**: 
- **Web**: https://console.firebase.google.com/project/event-47a2d/firestore
- **Mobile**: Firebase Console app

---

### **2. Local Memory Storage (Offline/Demo Mode)**
**Location**: App's runtime memory
**Status**: Fallback storage when Firebase is unavailable

#### **Data Structure:**
```dart
List<Event> _events = [
  Event(
    id: 'local_1234567890',
    title: 'Local Event',
    description: 'Stored in memory',
    dateTime: DateTime.now(),
    location: 'Local',
    userId: 'demo_user_123',
    isReminderSet: false,
  ),
  // ... more events
];
```

#### **Characteristics:**
- ✅ **Fast access** - No network delay
- ❌ **Temporary** - Lost when app restarts
- ❌ **Device-specific** - Not synced across devices
- ❌ **No backup** - No cloud backup

---

### **3. Firebase Authentication (User Data)**
**Location**: Firebase Auth service
**Status**: User management and authentication

#### **User Data:**
```json
{
  "uid": "user_123_uid",
  "email": "user@example.com",
  "displayName": "John Doe",
  "emailVerified": true,
  "creationTime": "2024-01-01T00:00:00Z",
  "lastSignInTime": "2024-01-15T10:30:00Z"
}
```

#### **Access**: 
- **Web**: https://console.firebase.google.com/project/event-47a2d/authentication

---

### **4. Local Notifications (Reminders)**
**Location**: Device's notification system
**Status**: Local reminder scheduling

#### **Storage**: 
- **Android**: Android Notification Manager
- **iOS**: iOS Local Notifications
- **Web**: Browser notifications (if supported)

---

## 🔄 **How Storage Works**

### **Storage Flow:**

```
1. User adds event
   ↓
2. Check Firebase availability
   ↓
3a. If Firebase available:
    → Save to Firestore
    → Sync across devices
    → Cloud backup
   ↓
3b. If Firebase unavailable:
    → Save to local memory
    → Temporary storage only
   ↓
4. Schedule notifications (if enabled)
   ↓
5. Update UI
```

### **Data Persistence:**

| Storage Type | Persistence | Sync | Backup | Speed |
|-------------|-------------|------|--------|-------|
| **Firestore** | ✅ Permanent | ✅ Yes | ✅ Yes | 🟡 Medium |
| **Local Memory** | ❌ Temporary | ❌ No | ❌ No | ✅ Fast |
| **Notifications** | ✅ Until triggered | ❌ No | ❌ No | ✅ Fast |

---

## 🛠️ **Storage Configuration**

### **Current Setup:**
```dart
// In event_service.dart
class EventService extends ChangeNotifier {
  FirebaseFirestore? _firestore;  // Online storage
  List<Event> _events = [];       // Local storage
  bool _isFirebaseAvailable = false;
}
```

### **Storage Priority:**
1. **Firebase Firestore** (if available)
2. **Local Memory** (fallback)

---

## 📱 **Platform-Specific Storage**

### **Web (Chrome/Edge):**
- **Firestore**: ✅ Full support
- **Local Storage**: ✅ IndexedDB/WebSQL
- **Notifications**: ✅ Browser notifications

### **Android:**
- **Firestore**: ✅ Full support
- **Local Storage**: ✅ SharedPreferences
- **Notifications**: ✅ Android notifications

### **iOS:**
- **Firestore**: ✅ Full support
- **Local Storage**: ✅ UserDefaults
- **Notifications**: ✅ iOS notifications

---

## 🔍 **How to Check Where Your Data is Stored**

### **1. Check App Status:**
Look for these indicators in the app:
- **Orange banner**: "Demo Mode: Events are stored locally only"
- **No banner**: Firebase is working, data stored in cloud

### **2. Use Firebase Test Screen:**
1. Click the bug icon (🐛) in the app bar
2. Run "Test Connection" to verify Firebase
3. Check test results for storage status

### **3. Check Firebase Console:**
1. Go to https://console.firebase.google.com/project/event-47a2d
2. Navigate to **Firestore Database**
3. Look for your events in the `events` collection

---

## 🚨 **Common Storage Issues & Solutions**

### **Issue 1: "Add Event" doesn't work**
**Cause**: Missing userId or Firebase configuration
**Solution**: ✅ Fixed in latest update

### **Issue 2: Events disappear after app restart**
**Cause**: Using local storage (demo mode)
**Solution**: Enable Firebase services in console

### **Issue 3: Events not syncing across devices**
**Cause**: Firebase not configured or offline
**Solution**: Check internet connection and Firebase setup

### **Issue 4: Notifications not working**
**Cause**: Permission denied or service not initialized
**Solution**: Grant notification permissions

---

## 📊 **Data Migration**

### **From Local to Firebase:**
```dart
// When Firebase becomes available
if (localEvents.isNotEmpty && firebaseAvailable) {
  for (var event in localEvents) {
    await firestore.collection('events').add(event.toMap());
  }
  localEvents.clear();
}
```

### **From Firebase to Local:**
```dart
// When Firebase becomes unavailable
if (firebaseEvents.isNotEmpty && !firebaseAvailable) {
  localEvents.addAll(firebaseEvents);
}
```

---

## 🔒 **Data Security**

### **Firestore Security Rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /events/{eventId} {
      // Users can only access their own events
      allow read, write: if request.auth != null && 
                           request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && 
                      request.auth.uid == request.resource.data.userId;
    }
  }
}
```

### **Data Privacy:**
- ✅ **User isolation**: Each user only sees their own events
- ✅ **Authentication required**: Must be logged in to access data
- ✅ **Encrypted transmission**: HTTPS for all Firebase communication

---

## 📈 **Storage Analytics**

### **Current Usage:**
- **Events collection**: 0 documents (if Firebase not enabled)
- **Users**: 0 (if not registered)
- **Local events**: Varies based on usage

### **Storage Limits:**
- **Firestore**: 1GB free tier, then pay per use
- **Local memory**: Limited by device RAM
- **Notifications**: Limited by device settings

---

## 🎯 **Next Steps**

1. **Enable Firebase services** in the console
2. **Test data persistence** by adding events
3. **Verify cross-device sync** by logging in on different devices
4. **Monitor storage usage** in Firebase console
5. **Set up backup strategies** if needed

---

## 📞 **Support**

If you have storage issues:
1. Check the Firebase test screen (bug icon)
2. Verify Firebase console configuration
3. Check internet connection
4. Review error messages in app console
5. Consult this guide for troubleshooting 