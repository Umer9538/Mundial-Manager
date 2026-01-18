import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/gradient_scaffold.dart';
import '../../widgets/common/glass_card.dart';

class FanProfileScreen extends StatelessWidget {
  const FanProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.currentUser;
          if (user == null) return const SizedBox();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            child: SafeArea(
              child: Column(
                children: [
                  // Header with back button and title
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'My Profile',
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 40), // Balance the back button
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Profile Avatar
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: AppColors.coolSteelBlue.withOpacity(0.5),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.coolSteelBlue,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      Icons.person_outline,
                      size: 55,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // User Name
                  Text(
                    user.name,
                    style: GoogleFonts.montserrat(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Email
                  Text(
                    user.email,
                    style: GoogleFonts.roboto(
                      fontSize: 15,
                      color: Colors.white60,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Role Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.softTealBlue.withOpacity(0.6),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      user.roleDisplayName,
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.softTealBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Edit Profile Button (Green)
                  _ActionButton(
                    text: 'Edit Profile',
                    icon: Icons.edit_outlined,
                    backgroundColor: AppColors.green,
                    textColor: Colors.white,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Edit Profile coming soon')),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Change Password Button (Outline)
                  _ActionButton(
                    text: 'Change Password',
                    icon: Icons.lock_outline,
                    backgroundColor: Colors.transparent,
                    textColor: Colors.white,
                    borderColor: Colors.white38,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Change Password coming soon')),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Logout Button (Red/Orange)
                  _ActionButton(
                    text: 'Logout',
                    icon: Icons.logout,
                    backgroundColor: AppColors.red,
                    textColor: Colors.white,
                    onPressed: () async {
                      await authProvider.logout();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                  ),
                  const SizedBox(height: 32),

                  // Settings Section
                  GlassCard(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: Column(
                      children: [
                        _SettingsTile(
                          icon: Icons.location_on_outlined,
                          title: 'Location Sharing',
                          subtitle: 'Help improve crowd management',
                          value: user.locationSharingEnabled,
                          onChanged: (value) => authProvider.toggleLocationSharing(),
                        ),
                        const Divider(color: Colors.white12, height: 1, indent: 16, endIndent: 16),
                        _SettingsTile(
                          icon: Icons.notifications_outlined,
                          title: 'Push Notifications',
                          subtitle: 'Receive alerts and updates',
                          value: true,
                          onChanged: (value) {
                            // TODO: Implement notification toggle
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.text,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: borderColor != null
              ? Border.all(color: borderColor!, width: 1.5)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 10),
            Text(
              text,
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white70, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.roboto(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: AppColors.green,
            inactiveThumbColor: Colors.white70,
            inactiveTrackColor: Colors.white24,
          ),
        ],
      ),
    );
  }
}
