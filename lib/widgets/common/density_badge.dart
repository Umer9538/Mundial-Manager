import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class DensityBadge extends StatelessWidget {
  final double peoplePerSqMeter;
  final bool showLabel;
  final double size;

  const DensityBadge({
    super.key,
    required this.peoplePerSqMeter,
    this.showLabel = true,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getDensityColor(peoplePerSqMeter);
    final status = AppColors.getDensityStatus(peoplePerSqMeter);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            border: Border.all(color: color, width: 3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                peoplePerSqMeter.toStringAsFixed(1),
                style: AppTheme.monoTextStyleWithSize(size * 0.3).copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'people/m²',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontSize: size * 0.12,
                ),
              ),
            ],
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class DensityChip extends StatelessWidget {
  final double peoplePerSqMeter;
  final bool compact;

  const DensityChip({
    super.key,
    required this.peoplePerSqMeter,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getDensityColor(peoplePerSqMeter);
    final status = AppColors.getDensityStatus(peoplePerSqMeter);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people,
            size: compact ? 14 : 16,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            compact ? status : '$status (${peoplePerSqMeter.toStringAsFixed(1)}/m²)',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: compact ? 10 : 12,
            ),
          ),
        ],
      ),
    );
  }
}
