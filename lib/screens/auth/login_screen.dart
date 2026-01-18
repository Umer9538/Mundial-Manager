import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
        context.go(AppRouter.getDashboardRoute(authProvider.userRole!));
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

  Future<void> _quickLogin(String role) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.quickLoginAs(role);
    if (mounted && authProvider.isAuthenticated) {
      context.go(AppRouter.getDashboardRoute(role));
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
                    _buildLogo(),
                    const SizedBox(height: 32),

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
                    const SizedBox(height: 32),

                    // User Icon
                    Center(
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0x1AFFFFFF),
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
                    ),
                    const SizedBox(height: 32),

                    // Login Form Card
                    GlassCard(
                      padding: const EdgeInsets.all(24),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Remember Me
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
                                      fillColor: WidgetStateProperty.resolveWith(
                                        (states) {
                                          if (states.contains(WidgetState.selected)) {
                                            return AppColors.blue;
                                          }
                                          return Colors.transparent;
                                        },
                                      ),
                                      side: const BorderSide(
                                        color: Colors.white54,
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Remember Me',
                                    style: GoogleFonts.roboto(
                                      fontSize: 13,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                              // Forgot Password
                              GestureDetector(
                                onTap: () {
                                  // TODO: Implement forgot password
                                },
                                child: Text(
                                  'Forgot Password?',
                                  style: GoogleFonts.roboto(
                                    fontSize: 13,
                                    color: AppColors.softTealBlue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
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
                    const SizedBox(height: 24),

                    // Or Register With
                    Text(
                      'or Register With',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: Colors.white54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Social Login Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SocialLoginButton(
                          icon: Icons.g_mobiledata,
                          color: Colors.white,
                          backgroundColor: const Color(0xFFEA4335),
                          onPressed: () {
                            // TODO: Implement Google login
                          },
                        ),
                        const SizedBox(width: 16),
                        _SocialLoginButton(
                          icon: Icons.facebook,
                          color: Colors.white,
                          backgroundColor: const Color(0xFF1877F2),
                          onPressed: () {
                            // TODO: Implement Facebook login
                          },
                        ),
                        const SizedBox(width: 16),
                        _SocialLoginButton(
                          icon: Icons.apple,
                          color: Colors.white,
                          backgroundColor: Colors.black,
                          onPressed: () {
                            // TODO: Implement Apple login
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/register'),
                          child: Text(
                            'Register',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: AppColors.softTealBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Quick Login Section (Demo Only)
                    _buildQuickLoginSection(authProvider),

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

  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.softTealBlue.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.softTealBlue.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Location pin shape
            Icon(
              Icons.location_on,
              size: 60,
              color: AppColors.softTealBlue,
            ),
            // Football icon overlay
            Positioned(
              top: 18,
              child: Icon(
                Icons.sports_soccer,
                size: 28,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickLoginSection(AuthProvider authProvider) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: const Color(0x0DFFFFFF),
      child: Column(
        children: [
          Text(
            'Quick Login (Demo)',
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _QuickLoginChip(
                label: 'Fan',
                icon: Icons.person,
                onPressed: () => _quickLogin('fan'),
              ),
              _QuickLoginChip(
                label: 'Organizer',
                icon: Icons.manage_accounts,
                onPressed: () => _quickLogin('organizer'),
              ),
              _QuickLoginChip(
                label: 'Security',
                icon: Icons.security,
                onPressed: () => _quickLogin('security'),
              ),
              _QuickLoginChip(
                label: 'Emergency',
                icon: Icons.medical_services,
                onPressed: () => _quickLogin('emergency'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onPressed;

  const _SocialLoginButton({
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: 28,
        ),
      ),
    );
  }
}

class _QuickLoginChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _QuickLoginChip({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0x1AFFFFFF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0x33FFFFFF),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 13,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
