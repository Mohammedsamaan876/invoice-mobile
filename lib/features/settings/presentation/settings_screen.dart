import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final user = ref.watch(currentUserProvider);
    final isAuthenticated = user != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Account / Auth Section
          if (isAuthenticated) ...[
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withAlpha(25),
                child: const Icon(Icons.person_rounded, color: AppColors.primary),
              ),
              title: Text(
                user.fullName ?? user.email,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                user.fullName != null ? '${user.email} • Connected' : 'Connected to Supabase',
                style: const TextStyle(color: AppColors.success),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                tooltip: 'Sign Out',
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).signOut();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Signed out successfully'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.account_circle_outlined, color: AppColors.primary),
              title: const Text('Sign In / Register', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Connect to Supabase for cloud sync'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, AppRoutes.login),
            ),
          ],
          const Divider(),

          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: const Text('Products & Services'),
            subtitle: const Text('Manage your item catalog and pricing'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, AppRoutes.products),
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.business_outlined),
            title: const Text('Company Profile'),
            subtitle: const Text('Manage company details, logo, and signature'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, AppRoutes.company),
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.brightness_medium_outlined),
            title: const Text('Theme Mode'),
            subtitle: Text(themeMode.name.toUpperCase()),
            trailing: PopupMenuButton<ThemeMode>(
              initialValue: themeMode,
              onSelected: (mode) {
                ref.read(themeModeProvider.notifier).setThemeMode(mode);
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: ThemeMode.system,
                  child: Text('System'),
                ),
                PopupMenuItem(
                  value: ThemeMode.light,
                  child: Text('Light'),
                ),
                PopupMenuItem(
                  value: ThemeMode.dark,
                  child: Text('Dark'),
                ),
              ],
            ),
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: const Text('${AppConstants.appName} v${AppConstants.appVersion}'),
          ),
        ],
      ),
    );
  }
}
