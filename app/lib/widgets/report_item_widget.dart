import 'package:flutter/material.dart';
import '../models/report.dart';
import '../styles/app_theme.dart';

class ReportItemWidget extends StatelessWidget {
  final Report report;
  final bool detailed;

  const ReportItemWidget({
    super.key,
    required this.report,
    this.detailed = false,
  });

  @override
  Widget build(BuildContext context) {
    if (detailed) {
      return _buildDetailedItem();
    }
    return _buildCompactItem();
  }

  Widget _buildDetailedItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _getStatusBackgroundColor(report.status), // Status Tint
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStatusColor(report.status).withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor(report.status).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Navigate to details if needed
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _getCategoryIcon(report.category),
                        color: _getStatusColor(
                            report.status), // Icon matches status
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  report.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.neutral900,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                              _buildStatusBadge(report.status),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            report.date,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.neutral600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (report.description != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    report.description!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.neutral700,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (report.location != null)
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: AppTheme.neutral500,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                report.location!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.neutral600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (report.hasAttachments)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.neutral300,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.attach_file_rounded,
                              size: 14,
                              color: AppTheme.neutral600,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Photo',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.neutral700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.neutral200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(report.category),
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.neutral800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        report.date,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.neutral500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                            color: AppTheme.neutral300, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        report.status.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(report.status),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ReportStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStatusColor(status).withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: _getStatusColor(status),
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
      case 'Public Safety':
        return Icons.shield_rounded;
      case 'Sanitation':
        return Icons.cleaning_services_rounded;
      default:
        return Icons.report_problem_rounded;
    }
  }

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.sent:
        return AppTheme.primaryColor;
      case ReportStatus.received:
        return AppTheme
            .warningColor; // Use warning/orange for in-progress feeling
      case ReportStatus.resolved:
        return AppTheme.successColor;
    }
  }

  Color _getStatusBackgroundColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.sent:
        return AppTheme.infoLight;
      case ReportStatus.received:
        return AppTheme.warningLight;
      case ReportStatus.resolved:
        return AppTheme.successLight;
    }
  }
}
