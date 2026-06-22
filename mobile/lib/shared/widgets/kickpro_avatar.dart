import 'package:flutter/material.dart';
import 'package:kickpro/core/theme/app_colors.dart';

/// User profile avatar with network photo and name-initial fallback.
class KickproAvatar extends StatelessWidget {
  const KickproAvatar({
    super.key,
    this.photoUrl,
    required this.name,
    this.radius = 20,
    this.backgroundColor = AppColors.primary,
    this.fallbackTextColor = Colors.white,
    this.fallbackFontSize,
  });

  final String? photoUrl;
  final String name;
  final double radius;
  final Color backgroundColor;
  final Color fallbackTextColor;
  final double? fallbackFontSize;

  bool get _hasPhoto => photoUrl != null && photoUrl!.trim().isNotEmpty;

  String get _initial {
    final trimmed = name.trim();
    return trimmed.isNotEmpty ? trimmed[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPhoto) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        child: Text(
          _initial,
          style: TextStyle(
            color: fallbackTextColor,
            fontWeight: FontWeight.w700,
            fontSize: fallbackFontSize ?? radius * 0.85,
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: ClipOval(
        child: Image.network(
          photoUrl!,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => ColoredBox(
            color: backgroundColor,
            child: Center(
              child: Text(
                _initial,
                style: TextStyle(
                  color: fallbackTextColor,
                  fontWeight: FontWeight.w700,
                  fontSize: fallbackFontSize ?? radius * 0.85,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
