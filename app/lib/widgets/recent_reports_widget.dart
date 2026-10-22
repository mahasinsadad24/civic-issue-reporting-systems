import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../styles/app_theme.dart';
import '../models/report.dart';
import '../providers/reports_provider.dart';

class RecentReportsWidget extends StatefulWidget {
  final VoidCallback? onReportIssuePressed;

  const RecentReportsWidget({
    super.key,
    this.onReportIssuePressed,
  });

  @override
  State<RecentReportsWidget> createState() => _RecentReportsWidgetState();
}

class _RecentReportsWidgetState extends State<RecentReportsWidget>
    with TickerProviderStateMixin {
  final List<AnimationController> _itemControllers = [];
  final List<Animation<double>> _itemAnimations = [];

  @override
  void dispose() {
    for (var controller in _itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeItemAnimations(int count) {
    // Clear existing animations if count changes or re-initializing
    for (var controller in _itemControllers) {
      controller.dispose();
    }
    _itemControllers.clear();
    _itemAnimations.clear();

    for (int i = 0; i < count; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      );
      final animation = CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
      );
      _itemControllers.add(controller);
      _itemAnimations.add(animation);
    }
  }

  void _animateItems() async {
    for (int i = 0; i < _itemControllers.length; i++) {
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 100));
        _itemControllers[i].forward();
      }
    }
  }

  void _showReportDetails(Report report) {
    // TODO: Navigate to details screen or show dialog
    // For now just show a snackbar or no-op
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing: ${report.title}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportsProvider>(
      builder: (context, reportsProvider, child) {
        final reports = reportsProvider.recentReports;
        final isLoading = reportsProvider.isLoading;

        // Initialize animations when reports change
        if (reports.isNotEmpty && _itemControllers.length != reports.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _initializeItemAnimations(reports.length);
            _animateItems();
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.history_rounded,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Recent Reports',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.neutral800,
                      ),
                ),
                const Spacer(),
                if (!isLoading && reports.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/reports');
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View All',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: AppTheme.primaryColor,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (isLoading)
              Column(
                children: List.generate(
                  3,
                  (index) => Container(
                    height: 120,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.neutral300.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
              )
            else if (reports.isEmpty)
              _buildEmptyState()
            else
              Column(
                children: reports.asMap().entries.map((entry) {
                  if (entry.key < _itemAnimations.length) {
                    return FadeTransition(
                      opacity: _itemAnimations[entry.key],
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(_itemAnimations[entry.key]),
                        child: _buildReportCard(entry.value, entry.key),
                      ),
                    );
                  }
                  return _buildReportCard(entry.value, entry.key); // Fallback
                }).toList(),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.neutral100.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.neutral200),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.assignment_add,
              size: 40,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No reports yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.neutral800,
                  letterSpacing: 0.5,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Keep your community clean and safe.\nStart by reporting your first civic issue.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.neutral600,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 24),
          if (widget.onReportIssuePressed != null)
            ElevatedButton.icon(
              onPressed: widget.onReportIssuePressed,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Report Issue'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                elevation: 4,
                shadowColor: AppTheme.primaryColor.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReportCard(Report report, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.neutral200.withValues(alpha: 0.5)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showReportDetails(report),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildReportContent(report),
          ),
        ),
      ),
    );
  }

  Widget _buildReportContent(Report report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    _getCategoryColor(report.category).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _getCategoryIcon(report.category),
                color: _getCategoryColor(report.category),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          report.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.neutral800,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusChip(report.status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (report.description != null)
                    Text(
                      report.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.neutral600,
                            height: 1.4,
                          ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: AppTheme.neutral500.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(report.date),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.neutral500,
                            ),
                      ),
                      if (report.location != null) ...[
                        const SizedBox(width: 12),
                        Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: AppTheme.neutral500.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            report.location!,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.neutral500,
                                    ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(ReportStatus status) {
    Color color;
    String label;

    switch (status) {
      case ReportStatus.sent:
        color = AppTheme.primaryColor;
        label = 'Pending';
        break;
      case ReportStatus.received:
        color = AppTheme.warningColor;
        label = 'Received';
        break;
      case ReportStatus.resolved:
        color = AppTheme.successColor;
        label = 'Resolved';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Power Outage':
        return Icons.electric_bolt_rounded;
      case 'Water Leakage':
        return Icons.water_drop_rounded;
      case 'Road Damage':
        return Icons.add_road_rounded;
      case 'Streetlight Issue':
        return Icons.lightbulb_rounded;
      case 'Sewer Clogging':
        return Icons.plumbing_rounded;
      case 'Waste Management':
        return Icons.delete_outline_rounded;
      default:
        return Icons.report_problem_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    // You can customize colors per category if desired
    return AppTheme.primaryColor;
  }

  String _formatDate(String dateString) {
    // Basic date formatting, assuming dateString is readable or ISO
    // Implementation depends on actual date format in Report model
    return dateString;
  }
}
