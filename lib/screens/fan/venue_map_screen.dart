import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/crowd_provider.dart';
import '../../providers/alert_provider.dart';
import '../../widgets/map/crowd_heatmap.dart';
import '../common/report_incident_screen.dart';

class VenueMapScreen extends StatefulWidget {
  final VoidCallback? onNavigateHome;

  const VenueMapScreen({super.key, this.onNavigateHome});

  @override
  State<VenueMapScreen> createState() => _VenueMapScreenState();
}

class _VenueMapScreenState extends State<VenueMapScreen> {
  String? _selectedZoneFilter; // null = All

  @override
  void initState() {
    super.initState();
    _loadEventData();
  }

  Future<void> _loadEventData() async {
    // Event data is loaded by CrowdProvider; this is kept for future use
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Consumer2<CrowdProvider, AlertProvider>(
      builder: (context, crowdProvider, alertProvider, _) {
        final stats = crowdProvider.venueStats;
        final avgOccupancy = stats['occupancyPercentage'] as int? ?? 0;
        final criticalCount = stats['criticalZones'] as int? ?? 0;
        final criticalAlerts = alertProvider.criticalAlerts.length;

        return Container(
          color: const Color(0xFF0D1B2A),
          child: Column(
            children: [
              // Top bar
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      Text(
                        l.liveCrowdMonitoring,
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white70, size: 22),
                        onPressed: () => crowdProvider.refresh(),
                      ),
                    ],
                  ),
                ),
              ),

              // Heatmap area
              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                  child: CrowdHeatmap(
                    crowdData: crowdProvider.crowdData,
                    zones: crowdProvider.allZones,
                    onZoneTap: (zone) {
                      if (widget.onNavigateHome != null) {
                        widget.onNavigateHome!();
                      } else {
                        _showZoneDetails(context, zone.id, crowdProvider);
                      }
                    },
                  ),
                ),
              ),

              // Stats panel
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Column(
                    children: [
                      // Density info + zone filter
                      Row(
                        children: [
                          // Circular density gauge
                          SizedBox(
                            width: 70,
                            height: 70,
                            child: CustomPaint(
                              painter: _GaugePainter(
                                percentage: avgOccupancy.toDouble(),
                              ),
                              child: Center(
                                child: Text(
                                  '$avgOccupancy%',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Info text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l.densityLabel,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${l.densityLabel}: $avgOccupancy%',
                                  style: GoogleFonts.roboto(
                                    fontSize: 12,
                                    color: Colors.white60,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${l.activeAlerts}: ${criticalAlerts + criticalCount}',
                                  style: GoogleFonts.roboto(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Zone filter buttons
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ..._buildZoneFilterButtons(crowdProvider),
                              _zoneFilterButton(l.allFilter, null),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Action buttons
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ReportIncidentScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            l.reportIssue,
                            style: GoogleFonts.montserrat(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: OutlinedButton(
                          onPressed: () {
                            // Navigate to alerts tab (index 2 in fan dashboard)
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white38, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            l.viewAlerts,
                            style: GoogleFonts.montserrat(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildZoneFilterButtons(CrowdProvider provider) {
    final zones = provider.allZones;
    // Show first 3 zone codes as filter buttons
    return zones.take(3).map((zone) {
      final code = zone.name.split(' ').map((w) => w[0]).join();
      return _zoneFilterButton(code, zone.id);
    }).toList();
  }

  Widget _zoneFilterButton(String label, String? zoneId) {
    final isSelected = _selectedZoneFilter == zoneId;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: GestureDetector(
        onTap: () => setState(() => _selectedZoneFilter = zoneId),
        child: Container(
          width: 36,
          height: 28,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.softTealBlue.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: AppColors.softTealBlue, width: 1.5)
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.white60,
            ),
          ),
        ),
      ),
    );
  }

  void _showZoneDetails(BuildContext context, String zoneId, CrowdProvider crowdProvider) {
    final l = AppLocalizations.of(context)!;
    final zone = crowdProvider.getZone(zoneId);
    final density = crowdProvider.getZoneDensity(zoneId);

    if (zone == null || density == null) return;

    final color = AppColors.getDensityColorByOccupancy(density.occupancyPercentage);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF152238),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Text(
                  zone.name,
                  style: GoogleFonts.montserrat(
                    fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color, width: 1),
                  ),
                  child: Text(
                    density.statusDisplayName.toUpperCase(),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoRow(label: l.populationLabel, value: '${density.currentPopulation} / ${density.capacity}'),
            _InfoRow(label: l.occupancyLabel, value: '${density.occupancyPercentageRounded}%', valueColor: color),
            _InfoRow(label: l.densityLabel, value: '${density.densityPerSqMeter.toStringAsFixed(1)} p/m\u00B2'),
            if (density.temperature != null)
              _InfoRow(label: l.temperatureLabel, value: '${density.temperature!.toStringAsFixed(0)}\u00B0C'),
            if (density.weatherCondition != null)
              _InfoRow(label: l.weatherLabel, value: density.weatherCondition!),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.roboto(fontSize: 13, color: Colors.white54)),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.roboto(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.white,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

/// Circular gauge painter for the density percentage.
class _GaugePainter extends CustomPainter {
  final double percentage;

  _GaugePainter({required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * (percentage / 100).clamp(0.0, 1.0);

    // Background arc
    final bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final Color progressColor;
    if (percentage >= 85) {
      progressColor = AppColors.red;
    } else if (percentage >= 70) {
      progressColor = AppColors.orange;
    } else if (percentage >= 50) {
      progressColor = AppColors.yellow;
    } else {
      progressColor = AppColors.softTealBlue;
    }

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.percentage != percentage;
}
