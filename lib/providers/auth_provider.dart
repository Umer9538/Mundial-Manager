import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/location_service.dart';
import '../core/constants/constants.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();
  final LocationService _locationService = LocationService();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  String? get userRole => _currentUser?.role;

  // Initialize - Check if user is already logged in
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check Firebase Auth state
      final firebaseUser = _authService.currentUser;

      if (firebaseUser != null) {
        // User is logged in, fetch user data from Firestore
        _currentUser = await _authService.getUserData(firebaseUser.uid);

        if (_currentUser != null) {
          // Initialize notifications
          await _initializeNotifications();
        }
      } else {
        // Check SharedPreferences for offline mode
        final prefs = await SharedPreferences.getInstance();
        final isLoggedIn = prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;

        if (isLoggedIn) {
          final userId = prefs.getString(AppConstants.keyUserId);
          final userEmail = prefs.getString(AppConstants.keyUserEmail);
          final userName = prefs.getString(AppConstants.keyUserName);
          final userRole = prefs.getString(AppConstants.keyUserRole);

          if (userId != null && userEmail != null && userName != null && userRole != null) {
            _currentUser = User(
              id: userId,
              email: userEmail,
              name: userName,
              role: userRole,
              createdAt: DateTime.now(),
              lastLogin: DateTime.now(),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Initialize notifications for current user
  Future<void> _initializeNotifications() async {
    if (_currentUser == null) return;

    try {
      await _notificationService.initialize();

      // Subscribe to role-based topics
      await _notificationService.subscribeToRoleTopics(_currentUser!.role);

      // Save FCM token to Firestore
      final token = await _notificationService.getToken();
      if (token != null) {
        await _notificationService.saveTokenToFirestore(_currentUser!.id, token);
      }
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  // Login with email and password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (user != null) {
        _currentUser = user;
        await _saveUserToPrefs();
        await _initializeNotifications();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid email or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register new user
  Future<bool> register({
    required String email,
    required String name,
    required String password,
    required String role,
    String? phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        role: role,
        phone: phone,
      );

      if (user != null) {
        _currentUser = user;
        await _saveUserToPrefs();
        await _initializeNotifications();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Unsubscribe from notifications
      if (_currentUser != null) {
        await _notificationService.unsubscribeFromAllTopics(_currentUser!.role);
      }

      // Sign out from Firebase
      await _authService.signOut();

      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      _currentUser = null;
      _errorMessage = null;
    } catch (e) {
      debugPrint('Error logging out: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? profileImageUrl,
    bool? locationSharingEnabled,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await _authService.updateUserProfile(
        uid: _currentUser!.id,
        name: name,
        phone: phone,
        profileImageUrl: profileImageUrl,
      );

      // Update local user object
      _currentUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        phoneNumber: phone ?? _currentUser!.phoneNumber,
        profileImageUrl: profileImageUrl ?? _currentUser!.profileImageUrl,
        locationSharingEnabled: locationSharingEnabled ?? _currentUser!.locationSharingEnabled,
      );

      await _saveUserToPrefs();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Toggle location sharing
  bool get isLocationSharing => _locationService.isSharing;

  Future<void> toggleLocationSharing() async {
    if (_currentUser == null) return;

    final newValue = !_currentUser!.locationSharingEnabled;

    if (newValue) {
      // Start GPS sharing
      final success = await _locationService.startSharing(_currentUser!.id);
      if (!success) {
        _errorMessage = 'Location permission denied. Please enable it in Settings.';
        notifyListeners();
        return;
      }
    } else {
      // Stop GPS sharing
      await _locationService.stopSharing();
    }

    await updateProfile(locationSharingEnabled: newValue);
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to change password: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to send reset email: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Save user to shared preferences (for offline mode)
  Future<void> _saveUserToPrefs() async {
    if (_currentUser == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyIsLoggedIn, true);
    await prefs.setString(AppConstants.keyUserId, _currentUser!.id);
    await prefs.setString(AppConstants.keyUserEmail, _currentUser!.email);
    await prefs.setString(AppConstants.keyUserName, _currentUser!.name);
    await prefs.setString(AppConstants.keyUserRole, _currentUser!.role);
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Listen to auth state changes
  void listenToAuthChanges() {
    _authService.authStateChanges.listen((firebase_auth.User? firebaseUser) async {
      if (firebaseUser == null) {
        _currentUser = null;
        notifyListeners();
      } else {
        // Refresh user data
        _currentUser = await _authService.getUserData(firebaseUser.uid);
        notifyListeners();
      }
    });
  }

  // Refresh user data from Firestore
  Future<void> refreshUserData() async {
    if (_currentUser == null) return;

    try {
      final updatedUser = await _authService.getUserData(_currentUser!.id);
      if (updatedUser != null) {
        _currentUser = updatedUser;
        await _saveUserToPrefs();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error refreshing user data: $e');
    }
  }

  // Quick login for demo (using predefined demo accounts)
  Future<void> quickLoginAs(String role) async {
    // Demo credentials mapping
    final demoCredentials = {
      'fan': {'email': 'fan@test.com', 'password': 'password123'},
      'organizer': {'email': 'organizer@test.com', 'password': 'password123'},
      'security': {'email': 'security@test.com', 'password': 'password123'},
      'emergency': {'email': 'emergency@test.com', 'password': 'password123'},
    };

    final credentials = demoCredentials[role];
    if (credentials != null) {
      await login(credentials['email']!, credentials['password']!);
    }
  }
}
