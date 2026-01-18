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
import '../../widgets/map/crowd_heatmap.dart';
import '../../widgets/cards/stat_card.dart';
import '../../core/utils/dummy_data.dart';

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
                      eventId: DummyData.event.id,
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

  const _DashboardTab({required this.onSendAlert});

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
                const SizedBox(height: 16),
                // Header with title and actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Organizer Dashboard',
                      style: GoogleFonts.montserrat(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.search, color: Colors.white),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Mundial Manager subtitle
                Row(
                  children: [
                    Icon(Icons.location_on, color: AppColors.softTealBlue, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      'Mundial Manager',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

              // Quick Actions Grid
              _buildActionGrid(context),
              const SizedBox(height: 32),

              // Managed Events
              _buildManagedEvents(context),
              const SizedBox(height: 32),

              // Live Event Map
              _buildLiveMap(context),
              const SizedBox(height: 24),

              // Action Buttons
              CustomButton.primary(
                text: 'Create Event',
                icon: Icons.add,
                onPressed: () {
                  // TODO: Navigate to create event
                },
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
                onPressed: () {
                  // TODO: Navigate to analytics
                },
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _ActionTile(
          icon: Icons.add_circle_outline,
          label: 'Create Event',
          color: AppColors.softTealBlue,
          onTap: () {},
        ),
        _ActionTile(
          icon: Icons.campaign,
          label: 'Send Alert',
          color: AppColors.red,
          backgroundColor: AppColors.red.withOpacity(0.15),
          onTap: onSendAlert,
        ),
        _ActionTile(
          icon: Icons.analytics_outlined,
          label: 'View Analytics',
          color: Colors.white70,
          onTap: () {},
        ),
        _ActionTile(
          icon: Icons.security,
          label: 'Manage Security',
          color: Colors.white70,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildManagedEvents(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Managed Events',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        _EventCard(
          title: 'Annual Tech Summit',
          code: 'E-5024',
          date: '02/26/2024',
          icon: Icons.calendar_today,
          iconColor: AppColors.blue,
        ),
        const SizedBox(height: 10),
        _EventCard(
          title: 'Music Fest 2024',
          code: 'E-5022',
          date: '08/15/2024',
          icon: Icons.music_note,
          iconColor: AppColors.orange,
        ),
        const SizedBox(height: 10),
        _EventCard(
          title: 'Gaming Expo',
          code: 'E-5018',
          date: '04/02/2024',
          icon: Icons.sports_esports,
          iconColor: AppColors.green,
          status: 'Active',
        ),
      ],
    );
  }

  Widget _buildLiveMap(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Live Event Map',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: EdgeInsets.zero,
          borderRadius: 16,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
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
                    zones: DummyData.zones,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color? backgroundColor;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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

  const _EventCard({
    required this.title,
    required this.code,
    required this.date,
    required this.icon,
    required this.iconColor,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      onTap: () {},
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status!,
                style: GoogleFonts.roboto(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.green,
                ),
              ),
            ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.white38, size: 22),
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
              zones: DummyData.zones,
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
    final zones = DummyData.zones;

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
                    'Profile',
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
                      color: AppColors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.blue.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      user.roleDisplayName,
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Edit Profile Button
                  _ProfileActionButton(
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

                  // Change Password Button
                  _ProfileActionButton(
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

                  // Logout Button
                  _ProfileActionButton(
                    text: 'Logout',
                    icon: Icons.logout,
                    backgroundColor: AppColors.red,
                    textColor: Colors.white,
                    onPressed: () async {
                      await authProvider.logout();
                      if (context.mounted) context.go('/login');
                    },
                  ),
                  const SizedBox(height: 32),

                  // Settings Section
                  GlassCard(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: Column(
                      children: [
                        _ProfileSettingsTile(
                          icon: Icons.notifications_outlined,
                          title: 'Push Notifications',
                          subtitle: 'Receive alerts and updates',
                          value: true,
                          onChanged: (value) {},
                        ),
                        const Divider(color: Colors.white12, height: 1, indent: 16, endIndent: 16),
                        _ProfileSettingsTile(
                          icon: Icons.email_outlined,
                          title: 'Email Notifications',
                          subtitle: 'Receive event summaries',
                          value: true,
                          onChanged: (value) {},
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

class _ProfileActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback onPressed;

  const _ProfileActionButton({
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

class _ProfileSettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ProfileSettingsTile({
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
