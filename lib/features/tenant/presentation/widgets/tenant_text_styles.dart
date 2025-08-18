import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class TenantTextStyles {
  // Headers for dark backgrounds - Enhanced visibility
  static TextStyle get headerOnDark => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white, // Pure white for maximum contrast
    shadows: [
      Shadow(
        color: Colors.black87,
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
      Shadow(
        color: Colors.black54,
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ],
  );

  static TextStyle get subHeaderOnDark => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppTheme.textOnDark,
    shadows: [
      Shadow(
        color: Colors.black54,
        blurRadius: 2,
      ),
    ],
  );

  // Body text for dark backgrounds
  static TextStyle get bodyOnDark => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppTheme.textOnDark,
    shadows: [
      Shadow(
        color: Colors.black54,
        blurRadius: 1,
      ),
    ],
  );

  static TextStyle get bodySecondaryOnDark => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppTheme.textSecondaryOnDark,
    shadows: [
      Shadow(
        color: Colors.black54,
        blurRadius: 1,
      ),
    ],
  );

  static TextStyle get captionOnDark => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppTheme.textSecondaryOnDark,
    shadows: [
      Shadow(
        color: Colors.black54,
        blurRadius: 1,
      ),
    ],
  );

  // Headers for light backgrounds
  static TextStyle get headerOnLight => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppTheme.textHighContrast,
  );

  static TextStyle get subHeaderOnLight => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppTheme.textHighContrast,
  );

  // Body text for light backgrounds
  static TextStyle get bodyOnLight => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppTheme.textPrimary,
  );

  static TextStyle get bodySecondaryOnLight => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppTheme.textMediumContrast,
  );

  static TextStyle get captionOnLight => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppTheme.textSecondary,
  );

  // Status badge styles
  static TextStyle statusBadgeStyle(Color color) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: color,
  );

  // Loading text for dark backgrounds
  static TextStyle get loadingTextOnDark => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppTheme.textOnDark,
    shadows: [
      Shadow(
        color: Colors.black54,
        blurRadius: 2,
      ),
    ],
  );

  // Empty state text for dark backgrounds
  static TextStyle get emptyStateTitleOnDark => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppTheme.textOnDark,
    shadows: [
      Shadow(
        color: Colors.black54,
        blurRadius: 2,
      ),
    ],
  );

  static TextStyle get emptyStateSubtitleOnDark => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppTheme.textSecondaryOnDark,
    shadows: [
      Shadow(
        color: Colors.black54,
        blurRadius: 2,
      ),
    ],
  );

  // Card title styles
  static TextStyle get cardTitleOnDark => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppTheme.textOnDark,
  );

  static TextStyle get cardSubtitleOnDark => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppTheme.textOnDark.withOpacity(0.8),
  );

  static TextStyle get cardTitleOnLight => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppTheme.textPrimary,
  );

  static TextStyle get cardSubtitleOnLight => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppTheme.textSecondary,
  );

  // Button text styles
  static TextStyle get buttonTextPrimary => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle get buttonTextSecondary => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppTheme.primaryColor,
  );

  // Tab text styles
  static TextStyle get tabLabelActive => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle get tabLabelInactive => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.grey[400],
  );

  // Input text styles
  static TextStyle get inputText => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppTheme.textPrimary,
  );

  static TextStyle get inputLabel => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppTheme.textSecondary,
  );

  static TextStyle get inputHint => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppTheme.textHint,
  );

  // Price text styles
  static TextStyle get priceText => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppTheme.landlordSuccess,
  );

  static TextStyle get priceCurrency => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppTheme.landlordSuccess,
  );

  // Error text styles
  static TextStyle get errorText => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppTheme.errorColor,
  );

  // Success text styles
  static TextStyle get successText => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppTheme.landlordSuccess,
  );

  // Warning text styles
  static TextStyle get warningText => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppTheme.landlordWarning,
  );

  // Create custom text style with better visibility
  static TextStyle createVisibleTextStyle({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    bool isDarkBackground = false,
    bool addShadow = false,
  }) {
    List<Shadow> shadows = [];
    
    if (isDarkBackground || addShadow) {
      shadows.add(
        const Shadow(
          color: Colors.black54,
          blurRadius: 2,
        ),
      );
    }

    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      shadows: shadows.isNotEmpty ? shadows : null,
    );
  }

  // Get appropriate text color based on background
  static Color getTextColor(bool isDarkBackground) {
    return isDarkBackground ? AppTheme.textOnDark : AppTheme.textPrimary;
  }

  static Color getSecondaryTextColor(bool isDarkBackground) {
    return isDarkBackground ? AppTheme.textSecondaryOnDark : AppTheme.textSecondary;
  }
}
