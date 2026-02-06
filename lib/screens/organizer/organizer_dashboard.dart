import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/crowd_provider.dart';
import '../../providers/incident_provider.dart';
import '../../providers/alert_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/gradient_scaffold.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/profile_dialogs.dart';
import '../../widgets/map/crowd_heatmap.dart';
// DummyData import removed - using provider data instead

class OrganizerDashboard extends StatefulWidget {
  const OrganizerDashboard({super.key});

  @override
  State<OrganizerDashboard> createState() => _OrganizerDashboardState();
}

class _OrganizerDashboardState extends State<OrganizerDashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final crowdProvider = Provider.of<CrowdProvider>(context, listen: false);
    final incidentProvider = Provider.of<IncidentProvider>(context, listen: false);
    final alertProvider = Provider.of<AlertProvider>(context, listen: false);

    await Future.wait([
      crowdProvider.initialize(),
      incidentProvider.initialize(),
      alertProvider.initialize(),
    ]);

    crowdProvider.startRealTimeUpdates();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.deepNavyBlue,
        extendBody: true,
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _DashboardTab(
              onSendAlert: () => _showSendAlertDialog(context),
              onNavigate: _onItemTapped,
            ),
            _MapTab(),
            _AlertsTab(),
            _ProfileTab(),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.deepNavyBlue,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard,
                label: 'Home',
                isSelected: _selectedIndex == 0,
                onTap: () => _onItemTapped(0),
              ),
              _NavItem(
                icon: Icons.map_outlined,
                activeIcon: Icons.map,
                label: 'Map',
                isSelected: _selectedIndex == 1,
                onTap: () => _onItemTapped(1),
              ),
              _NavItem(
                icon: Icons.notifications_outlined,
                activeIcon: Icons.notifications,
                label: 'Alerts',
                isSelected: _selectedIndex == 2,
                onTap: () => _onItemTapped(2),
              ),
              _NavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
                isSelected: _selectedIndex == 3,
                onTap: () => _onItemTapped(3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSendAlertDialog(BuildContext context) {
    final messageController = TextEditingController();
    final titleController = TextEditingController();
    String selectedSeverity = 'warning';
    String selectedRecipient = 'all';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A3A5C), Color(0xFF0F253D)],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Send Alert',
                    style: GoogleFonts.montserrat(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Alert Title',
                hint: 'e.g., Gate Closure Change',
                controller: titleController,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Message',
                hint: 'Describe the alert...',
                controller: messageController,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              CustomDropdownField<String>(
                label: 'Recipient',
                hint: 'Select recipient',
                value: selectedRecipient,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Users')),
                  DropdownMenuItem(value: 'fans', child: Text('Fans Only')),
                  DropdownMenuItem(value: 'security', child: Text('Security Team')),
                  DropdownMenuItem(value: 'emergency', child: Text('Emergency Services')),
                ],
                onChanged: (value) => selectedRecipient = value!,
              ),
              const SizedBox(height: 16),
              Text(
                'Severity',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _SeverityChip(
                    label: 'Critical',
                    color: AppColors.red,
                    isSelected: selectedSeverity == 'critical',
                    onTap: () => setState(() => selectedSeverity = 'critical'),
                  ),
                  const SizedBox(width: 8),
                  _SeverityChip(
                    label: 'Moderate',
                    color: AppColors.orange,
                    isSelected: selectedSeverity == 'warning',
                    onTap: () => setState(() => selectedSeverity = 'warning'),
                  ),
                  const SizedBox(width: 8),
                  _SeverityChip(
                    label: 'Info',
                    color: AppColors.blue,
                    isSelected: selectedSeverity == 'info',
                    onTap: () => setState(() => selectedSeverity = 'info'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              CustomButton.danger(
                text: 'Send Alert',
                icon: Icons.send,
                onPressed: () async {
                  if (messageController.text.isNotEmpty) {
                    final alertProvider = Provider.of<AlertProvider>(context, listen: false);
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);

                    await alertProvider.sendAlert(
                      eventId: 'current_event',
                      createdBy: authProvider.currentUser!.id,
                      createdByName: authProvider.currentUser!.name,
                      type: 'info',
                      message: messageController.text,
                      targetRoles: ['fan', 'security', 'emergency'],
                      severity: selectedSeverity,
                    );

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Alert sent successfully!'),
                          backgroundColor: AppColors.green,
                        ),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 12),
              CustomButton.secondary(
                text: 'Cancel',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.softTealBlue : Colors.white54,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 12,
                color: isSelected ? AppColors.softTealBlue : Colors.white54,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeverityChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _SeverityChip({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  final VoidCallback onSendAlert;
  final Function(int) onNavigate;

  const _DashboardTab({required this.onSendAlert, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            Provider.of<CrowdProvider>(context, listen: false).refresh(),
            Provider.of<IncidentProvider>(context, listen: false).refresh(),
            Provider.of<AlertProvider>(context, listen: false).refresh(),
          ]);
        },
        color: AppColors.softTealBlue,
        backgroundColor: AppColors.deepNavyBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // App Bar: Logo + Mundial Manager + icons + avatar
                Row(
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      width: 36,
                      height: 36,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Mundial Manager',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () => _showSearch(context),
                    ),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                          onPressed: () => onNavigate(2),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Consumer<AlertProvider>(
                            builder: (context, alertProvider, _) {
                              final count = alertProvider.getAlertsForRole('organizer').length;
                              if (count == 0) return const SizedBox.shrink();
                              return Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: AppColors.red,
                                  shape: BoxShape.circle,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => onNavigate(3),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.coolSteelBlue,
                          border: Border.all(color: AppColors.softTealBlue, width: 2),
                        ),
                        child: const Icon(Icons.person, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Welcome Message
                Builder(
                  builder: (context) {
                    final userName = Provider.of<AuthProvider>(context, listen: false)
                        .currentUser?.name ?? 'Organizer';
                    return Row(
                      children: [
                        Text(
                          'Welcome, ',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          userName.split(' ').first,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.softTealBlue,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),

              // Dashboard Card
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Organizer Dashboard',
                      style: GoogleFonts.montserrat(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Managed Events
                    Text(
                      'Managed Events',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _EventCard(
                      title: 'Annual Tech Summit',
                      code: 'E-1024',
                      date: '10/26/2024',
                      icon: Icons.calendar_today,
                      iconColor: AppColors.softTealBlue,
                      status: 'Live',
                      statusColor: AppColors.green,
                    ),
                    const SizedBox(height: 10),
                    _EventCard(
                      title: 'Music Fest 2024',
                      code: 'E-1022',
                      date: '09/15/2024',
                      icon: Icons.music_note,
                      iconColor: Colors.white,
                      status: 'Upcoming',
                      statusColor: AppColors.softTealBlue,
                    ),
                    const SizedBox(height: 10),
                    _EventCard(
                      title: 'Gaming Expo',
                      code: 'E-1019',
                      date: '08/01/2024',
                      icon: Icons.sports_esports,
                      iconColor: Colors.white,
                      status: 'Ended',
                      statusColor: Colors.white54,
                    ),
                    const SizedBox(height: 24),

                    // Live Event Map
                    Text(
                      'Live Event Map',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 200,
                        child: Consumer<CrowdProvider>(
                          builder: (context, crowdProvider, _) {
                            if (crowdProvider.isLoading) {
                              return Center(
                                child: CircularProgressIndicator(color: AppColors.softTealBlue),
                              );
                            }
                            return CrowdHeatmap(
                              crowdData: crowdProvider.crowdData,
                              zones: crowdProvider.allZones,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons - matching design colors
              SizedBox(
                height: 52,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.softTealBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Create Event',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              CustomButton.danger(
                text: 'Send Alert',
                icon: Icons.campaign,
                onPressed: onSendAlert,
              ),
              const SizedBox(height: 12),
              CustomButton.secondary(
                text: 'View Analytics',
                icon: Icons.analytics_outlined,
                onPressed: () => context.push('/analytics'),
              ),
              const SizedBox(height: 12),
              CustomButton.secondary(
                text: 'Staff Management',
                icon: Icons.people_outline,
                onPressed: () => context.push('/staff-management'),
              ),
              const SizedBox(height: 12),
              CustomButton.secondary(
                text: 'Communication Hub',
                icon: Icons.chat_outlined,
                onPressed: () => context.push('/communication'),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final searchController = TextEditingController();
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
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
                  'Search',
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: searchController,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search events, zones, alerts...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon: const Icon(Icons.search, color: Colors.white54),
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
                  onSubmitted: (value) {
                    Navigator.pop(context);
                    if (value.trim().isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Searching for "$value"...'),
                          backgroundColor: AppColors.softTealBlue,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Quick Access',
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _SearchChip(label: 'Active Events', onTap: () => Navigator.pop(context)),
                    _SearchChip(label: 'Crowd Zones', onTap: () { Navigator.pop(context); onNavigate(1); }),
                    _SearchChip(label: 'Alerts', onTap: () { Navigator.pop(context); onNavigate(2); }),
                    _SearchChip(label: 'Incidents', onTap: () { Navigator.pop(context); onNavigate(2); }),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SearchChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SearchChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 13,
            color: Colors.white70,
          ),
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final String title;
  final String code;
  final String date;
  final IconData icon;
  final Color iconColor;
  final String? status;
  final Color? statusColor;

  const _EventCard({
    required this.title,
    required this.code,
    required this.date,
    required this.icon,
    required this.iconColor,
    this.status,
    this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final sColor = statusColor ?? AppColors.green;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
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
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$code | $date',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          if (status != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: sColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: sColor.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Text(
                status!,
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: sColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ==================== MAP TAB ====================
class _MapTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CrowdProvider>(
      builder: (context, crowdProvider, _) {
        return Stack(
          children: [
            // Full Map
            CrowdHeatmap(
              crowdData: crowdProvider.crowdData,
              zones: crowdProvider.allZones,
            ),

            // Density Legend
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: _DensityLegend(),
            ),

            // Zone Info Popup
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: _ZoneInfoCard(crowdProvider: crowdProvider),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DensityLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Density Legend',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          _LegendItem(label: 'Safe', color: AppColors.green, level: 'SAFE'),
          const SizedBox(height: 8),
          _LegendItem(label: 'Moderate', color: AppColors.yellow, level: 'MODERATE'),
          const SizedBox(height: 8),
          _LegendItem(label: 'High', color: AppColors.orange, level: 'HIGH'),
          const SizedBox(height: 8),
          _LegendItem(label: 'Critical', color: AppColors.red, level: 'CRITICAL'),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;
  final String level;

  const _LegendItem({
    required this.label,
    required this.color,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.groups, color: Colors.white, size: 14),
              const SizedBox(width: 4),
              Text(
                level,
                style: GoogleFonts.roboto(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 13,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}

class _ZoneInfoCard extends StatelessWidget {
  final CrowdProvider crowdProvider;

  const _ZoneInfoCard({required this.crowdProvider});

  @override
  Widget build(BuildContext context) {
    final zones = crowdProvider.allZones;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: zones.take(4).map((zone) {
          final density = crowdProvider.getZoneDensity(zone.id);
          final percentage = density?.occupancyPercentageRounded ?? 0;
          final level = _getDensityLevel(density?.densityPerSqMeter ?? 0);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  zone.name,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  '$percentage%',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _getColorForLevel(level),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getDensityLevel(double density) {
    if (density <= 1.5) return 'safe';
    if (density <= 2.5) return 'moderate';
    if (density <= 4.0) return 'high';
    return 'critical';
  }

  Color _getColorForLevel(String level) {
    switch (level) {
      case 'safe':
        return AppColors.green;
      case 'moderate':
        return AppColors.yellow;
      case 'high':
        return AppColors.orange;
      case 'critical':
        return AppColors.red;
      default:
        return AppColors.blue;
    }
  }
}

// ==================== ALERTS TAB ====================
class _AlertsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: Consumer<AlertProvider>(
        builder: (context, alertProvider, _) {
          final alerts = alertProvider.validAlerts;

          return CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Text(
                      'Alerts',
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),

              // Content
              if (alerts.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_outlined, size: 64, color: Colors.white24),
                        const SizedBox(height: 16),
                        Text(
                          'No active alerts',
                          style: GoogleFonts.roboto(fontSize: 16, color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final alert = alerts[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _AlertCard(alert: alert),
                        );
                      },
                      childCount: alerts.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final dynamic alert;

  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final color = _getAlertColor(alert.type);

    return GlassCardWithIndicator(
      indicatorColor: color,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getAlertIcon(alert.type),
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${alert.typeDisplayName} Alert',
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _getTimeAgo(alert.createdAt),
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            alert.message,
            style: GoogleFonts.roboto(
              fontSize: 13,
              color: Colors.white70,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Color _getAlertColor(String type) {
    switch (type.toLowerCase()) {
      case 'emergency':
        return AppColors.red;
      case 'safety':
        return AppColors.orange;
      case 'congestion':
        return AppColors.yellow;
      default:
        return AppColors.blue;
    }
  }

  IconData _getAlertIcon(String type) {
    switch (type.toLowerCase()) {
      case 'emergency':
        return Icons.emergency;
      case 'safety':
        return Icons.security;
      case 'congestion':
        return Icons.groups;
      default:
        return Icons.notifications;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours} hours ago';
    return '${difference.inDays} days ago';
  }
}

// ==================== PROFILE TAB ====================
class _ProfileTab extends StatelessWidget {
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
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    'My Profile',
                    style: GoogleFonts.montserrat(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Profile Card
                  GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      children: [
                        // Profile Avatar
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white38,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            size: 50,
                            color: Colors.white60,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // User Name
                        Text(
                          user.name,
                          style: GoogleFonts.montserrat(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Email
                        Text(
                          user.email,
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: Colors.white60,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Role
                        Text(
                          user.roleDisplayName,
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Edit Profile Button (Blue)
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () => ProfileDialogs.showEditProfile(context, authProvider),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Edit Profile',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Change Password Button (Outlined)
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton(
                            onPressed: () => ProfileDialogs.showChangePassword(context, authProvider),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white38, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Change Password',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Logout Button (Salmon/Pink-Red)
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () async {
                              await authProvider.logout();
                              if (context.mounted) context.go('/login');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE8706A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Logout',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
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

