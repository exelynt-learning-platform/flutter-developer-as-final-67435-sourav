import 'package:flutter/material.dart';
import '../../domain/entities/employee.dart';

class EmployeeCard extends StatelessWidget {
  final Employee employee;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EmployeeCard({
    super.key,
    required this.employee,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------------------------------------------------
            // Header
            // ---------------------------------------------------------

            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  child: Text(
                    _initials(employee.name),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${employee.id}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ---------------------------------------------------------
            // Employee details
            // ---------------------------------------------------------

            _InfoRow(
              icon: Icons.email_outlined,
              label: employee.email,
            ),

            const SizedBox(height: 8),

            _InfoRow(
              icon: Icons.phone_outlined,
              label: employee.mobile,
            ),

            const SizedBox(height: 8),

            _InfoRow(
              icon: Icons.public_outlined,
              label: employee.country,
            ),

            const SizedBox(height: 8),

            _InfoRow(
              icon: Icons.location_on_outlined,
              label: _location,
            ),

            const Spacer(),

            const SizedBox(height: 12),

            const Divider(height: 1),

            const SizedBox(height: 8),

            // ---------------------------------------------------------
            // Direct actions
            // ---------------------------------------------------------

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Tooltip(
                  message: 'View employee',
                  child: IconButton(
                    onPressed: onView,
                    icon: const Icon(
                      Icons.visibility_outlined,
                    ),
                    tooltip: 'View employee',
                  ),
                ),

                Tooltip(
                  message: 'Edit employee',
                  child: IconButton(
                    onPressed: onEdit,
                    icon: const Icon(
                      Icons.edit_outlined,
                    ),
                    tooltip: 'Edit employee',
                  ),
                ),

                Tooltip(
                  message: 'Delete employee',
                  child: IconButton(
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.delete_outline,
                    ),
                    tooltip: 'Delete employee',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String get _location {
    final parts = <String>[];

    if (employee.state.trim().isNotEmpty) {
      parts.add(employee.state.trim());
    }

    if (employee.district.trim().isNotEmpty) {
      parts.add(employee.district.trim());
    }

    if (parts.isEmpty) {
      return 'Location not available';
    }

    return parts.join(', ');
  }

  String _initials(String name) {
    final value = name.trim();

    if (value.isEmpty) {
      return '?';
    }

    final parts = value
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}'
        '${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}

// -------------------------------------------------------------------
// Employee information row
// -------------------------------------------------------------------

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label.isEmpty ? 'Not available' : label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
