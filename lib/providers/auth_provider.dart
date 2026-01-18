import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../core/utils/dummy_data.dart';
import '../core/constants/constants.dart';

class AuthProvider with ChangeNotifier {
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
    } catch (e) {
      debugPrint('Error initializing auth: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login with email and password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Check if credentials match dummy data
      final user = DummyData.getUserByEmail(email);

      if (user == null) {
        _errorMessage = 'Invalid email or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check password (all demo accounts use 'password123')
      if (password != 'password123') {
        _errorMessage = 'Invalid email or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Login successful
      _currentUser = user.copyWith(lastLogin: DateTime.now());
      await _saveUserToPrefs();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Login failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register new user (simplified for demo)
  Future<bool> register({
    required String email,
    required String name,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Check if email already exists
      final existingUser = DummyData.getUserByEmail(email);
      if (existingUser != null) {
        _errorMessage = 'Email already exists';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Create new user
      _currentUser = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: name,
        role: role,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      await _saveUserToPrefs();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Registration failed. Please try again.';
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
    String? phoneNumber,
    bool? locationSharingEnabled,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      _currentUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        phoneNumber: phoneNumber ?? _currentUser!.phoneNumber,
        locationSharingEnabled: locationSharingEnabled ?? _currentUser!.locationSharingEnabled,
      );

      await _saveUserToPrefs();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Toggle location sharing
  Future<void> toggleLocationSharing() async {
    if (_currentUser == null) return;

    final newValue = !_currentUser!.locationSharingEnabled;
    await updateProfile(locationSharingEnabled: newValue);
  }

  // Save user to shared preferences
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

  // Quick login for demo (bypasses password check)
  Future<void> quickLoginAs(String role) async {
    final email = AppConstants.demoCredentials[role]?['email'];
    if (email != null) {
      await login(email, 'password123');
    }
  }
}
