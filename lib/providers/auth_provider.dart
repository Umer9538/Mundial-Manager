import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/location_service.dart';
import '../core/constants/constants.dart';
import '../core/config/environment.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();
  final LocationService _locationService = LocationService();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _needsEmailVerification = false;
  int _loginAttempts = 0;
  DateTime? _lockoutUntil;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  String? get userRole => _currentUser?.role;
  bool get needsEmailVerification => _needsEmailVerification;
  bool get isEmailVerified => _authService.isEmailVerified;

  bool get isLockedOut {
    if (_lockoutUntil == null) return false;
    if (DateTime.now().isAfter(_lockoutUntil!)) {
      _lockoutUntil = null;
      _loginAttempts = 0;
      return false;
    }
    return true;
  }

  // Initialize - Check if user is already logged in
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadLockoutState();

      // Check session timeout
      final prefs = await SharedPreferences.getInstance();
      final lastActiveStr = prefs.getString(AppConstants.keyLastActiveTime);
      if (lastActiveStr != null) {
        final lastActive = DateTime.tryParse(lastActiveStr);
        if (lastActive != null) {
          final elapsed = DateTime.now().difference(lastActive);
          if (elapsed > AppConfig.sessionTimeout) {
            // Session expired - force logout
            await _clearLocalSession();
            _isLoading = false;
            notifyListeners();
            return;
          }
        }
      }

      // Check Firebase Auth state
      final firebaseUser = _authService.currentUser;

      if (firebaseUser != null) {
        // User is logged in, fetch user data from Firestore
        _currentUser = await _authService.getUserData(firebaseUser.uid);

        if (_currentUser != null) {
          await _initializeNotifications();
          await _updateLastActiveTime();
        }
      } else {
        // Check SharedPreferences for offline mode
        final isLoggedIn = prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;

        if (isLoggedIn) {
          final userId = prefs.getString(AppConstants.keyUserId);
          final userEmail = prefs.getString(AppConstants.keyUserEmail);
          final userName = prefs.getString(AppConstants.keyUserName);
          final userRole = prefs.getString(AppConstants.keyUserRole);

          if (userId != null &&
              userEmail != null &&
              userName != null &&
              userRole != null) {
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
      await _notificationService.subscribeToRoleTopics(_currentUser!.role);

      final token = await _notificationService.getToken();
      if (token != null) {
        await _notificationService.saveTokenToFirestore(
            _currentUser!.id, token);
      }
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  // Login with email and password
  Future<bool> login(String email, String password) async {
    // Check lockout
    if (isLockedOut) {
      final remaining = _lockoutUntil!.difference(DateTime.now()).inMinutes;
      _errorMessage =
          'Account locked. Try again in $remaining minute${remaining == 1 ? '' : 's'}.';
      notifyListeners();
      return false;
    }

    // Validate inputs
    final emailError = AppConstants.validateEmail(email);
    if (emailError != null) {
      _errorMessage = emailError;
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (user != null) {
        // Reset login attempts on success
        _loginAttempts = 0;
        _lockoutUntil = null;
        await _saveLockoutState();

        // Check email verification (skip for demo accounts in dev mode)
        final isDemoLogin = AppConfig.showDemoFeatures &&
            AppConstants.isDemoAccount(email);
        if (!isDemoLogin && !_authService.isEmailVerified) {
          _needsEmailVerification = true;
          _currentUser = user;
          await _saveUserToPrefs();
          _isLoading = false;
          notifyListeners();
          return true; // Login succeeded, but needs verification
        }

        _needsEmailVerification = false;
        _currentUser = user;
        await _saveUserToPrefs();
        await _updateLastActiveTime();
        await _initializeNotifications();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _handleFailedLogin();
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _handleFailedLogin();
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void _handleFailedLogin() {
    _loginAttempts++;
    if (_loginAttempts >= AppConfig.maxLoginAttempts) {
      _lockoutUntil = DateTime.now().add(AppConfig.lockoutDuration);
      _errorMessage = AppConstants.errorAccountLocked;
    } else {
      final remaining = AppConfig.maxLoginAttempts - _loginAttempts;
      _errorMessage =
          'Invalid email or password. $remaining attempt${remaining == 1 ? '' : 's'} remaining.';
    }
    _saveLockoutState();
  }

  Future<void> _loadLockoutState() async {
    final prefs = await SharedPreferences.getInstance();
    _loginAttempts = prefs.getInt(AppConstants.keyLoginAttempts) ?? 0;
    final lockoutStr = prefs.getString(AppConstants.keyLockoutUntil);
    if (lockoutStr != null) {
      _lockoutUntil = DateTime.tryParse(lockoutStr);
    }
  }

  Future<void> _saveLockoutState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.keyLoginAttempts, _loginAttempts);
    if (_lockoutUntil != null) {
      await prefs.setString(
          AppConstants.keyLockoutUntil, _lockoutUntil!.toIso8601String());
    } else {
      await prefs.remove(AppConstants.keyLockoutUntil);
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

    // Validate inputs
    final emailError = AppConstants.validateEmail(email);
    if (emailError != null) {
      _errorMessage = emailError;
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final passwordError = AppConstants.validatePassword(password);
    if (passwordError != null) {
      _errorMessage = passwordError;
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final nameError = AppConstants.validateName(name);
    if (nameError != null) {
      _errorMessage = nameError;
      _isLoading = false;
      notifyListeners();
      return false;
    }

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
        _needsEmailVerification = true;
        await _saveUserToPrefs();

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

  // Resend email verification
  Future<bool> resendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to send verification email: $e';
      notifyListeners();
      return false;
    }
  }

  // Check email verification and proceed
  Future<bool> checkAndConfirmEmailVerification() async {
    try {
      final verified = await _authService.checkEmailVerified();
      if (verified) {
        _needsEmailVerification = false;
        await _updateLastActiveTime();
        await _initializeNotifications();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking email verification: $e');
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_currentUser != null) {
        await _notificationService
            .unsubscribeFromAllTopics(_currentUser!.role);
      }

      // Stop location sharing
      if (_locationService.isSharing) {
        await _locationService.stopSharing();
      }

      await _authService.signOut();
      await _clearLocalSession();

      _currentUser = null;
      _errorMessage = null;
      _needsEmailVerification = false;
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
        locationSharingEnabled: locationSharingEnabled,
      );

      _currentUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        phoneNumber: phone ?? _currentUser!.phoneNumber,
        profileImageUrl: profileImageUrl ?? _currentUser!.profileImageUrl,
        locationSharingEnabled:
            locationSharingEnabled ?? _currentUser!.locationSharingEnabled,
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
      final success = await _locationService.startSharing(_currentUser!.id);
      if (!success) {
        _errorMessage =
            'Location permission denied. Please enable it in Settings.';
        notifyListeners();
        return;
      }
    } else {
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

    // Validate new password
    final passwordError = AppConstants.validatePassword(newPassword);
    if (passwordError != null) {
      _errorMessage = passwordError;
      _isLoading = false;
      notifyListeners();
      return false;
    }

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

  Future<void> _updateLastActiveTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        AppConstants.keyLastActiveTime, DateTime.now().toIso8601String());
  }

  Future<void> _clearLocalSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyIsLoggedIn);
    await prefs.remove(AppConstants.keyUserId);
    await prefs.remove(AppConstants.keyUserEmail);
    await prefs.remove(AppConstants.keyUserName);
    await prefs.remove(AppConstants.keyUserRole);
    await prefs.remove(AppConstants.keyLastActiveTime);
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Listen to auth state changes
  void listenToAuthChanges() {
    _authService.authStateChanges
        .listen((firebase_auth.User? firebaseUser) async {
      if (firebaseUser == null) {
        _currentUser = null;
        notifyListeners();
      } else {
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
        await _updateLastActiveTime();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error refreshing user data: $e');
    }
  }

  // Quick login for demo (only in non-production)
  Future<bool> quickLoginAs(String role) async {
    if (!AppConfig.showDemoFeatures) return false;

    final creds = AppConstants.demoCredentials;
    if (creds == null) return false;

    final credentials = creds[role];
    if (credentials != null) {
      return await login(credentials['email']!, credentials['password']!);
    }
    return false;
  }
}
