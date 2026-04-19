import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/crowd_density.dart';
import '../../models/zone.dart';
import '../../core/theme/app_colors.dart';

/// Custom stadium-layout crowd heatmap.
/// Draws a schematic top-down stadium view instead of a street/satellite map.
/// Each zone is rendered as a colored section with occupancy % labels.
class CrowdHeatmap extends StatefulWidget {
  final List<CrowdDensity> crowdData;
  final List<Zone> zones;
  final Function(Zone)? onZoneTap;

  // These are kept for API compatibility but ignored (no map tiles)
  final dynamic center;
  final double? zoom;

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

class _CrowdHeatmapState extends State<CrowdHeatmap>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  CrowdDensity? _getDensityForZone(String zoneId) {
    try {
      return widget.crowdData.firstWhere((cd) => cd.zoneId == zoneId);
    } catch (_) {
      return null;
    }
  }

  Color _getZoneColor(String zoneId) {
    final density = _getDensityForZone(zoneId);
    if (density == null) return AppColors.densitySafe;
    return AppColors.getDensityColorByOccupancy(density.occupancyPercentage);
  }

  int _getOccupancy(String zoneId) {
    final density = _getDensityForZone(zoneId);
    return density?.occupancyPercentageRounded ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A1628),
            Color(0xFF0F253D),
            Color(0xFF0A1628),
          ],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              return CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: _StadiumPainter(
                  zones: widget.zones,
                  crowdData: widget.crowdData,
                  pulseValue: _pulseController.value,
                ),
                child: _buildZoneLabels(constraints),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildZoneLabels(BoxConstraints constraints) {
    final w = constraints.maxWidth;
    final h = constraints.maxHeight;
    final cx = w / 2;
    final cy = h / 2;
    final stadiumR = math.min(w, h) * 0.35;

    // Position labels at each zone's angular position around the stadium
    final zonePositions = <String, Offset>{};

    for (final zone in widget.zones) {
      final pos = _getZonePosition(zone, cx, cy, stadiumR);
      zonePositions[zone.id] = pos;
    }

    return Stack(
      children: [
        // Legend at top
        Positioned(
          top: 8,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(AppColors.densitySafe, '<50%'),
              const SizedBox(width: 12),
              _legendDot(AppColors.densityModerate, '50-69%'),
              const SizedBox(width: 12),
              _legendDot(AppColors.densityHigh, '70-84%'),
              const SizedBox(width: 12),
              _legendDot(AppColors.densityCritical, '≥85%'),
            ],
          ),
        ),

        // Zone labels
        for (final zone in widget.zones)
          if (zonePositions.containsKey(zone.id))
            Positioned(
              left: zonePositions[zone.id]!.dx - 52,
              top: zonePositions[zone.id]!.dy - 16,
              child: GestureDetector(
                onTap: () => widget.onZoneTap?.call(zone),
                child: _ZoneLabel(
                  name: zone.name,
                  occupancy: _getOccupancy(zone.id),
                  color: _getZoneColor(zone.id),
                  type: zone.type,
                ),
              ),
            ),

        // Center field label
        Positioned(
          left: cx - 30,
          top: cy - 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1A472A),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF2D7A4A), width: 1),
            ),
            child: const Text(
              '⚽ PITCH',
              style: TextStyle(
                color: Color(0xFF4ADE80),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Offset _getZonePosition(Zone zone, double cx, double cy, double radius) {
    // Map zone type/name to angular positions around the stadium
    final name = zone.name.toLowerCase();

    if (name.contains('north')) return Offset(cx, cy - radius - 10);
    if (name.contains('south')) return Offset(cx, cy + radius + 10);
    if (name.contains('east')) return Offset(cx + radius + 10, cy);
    if (name.contains('west')) return Offset(cx - radius - 10, cy);
    if (name.contains('vip')) return Offset(cx, cy);
    if (name.contains('food')) return Offset(cx, cy - radius - 50);
    if (name.contains('entrance') || name.contains('main')) {
      return Offset(cx, cy + radius + 50);
    }

    // Default: distribute evenly
    final index = widget.zones.indexOf(zone);
    final angle = (index / widget.zones.length) * 2 * math.pi - math.pi / 2;
    return Offset(cx + radius * math.cos(angle), cy + radius * math.sin(angle));
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 3),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 9)),
      ],
    );
  }
}

/// Zone label chip widget
class _ZoneLabel extends StatelessWidget {
  final String name;
  final int occupancy;
  final Color color;
  final String type;

  const _ZoneLabel({
    required this.name,
    required this.occupancy,
    required this.color,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xE6101D30),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_getIcon(type), color: color, size: 11),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          // Occupancy bar
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 6,
              width: 80,
              child: LinearProgressIndicator(
                value: (occupancy / 100).clamp(0.0, 1.0),
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$occupancy%',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'entrance':
        return Icons.door_front_door;
      case 'vip':
        return Icons.star;
      case 'concourse':
        return Icons.restaurant;
      default:
        return Icons.stadium;
    }
  }
}

/// Custom painter that draws the stadium schematic layout
class _StadiumPainter extends CustomPainter {
  final List<Zone> zones;
  final List<CrowdDensity> crowdData;
  final double pulseValue;

  _StadiumPainter({
    required this.zones,
    required this.crowdData,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final stadiumRadius = math.min(size.width, size.height) * 0.35;
    final innerRadius = stadiumRadius * 0.55;

    // Draw stadium outer ring (the seating bowl)
    _drawStadiumRing(canvas, cx, cy, stadiumRadius, innerRadius);

    // Draw zone sections as colored arcs
    _drawZoneSections(canvas, cx, cy, stadiumRadius, innerRadius);

    // Draw the pitch (green field in center)
    _drawPitch(canvas, cx, cy, innerRadius * 0.85);

    // Draw grid lines for stadium feel
    _drawStructuralLines(canvas, cx, cy, stadiumRadius, innerRadius);
  }

  void _drawStadiumRing(
      Canvas canvas, double cx, double cy, double outer, double inner) {
    // Outer glow
    final glowPaint = Paint()
      ..color = const Color(0xFF27506D).withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(Offset(cx, cy), outer + 15, glowPaint);

    // Stadium outline
    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF3A5F7D)
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(cx, cy), outer, outlinePaint);

    // Inner ring
    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF2A4A65)
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(cx, cy), inner, innerPaint);
  }

  void _drawZoneSections(
      Canvas canvas, double cx, double cy, double outer, double inner) {
    // Map zones to angular segments
    final zoneAngles = <String, _ArcSegment>{};

    for (final zone in zones) {
      final name = zone.name.toLowerCase();
      double startAngle, sweepAngle;

      if (name.contains('north')) {
        startAngle = -math.pi * 0.85;
        sweepAngle = math.pi * 0.7;
      } else if (name.contains('south')) {
        startAngle = math.pi * 0.15;
        sweepAngle = math.pi * 0.7;
      } else if (name.contains('east')) {
        startAngle = -math.pi * 0.15;
        sweepAngle = math.pi * 0.3;
      } else if (name.contains('west')) {
        startAngle = math.pi * 0.85;
        sweepAngle = math.pi * 0.3;
      } else if (name.contains('vip')) {
        // VIP: inner ring, full circle drawn separately
        _drawVIPSection(canvas, cx, cy, inner);
        continue;
      } else if (name.contains('food')) {
        // Food court: small box above stadium
        _drawExternalZone(canvas, cx, cy - outer - 30, zone, 'food');
        continue;
      } else if (name.contains('entrance') || name.contains('main')) {
        // Main entrance: small box below stadium
        _drawExternalZone(canvas, cx, cy + outer + 30, zone, 'entrance');
        continue;
      } else {
        continue;
      }

      zoneAngles[zone.id] = _ArcSegment(startAngle, sweepAngle);
    }

    // Draw each zone arc
    for (final zone in zones) {
      final segment = zoneAngles[zone.id];
      if (segment == null) continue;

      final density = _getDensity(zone.id);
      final occupancy = density != null ? density.occupancyPercentage / 100 : 0.0;
      final color = _getColor(occupancy);

      // Filled arc between inner and outer radius
      final path = Path()
        ..addArc(
          Rect.fromCircle(center: Offset(cx, cy), radius: outer),
          segment.start,
          segment.sweep,
        )
        ..arcTo(
          Rect.fromCircle(center: Offset(cx, cy), radius: inner),
          segment.start + segment.sweep,
          -segment.sweep,
          false,
        )
        ..close();

      // Fill with gradient based on occupancy
      final fillPaint = Paint()
        ..color = color.withValues(alpha: 0.25 + occupancy * 0.35);
      canvas.drawPath(path, fillPaint);

      // Glow effect for high density zones
      if (occupancy >= 0.70) {
        final glowPaint = Paint()
          ..color = color.withValues(alpha: 0.15 + pulseValue * 0.1)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
        canvas.drawPath(path, glowPaint);
      }

      // Border
      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = color.withValues(alpha: 0.7)
        ..strokeWidth = 1.5;
      canvas.drawPath(path, borderPaint);
    }
  }

  void _drawVIPSection(Canvas canvas, double cx, double cy, double inner) {
    final vipRadius = inner * 0.4;
    final vipDensity = _getDensityByName('vip');
    final occupancy =
        vipDensity != null ? vipDensity.occupancyPercentage / 100 : 0.0;
    final color = _getColor(occupancy);

    // Diamond/hexagon shape for VIP
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i / 6) * 2 * math.pi - math.pi / 2;
      final x = cx + vipRadius * math.cos(angle);
      final y = cy + vipRadius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    final fill = Paint()
      ..color = color.withValues(alpha: 0.3 + occupancy * 0.3);
    canvas.drawPath(path, fill);

    if (occupancy >= 0.70) {
      final glow = Paint()
        ..color = color.withValues(alpha: 0.1 + pulseValue * 0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawPath(path, glow);
    }

    final border = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.6)
      ..strokeWidth = 1.5;
    canvas.drawPath(path, border);
  }

  void _drawExternalZone(
      Canvas canvas, double cx, double cy, Zone zone, String type) {
    final density = _getDensity(zone.id);
    final occupancy = density != null ? density.occupancyPercentage / 100 : 0.0;
    final color = _getColor(occupancy);

    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: 90, height: 28),
      const Radius.circular(8),
    );

    final fill = Paint()..color = color.withValues(alpha: 0.25 + occupancy * 0.3);
    canvas.drawRRect(rect, fill);

    final border = Paint()
      ..style = PaintingStyle.stroke
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    canvas.drawRRect(rect, border);
  }

  void _drawPitch(Canvas canvas, double cx, double cy, double radius) {
    // Green pitch ellipse
    final pitchRect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: radius * 1.8,
      height: radius * 1.2,
    );

    // Pitch fill
    final pitchFill = Paint()..color = const Color(0xFF1A472A);
    canvas.drawOval(pitchRect, pitchFill);

    // Pitch border
    final pitchBorder = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF2D7A4A)
      ..strokeWidth = 1.5;
    canvas.drawOval(pitchRect, pitchBorder);

    // Center circle
    final centerCirclePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF2D7A4A).withValues(alpha: 0.5)
      ..strokeWidth = 1;
    canvas.drawCircle(Offset(cx, cy), radius * 0.25, centerCirclePaint);

    // Center dot
    final dotPaint = Paint()..color = const Color(0xFF2D7A4A);
    canvas.drawCircle(Offset(cx, cy), 3, dotPaint);

    // Halfway line
    canvas.drawLine(
      Offset(cx, cy - radius * 0.58),
      Offset(cx, cy + radius * 0.58),
      centerCirclePaint,
    );
  }

  void _drawStructuralLines(
      Canvas canvas, double cx, double cy, double outer, double inner) {
    // Radial section dividers
    final dividerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF2A4A65).withValues(alpha: 0.4)
      ..strokeWidth = 0.8;

    // 8 radial dividers
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * math.pi;
      final x1 = cx + inner * math.cos(angle);
      final y1 = cy + inner * math.sin(angle);
      final x2 = cx + outer * math.cos(angle);
      final y2 = cy + outer * math.sin(angle);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), dividerPaint);
    }

    // Concentric ring between inner and outer
    final midRadius = (inner + outer) / 2;
    final midRingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF2A4A65).withValues(alpha: 0.2)
      ..strokeWidth = 0.5;
    canvas.drawCircle(Offset(cx, cy), midRadius, midRingPaint);
  }

  CrowdDensity? _getDensity(String zoneId) {
    try {
      return crowdData.firstWhere((cd) => cd.zoneId == zoneId);
    } catch (_) {
      return null;
    }
  }

  CrowdDensity? _getDensityByName(String nameContains) {
    try {
      return crowdData.firstWhere(
          (cd) => cd.zoneName.toLowerCase().contains(nameContains));
    } catch (_) {
      return null;
    }
  }

  Color _getColor(double occupancy) {
    return AppColors.getDensityColorByOccupancy(occupancy * 100);
  }

  @override
  bool shouldRepaint(covariant _StadiumPainter old) => true;
}

class _ArcSegment {
  final double start;
  final double sweep;
  _ArcSegment(this.start, this.sweep);
}
