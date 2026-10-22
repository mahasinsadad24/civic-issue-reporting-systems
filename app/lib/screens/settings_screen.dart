import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../styles/app_theme.dart';
import '../widgets/top_accent_strip.dart';
import '../providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 3),
          child: Column(
            children: [
              const SafeArea(
                bottom: false,
                child: TopAccentStrip(),
              ),
              AppBar(
                primary: false, // Prevent double-padding
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text('Settings'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
        body: Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionHeader(context, 'Appearance'),
                _buildThemeSelector(context, settings),
                _buildFontScaleSelector(context, settings),
                const SizedBox(height: 24),
                _buildSectionHeader(context, 'Notifications'),
                _buildNotificationSwitch(context, settings),
                const SizedBox(height: 24),
                _buildSectionHeader(context, 'About'),
                _buildAboutTile(context),
                const SizedBox(height: 32),
                _buildLogoutButton(context),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
      ),
    );
  }

  // ... (keeping other build methods unchanged) ...

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        onPressed: () async {
          final shouldLogout = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Log Out'),
              content: const Text('Are you sure you want to log out?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Log Out',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );

          if (shouldLogout == true && context.mounted) {
            await context.read<AuthProvider>().signOut();
            // AuthWrapper will handle navigation
            if (context.mounted) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.red.shade200),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded),
            SizedBox(width: 8),
            Text(
              'Log Out',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context, SettingsProvider settings) {
    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          RadioListTile<ThemeMode>(
            title: const Text('System Default'),
            value: ThemeMode.system,
            // ignore: deprecated_member_use
            groupValue: settings.themeMode,
            // ignore: deprecated_member_use
            onChanged: (mode) => settings.setThemeMode(mode!),
            activeColor: AppTheme.primaryColor,
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Light Mode'),
            value: ThemeMode.light,
            // ignore: deprecated_member_use
            groupValue: settings.themeMode,
            // ignore: deprecated_member_use
            onChanged: (mode) => settings.setThemeMode(mode!),
            activeColor: AppTheme.primaryColor,
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Dark Mode'),
            value: ThemeMode.dark,
            // ignore: deprecated_member_use
            groupValue: settings.themeMode,
            // ignore: deprecated_member_use
            onChanged: (mode) => settings.setThemeMode(mode!),
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildFontScaleSelector(
      BuildContext context, SettingsProvider settings) {
    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Font Size',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('A', style: TextStyle(fontSize: 12)),
                Expanded(
                  child: Slider(
                    value: settings.fontScale,
                    min: 0.85,
                    max: 1.15,
                    divisions: 3,
                    label: _getFontLabel(settings.fontScale),
                    activeColor: AppTheme.primaryColor,
                    onChanged: (value) => settings.setFontScale(value),
                  ),
                ),
                const Text('A',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
            Center(
              child: Text(
                _getFontLabel(settings.fontScale),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppTheme.neutral600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFontLabel(double scale) {
    if (scale <= 0.85) return 'Small';
    if (scale >= 1.15) return 'Large';
    return 'Normal';
  }

  Widget _buildNotificationSwitch(
      BuildContext context, SettingsProvider settings) {
    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        title: const Text('Push Notifications'),
        subtitle: const Text('Receive updates about your reports'),
        value: settings.enableNotifications,
        onChanged: (value) => settings.setNotifications(value),
        activeThumbColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildAboutTile(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.info_outline_rounded,
            color: AppTheme.primaryColor),
        title: const Text('Version'),
        trailing: Text(
          '1.0.0',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.neutral600,
              ),
        ),
      ),
    );
  }
}
