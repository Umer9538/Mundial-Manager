import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/constants.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../services/seed_service.dart';
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

  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _darkMode = prefs.getBool(AppConstants.keyDarkMode) ?? true;
      _textSize = prefs.getDouble(AppConstants.keyTextSize) ?? 1.0;
      _pushNotifications = prefs.getBool(AppConstants.keyPushNotifications) ?? true;
      _soundEnabled = prefs.getBool(AppConstants.keySoundEnabled) ?? true;
      _crowdAlerts = prefs.getBool(AppConstants.keyCrowdAlerts) ?? true;
      _emergencyAlerts = prefs.getBool(AppConstants.keyEmergencyAlerts) ?? true;
      _selectedLanguage = prefs.getString(AppConstants.keyLanguage) ?? 'English';
      _locationSharing = prefs.getBool(AppConstants.keyLocationSharing) ?? true;
      _analyticsEnabled = prefs.getBool(AppConstants.keyAnalyticsEnabled) ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyDarkMode, _darkMode);
    await prefs.setDouble(AppConstants.keyTextSize, _textSize);
    await prefs.setBool(AppConstants.keyPushNotifications, _pushNotifications);
    await prefs.setBool(AppConstants.keySoundEnabled, _soundEnabled);
    await prefs.setBool(AppConstants.keyCrowdAlerts, _crowdAlerts);
    await prefs.setBool(AppConstants.keyEmergencyAlerts, _emergencyAlerts);
    await prefs.setString(AppConstants.keyLanguage, _selectedLanguage);
    await prefs.setBool(AppConstants.keyLocationSharing, _locationSharing);
    await prefs.setBool(AppConstants.keyAnalyticsEnabled, _analyticsEnabled);
    _hasUnsavedChanges = false;
  }

  void _markChanged() {
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
  }

  void _restoreDefaults() async {
    final l = AppLocalizations.of(context)!;
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
      _hasUnsavedChanges = true;
    });
    Provider.of<LocaleProvider>(context, listen: false).setLocale(const Locale('en'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l.settingsRestored),
        backgroundColor: AppColors.softTealBlue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return GradientScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            children: [
              // Title
              Text(
                l.settingsTitle,
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
                      label: l.displayPreferences,
                      onTap: () => _showDisplayPreferences(),
                    ),
                    const _SettingsDivider(),
                    _SettingsItem(
                      icon: Icons.notifications_outlined,
                      label: l.notificationsAlerts,
                      onTap: () => _showNotificationSettings(),
                    ),
                    const _SettingsDivider(),
                    _SettingsItem(
                      icon: Icons.language,
                      label: l.languageLocalization,
                      onTap: () => _showLanguageSettings(),
                    ),
                    const _SettingsDivider(),
                    _SettingsItem(
                      icon: Icons.info_outline,
                      label: l.privacyAccount,
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
                  onPressed: () async {
                    await _saveSettings();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l.settingsSaved),
                          backgroundColor: AppColors.green,
                        ),
                      );
                      Navigator.pop(context);
                    }
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
                    _hasUnsavedChanges ? l.saveChanges : l.doneButton,
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
                  l.restoreDefaults,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.white54,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Seed Demo Data
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: _seedDemoData,
                  icon: const Icon(Icons.storage_outlined, size: 18),
                  label: Text(
                    l.seedDemoData,
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orangeAccent,
                    side: const BorderSide(color: Colors.orangeAccent, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Secured by Firebase
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, color: Colors.white38, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    AppLocalizations.of(context)!.securedByFirebase,
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

  Future<void> _seedDemoData() async {
    final l = AppLocalizations.of(context)!;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.coolSteelBlue,
        title: Text(l.seedDemoData, style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          'This will clear existing data and load fresh demo data (events, zones, crowd density, incidents, alerts, etc.).\n\nYou will be signed out and need to log back in.',
          style: GoogleFonts.roboto(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppLocalizations.of(context)!.cancelButton)),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
            child: Text(AppLocalizations.of(context)!.seedData),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final seedService = SeedService();
      await seedService.clearAndReseed();
      if (!mounted) return;
      Navigator.pop(context); // dismiss loading

      // Sign back in as the original user (seed signs in as temp organizer)
      // Redirect to splash to re-initialize the app with fresh data
      context.go('/splash');
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.seedingFailedShort),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showDisplayPreferences() {
    final l = AppLocalizations.of(context)!;

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
                l.displayPreferences,
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Dark Mode
              _ToggleRow(
                label: l.darkMode,
                subtitle: l.darkModeSubtitle,
                value: _darkMode,
                onChanged: (val) {
                  setSheetState(() {});
                  setState(() => _darkMode = val);
                  _markChanged();
                },
              ),
              const SizedBox(height: 20),

              // Text Size
              Text(
                l.textSize,
                style: GoogleFonts.roboto(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _textSize <= 0.8 ? l.textSizeSmall : _textSize >= 1.2 ? l.textSizeLarge : l.textSizeMedium,
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
                    _markChanged();
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
    final l = AppLocalizations.of(context)!;

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
                l.notificationsAlerts,
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              _ToggleRow(
                label: l.pushNotifications,
                subtitle: l.pushNotificationsSubtitle,
                value: _pushNotifications,
                onChanged: (val) {
                  setSheetState(() {});
                  setState(() => _pushNotifications = val);
                  _markChanged();
                },
              ),
              const SizedBox(height: 16),
              _ToggleRow(
                label: l.soundLabel,
                subtitle: l.soundSubtitle,
                value: _soundEnabled,
                onChanged: (val) {
                  setSheetState(() {});
                  setState(() => _soundEnabled = val);
                  _markChanged();
                },
              ),
              const SizedBox(height: 16),
              _ToggleRow(
                label: l.crowdAlerts,
                subtitle: l.crowdAlertsSubtitle,
                value: _crowdAlerts,
                onChanged: (val) {
                  setSheetState(() {});
                  setState(() => _crowdAlerts = val);
                  _markChanged();
                },
              ),
              const SizedBox(height: 16),
              _ToggleRow(
                label: l.emergencyAlerts,
                subtitle: l.emergencyAlertsSubtitle,
                value: _emergencyAlerts,
                onChanged: (val) {
                  setSheetState(() {});
                  setState(() => _emergencyAlerts = val);
                  _markChanged();
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
    final l = AppLocalizations.of(context)!;
    final languages = [
      {'label': l.languageEnglish, 'key': 'English', 'locale': const Locale('en')},
      {'label': l.languageArabic, 'key': 'Arabic', 'locale': const Locale('ar')},
    ];

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
                l.languageLocalization,
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
                  setState(() => _selectedLanguage = lang['key'] as String);
                  Provider.of<LocaleProvider>(context, listen: false)
                      .setLocale(lang['locale'] as Locale);
                  _markChanged();
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: _selectedLanguage == lang['key']
                        ? AppColors.softTealBlue.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedLanguage == lang['key']
                          ? AppColors.softTealBlue
                          : Colors.white12,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        lang['label'] as String,
                        style: GoogleFonts.roboto(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      if (_selectedLanguage == lang['key'])
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
    final l = AppLocalizations.of(context)!;

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
                l.privacyAccount,
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              _ToggleRow(
                label: l.locationSharing,
                subtitle: l.locationSharingSubtitle,
                value: _locationSharing,
                onChanged: (val) {
                  setSheetState(() {});
                  setState(() => _locationSharing = val);
                  _markChanged();
                },
              ),
              const SizedBox(height: 16),
              _ToggleRow(
                label: l.analyticsLabel,
                subtitle: l.analyticsSubtitle,
                value: _analyticsEnabled,
                onChanged: (val) {
                  setSheetState(() {});
                  setState(() => _analyticsEnabled = val);
                  _markChanged();
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
                    l.deleteAccount,
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
    final l = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2A3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l.deleteAccount,
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: Text(
          l.deleteAccountConfirm,
          style: GoogleFonts.roboto(fontSize: 14, color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.cancelButton,
              style: GoogleFonts.roboto(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final success = await authProvider.deleteAccount();
              if (mounted) {
                if (success) {
                  context.go('/login');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(authProvider.errorMessage ?? AppLocalizations.of(context)!.failedDeleteAccount),
                      backgroundColor: AppColors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.deleteButton,
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
