import 'package:flutter/material.dart';
import '../../domain/entities/employee.dart';

class EmployeeCard extends StatelessWidget {
  final Employee employee;
  final VoidCallback onView, onEdit, onDelete;

  const EmployeeCard(
      {super.key,
      required this.employee,
      required this.onView,
      required this.onEdit,
      required this.onDelete});

  @override
  Widget build(BuildContext context) =>
      Card(
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(
                  child: Text(employee.name.isEmpty
                      ? '?'
                      : employee.name[0].toUpperCase())),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(employee.name,
                        style: Theme.of(context).textTheme.titleMedium),
                    Text('#${employee.id}',
                        style: Theme.of(context).textTheme.bodySmall)
                  ])),
              PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'view') onView();
                    if (v == 'edit') onEdit();
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder: (_) => const [
                        PopupMenuItem(value: 'view', child: Text('View')),
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete'))
                      ])
            ]),
            const Divider(height: 24),
            _line(Icons.email_outlined, employee.email),
            _line(Icons.phone_outlined, employee.mobile),
            _line(Icons.location_on_outlined,
                '${employee.district}, ${employee.state}, ${employee.country}')
          ])));

  Widget _line(IconData i, String t) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Icon(i, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(t, overflow: TextOverflow.ellipsis))
      ]));
}
