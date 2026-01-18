import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Button variant types for the dark theme design
enum ButtonVariant {
  primary,   // Green - for main actions (Login, Register, Save)
  secondary, // Outlined - for secondary actions (Cancel, View)
  warning,   // Orange - for warning actions (Send Alert)
  danger,    // Red - for destructive actions (Logout, Delete, Evacuate)
  info,      // Blue - for informational actions
  ghost,     // Transparent with text - for tertiary actions
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonVariant variant;
  final IconData? icon;
  final double? width;
  final double? height;
  final double borderRadius;
  final bool fullWidth;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.width,
    this.height,
    this.borderRadius = 12.0,
    this.fullWidth = true,
  });

  // Convenience constructors
  const CustomButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
    this.borderRadius = 12.0,
    this.fullWidth = true,
  }) : variant = ButtonVariant.primary;

  const CustomButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
    this.borderRadius = 12.0,
    this.fullWidth = true,
  }) : variant = ButtonVariant.secondary;

  const CustomButton.warning({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
    this.borderRadius = 12.0,
    this.fullWidth = true,
  }) : variant = ButtonVariant.warning;

  const CustomButton.danger({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
    this.borderRadius = 12.0,
    this.fullWidth = true,
  }) : variant = ButtonVariant.danger;

  const CustomButton.info({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
    this.borderRadius = 12.0,
    this.fullWidth = true,
  }) : variant = ButtonVariant.info;

  const CustomButton.ghost({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
    this.borderRadius = 12.0,
    this.fullWidth = true,
  }) : variant = ButtonVariant.ghost;

  Color _getBackgroundColor() {
    switch (variant) {
      case ButtonVariant.primary:
        return AppColors.green;
      case ButtonVariant.secondary:
        return Colors.transparent;
      case ButtonVariant.warning:
        return AppColors.orange;
      case ButtonVariant.danger:
        return AppColors.red;
      case ButtonVariant.info:
        return AppColors.blue;
      case ButtonVariant.ghost:
        return Colors.transparent;
    }
  }

  Color _getTextColor() {
    switch (variant) {
      case ButtonVariant.primary:
      case ButtonVariant.warning:
      case ButtonVariant.danger:
      case ButtonVariant.info:
        return Colors.white;
      case ButtonVariant.secondary:
        return Colors.white;
      case ButtonVariant.ghost:
        return AppColors.blue;
    }
  }

  Color _getBorderColor() {
    switch (variant) {
      case ButtonVariant.secondary:
        return const Color(0x66FFFFFF); // 40% white
      case ButtonVariant.ghost:
        return Colors.transparent;
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getBackgroundColor();
    final textColor = _getTextColor();
    final borderColor = _getBorderColor();

    final buttonContent = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: textColor),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    final loadingWidget = SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: textColor,
      ),
    );

    return SizedBox(
      width: fullWidth ? double.infinity : width,
      height: height ?? 52,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: borderColor != Colors.transparent
                  ? Border.all(color: borderColor, width: 1.5)
                  : null,
            ),
            alignment: Alignment.center,
            child: isLoading ? loadingWidget : buttonContent,
          ),
        ),
      ),
    );
  }
}

/// Social login button for Google, Facebook, Apple
class SocialButton extends StatelessWidget {
  final String assetPath;
  final VoidCallback? onPressed;
  final double size;

  const SocialButton({
    super.key,
    required this.assetPath,
    this.onPressed,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0x1AFFFFFF), // 10% white
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0x26FFFFFF), // 15% white
            width: 1,
          ),
        ),
        child: ClipOval(
          child: Image.asset(
            assetPath,
            width: size * 0.5,
            height: size * 0.5,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.error_outline,
                color: Colors.white54,
                size: size * 0.5,
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Icon-based social button when asset is not available
class SocialIconButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color? backgroundColor;
  final VoidCallback? onPressed;
  final double size;

  const SocialIconButton({
    super.key,
    required this.icon,
    this.iconColor = Colors.white,
    this.backgroundColor,
    this.onPressed,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? const Color(0x1AFFFFFF),
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0x26FFFFFF),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: size * 0.5,
        ),
      ),
    );
  }
}
