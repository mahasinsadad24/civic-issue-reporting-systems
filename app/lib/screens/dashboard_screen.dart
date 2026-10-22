import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../widgets/report_form_widget.dart';
import '../widgets/recent_reports_widget.dart';
import '../widgets/bottom_nav_widget.dart';
import '../styles/app_theme.dart';
import '../widgets/top_accent_strip.dart';
import 'package:civic_issue_reporter/l10n/generated/app_localizations.dart';
import '../providers/auth_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: AppTheme.animationDuration,
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: AppTheme.animationCurve,
    );
    _fabAnimationController.forward();
    // Profile data is already managed by AuthProvider
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        // Already on dashboard
        break;
      case 1:
        Navigator.pushNamed(context, '/reports');
        break;
      case 2:
        Navigator.pushNamed(context, '/profile');
        break;
      case 3:
        Navigator.pushNamed(context, '/chatbot');
        break;
    }
  }

  void _showAddReportDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: AppTheme.neutral200,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                AppLocalizations.of(context)!.reportNewIssue,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ReportFormWidget(
                  onSubmitted: (report) {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.neutral100.withValues(alpha: 0.9),
          borderRadius:
              const BorderRadius.horizontal(right: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 30,
              offset: const Offset(5, 0),
            ),
          ],
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
                decoration: BoxDecoration(
                  color: AppTheme.neutral100, // White background
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.neutral300.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                ),
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const CircleAvatar(
                            radius: 36,
                            backgroundColor: AppTheme.neutral200,
                            child: Icon(
                              Icons.person_rounded,
                              size: 40,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          authProvider.userName,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: AppTheme.neutral800, // Dark text
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          authProvider.userEmail,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.neutral600, // Grey text
                                    letterSpacing: 0.5,
                                  ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Expanded(
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  children: [
                    _buildDrawerItem(
                      icon: Icons.assignment_rounded,
                      title: AppLocalizations.of(context)!.myReports,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/reports');
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildDrawerItem(
                      icon: Icons.support_agent_rounded,
                      title: AppLocalizations.of(context)!.helpSupport,
                      onTap: () {
                        Navigator.pop(context);
                        _showHelpDialog();
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildDrawerItem(
                      icon: Icons.settings_rounded,
                      title: AppLocalizations.of(context)!.settings,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/settings');
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Divider(
                        color: AppTheme.neutral300.withValues(alpha: 0.5),
                      ),
                    ),
                    _buildDrawerItem(
                      icon: Icons.logout_rounded,
                      title: AppLocalizations.of(context)!.logout,
                      onTap: () {
                        Navigator.pop(context);
                        _showLogoutDialog();
                      },
                      isDestructive: true,
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

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppTheme.errorColor : AppTheme.neutral700;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive
                    ? AppTheme.errorColor
                    : AppTheme.neutral500, // Simpler grey icons
                size: 22, // Slightly larger
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w500, // Less bold
                      letterSpacing: 0.2,
                    ),
              ),
              const Spacer(),
              if (!isDestructive)
                const Icon(
                  Icons.chevron_right_rounded, // Standard chevron
                  size: 20,
                  color: AppTheme.neutral400,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.help_outline_rounded, color: AppTheme.infoColor),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.helpSupport),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.helpTitle),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context)!.helpSteps),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.supportContact),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.logout_rounded, color: AppTheme.errorColor),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.logout),
          ],
        ),
        content: Text(AppLocalizations.of(context)!.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: Text(AppLocalizations.of(context)!.logout),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.neutral200,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: ClipRRect(
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(30)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.neutral100.withValues(alpha: 0.8),
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.only(top: 0), // Removed manual padding
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SafeArea(
                      bottom: false,
                      child: TopAccentStrip(),
                    ),
                    Expanded(
                      child: AppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        centerTitle: true,
                        scrolledUnderElevation:
                            0, // Prevent color change on scroll
                        primary:
                            false, // We handled the top padding manually via SafeArea above if needed,
                        // actually AppBar inside Column/Expanded might behave oddly with primary:true.
                        // Let's keep primary: true but check layout.
                        // Better: stack it?
                        // Let's try Column first. If AppBar is primary:true (default), it adds top padding.
                        // But we want Strip -> AppBar.
                        // If we use primary:false, AppBar has no top padding.
                        // So Strip (3px) + AppBar (56px) = 59px.
                        // PreferredSize is 80. Just enough room.
                        // Let's set primary: false.
                        leading: Builder(
                          builder: (context) => IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.neutral200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.grid_view_rounded,
                                color: AppTheme.neutral800,
                                size: 20,
                              ),
                            ),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          ),
                        ),
                        title: Column(
                          children: [
                            Text(
                              AppLocalizations.of(context)!
                                  .appTitle
                                  .toUpperCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2.0,
                                    color: AppTheme.primaryColor,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!
                                    .dashboardTitle
                                    .toUpperCase(),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                      fontSize: 8,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.neutral200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.notifications_none_rounded,
                                  color: AppTheme.neutral800,
                                  size: 20,
                                ),
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(AppLocalizations.of(context)!
                                        .notificationsEmpty),
                                    backgroundColor: AppTheme.infoColor,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        drawer: _buildDrawer(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              RecentReportsWidget(
                onReportIssuePressed: _showAddReportDialog,
              ),
              const SizedBox(height: 100), // Space for FAB
            ],
          ),
        ),
        floatingActionButton: ScaleTransition(
          scale: _fabAnimation,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.accentColor,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentColor.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              onPressed: _showAddReportDialog,
              backgroundColor: Colors.transparent,
              elevation: 0,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text(
                AppLocalizations.of(context)!.reportNewIssue,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              heroTag: 'main_fab',
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        bottomNavigationBar: BottomNavWidget(
          currentIndex: _currentIndex,
          onTap: _onBottomNavTap,
        ),
      ),
    );
  }
}
