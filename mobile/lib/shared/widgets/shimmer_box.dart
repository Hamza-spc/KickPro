import 'package:flutter/material.dart';
import 'package:kickpro/core/theme/app_colors.dart';

class ShimmerBox extends StatefulWidget {
  const ShimmerBox({super.key, required this.height, this.width, this.radius = 8});

  final double height;
  final double? width;
  final double radius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1 + _controller.value * 2, 0),
              end: const Alignment(1, 0),
              colors: const [
                AppColors.surface,
                Color(0xFF1A2332),
                AppColors.surface,
              ],
            ),
          ),
        );
      },
    );
  }
}
