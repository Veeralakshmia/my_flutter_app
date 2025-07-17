import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService extends ChangeNotifier {
  FirebaseAuth? _auth;
  User? _user;
  bool _isFirebaseAvailable = false;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isFirebaseAvailable => _isFirebaseAvailable;

  AuthService() {
    _initializeFirebase();
  }

  void _initializeFirebase() {
    try {
      _auth = FirebaseAuth.instance;
      _isFirebaseAvailable = true;
      
      _auth!.authStateChanges().listen((User? user) {
        _user = user;
        notifyListeners();
      });
    } catch (e) {
      print('Firebase Auth not available: $e');
      _isFirebaseAvailable = false;
      _user = null;
    }
  }

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    if (!_isFirebaseAvailable) {
      throw Exception('Firebase is not available. Please check your configuration.');
    }
    
    try {
      UserCredential result = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = result.user;
      notifyListeners();
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    if (!_isFirebaseAvailable) {
      throw Exception('Firebase is not available. Please check your configuration.');
    }
    
    try {
      UserCredential result = await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = result.user;
      notifyListeners();
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    if (!_isFirebaseAvailable) {
      _user = null;
      notifyListeners();
      return;
    }
    
    try {
      await _auth!.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    if (!_isFirebaseAvailable) {
      throw Exception('Firebase is not available. Please check your configuration.');
    }
    
    try {
      await _auth!.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Update user profile
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    if (!_isFirebaseAvailable) {
      throw Exception('Firebase is not available. Please check your configuration.');
    }
    
    try {
      if (_user != null) {
        await _user!.updateDisplayName(displayName);
        await _user!.updatePhotoURL(photoURL);
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _isFirebaseAvailable ? _auth!.currentUser : null;
  }

  // Check if user is signed in
  bool isUserSignedIn() {
    return _isFirebaseAvailable && _auth!.currentUser != null;
  }
} 