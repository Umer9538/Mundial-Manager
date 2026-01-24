import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/gradient_scaffold.dart';
import '../../widgets/common/glass_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Display Preferences
  bool _darkMode = true;
  double _textSize = 1.0; // 0.8 small, 1.0 medium, 1.2 large

  // Notifications
  bool _pushNotifications = true;
  bool _soundEnabled = true;
  bool _crowdAlerts = true;
  bool _emergencyAlerts = true;

  // Language
  String _selectedLanguage = 'English';

  // Privacy
  bool _locationSharing = true;
  bool _analyticsEnabled = true;

  void _restoreDefaults() {
    setState(() {
      _darkMode = true;
      _textSize = 1.0;
      _pushNotifications = true;
      _soundEnabled = true;
      _crowdAlerts = true;
      _emergencyAlerts = true;
      _selectedLanguage = 'English';
      _locationSharing = true;
      _analyticsEnabled = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Settings restored to defaults'),
        backgroundColor: AppColors.softTealBlue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            children: [
              // Title
              Text(
                'Settings',
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Settings Menu Card
              GlassCard(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    _SettingsItem(
                      icon: Icons.visibility_outlined,
                      label: 'Display Preferences',
                      onTap: () => _showDisplayPreferences(),
                    ),
                    const _SettingsDivider(),
                    _SettingsItem(
                      icon: Icons.notifications_outlined,
                      label: 'Notifications & Alerts',
                      onTap: () => _showNotificationSettings(),
                    ),
                    const _SettingsDivider(),
                    _SettingsItem(
                      icon: Icons.language,
                      label: 'Language & Localization',
                      onTap: () => _showLanguageSettings(),
                    ),
                    const _SettingsDivider(),
                    _SettingsItem(
                      icon: Icons.info_outline,
                      label: 'Privacy & Account',
                      onTap: () => _showPrivacySettings(),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Save Changes Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Settings saved successfully'),
                        backgroundColor: AppColors.green,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.softTealBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Save Changes',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Restore Defaults
              TextButton(
                onPressed: _restoreDefaults,
                child: Text(
                  'Restore Defaults',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.white54,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Secured by Firebase
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, color: Colors.white38, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Secured by Firebase',
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
      ),
    );
  }

  void _showDisplayPreferences() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.coolSteelBlue,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Display Preferences',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Dark Mode
              _ToggleRow(
                label: 'Dark Mode',
                subtitle: 'Use dark theme throughout the app',
                value: _darkMode,
                onChanged: (val) {
                  setSheetState(() {});
                  setState(() => _darkMode = val);
                },
              ),
              const SizedBox(height: 20),

              // Text Size
              Text(
                'Text Size',
                style: GoogleFonts.roboto(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _textSize <= 0.8 ? 'Small' : _textSize >= 1.2 ? 'Large' : 'Medium',
                style: GoogleFonts.roboto(fontSize: 13, color: Colors.white54),
              ),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: AppColors.softTealBlue,
                  inactiveTrackColor: Colors.white24,
                  thumbColor: AppColors.softTealBlue,
                  overlayColor: AppColors.softTealBlue.withValues(alpha: 0.2),
                ),
                child: Slider(
                  value: _textSize,
                  min: 0.8,
                  max: 1.2,
                  divisions: 2,
                  onChanged: (val) {
                    setSheetState(() {});
                    setState(() => _textSize = val);
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('A', style: GoogleFonts.roboto(fontSize: 12, color: Colors.white54)),
                  Text('A', style: GoogleFonts.roboto(fontSize: 16, color: Colors.white54)),
                  Text('A', style: GoogleFonts.roboto(fontSize: 20, color: Colors.white54)),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.coolSteelBlue,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Notifications & Alerts',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              _ToggleRow(
                label: 'Push Notifications',
                subtitle: 'Receive push notifications on your device',
                value: _pushNotifications,
                onChanged: (val) {
                  setSheetState(() {});
                  setState(() => _pushNotifications = val);
                },
              ),
              const SizedBox(height: 16),
              _ToggleRow(
                label: 'Sound',
                subtitle: 'Play sound for new alerts',
                value: _soundEnabled,
                onChanged: (val) {
                  setSheetState(() {});
                  setState(() => _soundEnabled = val);
                },
              ),
              const SizedBox(height: 16),
              _ToggleRow(
                label: 'Crowd Alerts',
                subtitle: 'Get notified about crowd density changes',
                value: _crowdAlerts,
                onChanged: (val) {
                  setSheetState(() {});
                  setState(() => _crowdAlerts = val);
                },
              ),
              const SizedBox(height: 16),
              _ToggleRow(
                label: 'Emergency Alerts',
                subtitle: 'Receive critical emergency notifications',
                value: _emergencyAlerts,
                onChanged: (val) {
                  setSheetState(() {});
                  setState(() => _emergencyAlerts = val);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageSettings() {
    final languages = ['English', 'Arabic', 'Spanish', 'French'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.coolSteelBlue,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Language & Localization',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              ...languages.map((lang) => GestureDetector(
                onTap: () {
                  setSheetState(() {});
                  setState(() => _selectedLanguage = lang);
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: _selectedLanguage == lang
                        ? AppColors.softTealBlue.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedLanguage == lang
                          ? AppColors.softTealBlue
                          : Colors.white12,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        lang,
                        style: GoogleFonts.roboto(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      if (_selectedLanguage == lang)
                        Icon(Icons.check_circle, color: AppColors.softTealBlue, size: 22),
                    ],
                  ),
                ),
              )),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showPrivacySettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.coolSteelBlue,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Privacy & Account',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              _ToggleRow(
                label: 'Location Sharing',
                subtitle: 'Share your location for crowd tracking',
                value: _locationSharing,
                onChanged: (val) {
                  setSheetState(() {});
                  setState(() => _locationSharing = val);
                },
              ),
              const SizedBox(height: 16),
              _ToggleRow(
                label: 'Analytics',
                subtitle: 'Help improve the app with usage data',
                value: _analyticsEnabled,
                onChanged: (val) {
                  setSheetState(() {});
                  setState(() => _analyticsEnabled = val);
                },
              ),
              const SizedBox(height: 24),

              // Delete Account
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showDeleteAccountConfirmation();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.red,
                    side: BorderSide(color: AppColors.red, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Delete Account',
                    style: GoogleFonts.roboto(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2A3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Account',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
          style: GoogleFonts.roboto(fontSize: 14, color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.roboto(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Account deletion requested'),
                  backgroundColor: AppColors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.roboto(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
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
          activeColor: AppColors.softTealBlue,
          activeTrackColor: AppColors.softTealBlue.withValues(alpha: 0.3),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.roboto(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.white38,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        color: Colors.white.withValues(alpha: 0.1),
        height: 1,
      ),
    );
  }
}
