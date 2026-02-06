import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/gradient_scaffold.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/custom_button.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isCheckingVerification = false;
  bool _isResending = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;
  Timer? _autoCheckTimer;

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
    _startAutoCheck();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _autoCheckTimer?.cancel();
    super.dispose();
  }

  void _startResendCooldown() {
    setState(() => _resendCooldown = 60);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() => _resendCooldown--);
      } else {
        timer.cancel();
      }
    });
  }

  void _startAutoCheck() {
    // Auto-check verification status every 3 seconds
    _autoCheckTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await _checkVerification(silent: true);
    });
  }

  Future<void> _checkVerification({bool silent = false}) async {
    if (_isCheckingVerification) return;

    if (!silent) {
      setState(() => _isCheckingVerification = true);
    }

    try {
      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        await firebaseUser.reload();
        final refreshedUser = firebase_auth.FirebaseAuth.instance.currentUser;

        if (refreshedUser != null && refreshedUser.emailVerified) {
          _autoCheckTimer?.cancel();

          if (mounted) {
            final authProvider =
                Provider.of<AuthProvider>(context, listen: false);
            await authProvider.refreshUserData();

            if (mounted) {
              final role = authProvider.currentUser?.role;
              _navigateToDashboard(role);
            }
          }
          return;
        }
      }

      if (!silent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Email not verified yet. Please check your inbox.',
              style: GoogleFonts.roboto(color: Colors.white),
            ),
            backgroundColor: AppColors.orange,
          ),
        );
      }
    } catch (e) {
      if (!silent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error checking verification status',
              style: GoogleFonts.roboto(color: Colors.white),
            ),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } finally {
      if (!silent && mounted) {
        setState(() => _isCheckingVerification = false);
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (_resendCooldown > 0 || _isResending) return;

    setState(() => _isResending = true);

    try {
      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        await firebaseUser.sendEmailVerification();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Verification email sent!',
                style: GoogleFonts.roboto(color: Colors.white),
              ),
              backgroundColor: AppColors.green,
            ),
          );
          _startResendCooldown();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to send verification email. Please try again.',
              style: GoogleFonts.roboto(color: Colors.white),
            ),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  void _navigateToDashboard(String? role) {
    switch (role) {
      case 'organizer':
        context.go('/organizer');
        break;
      case 'security':
        context.go('/security');
        break;
      case 'emergency':
        context.go('/emergency');
        break;
      case 'fan':
      default:
        context.go('/fan');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final email = authProvider.currentUser?.email ?? 'your email';

    return GradientScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // Email icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.softTealBlue.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.softTealBlue.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.mark_email_unread_outlined,
                  size: 56,
                  color: AppColors.softTealBlue,
                ),
              ),
              const SizedBox(height: 32),

              // Main content card
              GlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      'Verify Your Email',
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'We\'ve sent a verification email to:',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Email address
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0x1AFFFFFF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        email,
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.softTealBlue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'Please check your inbox and click the verification link '
                      'to activate your account. If you don\'t see the email, '
                      'check your spam or junk folder.',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: Colors.white54,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Verify button
                    CustomButton.primary(
                      text: _isCheckingVerification
                          ? 'Checking...'
                          : 'I\'ve Verified, Continue',
                      icon: Icons.check_circle_outline,
                      isLoading: _isCheckingVerification,
                      onPressed: _isCheckingVerification
                          ? null
                          : () => _checkVerification(),
                    ),
                    const SizedBox(height: 16),

                    // Resend button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: (_resendCooldown > 0 || _isResending)
                            ? null
                            : _resendVerificationEmail,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: _resendCooldown > 0
                                ? Colors.white24
                                : AppColors.softTealBlue,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isResending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.refresh,
                                    size: 20,
                                    color: _resendCooldown > 0
                                        ? Colors.white38
                                        : Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _resendCooldown > 0
                                        ? 'Resend Email ($_resendCooldown s)'
                                        : 'Resend Verification Email',
                                    style: GoogleFonts.roboto(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: _resendCooldown > 0
                                          ? Colors.white38
                                          : Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Cooldown timer display
                    if (_resendCooldown > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.timer_outlined,
                              size: 14, color: Colors.white38),
                          const SizedBox(width: 4),
                          Text(
                            'You can resend in $_resendCooldown seconds',
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              color: Colors.white38,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Help text
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.help_outline,
                        color: AppColors.softTealBlue, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Having trouble? Make sure to check your spam folder. '
                        'The email may take a few minutes to arrive.',
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: Colors.white54,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Back to login
              GestureDetector(
                onTap: () async {
                  final authProvider =
                      Provider.of<AuthProvider>(context, listen: false);
                  await authProvider.logout();
                  if (mounted) {
                    context.go('/login');
                  }
                },
                child: Text(
                  'Back to Login',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: AppColors.softTealBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
