import 'package:flutter/material.dart';
import 'package:omni/core/theme/app_theme.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.elevation,
  });

  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: AppTheme.space8),
      child: Material(
        color: isDark ? AppTheme.charcoalBlack : AppTheme.offWhite,
        surfaceTintColor: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        elevation: elevation ?? (isDark ? 12 : 4),
        shadowColor: isDark
            ? AppTheme.deepBlack.withValues(alpha: 0.8)
            : AppTheme.deepBlack.withValues(alpha: 0.12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          splashColor: isDark
              ? AppTheme.pureWhite.withValues(alpha: 0.06)
              : AppTheme.vibrantBlue.withValues(alpha: 0.08),
          highlightColor: isDark
              ? AppTheme.pureWhite.withValues(alpha: 0.03)
              : AppTheme.vibrantBlue.withValues(alpha: 0.04),
          child: Container(
            padding: padding ?? const EdgeInsets.all(AppTheme.space16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              border: isDark
                  ? Border.all(
                      color: AppTheme.darkGrey.withValues(alpha: 0.3),
                      width: 0.5,
                    )
                  : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
