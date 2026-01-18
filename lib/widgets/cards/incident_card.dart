import 'package:flutter/material.dart';
import '../../models/incident.dart';
import '../../core/theme/app_colors.dart';

class IncidentCard extends StatelessWidget {
  final Incident incident;
  final VoidCallback? onTap;
  final bool compact;

  const IncidentCard({
    super.key,
    required this.incident,
    this.onTap,
    this.compact = false,
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
    final severityColor = AppColors.getSeverityColor(incident.severity);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: severityColor,
                width: 4,
              ),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: severityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getIncidentIcon(),
                      color: severityColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          incident.typeDisplayName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${incident.timeSinceCreation.inMinutes} min ago',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status Indicator
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),

              if (!compact) ...[
                const SizedBox(height: 12),

                // Description
                Text(
                  incident.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),

                // Footer
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Severity Badge
                    _Badge(
                      label: incident.severity.toUpperCase(),
                      color: severityColor,
                    ),

                    // Status Badge
                    _Badge(
                      label: incident.statusDisplayName,
                      color: _getStatusColor(),
                    ),

                    // Reported By
                    if (incident.reportedByName.isNotEmpty)
                      _Badge(
                        label: incident.reportedByName,
                        color: AppColors.textSecondary,
                        icon: Icons.person,
                      ),

                    // Assigned To
                    if (incident.assignedToName != null)
                      _Badge(
                        label: incident.assignedToName!,
                        color: AppColors.info,
                        icon: Icons.assignment_ind,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _Badge({
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
