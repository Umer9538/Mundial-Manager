import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/alert_provider.dart';
import '../../widgets/common/gradient_scaffold.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: Consumer<AlertProvider>(
        builder: (context, alertProvider, _) {
          final alerts = alertProvider.getAlertsForRole('fan');

          if (alerts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: Colors.white38,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No alerts at the moment',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You\'ll be notified of any safety updates',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: alertProvider.refresh,
            color: AppColors.softTealBlue,
            backgroundColor: AppColors.deepNavyBlue,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 100),
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _AlertCard(alert: alerts[index]),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final dynamic alert;

  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final color = _getAlertColor(alert.type);

    return Container(
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left color indicator
          Container(
            width: 5,
            height: 160,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _getAlertIcon(alert.type),
                          color: color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Title and time
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${alert.typeDisplayName} Alert',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getTimeAgo(alert.createdAt),
                              style: GoogleFonts.roboto(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Message
                  Text(
                    alert.message,
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: Colors.grey[800],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Tags
                  Row(
                    children: [
                      _Tag(
                        label: 'WARNING',
                        color: color,
                        filled: true,
                      ),
                      const SizedBox(width: 8),
                      _Tag(
                        label: 'fan',
                        color: Colors.grey[600]!,
                        filled: false,
                      ),
                      const SizedBox(width: 8),
                      _Tag(
                        label: 'security',
                        color: Colors.grey[600]!,
                        filled: false,
                      ),
                    ],
                  ),
                ],
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
        return AppColors.orange;
      default:
        return AppColors.blue;
    }
  }

  IconData _getAlertIcon(String type) {
    switch (type.toLowerCase()) {
      case 'emergency':
        return Icons.emergency;
      case 'safety':
        return Icons.security;
      case 'congestion':
        return Icons.groups;
      default:
        return Icons.notifications;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  final bool filled;

  const _Tag({
    required this.label,
    required this.color,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: filled ? color.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: filled ? color : Colors.grey[400]!,
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.roboto(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: filled ? color : Colors.grey[600],
        ),
      ),
    );
  }
}
