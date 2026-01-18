import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../models/zone.dart';
import '../../core/theme/app_colors.dart';

class ZoneOverlay extends StatelessWidget {
  final List<Zone> zones;
  final String? highlightedZoneId;
  final Function(Zone)? onZoneTap;

  const ZoneOverlay({
    super.key,
    required this.zones,
    this.highlightedZoneId,
    this.onZoneTap,
  });

  @override
  Widget build(BuildContext context) {
    return PolygonLayer(
      polygons: zones.map((zone) {
        final isHighlighted = zone.id == highlightedZoneId;
        return Polygon(
          points: zone.boundaries,
          color: isHighlighted
              ? AppColors.primary.withOpacity(0.3)
              : Colors.blue.withOpacity(0.1),
          borderColor: isHighlighted
              ? AppColors.primary
              : AppColors.border,
          borderStrokeWidth: isHighlighted ? 3 : 1,
          isFilled: true,
        );
      }).toList(),
    );
  }
}

class ZoneLabels extends StatelessWidget {
  final List<Zone> zones;
  final Function(Zone)? onTap;

  const ZoneLabels({
    super.key,
    required this.zones,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MarkerLayer(
      markers: zones.map((zone) {
        return Marker(
          point: zone.center,
          width: 100,
          height: 40,
          child: GestureDetector(
            onTap: () => onTap?.call(zone),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    zone.name,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    zone.type,
                    style: TextStyle(
                      fontSize: 8,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
