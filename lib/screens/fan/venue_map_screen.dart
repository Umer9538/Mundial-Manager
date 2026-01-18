import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/crowd_provider.dart';
import '../../widgets/map/crowd_heatmap.dart';
import '../../core/utils/dummy_data.dart';

class VenueMapScreen extends StatelessWidget {
  const VenueMapScreen({super.key});

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
              onZoneTap: (zone) {
                _showZoneDetails(context, zone.id, crowdProvider);
              },
            ),

            // Density Legend
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: _DensityLegend(),
            ),

            // Zone Info Popup (shown when zones are available)
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
            // Handle
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
            Row(
              children: [
                _DensityBadge(
                  level: _getDensityLevel(density.densityPerSqMeter),
                  percentage: density.occupancyPercentageRounded,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(
                        label: 'Population',
                        value: '${density.currentPopulation}/${density.capacity}',
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                        label: 'Occupancy',
                        value: '${density.occupancyPercentageRounded}%',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _getDensityLevel(double density) {
    if (density <= 1.5) return 'safe';
    if (density <= 2.5) return 'moderate';
    if (density <= 4.0) return 'high';
    return 'critical';
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
              Icon(
                Icons.groups,
                color: Colors.white,
                size: 14,
              ),
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

class _DensityBadge extends StatelessWidget {
  final String level;
  final int percentage;

  const _DensityBadge({
    required this.level,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColorForLevel(level);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.groups,
            color: color,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            '$percentage%',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            level.toUpperCase(),
            style: GoogleFonts.roboto(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 14,
            color: Colors.white60,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
