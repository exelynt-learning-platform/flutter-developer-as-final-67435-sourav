import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/employee.dart';
import '../bloc/employee_cubit.dart';
import '../widgets/employee_card.dart';
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
  late final EmployeeCubit cubit;

  final searchController = TextEditingController();
  final filterText = TextEditingController();

  @override
  void initState() {
    super.initState();

    cubit = sl<EmployeeCubit>();
    cubit.load();
  }

  @override
  void dispose() {
    searchController.dispose();
    filterText.dispose();
    cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: Scaffold(
        appBar: _buildAppBar(context),
        floatingActionButton: FloatingActionButton.extended(
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
      ),
    );
  }

  Widget _buildEmployeeContent() {
    return BlocBuilder<EmployeeCubit, EmployeeState>(
      bloc: cubit,
      builder: (context, state) {
        // Loading
        if (state is EmployeeLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Error
        if (state is EmployeeError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 56,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Something went wrong',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: cubit.load,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Empty
        if (state is EmployeeEmpty) {
          return RefreshIndicator(
            onRefresh: cubit.load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 120),
                Icon(
                  Icons.people_outline,
                  size: 64,
                ),
                SizedBox(height: 16),
                Center(
                  child: Text(
                    'No employees found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Center(
                  child: Text(
                    'There are no employees available.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        }

        // Loaded
        if (state is EmployeeLoaded) {
          return EmployeeGrid(
            employees: _filteredEmployees(state),
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

  List<Employee> _filteredEmployees(
      EmployeeLoaded state,
      ) {
    var employees = state.employees;

    if (state.searchId.trim().isNotEmpty) {
      employees = employees
          .where(
            (employee) =>
        employee.id == state.searchId.trim(),
      )
          .toList();
    }

    if (state.filterText.trim().isNotEmpty) {
      final text = state.filterText.trim().toLowerCase();

      employees = employees.where((employee) {
        switch (state.filter) {
          case 'Name':
            return employee.name
                .toLowerCase()
                .contains(text);

          case 'Email':
            return employee.email
                .toLowerCase()
                .contains(text);

          case 'Mobile':
            return employee.mobile
                .toLowerCase()
                .contains(text);

          case 'Country':
            return employee.country
                .toLowerCase()
                .contains(text);

          default:
            return true;
        }
      }).toList();
    }

    return employees;
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

    await cubit.load();
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

    await cubit.load();
  }

  Future<void> _deleteEmployee(
      Employee employee,
      ) async {
    final confirmed = await showDeleteEmployeeDialog(
      context,
      employee,
    );

    if (!confirmed || !mounted) return;

    final success = await cubit.remove(
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
  final Future<void> Function()? onRefresh;

  const EmployeeGrid({
    super.key,
    required this.employees,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (employees.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.people_outline,
                size: 64,
              ),
              SizedBox(height: 16),
              Text(
                'No employees found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'No employees match your search or filter.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
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

        return RefreshIndicator(
          onRefresh: onRefresh ?? () async {},
          child: GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio:
              columns == 1 ? 1.7 : 1.35,
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(
                    employee.name.isEmpty
                        ? 'E'
                        : employee.name[0].toUpperCase(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    employee.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _InfoRow(
              icon: Icons.email_outlined,
              value: employee.email,
            ),

            _InfoRow(
              icon: Icons.phone_outlined,
              value: employee.mobile,
            ),

            _InfoRow(
              icon: Icons.public,
              value: employee.country,
            ),

            _InfoRow(
              icon: Icons.location_on_outlined,
              value:
              '${employee.state}, ${employee.district}',
            ),

            const Spacer(),

            Row(
              mainAxisAlignment:
              MainAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: 'View employee',
                  onPressed: onView,
                  icon: const Icon(
                    Icons.visibility_outlined,
                  ),
                ),
                IconButton(
                  tooltip: 'Edit employee',
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit_outlined,
                  ),
                ),
                IconButton(
                  tooltip: 'Delete employee',
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
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
