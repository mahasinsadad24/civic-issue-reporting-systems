import 'package:flutter/material.dart';
import '../models/report.dart';
import '../styles/app_theme.dart';

class StatusBarWidget extends StatelessWidget {
  final ReportStatus currentStatus;
  final bool compact;

  const StatusBarWidget({
    super.key,
    required this.currentStatus,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactStatusBar();
    }
    return _buildFullStatusBar();
  }

  Widget _buildCompactStatusBar() {
    final stages = _getStages();
    final currentStageIndex = _getCurrentStageIndex();

    return Row(
      children: [
        Row(
          children: stages.asMap().entries.map((entry) {
            final index = entry.key;
            final stage = entry.value;
            final isActive = index <= currentStageIndex;
            final isCurrent = index == currentStageIndex;

            return Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isActive
                        ? (isCurrent
                            ? AppTheme.primaryColor
                            : AppTheme.successColor)
                        : AppTheme.neutral300,
                    border: Border.all(
                      color: isActive
                          ? (isCurrent
                              ? AppTheme.primaryColor
                              : AppTheme.successColor)
                          : AppTheme.neutral400,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isActive && index < currentStageIndex
                        ? Icons.check
                        : stage.icon,
                    size: 10,
                    color: isActive ? AppTheme.neutral100 : AppTheme.neutral600,
                  ),
                ),
                if (index < stages.length - 1)
                  Container(
                    width: 16,
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: index < currentStageIndex
                          ? AppTheme.successColor
                          : AppTheme.neutral300,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
              ],
            );
          }).toList(),
        ),
        const SizedBox(width: 6),
        Text(
          currentStatus.name.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.neutral700,
          ),
        ),
      ],
    );
  }

  Widget _buildFullStatusBar() {
    final stages = _getStages();
    final currentStageIndex = _getCurrentStageIndex();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.neutral100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ISSUE STATUS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.neutral600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          ...stages.asMap().entries.map((entry) {
            final index = entry.key;
            final stage = entry.value;
            final isActive = index <= currentStageIndex;
            final isCurrent = index == currentStageIndex;

            return Column(
              children: [
                Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isActive
                                ? (isCurrent
                                    ? AppTheme.primaryColor
                                    : AppTheme.successColor)
                                : AppTheme.neutral300,
                            border: Border.all(
                              color: isActive
                                  ? (isCurrent
                                      ? AppTheme.primaryColor
                                      : AppTheme.successColor)
                                  : AppTheme.neutral400,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: isCurrent
                                ? [
                                    BoxShadow(
                                      color: AppTheme.primaryColor.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            isActive && index < currentStageIndex
                                ? Icons.check
                                : stage.icon,
                            size:
                                isActive && index < currentStageIndex ? 16 : 14,
                            color: isActive
                                ? AppTheme.neutral100
                                : AppTheme.neutral600,
                          ),
                        ),
                        if (index < stages.length - 1)
                          Container(
                            width: 2,
                            height: 24,
                            margin: const EdgeInsets.only(top: 6),
                            decoration: BoxDecoration(
                              color: index < currentStageIndex
                                  ? AppTheme.successColor
                                  : AppTheme.neutral300,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                stage.label,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isActive
                                      ? AppTheme.neutral800
                                      : AppTheme.neutral500,
                                ),
                              ),
                              if (isCurrent) ...[
                                const SizedBox(width: 8),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            stage.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: isActive
                                  ? AppTheme.neutral600
                                  : AppTheme.neutral400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (index < stages.length - 1) const SizedBox(height: 10),
              ],
            );
          }),
        ],
      ),
    );
  }

  List<StatusStage> _getStages() {
    return [
      StatusStage(
        key: ReportStatus.sent,
        label: 'Sent',
        icon: Icons.send,
        description: 'Report submitted successfully',
      ),
      StatusStage(
        key: ReportStatus.received,
        label: 'Received',
        icon: Icons.people,
        description: 'Acknowledged by concerned department',
      ),
      StatusStage(
        key: ReportStatus.resolved,
        label: 'Resolved',
        icon: Icons.check_circle,
        description: 'Issue has been resolved',
      ),
    ];
  }

  int _getCurrentStageIndex() {
    final stages = _getStages();
    return stages.indexWhere((stage) => stage.key == currentStatus);
  }
}

class StatusStage {
  final ReportStatus key;
  final String label;
  final IconData icon;
  final String description;

  StatusStage({
    required this.key,
    required this.label,
    required this.icon,
    required this.description,
  });
}
