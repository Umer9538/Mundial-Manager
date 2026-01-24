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
                          top: 32,
                          left: 24,
                          right: 24,
                          bottom: 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Title inside card
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
                                  elevation: 0,
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
                                    : Text(
                                        'Register',
                                        style: GoogleFonts.roboto(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Cancel Button
                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: () => context.pop(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.coolSteelBlue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Cancel',
                                  style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Login Link inside card
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account? ',
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => context.pop(),
                                  child: Text(
                                    'Login',
                                    style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      color: AppColors.softTealBlue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
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
