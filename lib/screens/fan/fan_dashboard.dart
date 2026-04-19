import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/event.dart';
import '../../services/database_service.dart';
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
  Event? _currentEvent;
  String? _eventVenueAddress;
  CrowdProvider? _crowdProvider;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _crowdProvider = Provider.of<CrowdProvider>(context, listen: false);
  }

  Future<void> _initializeData() async {
    final crowdProvider = Provider.of<CrowdProvider>(context, listen: false);
    final alertProvider = Provider.of<AlertProvider>(context, listen: false);

    // Load current active event from Firestore
    await _loadCurrentEvent();

    final eventId = _currentEvent?.id;

    await Future.wait([
      crowdProvider.initialize(eventId: eventId),
      alertProvider.initialize(eventId: eventId),
    ]);

    // Connect auto-alert system (dataset-driven density alerts)
    crowdProvider.connectAlertProvider(alertProvider);
    crowdProvider.startRealTimeUpdates(eventId: eventId);
  }

  Future<void> _loadCurrentEvent() async {
    try {
      final dbService = DatabaseService();
      final event = await dbService.getCurrentActiveEvent();
      if (!mounted) return;

      setState(() {
        _currentEvent = event;
      });

      if (event != null) {
        final address = await dbService.getVenueAddress(event.venueId);
        if (mounted) {
          setState(() {
            _eventVenueAddress = address;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading current event: $e');
    }
  }

  @override
  void dispose() {
    _crowdProvider?.stopRealTimeUpdates();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.deepNavyBlue,
        extendBody: true,
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _HomeTab(
              onNavigate: _onItemTapped,
              currentEvent: _currentEvent,
              venueAddress: _eventVenueAddress,
            ),
            VenueMapScreen(onNavigateHome: () => _onItemTapped(0)),
            const NotificationsScreen(),
            const FanProfileScreen(),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(l),
      ),
    );
  }

  Widget _buildBottomNav(AppLocalizations l) {
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
                label: l.homeTab,
                isSelected: _selectedIndex == 0,
                onTap: () => _onItemTapped(0),
              ),
              _NavItem(
                icon: Icons.map_outlined,
                activeIcon: Icons.map,
                label: l.mapTab,
                isSelected: _selectedIndex == 1,
                onTap: () => _onItemTapped(1),
              ),
              _NavItem(
                icon: Icons.notifications_outlined,
                activeIcon: Icons.notifications,
                label: l.alertsTab,
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
                label: l.profileTab,
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
  final Event? currentEvent;
  final String? venueAddress;

  const _HomeTab({
    required this.onNavigate,
    this.currentEvent,
    this.venueAddress,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

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
                    Text(
                      l.welcomeUser(userName.split(' ').first),
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.softTealBlue,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Current Event Card with Mundial Manager header
                    _buildEventCard(context, l, alertProvider, currentEvent, venueAddress),
                    const SizedBox(height: 24),

                    // Action Buttons
                    _buildActionButtons(context, l),
                    const SizedBox(height: 32),

                    // Active Alerts Section
                    if (alerts.isNotEmpty) ...[
                      _buildSectionHeader(context, l.activeAlerts, alerts.length),
                      const SizedBox(height: 12),
                      ...alerts.take(3).map((alert) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildAlertCard(context, l, alert),
                      )),
                      if (alerts.length > 3)
                        Center(
                          child: TextButton(
                            onPressed: () => onNavigate(2),
                            child: Text(
                              l.viewAllAlerts,
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

  Widget _buildEventCard(BuildContext context, AppLocalizations l, AlertProvider alertProvider, Event? event, String? venueAddress) {
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
                l.appName,
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

          if (event != null) ...[
            // Current Event label
            Text(
              l.currentEventLabel,
              style: GoogleFonts.roboto(
                fontSize: 13,
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 6),

            // Event name
            Text(
              event.name,
              style: GoogleFonts.montserrat(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),

            // Description (league/category)
            if (event.description != null)
              Text(
                event.description!,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.softTealBlue,
                ),
              ),
            const SizedBox(height: 2),

            // Date
            Text(
              _formatEventDate(event.startDate, event.endDate),
              style: GoogleFonts.roboto(
                fontSize: 13,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 6),

            // Location
            if (venueAddress != null)
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: Colors.white54,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      venueAddress,
                      style: GoogleFonts.roboto(
                        fontSize: 13,
                        color: Colors.white54,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
          ] else ...[
            // No active event
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_busy_outlined,
                      color: Colors.white38,
                      size: 36,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l.noActiveEvent,
                      style: GoogleFonts.roboto(
                        fontSize: 15,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatEventDate(DateTime start, DateTime end) {
    final dateFormat = DateFormat('MMM d');
    if (start.year == end.year && start.month == end.month && start.day == end.day) {
      return '${dateFormat.format(start)}, ${DateFormat('h:mm a').format(start)} - ${DateFormat('h:mm a').format(end)}';
    }
    return '${dateFormat.format(start)} - ${dateFormat.format(end)}';
  }

  Widget _buildActionButtons(BuildContext context, AppLocalizations l) {
    return Column(
      children: [
        CustomButton.primary(
          text: l.viewMap,
          icon: Icons.map_outlined,
          onPressed: () => onNavigate(1),
        ),
        const SizedBox(height: 12),
        CustomButton.secondary(
          text: l.viewAlerts,
          icon: Icons.notifications_outlined,
          onPressed: () => onNavigate(2),
        ),
        const SizedBox(height: 12),
        CustomButton.warning(
          text: l.reportIncident,
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
              onTap: () => _showLocationSharingDialog(context, l, authProvider, isSharing),
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
                      isSharing ? l.locationSharingOn : l.shareMyLocation,
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

  void _showLocationSharingDialog(
    BuildContext context,
    AppLocalizations l,
    AuthProvider authProvider,
    bool isCurrentlySharing,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF1A2A3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: (isCurrentlySharing ? AppColors.red : AppColors.green)
                      .withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCurrentlySharing ? Icons.location_off : Icons.location_on,
                  color: isCurrentlySharing ? AppColors.red : AppColors.green,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l.locationSharing,
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isCurrentlySharing
                    ? l.locationSharingSubtitle
                    : l.locationSharingSubtitle,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Colors.white60,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(l.cancelButton),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isCurrentlySharing ? AppColors.red : AppColors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isCurrentlySharing ? l.locationSharingOn : l.shareMyLocation,
                        style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
                      ),
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

  Widget _buildAlertCard(BuildContext context, AppLocalizations l, dynamic alert) {
    return GlassCardWithIndicator(
      indicatorColor: _getAlertColor(alert.type),
      padding: const EdgeInsets.all(16),
      onTap: () => onNavigate(2),
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
              l.viewOnMap,
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
