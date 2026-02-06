import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/crowd_provider.dart';
import '../../providers/alert_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/gradient_scaffold.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/map/crowd_heatmap.dart';
import '../../widgets/cards/alert_card.dart';

import '../common/report_incident_screen.dart';
import 'venue_map_screen.dart';
import 'notifications_screen.dart';
import 'fan_profile_screen.dart';

class FanDashboard extends StatefulWidget {
  const FanDashboard({super.key});

  @override
  State<FanDashboard> createState() => _FanDashboardState();
}

class _FanDashboardState extends State<FanDashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final crowdProvider = Provider.of<CrowdProvider>(context, listen: false);
    final alertProvider = Provider.of<AlertProvider>(context, listen: false);

    await Future.wait([
      crowdProvider.initialize(),
      alertProvider.initialize(),
    ]);

    crowdProvider.startRealTimeUpdates();
  }

  @override
  void dispose() {
    Provider.of<CrowdProvider>(context, listen: false).stopRealTimeUpdates();
    super.dispose();
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
            const VenueMapScreen(),
            const NotificationsScreen(),
            const FanProfileScreen(),
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
                badge: Consumer<AlertProvider>(
                  builder: (context, alertProvider, _) {
                    final count = alertProvider.getAlertsForRole('fan').length;
                    if (count == 0) return const SizedBox.shrink();
                    return _BadgeCount(count: count);
                  },
                ),
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
                  color: isSelected ? AppColors.softTealBlue : Colors.white54,
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

class _HomeTab extends StatelessWidget {
  final Function(int) onNavigate;

  const _HomeTab({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: Consumer2<CrowdProvider, AlertProvider>(
        builder: (context, crowdProvider, alertProvider, _) {
          if (crowdProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.softTealBlue,
              ),
            );
          }

          final alerts = alertProvider.getAlertsForRole('fan');
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final userName = authProvider.currentUser?.name ?? 'Guest';

          return RefreshIndicator(
            onRefresh: () async {
              await crowdProvider.refresh();
              await alertProvider.refresh();
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

                    // Welcome Header
                    Row(
                      children: [
                        Text(
                          'Welcome, ',
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.w400,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          userName.split(' ').first,
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.softTealBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Current Event Card with Mundial Manager header
                    _buildEventCard(context, alertProvider),
                    const SizedBox(height: 24),

                    // Action Buttons
                    _buildActionButtons(context),
                    const SizedBox(height: 32),

                    // Active Alerts Section
                    if (alerts.isNotEmpty) ...[
                      _buildSectionHeader(context, 'Active Alerts', alerts.length),
                      const SizedBox(height: 12),
                      ...alerts.take(3).map((alert) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildAlertCard(context, alert),
                      )),
                      if (alerts.length > 3)
                        Center(
                          child: TextButton(
                            onPressed: () => onNavigate(2),
                            child: Text(
                              'View All Alerts',
                              style: GoogleFonts.roboto(
                                color: AppColors.softTealBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, AlertProvider alertProvider) {
    final unreadCount = alertProvider.getAlertsForRole('fan').length;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mundial Manager Header with notification bell
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: AppColors.softTealBlue,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Mundial Manager',
                style: GoogleFonts.montserrat(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => onNavigate(2),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      color: Colors.white70,
                      size: 24,
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            unreadCount > 9 ? '9+' : unreadCount.toString(),
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Current Event label
          Text(
            'Current Event:',
            style: GoogleFonts.roboto(
              fontSize: 13,
              color: Colors.white60,
            ),
          ),
          const SizedBox(height: 6),

          // Event name
          Text(
            'Al-Taawoun FC vs NEOM SC',
            style: GoogleFonts.montserrat(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),

          // League name
          Text(
            'Saudi Pro League',
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.softTealBlue,
            ),
          ),
          const SizedBox(height: 2),

          // Date
          Text(
            'Nov 23 - Nov 25',
            style: GoogleFonts.roboto(
              fontSize: 13,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 6),

          // Location
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 14,
                color: Colors.white54,
              ),
              const SizedBox(width: 4),
              Text(
                'Riyadh, SA',
                style: GoogleFonts.roboto(
                  fontSize: 13,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        CustomButton.primary(
          text: 'View Map',
          icon: Icons.map_outlined,
          onPressed: () => onNavigate(1),
        ),
        const SizedBox(height: 12),
        CustomButton.secondary(
          text: 'View Alerts',
          icon: Icons.notifications_outlined,
          onPressed: () => onNavigate(2),
        ),
        const SizedBox(height: 12),
        CustomButton.warning(
          text: 'Report Incident',
          icon: Icons.warning_amber,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ReportIncidentScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            final isSharing = authProvider.currentUser?.locationSharingEnabled ?? false;
            return GestureDetector(
              onTap: () async {
                await authProvider.toggleLocationSharing();
                if (context.mounted && authProvider.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(authProvider.errorMessage!),
                      backgroundColor: AppColors.red,
                    ),
                  );
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSharing
                      ? AppColors.green.withOpacity(0.2)
                      : Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSharing ? AppColors.green : Colors.white24,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isSharing ? Icons.location_on : Icons.location_off_outlined,
                      color: isSharing ? AppColors.green : Colors.white70,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isSharing ? 'Location Sharing: ON' : 'Share My Location',
                      style: GoogleFonts.roboto(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isSharing ? AppColors.green : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
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

  Widget _buildAlertCard(BuildContext context, dynamic alert) {
    return GlassCardWithIndicator(
      indicatorColor: _getAlertColor(alert.type),
      padding: const EdgeInsets.all(16),
      onTap: () {
        // TODO: Show alert details
      },
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.typeDisplayName,
                  style: GoogleFonts.roboto(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alert.message,
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'View on Map',
              style: GoogleFonts.roboto(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
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
}
