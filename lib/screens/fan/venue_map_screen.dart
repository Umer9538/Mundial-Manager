import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/crowd_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/map/crowd_heatmap.dart';
import '../../core/utils/dummy_data.dart';

class VenueMapScreen extends StatefulWidget {
  const VenueMapScreen({super.key});

  @override
  State<VenueMapScreen> createState() => _VenueMapScreenState();
}

class _VenueMapScreenState extends State<VenueMapScreen> {
  bool _showAlert = true;

  @override
  Widget build(BuildContext context) {
    return Consumer2<CrowdProvider, AuthProvider>(
      builder: (context, crowdProvider, authProvider, _) {
        return Stack(
          children: [
            // Full Map
            CrowdHeatmap(
              crowdData: crowdProvider.crowdData,
              zones: DummyData.zones,
              onZoneTap: (zone) {
                _showZoneDetails(context, zone.id, crowdProvider);
              },
            ),

            // Top Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () {},
                      ),
                      const Spacer(),
                      Text(
                        'Event Map',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                            onPressed: () {},
                          ),
                          Positioned(
                            right: 10,
                            top: 10,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Alert Banner
            if (_showAlert)
              Positioned(
                top: MediaQuery.of(context).padding.top + 56,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCC5A50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber, color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Zone B is crowded',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Move toward Gate 3 for a safer path.',
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _showAlert = false),
                        child: const Icon(Icons.close, color: Colors.white70, size: 20),
                      ),
                    ],
                  ),
                ),
              ),

            // POI Markers overlay
            Positioned(
              top: MediaQuery.of(context).padding.top + (_showAlert ? 150 : 70),
              right: 24,
              child: _PoiMarker(icon: Icons.local_hospital, label: 'First Aid'),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.3,
              left: 40,
              child: _PoiMarker(icon: Icons.restaurant, label: 'Food'),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.45,
              left: MediaQuery.of(context).size.width * 0.4,
              child: _PoiMarker(icon: Icons.door_front_door_outlined, label: 'Entrance'),
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.25,
              left: 50,
              child: _PoiMarker(icon: Icons.mosque, label: 'Prayer'),
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.15,
              left: MediaQuery.of(context).size.width * 0.4,
              child: _PoiMarker(icon: Icons.exit_to_app, label: 'Exit'),
            ),

            // Bottom Action Buttons
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Expanded(
                    child: Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        return SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () => auth.toggleLocationSharing(),
                            icon: Icon(
                              Icons.my_location,
                              size: 18,
                              color: auth.isLocationSharing ? Colors.white : Colors.white70,
                            ),
                            label: Text(
                              'Share\nLocation',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: auth.isLocationSharing
                                  ? AppColors.softTealBlue
                                  : AppColors.coolSteelBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => _showEventInfo(context),
                        icon: const Icon(Icons.info_outline, size: 18),
                        label: Text(
                          'Event Info',
                          style: GoogleFonts.roboto(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.coolSteelBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEventInfo(BuildContext context) {
    final venue = DummyData.venue;
    final event = DummyData.event;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              venue.name,
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            _InfoRow(label: 'Event', value: event.name),
            _InfoRow(label: 'Capacity', value: '${venue.capacity}'),
            _InfoRow(label: 'Status', value: event.status.toUpperCase()),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showZoneDetails(BuildContext context, String zoneId, CrowdProvider crowdProvider) {
    final zone = DummyData.getZoneById(zoneId);
    final density = crowdProvider.getZoneDensity(zoneId);

    if (zone == null || density == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              zone.name,
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _InfoRow(
              label: 'Population',
              value: '${density.currentPopulation}/${density.capacity}',
            ),
            _InfoRow(
              label: 'Occupancy',
              value: '${density.occupancyPercentageRounded}%',
            ),
            _InfoRow(
              label: 'Density',
              value: '${density.densityPerSqMeter.toStringAsFixed(1)} p/m²',
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _PoiMarker extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PoiMarker({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.coolSteelBlue.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24, width: 1),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.roboto(fontSize: 14, color: Colors.white60),
          ),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
