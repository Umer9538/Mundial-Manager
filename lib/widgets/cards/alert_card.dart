import 'package:flutter/material.dart';
import '../../models/alert.dart';
import '../../core/theme/app_colors.dart';

class AlertCard extends StatelessWidget {
  final Alert alert;
  final VoidCallback? onTap;
  final bool showDismiss;
  final VoidCallback? onDismiss;

  const AlertCard({
    super.key,
    required this.alert,
    this.onTap,
    this.showDismiss = false,
    this.onDismiss,
  });

  IconData _getAlertIcon() {
    switch (alert.type) {
      case 'emergency':
        return Icons.emergency;
      case 'safety':
        return Icons.warning;
      case 'congestion':
        return Icons.groups;
      case 'info':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getAlertColor(alert.type);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: color,
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
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getAlertIcon(),
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.typeDisplayName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        Text(
                          alert.timeAgo,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showDismiss)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: onDismiss,
                      color: AppColors.textSecondary,
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Message
              Text(
                alert.message,
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 12),

              // Footer
              Row(
                children: [
                  // Severity Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getSeverityColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      alert.severity.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _getSeverityColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Target Roles
                  Expanded(
                    child: Wrap(
                      spacing: 4,
                      children: alert.targetRoles.map((role) {
                        return Chip(
                          label: Text(
                            role,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
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

  Color _getSeverityColor() {
    switch (alert.severity) {
      case 'critical':
        return AppColors.error;
      case 'warning':
        return AppColors.warning;
      case 'info':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }
}
