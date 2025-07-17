# Firebase Setup Guide for Event Reminder App

## Current Status ✅
- Firebase project is configured: `event-47a2d`
- Google Services plugin is properly set up
- Firebase configuration files are in place

## Required Firebase Services Setup

### 1. Firebase Authentication 🔐
**Status: Needs to be enabled**

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `event-47a2d`
3. Navigate to **Authentication** → **Sign-in method**
4. Enable **Email/Password** authentication:
   - Click on "Email/Password"
   - Toggle "Enable"
   - Click "Save"

### 2. Cloud Firestore Database 📊
**Status: Needs to be enabled**

1. In Firebase Console, go to **Firestore Database**
2. Click **Create database**
3. Choose **Start in test mode** (for development)
4. Select a location (choose closest to your users)
5. Click **Done**

### 3. Firebase Storage (Optional) 📁
**Status: Optional for this app**

If you want to add image uploads for events:
1. Go to **Storage**
2. Click **Get started**
3. Choose **Start in test mode**
4. Select a location

## Security Rules Setup

### Firestore Security Rules
Replace the default rules in **Firestore Database** → **Rules** with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Events collection - users can only access their own events
    match /events/{eventId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
    }
  }
}
```

### Storage Security Rules (if using Storage)
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Testing Firebase Features

### 1. Test Authentication
1. Run your app: `flutter run -d chrome`
2. Try to register a new user
3. Try to login with the registered user
4. Check Firebase Console → Authentication → Users to see the user

### 2. Test Firestore
1. Add an event in your app
2. Check Firebase Console → Firestore Database to see the event document
3. Verify the event has the correct `userId` field

## Troubleshooting

### Common Issues:

1. **"Firebase is not available" message**
   - Check if you're connected to the internet
   - Verify the `firebase_options.dart` file has correct values
   - Make sure Firebase services are enabled in the console

2. **Authentication errors**
   - Ensure Email/Password auth is enabled in Firebase Console
   - Check if the user exists in Authentication → Users

3. **Firestore permission errors**
   - Verify security rules are set correctly
   - Check if the user is authenticated before accessing Firestore

4. **Build errors**
   - Run `flutter clean`
   - Run `flutter pub get`
   - Try `flutter run` again

## Next Steps

1. **Enable Firebase services** in the console (steps above)
2. **Test the app** with real Firebase backend
3. **Deploy security rules** for production
4. **Add more features** like:
   - Push notifications
   - Image uploads
   - Event sharing
   - Calendar integration

## Firebase Console Links

- **Project Overview**: https://console.firebase.google.com/project/event-47a2d
- **Authentication**: https://console.firebase.google.com/project/event-47a2d/authentication
- **Firestore Database**: https://console.firebase.google.com/project/event-47a2d/firestore
- **Storage**: https://console.firebase.google.com/project/event-47a2d/storage

## Support

If you encounter issues:
1. Check Firebase Console for error logs
2. Verify all services are enabled
3. Test with a simple Firebase app first
4. Check Firebase documentation: https://firebase.flutter.dev/ 