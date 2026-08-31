import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../domain/entities/employee.dart';
import '../bloc/employee_cubit.dart';
import '../widgets/employee_card.dart';
import '../widgets/employee_state_widgets.dart';
import 'employee_form_page.dart';

class EmployeeDashboardPage extends StatefulWidget {
  final AppUser user;
  final VoidCallback? onToggleTheme;

  const EmployeeDashboardPage({
    super.key,
    required this.user,
    this.onToggleTheme,
  });

  @override
  State<EmployeeDashboardPage> createState() =>
      _EmployeeDashboardPageState();
}

class _EmployeeDashboardPageState
    extends State<EmployeeDashboardPage> {
  final searchController = TextEditingController();
  final filterText = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    filterText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EmployeeCubit>(
      create: (_) {
        final cubit = sl<EmployeeCubit>();
        cubit.load();
        return cubit;
      },
      child: Builder(
        builder: (context) {
          final cubit = context.read<EmployeeCubit>();

          return Scaffold(
            appBar: _buildAppBar(context),

            floatingActionButton:
            FloatingActionButton.extended(
              onPressed: () => _openEmployeeForm(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Employee'),
            ),

            body: SafeArea(
              child: Column(
                children: [
                  EmployeeSearchFilter(
                    searchController: searchController,
                    filterController: filterText,
                    onSearchChanged: cubit.searchId,
                    onFilterChanged: cubit.filter,
                  ),

                  const SizedBox(height: 12),

                  Expanded(
                    child: _buildEmployeeContent(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmployeeContent() {
    return BlocBuilder<EmployeeCubit, EmployeeState>(
      builder: (context, state) {
        final cubit = context.read<EmployeeCubit>();

        // -----------------------------------------------------------
        // Loading
        // -----------------------------------------------------------

        if (state.status == EmployeeStatus.loading) {
          return const EmployeeLoadingState();
        }

        // -----------------------------------------------------------
        // Error
        // -----------------------------------------------------------

        if (state.status == EmployeeStatus.error) {
          return EmployeeErrorState(
            message: state.errorMessage ?? "SomeThing Went Wrong",
            onRetry: cubit.load,
          );
        }


        // -----------------------------------------------------------
        // Loaded
        // -----------------------------------------------------------

        if (state.status == EmployeeStatus.success) {
          final visibleEmployees = state.visible;

          if (visibleEmployees.isEmpty) {
            return const EmployeeEmptyState(
              message: 'No employees match your search.',
            );
          }

          return EmployeeGrid(
            employees: visibleEmployees,
            onView: _viewEmployee,
            onEdit: _editEmployee,
            onDelete: _deleteEmployee,
            onRefresh: cubit.load,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context,
      ) {
    return AppBar(
      title: const Text('Employees'),
      actions: [
        IconButton(
          onPressed: widget.onToggleTheme,
          tooltip: 'Toggle theme',
          icon: const Icon(
            Icons.brightness_6_outlined,
          ),
        ),
      ],
    );
  }

  Future<void> _openEmployeeForm(
      BuildContext context,
      ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EmployeeFormPage(),
      ),
    );

    if (!mounted) return;

    context.read<EmployeeCubit>().load();
  }

  Future<void> _viewEmployee(
      Employee employee,
      ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmployeeFormPage(
          employee: employee,
        ),
      ),
    );
  }

  Future<void> _editEmployee(
      Employee employee,
      ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmployeeFormPage(
          employee: employee,
        ),
      ),
    );

    if (!mounted) return;

    context.read<EmployeeCubit>().load();
  }

  Future<void> _deleteEmployee(
      Employee employee,
      ) async {
    final confirmed = await showDeleteEmployeeDialog(
      context,
      employee,
    );

    if (!confirmed || !mounted) return;

    final success = await context.read<EmployeeCubit>().remove(
      employee.id,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Employee deleted successfully.',
          ),
        ),
      );
    }
  }
}

class EmployeeGrid extends StatelessWidget {
  final List<Employee> employees;
  final ValueChanged<Employee> onView;
  final ValueChanged<Employee> onEdit;
  final ValueChanged<Employee> onDelete;
  final Future<void> Function() onRefresh;

  const EmployeeGrid({
    super.key,
    required this.employees,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (employees.isEmpty) {
      return const EmployeeEmptyState(
        message: 'No employees match your search.',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        int columns;

        if (width >= 1200) {
          columns = 4;
        } else if (width >= 800) {
          columns = 3;
        } else if (width >= 600) {
          columns = 2;
        } else {
          columns = 1;
        }

        // Give every card enough vertical space.
        final double cardHeight;

        if (columns == 1) {
          cardHeight = 285;
        } else if (columns == 2) {
          cardHeight = 290;
        } else {
          cardHeight = 300;
        }

        return RefreshIndicator(
          onRefresh: onRefresh,
          child: GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,

              // IMPORTANT:
              // Use fixed height instead of childAspectRatio.
              mainAxisExtent: cardHeight,
            ),
            itemCount: employees.length,
            itemBuilder: (context, index) {
              final employee = employees[index];

              return EmployeeCard(
                employee: employee,
                onView: () => onView(employee),
                onEdit: () => onEdit(employee),
                onDelete: () => onDelete(employee),
              );
            },
          ),
        );
      },
    );
  }
}

Future<bool> showDeleteEmployeeDialog(
    BuildContext context,
    Employee employee,
    ) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(
          'Delete Employee?',
        ),
        content: Text(
          'Are you sure you want to delete '
              '${employee.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  return result ?? false;
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class EmployeeSearchFilter extends StatelessWidget {
  final TextEditingController searchController;
  final TextEditingController filterController;
  final ValueChanged<String> onSearchChanged;
  final void Function(String type, String text)
  onFilterChanged;

  const EmployeeSearchFilter({
    super.key,
    required this.searchController,
    required this.filterController,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        0,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 650) {
            return Column(
              children: [
                _buildSearch(),
                const SizedBox(height: 12),
                _buildFilter(),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: _buildSearch(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilter(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearch() {
    return TextField(
      controller: searchController,
      onChanged: onSearchChanged,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Search by Employee ID',
        prefixIcon: Icon(
          Icons.search,
        ),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildFilter() {
    return DropdownButtonFormField<String>(
      initialValue: 'Name',
      decoration: const InputDecoration(
        labelText: 'Filter by',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(
          value: 'Name',
          child: Text('Name'),
        ),
        DropdownMenuItem(
          value: 'Email',
          child: Text('Email'),
        ),
        DropdownMenuItem(
          value: 'Mobile',
          child: Text('Mobile'),
        ),
        DropdownMenuItem(
          value: 'Country',
          child: Text('Country'),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          onFilterChanged(
            value,
            filterController.text,
          );
        }
      },
    );
  }
}
