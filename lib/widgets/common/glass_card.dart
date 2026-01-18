import 'dart:ui';
import 'package:flutter/material.dart';

/// A glassmorphic card with blur effect and semi-transparent background.
/// Used for cards, containers, and panels in the dark theme design.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16.0,
    this.blur = 10.0,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final card = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor ?? const Color(0x26FFFFFF), // 15% white
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? const Color(0x33FFFFFF), // 20% white
              width: borderWidth,
            ),
          ),
          padding: padding ?? const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );

    if (margin != null) {
      return Padding(
        padding: margin!,
        child: onTap != null
            ? InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(borderRadius),
                child: card,
              )
            : card,
      );
    }

    return onTap != null
        ? InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            child: card,
          )
        : card;
  }
}

/// A variant of GlassCard with a colored left border indicator
class GlassCardWithIndicator extends StatelessWidget {
  final Widget child;
  final Color indicatorColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double indicatorWidth;
  final VoidCallback? onTap;

  const GlassCardWithIndicator({
    super.key,
    required this.child,
    required this.indicatorColor,
    this.padding,
    this.margin,
    this.borderRadius = 16.0,
    this.indicatorWidth = 4.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      margin: margin,
      borderRadius: borderRadius,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: indicatorWidth,
            decoration: BoxDecoration(
              color: indicatorColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(borderRadius),
                bottomLeft: Radius.circular(borderRadius),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: padding ?? const EdgeInsets.all(16.0),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

/// A simple container with glass effect for input fields
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 12.0,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0x1AFFFFFF), // 10% white
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? const Color(0x26FFFFFF), // 15% white
          width: 1.0,
        ),
      ),
      padding: padding,
      child: child,
    );
  }
}

/// A tile component for dashboard grids (like Create Event, Send Alert tiles)
class GlassTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final VoidCallback? onTap;
  final double iconSize;
  final double borderRadius;

  const GlassTile({
    super.key,
    required this.icon,
    required this.label,
    this.iconColor,
    this.iconBackgroundColor,
    this.onTap,
    this.iconSize = 28.0,
    this.borderRadius = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: borderRadius,
      onTap: onTap,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconBackgroundColor ?? const Color(0x33FFFFFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor ?? Colors.white,
              size: iconSize,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
