import 'dart:ui';
import 'package:flutter/material.dart';
import '../styles/app_theme.dart';

class BottomNavWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      decoration: BoxDecoration(
        color: AppTheme.neutral100.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(
                  icon: Icons.home_rounded,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.grid_view_rounded,
                  activeIcon: Icons.grid_view_rounded,
                  label: 'Reports',
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.person_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Profile',
                  index: 2,
                ),
                _buildNavItem(
                  icon: Icons.chat_bubble_rounded,
                  activeIcon: Icons.chat_bubble_rounded,
                  label: 'Chat',
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = currentIndex == index;
    // Active: White icon on Blue Pill. Inactive: Grey icon.
    final color = isActive ? Colors.white : AppTheme.neutral500;
    final bgColor = isActive ? AppTheme.primaryColor : Colors.transparent;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 20 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(30), // Pill shape
        ),
        child: Row(
          // Row for "Pill with Label" if simplified, or Column?
          // Plan said: "Add subtle background pill ONLY for active tab"
          // Let's stick to Column layout but with the Pill background around the ICON/Label group?
          // Actually, standard M3 is "pill around icon".
          // But user wants "Pill Nav" which often implies the whole item.
          // Let's do: Pill around the Icon+Text for active state.
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: color,
              size: 24,
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
