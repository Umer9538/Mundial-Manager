import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class ProfileDialogs {
  static void showEditProfile(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.currentUser!;
    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phoneNumber ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A2A3A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Edit Profile',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(
                      controller: nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.roboto(color: Colors.white54),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final name = nameController.text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Name cannot be empty'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          setDialogState(() => isLoading = true);

                          final success = await authProvider.updateProfile(
                            name: name,
                            phone: phoneController.text.trim().isNotEmpty
                                ? phoneController.text.trim()
                                : null,
                          );

                          if (dialogContext.mounted) Navigator.pop(dialogContext);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Profile updated successfully'
                                      : 'Failed to update profile',
                                ),
                                backgroundColor: success ? Colors.green : Colors.red,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
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
                      : Text(
                          'Save',
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static void showChangePassword(BuildContext context, AuthProvider authProvider) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        bool isLoading = false;
        bool showCurrentPassword = false;
        bool showNewPassword = false;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A2A3A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Change Password',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(
                      controller: currentPasswordController,
                      label: 'Current Password',
                      icon: Icons.lock_outline,
                      obscureText: !showCurrentPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          showCurrentPassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white38,
                          size: 20,
                        ),
                        onPressed: () => setDialogState(
                          () => showCurrentPassword = !showCurrentPassword,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: newPasswordController,
                      label: 'New Password',
                      icon: Icons.lock_reset,
                      obscureText: !showNewPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          showNewPassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white38,
                          size: 20,
                        ),
                        onPressed: () => setDialogState(
                          () => showNewPassword = !showNewPassword,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: confirmPasswordController,
                      label: 'Confirm New Password',
                      icon: Icons.lock_reset,
                      obscureText: !showNewPassword,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.roboto(color: Colors.white54),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final current = currentPasswordController.text;
                          final newPass = newPasswordController.text;
                          final confirm = confirmPasswordController.text;

                          if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill in all fields'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          if (newPass.length < 8) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('New password must be at least 8 characters'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          if (newPass != confirm) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('New passwords do not match'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          setDialogState(() => isLoading = true);

                          final success = await authProvider.changePassword(
                            currentPassword: current,
                            newPassword: newPass,
                          );

                          if (dialogContext.mounted) Navigator.pop(dialogContext);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Password changed successfully'
                                      : authProvider.errorMessage ?? 'Failed to change password',
                                ),
                                backgroundColor: success ? Colors.green : Colors.red,
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
                      : Text(
                          'Change',
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.white54, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFF0D1B2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.softTealBlue),
        ),
      ),
    );
  }
}
