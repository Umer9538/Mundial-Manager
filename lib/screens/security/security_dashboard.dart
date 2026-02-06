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
import '../common/report_incident_screen.dart';
import '../../widgets/map/crowd_heatmap.dart';
import 'package:latlong2/latlong.dart';

class SecurityDashboard extends StatefulWidget {
  const SecurityDashboard({super.key});

  @override
  State<SecurityDashboard> createState() => _SecurityDashboardState();
}

class _SecurityDashboardState extends State<SecurityDashboard> {
  int _selectedIndex = 0;
  bool _isOnDuty = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      Provider.of<CrowdProvider>(context, listen: false).initialize(),
      Provider.of<IncidentProvider>(context, listen: false).initialize(),
      Provider.of<AlertProvider>(context, listen: false).initialize(),
    ]);
    Provider.of<CrowdProvider>(context, listen: false).startRealTimeUpdates();
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
              isOnDuty: _isOnDuty,
              onToggleDuty: () => setState(() => _isOnDuty = !_isOnDuty),
              onReportIncident: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ReportIncidentScreen(),
                  ),
                );
              },
            ),
            _MonitoringTab(),
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
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                isSelected: _selectedIndex == 0,
                onTap: () => _onItemTapped(0),
              ),
              _NavItem(
                icon: Icons.radar_outlined,
                activeIcon: Icons.radar,
                label: 'Zones',
                isSelected: _selectedIndex == 1,
                onTap: () => _onItemTapped(1),
              ),
              _NavItem(
                icon: Icons.map_outlined,
                activeIcon: Icons.map,
                label: 'Map',
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

  void _showReportIncidentSheet(BuildContext context) {
    final descriptionController = TextEditingController();
    String selectedZone = 'Main Stage - Area A';
    String selectedType = 'crowd';

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
                    'Report Incident',
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
              CustomDropdownField<String>(
                label: 'Select Zone',
                hint: 'Choose zone',
                value: selectedZone,
                items: const [
                  DropdownMenuItem(value: 'Main Stage - Area A', child: Text('Main Stage - Area A')),
                  DropdownMenuItem(value: 'North Stand', child: Text('North Stand')),
                  DropdownMenuItem(value: 'South Stand', child: Text('South Stand')),
                  DropdownMenuItem(value: 'East Gate', child: Text('East Gate')),
                  DropdownMenuItem(value: 'West Gate', child: Text('West Gate')),
                ],
                onChanged: (value) => selectedZone = value!,
              ),
              const SizedBox(height: 16),
              CustomDropdownField<String>(
                label: 'Incident Type',
                hint: 'Select type',
                value: selectedType,
                items: const [
                  DropdownMenuItem(value: 'crowd', child: Text('Crowd Issue')),
                  DropdownMenuItem(value: 'medical', child: Text('Medical Emergency')),
                  DropdownMenuItem(value: 'security', child: Text('Security Threat')),
                  DropdownMenuItem(value: 'fire', child: Text('Fire Hazard')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (value) => selectedType = value!,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Description',
                hint: 'Enter details about the incident...',
                controller: descriptionController,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              GlassCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.attach_file, color: Colors.white54, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Attach Image',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                backgroundColor: AppColors.green.withOpacity(0.15),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.green, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Incident sent to Security Team.',
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: AppColors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              CustomButton.primary(
                text: 'Submit Report',
                icon: Icons.send,
                onPressed: () async {
                  if (descriptionController.text.isNotEmpty) {
                    final incidentProvider = Provider.of<IncidentProvider>(context, listen: false);
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);

                    final crowdProv = Provider.of<CrowdProvider>(context, listen: false);
                    final defaultLocation = crowdProv.allZones.isNotEmpty
                        ? crowdProv.allZones.first.center
                        : const LatLng(24.7257, 46.8222);
                    await incidentProvider.reportIncident(
                      eventId: 'current_event',
                      reportedBy: authProvider.currentUser!.id,
                      reportedByName: authProvider.currentUser!.name,
                      location: defaultLocation,
                      type: selectedType,
                      description: descriptionController.text,
                      severity: 'medium',
                    );

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Incident reported successfully!'),
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

class _DashboardTab extends StatelessWidget {
  final bool isOnDuty;
  final VoidCallback onToggleDuty;
  final VoidCallback onReportIncident;

  const _DashboardTab({
    required this.isOnDuty,
    required this.onToggleDuty,
    required this.onReportIncident,
  });

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<CrowdProvider>(context, listen: false).refresh();
          await Provider.of<IncidentProvider>(context, listen: false).refresh();
          await Provider.of<AlertProvider>(context, listen: false).refresh();
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
                // Header Row
                Row(
                  children: [
                    Icon(Icons.shield, color: AppColors.softTealBlue, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Security Dashboard',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    // On Duty Toggle
                    GestureDetector(
                      onTap: onToggleDuty,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isOnDuty ? AppColors.green.withOpacity(0.2) : Colors.white12,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isOnDuty ? AppColors.green : Colors.white24,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isOnDuty ? AppColors.green : Colors.white38,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isOnDuty ? 'On Duty' : 'Off Duty',
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isOnDuty ? AppColors.green : Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
                  ],
                ),
                const SizedBox(height: 20),

                // Welcome Message
                Builder(
                  builder: (context) {
                    final userName = Provider.of<AuthProvider>(context, listen: false)
                        .currentUser?.name ?? 'Officer';
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
                const SizedBox(height: 24),
                // Quick Actions Grid
                _buildActionGrid(context),
                const SizedBox(height: 28),

                // Active Alerts Section
                _buildActiveAlerts(context),
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
          icon: Icons.groups_outlined,
          label: 'Monitor Crowd',
          color: AppColors.softTealBlue,
          onTap: () {},
        ),
        _ActionTile(
          icon: Icons.report_problem_outlined,
          label: 'Report Incident',
          color: AppColors.red,
          backgroundColor: AppColors.red.withOpacity(0.15),
          onTap: onReportIncident,
        ),
        _ActionTile(
          icon: Icons.notifications_active_outlined,
          label: 'View Alerts',
          color: Colors.white70,
          onTap: () {},
        ),
        _ActionTile(
          icon: Icons.group_outlined,
          label: 'Team Updates',
          color: Colors.white70,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildActiveAlerts(BuildContext context) {
    return Consumer2<AlertProvider, CrowdProvider>(
      builder: (context, alertProvider, crowdProvider, _) {
        final alerts = alertProvider.getAlertsForRole('security');
        final criticalZones = crowdProvider.criticalZones;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active Alerts',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),

            // Sample alert cards based on mockup
            _AlertListItem(
              title: 'Zone B - Density 87%',
              subtitle: '14:32 - Main Stage area',
              severity: 'critical',
              onTap: () {},
            ),
            const SizedBox(height: 10),
            _AlertListItem(
              title: 'Gate 2 - Unauthorized Entry',
              subtitle: '14:28 - Perimeter Checkpoint',
              severity: 'high',
              onTap: () {},
            ),
            const SizedBox(height: 10),
            _AlertListItem(
              title: 'First Aid Request',
              subtitle: '14:25 - Sector 4 Food Court',
              severity: 'medium',
              onTap: () {},
            ),

            // Additional alerts from provider
            if (alerts.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...alerts.take(2).map((alert) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _AlertListItem(
                  title: alert.typeDisplayName,
                  subtitle: alert.message,
                  severity: alert.severity,
                  onTap: () {},
                ),
              )),
            ],
          ],
        );
      },
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

class _AlertListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String severity;
  final VoidCallback onTap;

  const _AlertListItem({
    required this.title,
    required this.subtitle,
    required this.severity,
    required this.onTap,
  });

  Color get _severityColor {
    switch (severity.toLowerCase()) {
      case 'critical':
        return AppColors.red;
      case 'high':
        return AppColors.orange;
      case 'medium':
      case 'warning':
        return AppColors.yellow;
      default:
        return AppColors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCardWithIndicator(
      indicatorColor: _severityColor,
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        children: [
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
                  subtitle,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _severityColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              severity.toUpperCase(),
              style: GoogleFonts.roboto(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: _severityColor,
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

class _MonitoringTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: Consumer<CrowdProvider>(
        builder: (context, crowdProvider, _) {
          final stats = crowdProvider.venueStats;

          return Column(
            children: [
              // Header with SafeArea
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Live Crowd Monitoring',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Icon(Icons.refresh, color: Colors.white, size: 24),
                    ],
                  ),
                ),
              ),
              // Map
              Expanded(
                child: Stack(
                  children: [
                    CrowdHeatmap(
                      crowdData: crowdProvider.crowdData,
                      zones: crowdProvider.allZones,
                    ),
                    // Zone info overlay
                    Positioned(
                      left: 16,
                      top: 16,
                      child: GlassCard(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Zone D -',
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Overcrowding',
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                color: AppColors.orange,
                              ),
                            ),
                            Text(
                              '85% Capacity',
                              style: GoogleFonts.roboto(
                                fontSize: 11,
                                color: Colors.white54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                'View Details',
                                style: GoogleFonts.roboto(
                                  fontSize: 12,
                                  color: AppColors.softTealBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Density Legend
                    Positioned(
                      right: 16,
                      top: 16,
                      child: _DensityLegend(),
                    ),
                  ],
                ),
              ),

              // Bottom stats panel
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.deepNavyBlue,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Density indicator
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.orange.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.orange, width: 3),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${stats['occupancyPercentage']}%',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Current Avg. Density',
                                  style: GoogleFonts.roboto(
                                    fontSize: 13,
                                    color: Colors.white54,
                                  ),
                                ),
                                Text(
                                  'Above Recommended',
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              _QuickActionBtn(
                                label: 'Report...',
                                color: AppColors.red,
                                onTap: () {},
                              ),
                              const SizedBox(height: 8),
                              _QuickActionBtn(
                                label: 'View A...',
                                color: AppColors.blue,
                                onTap: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
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

class _DensityLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Density',
            style: GoogleFonts.roboto(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          _LegendItem(color: AppColors.green, label: 'SAFE'),
          const SizedBox(height: 4),
          _LegendItem(color: AppColors.yellow, label: 'MODERATE'),
          const SizedBox(height: 4),
          _LegendItem(color: AppColors.orange, label: 'HIGH'),
          const SizedBox(height: 4),
          _LegendItem(color: AppColors.red, label: 'CRITICAL'),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _QuickActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionBtn({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _AlertsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: Consumer<AlertProvider>(
        builder: (context, alertProvider, _) {
          final alerts = alertProvider.getAlertsForRole('security');

          return CustomScrollView(
            slivers: [
              // Header with SafeArea
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Text(
                      'Alerts',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              // Alert content
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
                          child: _AlertListItem(
                            title: alert.typeDisplayName,
                            subtitle: alert.message,
                            severity: alert.severity,
                            onTap: () {},
                          ),
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
                  Text(
                    'My Profile',
                    style: GoogleFonts.montserrat(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),

                  GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      children: [
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
                        Text(
                          user.name,
                          style: GoogleFonts.montserrat(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          user.email,
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: Colors.white60,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.roleDisplayName,
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Edit Profile Button
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

                        // Change Password Button
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

                        // Logout Button
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
