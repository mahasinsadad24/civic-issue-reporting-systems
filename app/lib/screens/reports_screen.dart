import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/report.dart';
import '../widgets/report_item_widget.dart';
import '../widgets/bottom_nav_widget.dart';
import '../styles/app_theme.dart';
import '../providers/reports_provider.dart';
import '../widgets/top_accent_strip.dart';
import 'package:civic_issue_reporter/l10n/generated/app_localizations.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _currentIndex = 1;
  String _selectedStatus = 'all';
  String _searchTerm = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Report> _getFilteredReports(List<Report> reports) {
    return reports.where((report) {
      final matchesStatus =
          _selectedStatus == 'all' || report.status.name == _selectedStatus;
      final matchesSearch =
          report.title.toLowerCase().contains(_searchTerm.toLowerCase()) ||
              report.category.toLowerCase().contains(_searchTerm.toLowerCase());
      return matchesStatus && matchesSearch;
    }).toList();
  }

  Map<String, int> _getStatusCounts(List<Report> reports) {
    return {
      'all': reports.length,
      'sent': reports.where((r) => r.status == ReportStatus.sent).length,
      'received':
          reports.where((r) => r.status == ReportStatus.received).length,
      'resolved':
          reports.where((r) => r.status == ReportStatus.resolved).length,
    };
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/');
        break;
      case 1:
        // Already on reports
        break;
      case 2:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.neutral100,
      extendBody: true, // For floating bottom nav
      body: Consumer<ReportsProvider>(
        builder: (context, reportsProvider, child) {
          final reports = reportsProvider.reports;
          final filteredReports = _getFilteredReports(reports);
          final statusCounts = _getStatusCounts(reports);

          return Column(
            children: [
              // Header with search and filters - Clean White Surface
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                    child: Column(
                      children: [
                        const TopAccentStrip(),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.myReports,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.neutral900,
                                    letterSpacing: -0.5,
                                  ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${filteredReports.length} Active',
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Search Bar - Soft Grey Background
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.neutral200,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.transparent,
                            ),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() {
                                _searchTerm = value;
                              });
                            },
                            style: const TextStyle(
                              color: AppTheme.neutral800,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            cursorColor: AppTheme.primaryColor,
                            decoration: InputDecoration(
                              hintText:
                                  AppLocalizations.of(context)!.searchReports,
                              hintStyle: const TextStyle(
                                color: AppTheme.neutral500,
                                fontSize: 14,
                              ),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: AppTheme.neutral500,
                                size: 20,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Status Filter - Cleaner Chips
                        SizedBox(
                          height: 32,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: statusCounts.length,
                            itemBuilder: (context, index) {
                              final status = statusCounts.keys.elementAt(index);
                              final count = statusCounts[status]!;
                              final isSelected = _selectedStatus == status;

                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedStatus = status;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppTheme.primaryColor
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.transparent
                                            : AppTheme.neutral300,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          status == 'all'
                                              ? 'All Reports'
                                              : status.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? Colors.white
                                                : AppTheme.neutral600,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Colors.white
                                                    .withValues(alpha: 0.2)
                                                : AppTheme.neutral200,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            '$count',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected
                                                  ? Colors.white
                                                  : AppTheme.neutral600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Reports List
              Expanded(
                child: filteredReports.isEmpty
                    ? Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: const BoxDecoration(
                                  color: AppTheme.neutral200,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons
                                      .filter_list_off_rounded, // Specific icon
                                  size: 48,
                                  color: AppTheme.neutral500,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                AppLocalizations.of(context)!.noReportsFound,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: AppTheme.neutral700,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try clearing filters or searching for something else.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppTheme.neutral500,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                            16, 24, 16, 100), // Increased top padding
                        itemCount: filteredReports.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ReportItemWidget(
                              report: filteredReports[index],
                              detailed: true,
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavWidget(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }
}
