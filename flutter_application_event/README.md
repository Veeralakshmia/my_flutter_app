# Event Reminder App

A Flutter application with Firebase integration for managing events and reminders.

## Features
- User authentication (Firebase Auth)
- Event management (CRUD operations)
- Local notifications for reminders
- Cloud storage (Firestore)

## Setup
1. Add `google-services.json` to `android/app/`
2. Run `flutter pub get`
3. Run `flutter run`

## Firebase Configuration
- Package name: `com.example.flutter_application_event`
- Enable Authentication (Email/Password)
- Enable Firestore Database

## Dependencies
- firebase_core, firebase_auth, cloud_firestore
- provider (state management)
- flutter_local_notifications
- permission_handler, timezone, intl
