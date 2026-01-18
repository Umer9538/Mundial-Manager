import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/gradient_scaffold.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/custom_button.dart';
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
                    _buildLogo(),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'Create Your Account',
                      style: GoogleFonts.montserrat(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Registration Form Card
                    GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Name Field
                          CustomTextField(
                            label: 'Name',
                            hint: 'Enter your full name',
                            controller: _nameController,
                            prefixIcon: Icons.person_outline,
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
                          const SizedBox(height: 16),

                          // Password Field
                          CustomTextField(
                            label: 'Password',
                            hint: 'Enter your password',
                            controller: _passwordController,
                            obscureText: true,
                            prefixIcon: Icons.lock_outline,
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
                            prefixIcon: Icons.lock_outline,
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
                            prefixIcon: Icons.badge_outlined,
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
                          CustomButton.primary(
                            text: 'Register',
                            onPressed: _handleRegister,
                            isLoading: authProvider.isLoading,
                          ),
                          const SizedBox(height: 12),

                          // Cancel Button
                          CustomButton.secondary(
                            text: 'Cancel',
                            onPressed: () => context.pop(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Login Link
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
                    const SizedBox(height: 32),
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
        width: 80,
        height: 80,
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
            Icon(
              Icons.location_on,
              size: 48,
              color: AppColors.softTealBlue,
            ),
            Positioned(
              top: 14,
              child: Icon(
                Icons.sports_soccer,
                size: 22,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
