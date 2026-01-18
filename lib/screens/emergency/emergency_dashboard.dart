import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/constants.dart';
import '../../core/utils/dummy_data.dart';
import '../../providers/incident_provider.dart';
import '../../providers/alert_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/gradient_scaffold.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/map/incident_marker.dart';

class EmergencyDashboard extends StatefulWidget {
  const EmergencyDashboard({super.key});

  @override
  State<EmergencyDashboard> createState() => _EmergencyDashboardState();
}

class _EmergencyDashboardState extends State<EmergencyDashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      Provider.of<IncidentProvider>(context, listen: false).initialize(),
      Provider.of<AlertProvider>(context, listen: false).initialize(),
    ]);
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
            _HomeTab(onNavigate: _onItemTapped),
            _AlertsTab(onNavigate: _onItemTapped),
            const _MapTab(),
            const _ProfileTab(),
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
                icon: Icons.warning_amber_outlined,
                activeIcon: Icons.warning_amber,
                label: 'Alerts',
                isSelected: _selectedIndex == 1,
                onTap: () => _onItemTapped(1),
                badge: Consumer<IncidentProvider>(
                  builder: (context, incidentProvider, _) {
                    final count = incidentProvider.activeIncidents.length;
                    if (count == 0) return const SizedBox.shrink();
                    return _BadgeCount(count: count);
                  },
                ),
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
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? badge;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge,
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
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? AppColors.red : Colors.white54,
                  size: 26,
                ),
                if (badge != null)
                  Positioned(
                    right: -8,
                    top: -4,
                    child: badge!,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 12,
                color: isSelected ? AppColors.red : Colors.white54,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeCount extends StatelessWidget {
  final int count;

  const _BadgeCount({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: AppColors.red,
        shape: BoxShape.circle,
      ),
      constraints: const BoxConstraints(
        minWidth: 18,
        minHeight: 18,
      ),
      child: Text(
        count > 9 ? '9+' : count.toString(),
        style: GoogleFonts.roboto(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ==================== HOME TAB ====================
class _HomeTab extends StatelessWidget {
  final Function(int) onNavigate;

  const _HomeTab({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: Consumer<IncidentProvider>(
        builder: (context, incidentProvider, _) {
          if (incidentProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.red,
              ),
            );
          }

          final activeIncidents = incidentProvider.activeIncidents;
          final criticalIncidents = incidentProvider.criticalIncidents;

          return RefreshIndicator(
            onRefresh: incidentProvider.refresh,
            color: AppColors.red,
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
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.emergency,
                            color: AppColors.red,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Emergency Services',
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Consumer<IncidentProvider>(
                          builder: (context, incidentProvider, _) {
                            final criticalCount = incidentProvider.criticalIncidents.length;
                            return GestureDetector(
                              onTap: () => onNavigate(1),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Icon(Icons.warning_amber, color: Colors.white, size: 24),
                                  if (criticalCount > 0)
                                    Positioned(
                                      right: -6,
                                      top: -4,
                                      child: _BadgeCount(count: criticalCount),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Venue Header
                    _buildVenueHeader(),
                    const SizedBox(height: 24),

                    // Stats Row
                    _buildStatsRow(incidentProvider),
                    const SizedBox(height: 24),

                    // Active Incidents Section
                    if (activeIncidents.isNotEmpty) ...[
                      _buildSectionHeader('Active Incidents', activeIncidents.length),
                      const SizedBox(height: 12),
                      ...activeIncidents.take(3).map((incident) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _IncidentCard(
                          incident: incident,
                          onAcknowledge: () => _acknowledgeIncident(context, incident, incidentProvider),
                          onDispatch: () => _dispatchIncident(context, incident, incidentProvider),
                        ),
                      )),
                      if (activeIncidents.length > 3)
                        Center(
                          child: TextButton(
                            onPressed: () => onNavigate(1),
                            child: Text(
                              'View All Incidents',
                              style: GoogleFonts.roboto(
                                color: AppColors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ] else ...[
                      _buildNoIncidentsCard(),
                    ],
                    const SizedBox(height: 24),

                    // Quick Actions
                    _buildQuickActions(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVenueHeader() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.stadium,
              color: AppColors.red,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'King Fahad Stadium',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'On Duty',
                      style: GoogleFonts.roboto(
                        fontSize: 13,
                        color: AppColors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.red.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Text(
              'ACTIVE',
              style: GoogleFonts.roboto(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.red,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(IncidentProvider incidentProvider) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Active',
            value: '${incidentProvider.activeIncidents.length}',
            icon: Icons.emergency,
            color: AppColors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Critical',
            value: '${incidentProvider.criticalIncidents.length}',
            icon: Icons.priority_high,
            color: AppColors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Resolved',
            value: '${incidentProvider.resolvedIncidents.length}',
            icon: Icons.check_circle,
            color: AppColors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: GoogleFonts.roboto(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.red,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoIncidentsCard() {
    return GlassCard(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: AppColors.green,
            ),
            const SizedBox(height: 16),
            Text(
              'No Active Incidents',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All clear. No emergencies reported.',
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionTile(
                icon: Icons.local_hospital,
                label: 'Medical',
                color: AppColors.red,
                onTap: () => _triggerEmergencyAction(context, 'Medical'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionTile(
                icon: Icons.local_fire_department,
                label: 'Fire',
                color: AppColors.orange,
                onTap: () => _triggerEmergencyAction(context, 'Fire'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionTile(
                icon: Icons.security,
                label: 'Security',
                color: AppColors.blue,
                onTap: () => _triggerEmergencyAction(context, 'Security'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionTile(
                icon: Icons.exit_to_app,
                label: 'Evacuate',
                color: AppColors.yellow,
                onTap: () => _showEvacuationDialog(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _acknowledgeIncident(BuildContext context, dynamic incident, IncidentProvider provider) async {
    await provider.updateIncidentStatus(
      incidentId: incident.id,
      newStatus: AppConstants.statusDispatched,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Incident acknowledged'),
          backgroundColor: AppColors.blue,
        ),
      );
    }
  }

  void _dispatchIncident(BuildContext context, dynamic incident, IncidentProvider provider) async {
    await provider.updateIncidentStatus(
      incidentId: incident.id,
      newStatus: AppConstants.statusDispatched,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Team dispatched'),
          backgroundColor: AppColors.green,
        ),
      );
    }
  }

  void _triggerEmergencyAction(BuildContext context, String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$type emergency response initiated'),
        backgroundColor: AppColors.red,
      ),
    );
  }

  void _showEvacuationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.coolSteelBlue,
        title: Text(
          'Initiate Evacuation?',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This will trigger an evacuation alert for all attendees in the venue. This action cannot be undone.',
          style: GoogleFonts.roboto(color: Colors.white70),
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
                  content: const Text('Evacuation initiated'),
                  backgroundColor: AppColors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
            ),
            child: Text(
              'Evacuate',
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== ALERTS TAB ====================
class _AlertsTab extends StatelessWidget {
  final Function(int) onNavigate;

  const _AlertsTab({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: Consumer<IncidentProvider>(
        builder: (context, incidentProvider, _) {
          final incidents = incidentProvider.activeIncidents;

          return CustomScrollView(
            slivers: [
              // Header with SafeArea
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Center(
                      child: Text(
                        'All Incidents',
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Content
              if (incidents.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 64,
                          color: AppColors.green,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Active Incidents',
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'All emergencies have been resolved',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: Colors.white54,
                          ),
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
                        final incident = incidents[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _IncidentCard(
                            incident: incident,
                            onAcknowledge: () async {
                              await incidentProvider.updateIncidentStatus(
                                incidentId: incident.id,
                                newStatus: AppConstants.statusDispatched,
                              );
                            },
                            onDispatch: () async {
                              await incidentProvider.updateIncidentStatus(
                                incidentId: incident.id,
                                newStatus: AppConstants.statusDispatched,
                              );
                            },
                            onTap: () => _showIncidentDetails(context, incident, incidentProvider),
                          ),
                        );
                      },
                      childCount: incidents.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showIncidentDetails(BuildContext context, dynamic incident, IncidentProvider incidentProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.coolSteelBlue,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
                    children: [
                      // Incident Type Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getSeverityColor(incident.severity).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getIncidentIcon(incident.type),
                              color: _getSeverityColor(incident.severity),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  incident.typeDisplayName,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getSeverityColor(incident.severity).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    incident.severity.toUpperCase(),
                                    style: GoogleFonts.roboto(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: _getSeverityColor(incident.severity),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Description
                      Text(
                        'Description',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        incident.description,
                        style: GoogleFonts.roboto(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Details
                      _DetailRow(label: 'Status', value: incident.statusDisplayName),
                      _DetailRow(label: 'Reported By', value: incident.reportedByName),
                      _DetailRow(label: 'Time', value: '${incident.timeSinceCreation.inMinutes} minutes ago'),
                      const SizedBox(height: 24),

                      // Action Buttons
                      Text(
                        'Update Status',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton.primary(
                              text: 'Dispatch',
                              icon: Icons.directions_run,
                              onPressed: () async {
                                await incidentProvider.updateIncidentStatus(
                                  incidentId: incident.id,
                                  newStatus: AppConstants.statusDispatched,
                                );
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Team dispatched'),
                                      backgroundColor: AppColors.blue,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton.secondary(
                              text: 'On Site',
                              icon: Icons.location_on,
                              onPressed: () async {
                                await incidentProvider.updateIncidentStatus(
                                  incidentId: incident.id,
                                  newStatus: AppConstants.statusOnSite,
                                );
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Status: On Site'),
                                      backgroundColor: AppColors.orange,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomButton.info(
                              text: 'Resolve',
                              icon: Icons.check_circle,
                              onPressed: () async {
                                await incidentProvider.updateIncidentStatus(
                                  incidentId: incident.id,
                                  newStatus: AppConstants.statusResolved,
                                  resolutionNotes: 'Resolved by emergency team',
                                );
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Incident resolved'),
                                      backgroundColor: AppColors.green,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return AppColors.red;
      case 'high':
        return AppColors.orange;
      case 'medium':
        return AppColors.yellow;
      default:
        return AppColors.blue;
    }
  }

  IconData _getIncidentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'medical':
        return Icons.local_hospital;
      case 'fire':
        return Icons.local_fire_department;
      case 'security':
        return Icons.security;
      case 'crowd':
        return Icons.groups;
      default:
        return Icons.warning;
    }
  }
}

// ==================== MAP TAB ====================
class _MapTab extends StatelessWidget {
  const _MapTab();

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: Consumer<IncidentProvider>(
        builder: (context, incidentProvider, _) {
          final activeIncidents = incidentProvider.activeIncidents;

          return Stack(
            children: [
              // Map
              FlutterMap(
                options: MapOptions(
                  initialCenter: DummyData.venue.coordinates,
                  initialZoom: AppConstants.defaultZoom,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.mundialmanager.app',
                  ),
                  IncidentMarkers(
                    incidents: activeIncidents,
                    onIncidentTap: (incident) {},
                  ),
                ],
              ),

              // Header and Stats Bar with SafeArea
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      children: [
                        // Title
                        Text(
                          'Incident Map',
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Stats Bar
                        GlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _MapStat(
                                label: 'Active',
                                value: '${incidentProvider.activeIncidents.length}',
                                color: AppColors.red,
                              ),
                              Container(width: 1, height: 30, color: Colors.white24),
                              _MapStat(
                                label: 'Critical',
                                value: '${incidentProvider.criticalIncidents.length}',
                                color: AppColors.orange,
                              ),
                              Container(width: 1, height: 30, color: Colors.white24),
                              _MapStat(
                                label: 'Teams',
                                value: '5',
                                color: AppColors.green,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Legend
              Positioned(
                bottom: 100,
                right: 16,
                child: GlassCard(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Severity',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _LegendItem(label: 'Critical', color: AppColors.red),
                      _LegendItem(label: 'High', color: AppColors.orange),
                      _LegendItem(label: 'Medium', color: AppColors.yellow),
                      _LegendItem(label: 'Low', color: AppColors.blue),
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

// ==================== PROFILE TAB ====================
class _ProfileTab extends StatefulWidget {
  const _ProfileTab();

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  bool _locationSharing = true;
  bool _pushNotifications = true;

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
                  // Profile Header
                  Text(
                    'Profile',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Profile Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.red.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.red.withOpacity(0.5),
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.emergency,
                      size: 50,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // User Name
                  Text(
                    user.name,
                    style: GoogleFonts.montserrat(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  // Email
                  Text(
                    user.email,
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: Colors.white60,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Role Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.red.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Emergency Responder',
                      style: GoogleFonts.roboto(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  CustomButton.primary(
                    text: 'Edit Profile',
                    icon: Icons.edit_outlined,
                    onPressed: () {
                      // TODO: Implement edit profile
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomButton.secondary(
                    text: 'Change Password',
                    icon: Icons.lock_outline,
                    onPressed: () {
                      // TODO: Implement change password
                    },
                  ),
                  const SizedBox(height: 24),

                  // Stats Card
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          'Today\'s Stats',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _ProfileStat(
                                label: 'Responded',
                                value: '12',
                                icon: Icons.check_circle,
                                color: AppColors.green,
                              ),
                            ),
                            Expanded(
                              child: _ProfileStat(
                                label: 'Avg Response',
                                value: '3.2m',
                                icon: Icons.timer,
                                color: AppColors.blue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Settings Section
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Settings',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Location Sharing Toggle
                  GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.red.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.location_on_outlined,
                            color: AppColors.red,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Location Sharing',
                                style: GoogleFonts.roboto(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Share your location with team',
                                style: GoogleFonts.roboto(
                                  fontSize: 12,
                                  color: Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _locationSharing,
                          onChanged: (value) {
                            setState(() => _locationSharing = value);
                          },
                          activeColor: AppColors.red,
                          activeTrackColor: AppColors.red.withOpacity(0.3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Push Notifications Toggle
                  GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.red.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.notifications_outlined,
                            color: AppColors.red,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Push Notifications',
                                style: GoogleFonts.roboto(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Receive emergency alerts',
                                style: GoogleFonts.roboto(
                                  fontSize: 12,
                                  color: Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _pushNotifications,
                          onChanged: (value) {
                            setState(() => _pushNotifications = value);
                          },
                          activeColor: AppColors.red,
                          activeTrackColor: AppColors.red.withOpacity(0.3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Logout Button
                  CustomButton.danger(
                    text: 'Logout',
                    icon: Icons.logout,
                    onPressed: () async {
                      await authProvider.logout();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
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

// ==================== HELPER WIDGETS ====================

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 12,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}

class _IncidentCard extends StatelessWidget {
  final dynamic incident;
  final VoidCallback? onAcknowledge;
  final VoidCallback? onDispatch;
  final VoidCallback? onTap;

  const _IncidentCard({
    required this.incident,
    this.onAcknowledge,
    this.onDispatch,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getSeverityColor(incident.severity);

    return GestureDetector(
      onTap: onTap,
      child: GlassCardWithIndicator(
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
                    _getIncidentIcon(incident.type),
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
                        incident.typeDisplayName,
                        style: GoogleFonts.montserrat(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${incident.timeSinceCreation.inMinutes}m ago • ${incident.statusDisplayName}',
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    incident.severity.toUpperCase(),
                    style: GoogleFonts.roboto(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              incident.description,
              style: GoogleFonts.roboto(
                fontSize: 13,
                color: Colors.white70,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (onAcknowledge != null || onDispatch != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (onAcknowledge != null)
                    Expanded(
                      child: _SmallButton(
                        label: 'Acknowledge',
                        color: AppColors.blue,
                        onPressed: onAcknowledge!,
                      ),
                    ),
                  if (onAcknowledge != null && onDispatch != null)
                    const SizedBox(width: 8),
                  if (onDispatch != null)
                    Expanded(
                      child: _SmallButton(
                        label: 'Dispatch',
                        color: AppColors.green,
                        onPressed: onDispatch!,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return AppColors.red;
      case 'high':
        return AppColors.orange;
      case 'medium':
        return AppColors.yellow;
      default:
        return AppColors.blue;
    }
  }

  IconData _getIncidentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'medical':
        return Icons.local_hospital;
      case 'fire':
        return Icons.local_fire_department;
      case 'security':
        return Icons.security;
      case 'crowd':
        return Icons.groups;
      default:
        return Icons.warning;
    }
  }
}

class _SmallButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _SmallButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 11,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MapStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 11,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.white54,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ProfileStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 12,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }
}
