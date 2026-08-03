import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../styles/app_styles.dart';
import 'package:xaneo/l10n/app_localizations.dart';

/// Плавающая навигационная панель без дорогого backdrop blur.
class LiquidGlassNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const LiquidGlassNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(left: 32, right: 32, bottom: 16),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xF2141416),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 16) / 3;
              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      alignment: _getAlignment(selectedIndex),
                      child: Container(
                        width: itemWidth - 8,
                        height: 40,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _NavItem(
                          icon: FontAwesomeIcons.solidComment,
                          label: AppLocalizations.of(context)?.chaty_19ad ??
                              'Fallback',
                          isSelected: selectedIndex == 0,
                          onTap: () => onDestinationSelected(0),
                        ),
                      ),
                      Expanded(
                        child: _NavItem(
                          icon: FontAwesomeIcons.users,
                          label: AppLocalizations.of(context)?.kontakty_7576 ??
                              'Fallback',
                          isSelected: selectedIndex == 1,
                          onTap: () => onDestinationSelected(1),
                        ),
                      ),
                      Expanded(
                        child: _NavItem(
                          icon: FontAwesomeIcons.gear,
                          label: AppLocalizations.of(context)?.nastroyki_c919 ??
                              'Fallback',
                          isSelected: selectedIndex == 2,
                          onTap: () => onDestinationSelected(2),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Получить выравнивание для индикатора в зависимости от индекса
  Alignment _getAlignment(int index) {
    switch (index) {
      case 0:
        return Alignment.centerLeft;
      case 1:
        return Alignment.center;
      case 2:
        return Alignment.centerRight;
      default:
        return Alignment.centerLeft;
    }
  }
}

/// Элемент навигационной панели
class _NavItem extends StatelessWidget {
  final FaIconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              child: FaIcon(
                icon,
                size: isSelected ? 24 : 22,
                color: isSelected
                    ? AppStyles.textPrimaryColor
                    : AppStyles.textMutedColor,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                fontSize: isSelected ? 10 : 9,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppStyles.textPrimaryColor
                    : AppStyles.textMutedColor,
                fontFamily: AppStyles.fontFamily,
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
