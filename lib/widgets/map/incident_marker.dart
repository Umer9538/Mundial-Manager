import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../models/incident.dart';
import '../../core/theme/app_colors.dart';

class IncidentMarkers extends StatelessWidget {
  final List<Incident> incidents;
  final Function(Incident)? onIncidentTap;

  const IncidentMarkers({
    super.key,
    required this.incidents,
    this.onIncidentTap,
  });

  @override
  Widget build(BuildContext context) {
    return MarkerLayer(
      markers: incidents.map((incident) {
        return Marker(
          point: incident.location,
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () => onIncidentTap?.call(incident),
            child: IncidentMarkerWidget(incident: incident),
          ),
        );
      }).toList(),
    );
  }
}

class IncidentMarkerWidget extends StatelessWidget {
  final Incident incident;

  const IncidentMarkerWidget({
    super.key,
    required this.incident,
  });

  IconData _getIncidentIcon() {
    switch (incident.type) {
      case 'medical':
        return Icons.medical_services;
      case 'security':
        return Icons.security;
      case 'overcrowding':
        return Icons.groups;
      case 'other':
        return Icons.report_problem;
      default:
        return Icons.info;
    }
  }

  Color _getSeverityColor() {
    return AppColors.getSeverityColor(incident.severity);
  }

  Color _getStatusColor() {
    switch (incident.status) {
      case 'reported':
        return AppColors.warning;
      case 'dispatched':
        return AppColors.info;
      case 'on-site':
        return AppColors.secondary;
      case 'resolved':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isResolved = incident.status == 'resolved';

    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulsing effect for active incidents
        if (!isResolved)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getSeverityColor().withOpacity(0.3),
            ),
          ),

        // Main marker
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _getSeverityColor(),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(
            _getIncidentIcon(),
            color: Colors.white,
            size: 20,
          ),
        ),

        // Status indicator
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getStatusColor(),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class IncidentInfoPopup extends StatelessWidget {
  final Incident incident;
  final VoidCallback? onViewDetails;

  const IncidentInfoPopup({
    super.key,
    required this.incident,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type & Severity
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.getSeverityColor(incident.severity).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  incident.typeDisplayName,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getSeverityColor(incident.severity),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                incident.severity.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getSeverityColor(incident.severity),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            incident.description,
            style: const TextStyle(fontSize: 11),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // Status
          Row(
            children: [
              const Text(
                'Status: ',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
              Text(
                incident.statusDisplayName,
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Time
          Text(
            '${incident.timeSinceCreation.inMinutes} min ago',
            style: TextStyle(
              fontSize: 9,
              color: AppColors.textSecondary,
            ),
          ),

          // View Details Button
          if (onViewDetails != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 28,
              child: ElevatedButton(
                onPressed: onViewDetails,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  textStyle: const TextStyle(fontSize: 10),
                ),
                child: const Text('View Details'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
