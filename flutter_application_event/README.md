# Flutter Application Event

A cross-platform event management app built with Flutter. This application allows users to register, log in, create, edit, and view events. It leverages Firebase for authentication and data storage, and supports Android, iOS, web, Windows, macOS, and Linux platforms.

## Features
- User registration and login
- Event creation, editing, and deletion
- Event listing and details
- Firebase Authentication
- Cloud Firestore integration
- Local notifications
- Responsive UI for multiple platforms

## Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Dart SDK](https://dart.dev/get-dart) (usually included with Flutter)
- A Firebase project (see below)

### Installation
1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd flutter_application_event
   ```
2. **Install dependencies:**
   ```bash
   flutter pub get
   ```
3. **Set up Firebase:**
   - Follow the instructions in [FIREBASE_SETUP.md](FIREBASE_SETUP.md) to configure Firebase for your platforms.
4. **Run the app:**
   ```bash
   flutter run
   ```

## Folder Structure
```
lib/
  main.dart                # App entry point
  firebase_options.dart    # Firebase configuration
  models/                  # Data models (e.g., event.dart)
  screens/                 # UI screens (login, register, home, etc.)
  services/                # Business logic and services (auth, event, notification)
assets/
  images/                  # App images
```

## Firebase Setup
See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for detailed instructions on integrating Firebase with your app.

## Data Storage
Refer to [DATA_STORAGE_GUIDE.md](DATA_STORAGE_GUIDE.md) for information on how data is stored and managed in the app.

## Screenshots
<!-- Add screenshots of your app here -->

## License
<!-- Specify your license here -->

---
Feel free to contribute or raise issues to help improve this project!
