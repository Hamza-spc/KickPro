import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/router/app_router.dart';
import 'package:kickpro/core/theme/app_colors.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Admin',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    onPressed: () => logout(ref),
                    icon: const Icon(Icons.logout, color: AppColors.textHint),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Drill validation is done via API for now. Use Postman or curl to approve player submissions.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Admin endpoints', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                    SizedBox(height: 8),
                    Text('GET  /api/v1/drills/admin/submissions/pending', style: TextStyle(color: AppColors.accent, fontSize: 12)),
                    SizedBox(height: 4),
                    Text('PUT  /api/v1/drills/admin/submissions/{id}/review', style: TextStyle(color: AppColors.accent, fontSize: 12)),
                    SizedBox(height: 12),
                    Text(
                      'Body: { "status": "APPROVED", "score": 85 }',
                      style: TextStyle(color: AppColors.textHint, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
