import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/crowd_density.dart';
import '../../models/zone.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/constants.dart';

class CrowdHeatmap extends StatefulWidget {
  final List<CrowdDensity> crowdData;
  final List<Zone> zones;
  final LatLng? center;
  final double? zoom;
  final Function(Zone)? onZoneTap;

  const CrowdHeatmap({
    super.key,
    required this.crowdData,
    required this.zones,
    this.center,
    this.zoom,
    this.onZoneTap,
  });

  @override
  State<CrowdHeatmap> createState() => _CrowdHeatmapState();
}

class _CrowdHeatmapState extends State<CrowdHeatmap> {
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  Color _getZoneColor(String zoneId) {
    final crowdDensity = widget.crowdData.firstWhere(
          (cd) => cd.zoneId == zoneId,
      orElse: () => CrowdDensity(
        zoneId: zoneId,
        zoneName: '',
        currentPopulation: 0,
        capacity: 1,
        densityPerSqMeter: 0,
        status: 'safe',
        lastUpdated: DateTime.now(),
      ),
    );

    return AppColors.getDensityColor(crowdDensity.densityPerSqMeter);
  }

  @override
  Widget build(BuildContext context) {
    final center = widget.center ??
        const LatLng(AppConstants.defaultLat, AppConstants.defaultLng);
    final zoom = widget.zoom ?? AppConstants.defaultZoom;

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: zoom,
        minZoom: AppConstants.minZoom,
        maxZoom: AppConstants.maxZoom,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        // Base Map Tile Layer
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.mundialmanager.app',
        ),

        // Zone Polygons with Heatmap Colors
        PolygonLayer(
          polygons: widget.zones.map((zone) {
            final color = _getZoneColor(zone.id);
            return Polygon(
              points: zone.boundaries,
              color: color.withOpacity(0.4),
              borderColor: color,
              borderStrokeWidth: 2,
              isFilled: true,
            );
          }).toList(),
        ),

        // Zone Labels
        MarkerLayer(
          markers: widget.zones.map((zone) {
            final crowdDensity = widget.crowdData.firstWhere(
                  (cd) => cd.zoneId == zone.id,
              orElse: () => CrowdDensity(
                zoneId: zone.id,
                zoneName: zone.name,
                currentPopulation: 0,
                capacity: zone.capacity,
                densityPerSqMeter: 0,
                status: 'safe',
                lastUpdated: DateTime.now(),
              ),
            );

            return Marker(
              point: zone.center,
              width: 120,
              height: 60,
              child: GestureDetector(
                onTap: () => widget.onZoneTap?.call(zone),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
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
                        '${crowdDensity.occupancyPercentageRounded}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getZoneColor(zone.id),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
