import 'package:flutter/material.dart';
import 'package:kickpro/core/l10n/app_translations.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/shared/models/search_models.dart';

class BookmarksSplitCompareScreen extends StatefulWidget {
  const BookmarksSplitCompareScreen({
    super.key,
    required this.left,
    required this.right,
  });

  final PlayerSearchResult left;
  final PlayerSearchResult right;

  @override
  State<BookmarksSplitCompareScreen> createState() => _BookmarksSplitCompareScreenState();
}

class _BookmarksSplitCompareScreenState extends State<BookmarksSplitCompareScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  late final Animation<double> _stage1;
  late final Animation<double> _stage2;
  late final Animation<double> _stage3;
  late final Animation<double> _stage4;
  late final Animation<double> _stage5;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
      ..forward();

    _stage1 = CurvedAnimation(parent: _c, curve: const Interval(0.00, 0.22, curve: Curves.easeOut));
    _stage2 = CurvedAnimation(parent: _c, curve: const Interval(0.18, 0.42, curve: Curves.easeOut));
    _stage3 = CurvedAnimation(parent: _c, curve: const Interval(0.38, 0.60, curve: Curves.easeOut));
    _stage4 = CurvedAnimation(parent: _c, curve: const Interval(0.56, 0.78, curve: Curves.easeOut));
    _stage5 = CurvedAnimation(parent: _c, curve: const Interval(0.74, 1.00, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  ),
                  Expanded(
                    child: Text(
                      context.tr.comparePlayers,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _CompareHalf(
                      sideColor: const Color(0xFF1E3A5F),
                      player: widget.left,
                      stage1: _stage1,
                      stage2: _stage2,
                      stage3: _stage3,
                      stage4: _stage4,
                      stage5: _stage5,
                    ),
                  ),
                  Container(width: 1, color: AppColors.border.withValues(alpha: 0.6)),
                  Expanded(
                    child: _CompareHalf(
                      sideColor: AppColors.primary.withValues(alpha: 0.35),
                      player: widget.right,
                      stage1: _stage1,
                      stage2: _stage2,
                      stage3: _stage3,
                      stage4: _stage4,
                      stage5: _stage5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompareHalf extends StatelessWidget {
  const _CompareHalf({
    required this.player,
    required this.sideColor,
    required this.stage1,
    required this.stage2,
    required this.stage3,
    required this.stage4,
    required this.stage5,
  });

  final PlayerSearchResult player;
  final Color sideColor;
  final Animation<double> stage1;
  final Animation<double> stage2;
  final Animation<double> stage3;
  final Animation<double> stage4;
  final Animation<double> stage5;

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final avatar = player.profilePhotoUrl;

    Widget line(Animation<double> a, Widget child) {
      return FadeTransition(
        opacity: a,
        child: SlideTransition(
          position: a.drive(Tween(begin: const Offset(0, 0.06), end: Offset.zero)),
          child: child,
        ),
      );
    }

    return Container(
      color: sideColor.withValues(alpha: 0.12),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          line(
            stage1,
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.surface,
                  backgroundImage: (avatar != null && avatar.isNotEmpty) ? NetworkImage(avatar) : null,
                  child: (avatar == null || avatar.isEmpty)
                      ? Text(
                          player.fullName.isNotEmpty ? player.fullName[0].toUpperCase() : '?',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    player.fullName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          line(
            stage2,
            _StatPill(
              label: tr.positionLabel(player.position),
              value: '${player.city} · ${tr.nYearsOld(player.age)}',
            ),
          ),
          const SizedBox(height: 10),
          line(
            stage3,
            _StatPill(
              icon: Icons.sports_soccer_outlined,
              label: tr.matches,
              value: '${player.approvedMatchCount}',
            ),
          ),
          const SizedBox(height: 10),
          line(
            stage4,
            _StatPill(
              icon: Icons.verified_outlined,
              label: tr.certs,
              value: '${player.certificationCount}',
            ),
          ),
          const SizedBox(height: 10),
          line(
            stage5,
            _StatPill(
              icon: Icons.bolt,
              label: tr.score,
              value: '${player.credibilityScore.round()}/100',
              valueColor: AppColors.accent,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData? icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppColors.textHint),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

