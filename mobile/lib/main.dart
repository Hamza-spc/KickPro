import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/router/app_router.dart';
import 'package:kickpro/core/theme/app_theme.dart';
import 'package:kickpro/features/auth/screens/login_screen.dart';
import 'package:kickpro/shared/widgets/shimmer_box.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: KickproApp()));
}

class KickproApp extends ConsumerWidget {
  const KickproApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final session = ref.watch(sessionBootstrapProvider);

    return MaterialApp.router(
      title: 'KickPro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: router,
      builder: (context, child) {
        return session.when(
          loading: () => const Scaffold(
            body: Center(child: ShimmerBox(height: 48, width: 160)),
          ),
          error: (_, _) => child ?? const LoginScreen(),
          data: (hasToken) {
            if (hasToken) {
              final location = router.state.matchedLocation;
              if (location == '/login' || location == '/profile') {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  navigateAfterAuth(ref);
                });
              }
            }
            return child ?? const SizedBox.shrink();
          },
        );
      },
    );
  }
}
