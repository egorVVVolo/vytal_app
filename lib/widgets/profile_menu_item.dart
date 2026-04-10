import 'package:flutter/material.dart';
import '../theme/colors.dart';

class ProfileMenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive; // Для кнопки "Log Out" (красная)

  const ProfileMenuItem({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: VytalColors.textPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: VytalColors.textPrimary.withValues(alpha: 0.03),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive
                ? VytalColors.warningAccent.withValues(alpha: 0.1)
                : VytalColors.primaryAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(
            icon,
            color: isDestructive
                ? VytalColors.warningAccent
                : VytalColors.primaryAccent,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? VytalColors.warningAccent : Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}
