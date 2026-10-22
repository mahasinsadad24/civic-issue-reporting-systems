import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get currentUser => _authService.currentUser;

  // Expose auth state changes
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  // Restore session - relying strictly on Firebase Auth persistence
  Future<bool> checkAuthState() async {
    // We just wait for the first event from the stream or check current user
    // Firebase Auth automatically persists session locally.
    final firebaseUser = _authService.currentUser;
    if (firebaseUser != null) {
      await loadProfile();
      return true;
    }
    return false;
  }

  /// Login with Email and Password
  Future<void> login({
    required String email,
    required String password,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // await _setLoggedIn(); // Deprecated
      onSuccess();
    } on FirebaseAuthException catch (e) {
      _setLoading(false);

      String message = 'Login failed';
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email.';
          break;
        case 'wrong-password':
          message = 'Incorrect password.';
          break;
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        case 'user-disabled':
          message = 'This user has been disabled.';
          break;
        default:
          message = e.message ?? 'Authentication failed.';
      }

      _error = message;
      onError(message);
    } catch (e) {
      _setLoading(false);
      _error = e.toString();
      onError('Something went wrong. Please try again.');
    }
  }

  /// Register with Email and Password
  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    VoidCallback? onSuccess,
    Function(String)? onError,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final credential = await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile in Firestore immediately
      if (credential.user != null) {
        await _authService.currentUser?.updateDisplayName(name);
        await updateProfile(
          name: name,
          email: email,
          phone: phone,
          address: '',
          bio: 'New User',
        );
      }

      onSuccess?.call();
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      String message = 'Registration failed';
      switch (e.code) {
        case 'email-already-in-use':
          message = 'The email address is already in use.';
          break;
        case 'weak-password':
          message = 'The password provided is too weak.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
      }
      _error = message;
      onError?.call(message);
    } catch (e) {
      _setLoading(false);
      _error = e.toString();
      onError?.call(e.toString());
    } finally {
      // _setLoading(false); // Handled in onSuccess/onError paths mostly but good to ensure
    }
  }

  /// Send Password Reset Email
  Future<void> resetPassword({
    required String email,
    VoidCallback? onSuccess,
    Function(String)? onError,
  }) async {
    _setLoading(true);
    try {
      await _authService.sendPasswordResetEmail(email);
      onSuccess?.call();
    } on FirebaseAuthException catch (e) {
      String message = 'Failed to send reset email';
      if (e.code == 'user-not-found') {
        message = 'No user found with this email.';
      }
      onError?.call(message);
    } catch (e) {
      onError?.call(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Profile Data
  String _userName = 'User Name';
  String _userEmail = 'user@example.com';
  String _userPhone = '';
  String _userAddress = '';
  String _userBio = '';

  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userPhone => _userPhone;
  String get userAddress => _userAddress;
  String get userBio => _userBio;

  Future<void> loadProfile() async {
    final user = _authService.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _userName = data['name'] ?? user.displayName ?? 'User Name';
        _userEmail = data['email'] ?? user.email ?? 'user@example.com';
        _userPhone = data['phone'] ?? '';
        _userAddress = data['address'] ?? '';
        _userBio = data['bio'] ?? '';
      } else {
        // Create default doc if missing
        await updateProfile(
          name: user.displayName ?? 'User Name',
          email: user.email ?? 'user@example.com',
          phone: '',
          address: '',
          bio: '',
        );
      }
      notifyListeners();
    } catch (e) {
      print('Error loading profile: $e');
    }
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String bio,
  }) async {
    final user = _authService.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'bio': bio,
      }, SetOptions(merge: true));

      _userName = name;
      _userEmail = email;
      _userPhone = phone;
      _userAddress = address;
      _userBio = bio;
      notifyListeners();

      // Also update Auth displayName if name changed
      if (name != user.displayName) {
        await user.updateDisplayName(name);
      }
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    await _authService.signOut();
    // Clear profile data from memory
    _userName = 'User Name';
    _userEmail = 'user@example.com';
    _userPhone = '';
    _userAddress = '';
    _userBio = '';
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
