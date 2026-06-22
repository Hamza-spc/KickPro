import 'package:flutter/material.dart';
import 'package:kickpro/core/l10n/app_translations.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/shared/models/search_models.dart';
import 'package:kickpro/shared/widgets/kickpro_avatar.dart';

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
    final tr = context.tr;

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
                      tr.comparePlayers,
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
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                children: [
                  _AnimatedRow(
                    animation: _stage1,
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _PlayerHeader(
                              player: widget.left,
                              tint: const Color(0xFF1E3A5F),
                            ),
                          ),
                          _VerticalDivider(),
                          Expanded(
                            child: _PlayerHeader(
                              player: widget.right,
                              tint: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _AnimatedRow(
                    animation: _stage2,
                    child: _SyncedStatRow(
                      left: _StatCell.text(
                        tr.positionLabel(widget.left.position),
                        fontWeight: FontWeight.w700,
                      ),
                      right: _StatCell.text(
                        tr.positionLabel(widget.right.position),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _AnimatedRow(
                    animation: _stage2,
                    child: _SyncedStatRow(
                      left: _StatCell.text(
                        '${widget.left.city} · ${tr.nYearsOld(widget.left.age)}',
                        color: AppColors.textSecondary,
                      ),
                      right: _StatCell.text(
                        '${widget.right.city} · ${tr.nYearsOld(widget.right.age)}',
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _AnimatedRow(
                    animation: _stage3,
                    child: _SyncedStatRow(
                      left: _StatCell.metric(
                        icon: Icons.sports_soccer_outlined,
                        label: tr.matches,
                        value: '${widget.left.approvedMatchCount}',
                      ),
                      right: _StatCell.metric(
                        icon: Icons.sports_soccer_outlined,
                        label: tr.matches,
                        value: '${widget.right.approvedMatchCount}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _AnimatedRow(
                    animation: _stage4,
                    child: _SyncedStatRow(
                      left: _StatCell.metric(
                        icon: Icons.verified_outlined,
                        label: tr.certs,
                        value: '${widget.left.certificationCount}',
                      ),
                      right: _StatCell.metric(
                        icon: Icons.verified_outlined,
                        label: tr.certs,
                        value: '${widget.right.certificationCount}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _AnimatedRow(
                    animation: _stage5,
                    child: _SyncedStatRow(
                      left: _StatCell.metric(
                        icon: Icons.bolt,
                        label: tr.score,
                        value: '${widget.left.credibilityScore.round()}/100',
                        valueColor: AppColors.accent,
                      ),
                      right: _StatCell.metric(
                        icon: Icons.bolt,
                        label: tr.score,
                        value: '${widget.right.credibilityScore.round()}/100',
                        valueColor: AppColors.accent,
                      ),
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

class _AnimatedRow extends StatelessWidget {
  const _AnimatedRow({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: animation.drive(Tween(begin: const Offset(0, 0.06), end: Offset.zero)),
        child: child,
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      color: AppColors.border.withValues(alpha: 0.6),
    );
  }
}

class _PlayerHeader extends StatelessWidget {
  const _PlayerHeader({required this.player, required this.tint});

  final PlayerSearchResult player;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 72),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          KickproAvatar(
            radius: 24,
            photoUrl: player.profilePhotoUrl,
            name: player.fullName,
            backgroundColor: AppColors.surface,
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
                fontSize: 15,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncedStatRow extends StatelessWidget {
  const _SyncedStatRow({required this.left, required this.right});

  final _StatCell left;
  final _StatCell right;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: left),
          _VerticalDivider(),
          Expanded(child: right),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell._({
    required this.child,
  });

  factory _StatCell.text(
    String text, {
    Color color = AppColors.textPrimary,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return _StatCell._(
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: color, fontWeight: fontWeight, fontSize: 14, height: 1.25),
        ),
      ),
    );
  }

  factory _StatCell.metric({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return _StatCell._(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textHint),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: child,
    );
  }
}
