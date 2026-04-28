import 'package:flutter/material.dart';

enum PersonalDataType { vacation, sickLeave, salaryAdvance, dms, probation }

class PersonalDataCard extends StatelessWidget {
  const PersonalDataCard({
    super.key,
    required this.type,
    required this.title,
    required this.value,
    this.subtitle,
    this.date,
    this.onTap,
  });

  final PersonalDataType type;
  final String title;
  final String value;
  final String? subtitle;
  final DateTime? date;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = _iconForType(type);
    final color = _colorForType(type, theme);

    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              if (date != null) ...[
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatDate(date!),
                      style: theme.textTheme.labelMedium,
                    ),
                  ],
                ),
              ],
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForType(PersonalDataType type) {
    switch (type) {
      case PersonalDataType.vacation:
        return Icons.beach_access_outlined;
      case PersonalDataType.sickLeave:
        return Icons.local_hospital_outlined;
      case PersonalDataType.salaryAdvance:
        return Icons.payments_outlined;
      case PersonalDataType.dms:
        return Icons.health_and_safety_outlined;
      case PersonalDataType.probation:
        return Icons.badge_outlined;
    }
  }

  Color _colorForType(PersonalDataType type, ThemeData theme) {
    switch (type) {
      case PersonalDataType.vacation:
        return const Color(0xFF2196F3);
      case PersonalDataType.sickLeave:
        return const Color(0xFFFF9800);
      case PersonalDataType.salaryAdvance:
        return const Color(0xFF4CAF50);
      case PersonalDataType.dms:
        return const Color(0xFF9C27B0);
      case PersonalDataType.probation:
        return const Color(0xFF607D8B);
    }
  }

  String _formatDate(DateTime dt) {
    final months = [
      'янв', 'фев', 'мар', 'апр', 'май', 'июн',
      'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }
}