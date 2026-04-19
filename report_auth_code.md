# Authentication System - Complete Source Code

## Architecture Overview

The authentication system follows a **3-layer architecture**:

1. **UI Layer** (`LoginScreen`, `RegisterScreen`) - User interface with form validation
2. **State Management Layer** (`AuthProvider`) - Business logic using Provider/ChangeNotifier pattern
3. **Service Layer** (`AuthService`) - Direct Firebase Auth & Firestore operations

**Flow:**
```
UI Screen → AuthProvider → AuthService → Firebase Auth + Firestore
```

---

## 1. User Model (`lib/models/user.dart`)

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final String name;
  final String role; // fan, organizer, security, emergency
  final String? phoneNumber;
  final String? profileImageUrl;
  final String? assignedZone;
  final bool locationSharingEnabled;
  final DateTime createdAt;
  final DateTime? lastLogin;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phoneNumber,
    this.profileImageUrl,
    this.assignedZone,
    this.locationSharingEnabled = false,
    required this.createdAt,
    this.lastLogin,
  });

  // Helper to parse DateTime from various formats (Firestore Timestamp, String, or DateTime)
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  // Create user from JSON/Firestore document
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      phoneNumber: json['phoneNumber'] as String? ?? json['phone'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      assignedZone: json['assignedZone'] as String?,
      locationSharingEnabled: json['locationSharingEnabled'] as bool? ?? false,
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      lastLogin: _parseDateTime(json['lastLogin']),
    );
  }

  // Convert user to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'assignedZone': assignedZone,
      'locationSharingEnabled': locationSharingEnabled,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  // Copy with method
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? phoneNumber,
    String? profileImageUrl,
    String? assignedZone,
    bool? locationSharingEnabled,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      assignedZone: assignedZone ?? this.assignedZone,
      locationSharingEnabled: locationSharingEnabled ?? this.locationSharingEnabled,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  // Get role display name
  String get roleDisplayName {
    switch (role) {
      case 'fan':
        return 'Fan';
      case 'organizer':
        return 'Event Organizer';
      case 'security':
        return 'Security Team';
      case 'emergency':
        return 'Emergency Services';
      default:
        return 'User';
    }
  }
}
```

---

## 2. Auth Service (`lib/services/auth_service.dart`)

This service handles all direct Firebase Authentication and Firestore operations.

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as app_models;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current Firebase user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if current user's email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Sign in with email and password
  Future<app_models.User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Update last login timestamp
        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .update({
          'lastLogin': FieldValue.serverTimestamp(),
        }).catchError((_) {});

        // Fetch user data from Firestore
        final userDoc = await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .get();

        if (userDoc.exists) {
          return app_models.User.fromJson({
            'id': credential.user!.uid,
            ...userDoc.data()!,
          });
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Register with email and password
  Future<app_models.User?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String role,
    String? phone,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Send email verification
        await credential.user!.sendEmailVerification();

        // Create user document in Firestore
        final userData = {
          'email': email,
          'name': name,
          'role': role,
          'phone': phone,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
          'isActive': true,
          'emailVerified': false,
          'assignedZones': <String>[],
          'profileImageUrl': null,
          'locationSharingEnabled': false,
        };

        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(userData);

        // Update display name
        await credential.user!.updateDisplayName(name);

        return app_models.User.fromJson({
          'id': credential.user!.uid,
          ...userData,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // Check email verification status
  Future<bool> checkEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    await user.reload();
    final isVerified = _auth.currentUser?.emailVerified ?? false;

    if (isVerified) {
      // Update Firestore record
      await _firestore.collection('users').doc(user.uid).update({
        'emailVerified': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }).catchError((_) {});
    }

    return isVerified;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get user data from Firestore
  Future<app_models.User?> getUserData(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        return app_models.User.fromJson({
          'id': uid,
          ...userDoc.data()!,
        });
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? phone,
    String? profileImageUrl,
    List<String>? assignedZones,
    bool? locationSharingEnabled,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (profileImageUrl != null) updates['profileImageUrl'] = profileImageUrl;
    if (assignedZones != null) updates['assignedZones'] = assignedZones;
    if (locationSharingEnabled != null) {
      updates['locationSharingEnabled'] = locationSharingEnabled;
    }

    await _firestore.collection('users').doc(uid).update(updates);

    // Update Firebase Auth display name if name changed
    if (name != null && _auth.currentUser != null) {
      await _auth.currentUser!.updateDisplayName(name);
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('No user logged in');
    }

    // Re-authenticate user
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);

    // Update password
    await user.updatePassword(newPassword);
  }

  // Delete account
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Delete Firestore document
    await _firestore.collection('users').doc(user.uid).delete();

    // Delete Firebase Auth account
    await user.delete();
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 8 characters.';
      case 'operation-not-allowed':
        return 'This sign-in method is not allowed.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return e.message ?? 'An error occurred during authentication.';
    }
  }
}
```

---

## 3. Auth Provider (`lib/providers/auth_provider.dart`)

State management layer that connects UI to services. Implements login lockout, session management, and offline support.

```dart
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

          if (userId != null && userEmail != null &&
              userName != null && userRole != null) {
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

        // Check email verification
        final isDemoLogin = AppConfig.showDemoFeatures &&
            AppConstants.isDemoAccount(email);
        if (!isDemoLogin && !_authService.isEmailVerified) {
          _needsEmailVerification = true;
          _currentUser = user;
          await _saveUserToPrefs();
          _isLoading = false;
          notifyListeners();
          return true;
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

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_currentUser != null) {
        await _notificationService
            .unsubscribeFromAllTopics(_currentUser!.role);
      }

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

  // Delete user account
  Future<bool> deleteAccount() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_currentUser != null) {
        await _notificationService
            .unsubscribeFromAllTopics(_currentUser!.role);
      }

      if (_locationService.isSharing) {
        await _locationService.stopSharing();
      }

      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        await firebaseUser.delete();
      }

      await _clearLocalSession();
      _currentUser = null;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        _errorMessage =
            'Please log out and log back in before deleting your account.';
      } else {
        _errorMessage = 'Failed to delete account: ${e.message}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to delete account';
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

  // Save user to SharedPreferences (for offline mode)
  Future<void> _saveUserToPrefs() async {
    if (_currentUser == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyIsLoggedIn, true);
    await prefs.setString(AppConstants.keyUserId, _currentUser!.id);
    await prefs.setString(AppConstants.keyUserEmail, _currentUser!.email);
    await prefs.setString(AppConstants.keyUserName, _currentUser!.name);
    await prefs.setString(AppConstants.keyUserRole, _currentUser!.role);
  }

  Future<void> _clearLocalSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyIsLoggedIn);
    await prefs.remove(AppConstants.keyUserId);
    await prefs.remove(AppConstants.keyUserEmail);
    await prefs.remove(AppConstants.keyUserName);
    await prefs.remove(AppConstants.keyUserRole);
    await prefs.remove(AppConstants.keyLastActiveTime);

    final rememberMe = prefs.getBool(AppConstants.keyRememberMe) ?? false;
    if (!rememberMe) {
      await prefs.remove(AppConstants.keyRememberedEmail);
    }
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

  Future<void> _updateLastActiveTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        AppConstants.keyLastActiveTime, DateTime.now().toIso8601String());
  }

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
}
```

---

## 4. Login Screen UI (`lib/screens/auth/login_screen.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/constants.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/gradient_scaffold.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedEmail();
  }

  Future<void> _loadRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final remembered = prefs.getBool(AppConstants.keyRememberMe) ?? false;
    final email = prefs.getString(AppConstants.keyRememberedEmail) ?? '';
    if (remembered && email.isNotEmpty && mounted) {
      setState(() {
        _rememberMe = true;
        _emailController.text = email;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (mounted) {
      if (success) {
        // Save or clear remembered email
        final prefs = await SharedPreferences.getInstance();
        if (_rememberMe) {
          await prefs.setBool(AppConstants.keyRememberMe, true);
          await prefs.setString(
              AppConstants.keyRememberedEmail, _emailController.text.trim());
        } else {
          await prefs.remove(AppConstants.keyRememberMe);
          await prefs.remove(AppConstants.keyRememberedEmail);
        }

        if (mounted) {
          context.go(AppRouter.getDashboardRoute(authProvider.userRole!));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Login failed'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(
      text: _emailController.text.trim(),
    );

    showDialog(
      context: context,
      builder: (context) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A2A3A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Reset Password',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter your email address and we\'ll send you a link '
                    'to reset your password.',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: resetEmailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.email_outlined,
                          color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF0D1B2A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: Text('Cancel',
                      style: GoogleFonts.roboto(color: Colors.white54)),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final email = resetEmailController.text.trim();
                          if (email.isEmpty || !email.contains('@')) {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a valid email'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          setDialogState(() => isLoading = true);

                          final authProvider = Provider.of<AuthProvider>(
                            this.context,
                            listen: false,
                          );
                          final success =
                              await authProvider.resetPassword(email);

                          if (context.mounted) Navigator.pop(context);

                          if (mounted) {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Password reset link sent to $email'
                                      : authProvider.errorMessage ??
                                          'Failed to send reset email',
                                ),
                                backgroundColor:
                                    success ? Colors.green : Colors.red,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.softTealBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text('Send Link',
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          )),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),

                    // Logo
                    Center(
                      child: Image.asset(
                        'assets/logo.png',
                        width: 140,
                        height: 140,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'Welcome Back',
                      style: GoogleFonts.montserrat(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please enter your account details.',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Login Form Card with overlapping user icon
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topCenter,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: GlassCard(
                            padding: const EdgeInsets.only(
                              top: 50, left: 24, right: 24, bottom: 24,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Email Field
                                CustomTextField(
                                  label: 'Email',
                                  hint: 'Enter your email',
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  prefixIcon: Icons.email_outlined,
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!value.contains('@')) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                // Password Field
                                CustomTextField(
                                  label: 'Password',
                                  hint: 'Enter your password',
                                  controller: _passwordController,
                                  obscureText: true,
                                  prefixIcon: Icons.lock_outline,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _handleLogin(),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    if (value.length < 8) {
                                      return 'Password must be at least 8 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Remember Me & Forgot Password
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: Checkbox(
                                            value: _rememberMe,
                                            onChanged: (value) {
                                              setState(() {
                                                _rememberMe = value ?? false;
                                              });
                                            },
                                            fillColor:
                                                WidgetStateProperty.resolveWith(
                                              (states) {
                                                if (states.contains(
                                                    WidgetState.selected)) {
                                                  return AppColors.blue;
                                                }
                                                return Colors.transparent;
                                              },
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text('Remember Me',
                                            style: GoogleFonts.roboto(
                                              fontSize: 13,
                                              color: Colors.white70,
                                            )),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: () =>
                                          _showForgotPasswordDialog(),
                                      child: Text('Forgot Password?',
                                          style: GoogleFonts.roboto(
                                            fontSize: 13,
                                            color: AppColors.softTealBlue,
                                            fontWeight: FontWeight.w500,
                                          )),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // Login Button
                                CustomButton(
                                  text: 'Login',
                                  variant: ButtonVariant.secondary,
                                  onPressed: _handleLogin,
                                  isLoading: authProvider.isLoading,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // User Icon overlapping card top
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A3A5C),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0x33FFFFFF),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            color: Colors.white70,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account? ",
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: Colors.white70,
                            )),
                        GestureDetector(
                          onTap: () => context.push('/register'),
                          child: Text('Register',
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                color: AppColors.softTealBlue,
                                fontWeight: FontWeight.w600,
                              )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
```

---

## 5. Register Screen UI (`lib/screens/auth/register_screen.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/gradient_scaffold.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _selectedRole;

  final List<Map<String, dynamic>> _roles = [
    {'value': 'fan', 'label': 'Fan', 'icon': Icons.person},
    {'value': 'organizer', 'label': 'Event Organizer', 'icon': Icons.manage_accounts},
    {'value': 'security', 'label': 'Security Team', 'icon': Icons.security},
    {'value': 'emergency', 'label': 'Emergency Services', 'icon': Icons.medical_services},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Passwords do not match'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a role'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.register(
      email: _emailController.text.trim(),
      name: _nameController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole!,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Registration successful!'),
            backgroundColor: AppColors.green,
          ),
        );
        context.pop(); // Return to login
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Registration failed'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),

                    // Logo
                    Center(
                      child: Image.asset(
                        'assets/logo.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    ),

                    // Card overlapping below logo
                    Transform.translate(
                      offset: const Offset(0, -16),
                      child: GlassCard(
                        padding: const EdgeInsets.only(
                          top: 32, left: 24, right: 24, bottom: 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Create Your Account',
                              style: GoogleFonts.montserrat(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),

                            // Name Field
                            CustomTextField(
                              label: 'Name',
                              hint: 'Enter your full name',
                              controller: _nameController,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                if (value.length < 2) {
                                  return 'Name must be at least 2 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Email Field
                            CustomTextField(
                              label: 'Email',
                              hint: 'Enter your email',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Password Field
                            CustomTextField(
                              label: 'Password',
                              hint: 'Enter your password',
                              controller: _passwordController,
                              obscureText: true,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a password';
                                }
                                if (value.length < 8) {
                                  return 'Password must be at least 8 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Confirm Password Field
                            CustomTextField(
                              label: 'Confirm Password',
                              hint: 'Confirm your password',
                              controller: _confirmPasswordController,
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Role Selection Dropdown
                            CustomDropdownField<String>(
                              label: 'Select Your Role',
                              hint: 'Select Role',
                              value: _selectedRole,
                              items: _roles.map((role) {
                                return DropdownMenuItem<String>(
                                  value: role['value'] as String,
                                  child: Row(
                                    children: [
                                      Icon(
                                        role['icon'] as IconData,
                                        size: 20,
                                        color: Colors.white70,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(role['label'] as String),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedRole = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a role';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 28),

                            // Register Button
                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: authProvider.isLoading
                                    ? null
                                    : _handleRegister,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.softTealBlue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: authProvider.isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text('Register',
                                        style: GoogleFonts.roboto(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        )),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Login Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Already have an account? ',
                                    style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    )),
                                GestureDetector(
                                  onTap: () => context.pop(),
                                  child: Text('Login',
                                      style: GoogleFonts.roboto(
                                        fontSize: 14,
                                        color: AppColors.softTealBlue,
                                        fontWeight: FontWeight.w600,
                                      )),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
```

---

## Security Features Summary

| Feature | Implementation |
|---------|---------------|
| **Password Hashing** | Handled by Firebase Auth (bcrypt internally) |
| **Login Lockout** | 5 failed attempts → 15-minute lockout (configurable) |
| **Session Timeout** | Auto-logout after inactivity period |
| **Email Verification** | Sent on registration, checked on login |
| **Remember Me** | Email stored in SharedPreferences |
| **Offline Support** | User data cached in SharedPreferences |
| **Input Validation** | Email regex, password strength, name length |
| **Error Handling** | Firebase error codes mapped to user-friendly messages |
| **Account Deletion** | Firebase Auth + Firestore cleanup |
| **Password Reset** | Firebase email-based reset link |
