import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getRoles(AppLocalizations l) {
    return [
      {'value': 'fan', 'label': l.roleFan, 'icon': Icons.person},
      {'value': 'organizer', 'label': l.roleOrganizer, 'icon': Icons.manage_accounts},
      {'value': 'security', 'label': l.roleSecurity, 'icon': Icons.security},
      {'value': 'emergency', 'label': l.roleEmergency, 'icon': Icons.medical_services},
    ];
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final l = AppLocalizations.of(context)!;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.passwordsMismatch),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.pleaseSelectRole),
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
            content: Text(l.registrationSuccess),
            backgroundColor: AppColors.green,
          ),
        );
        context.pop(); // Return to login
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? l.registrationFailed),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final roles = _getRoles(l);

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
                              l.createAccountTitle,
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
                              label: l.nameLabel,
                              hint: l.nameHint,
                              controller: _nameController,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l.nameRequired;
                                }
                                if (value.length < 2) {
                                  return l.nameMinLength;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Email Field
                            CustomTextField(
                              label: l.emailLabel,
                              hint: l.emailHint,
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l.emailRequired;
                                }
                                if (!value.contains('@')) {
                                  return l.emailInvalid;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Password Field
                            CustomTextField(
                              label: l.passwordLabel,
                              hint: l.passwordHint,
                              controller: _passwordController,
                              obscureText: true,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l.passwordRequired;
                                }
                                if (value.length < 8) {
                                  return l.passwordMinLength;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Confirm Password Field
                            CustomTextField(
                              label: l.confirmPasswordLabel,
                              hint: l.confirmPasswordHint,
                              controller: _confirmPasswordController,
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l.confirmPasswordRequired;
                                }
                                if (value != _passwordController.text) {
                                  return l.passwordsMismatch;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Role Selection Dropdown
                            CustomDropdownField<String>(
                              label: l.selectRoleLabel,
                              hint: l.selectRoleHint,
                              value: _selectedRole,
                              items: roles.map((role) {
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
                                  return l.pleaseSelectRole;
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
                                        l.registerButton,
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
                                  l.cancelButton,
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
                                  l.alreadyHaveAccount,
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => context.pop(),
                                  child: Text(
                                    l.loginLink,
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
