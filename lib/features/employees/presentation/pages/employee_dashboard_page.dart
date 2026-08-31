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
  final VoidCallback onToggleTheme;

  const EmployeeDashboardPage({
    super.key,
    required this.user,
    required this.onToggleTheme,
  });

  @override
  State<EmployeeDashboardPage> createState() =>
      _EmployeeDashboardPageState();
}

class _EmployeeDashboardPageState extends State<EmployeeDashboardPage> {
  late final EmployeeCubit cubit;

  final TextEditingController search = TextEditingController();
  final TextEditingController filterText = TextEditingController();

  String filter = 'All';

  @override
  void initState() {
    super.initState();

    cubit = sl<EmployeeCubit>();

    cubit.load();
  }

  @override
  void dispose() {
    search.dispose();
    filterText.dispose();

    cubit.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Employees'),
          actions: [
            IconButton(
              onPressed: widget.onToggleTheme,
              tooltip: 'Toggle theme',
              icon: const Icon(
                Icons.brightness_6_outlined,
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: PopupMenuButton<String>(
                tooltip: 'Account',

                onSelected: (value) {
                  if (value == 'logout') {
                    context.read<AuthCubit>().logout();
                  }
                },

                itemBuilder: (_) {
                  return [
                    PopupMenuItem<String>(
                      enabled: false,
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          if (widget.user.photoUrl != null)
                            CircleAvatar(
                              radius: 22,
                              backgroundImage: NetworkImage(
                                widget.user.photoUrl!,
                              ),
                            ),

                          const SizedBox(height: 8),

                          Text(
                            widget.user.name.isEmpty
                                ? 'User'
                                : widget.user.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 2),

                          Text(
                            widget.user.email,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall,
                          ),
                        ],
                      ),
                    ),

                    const PopupMenuDivider(),

                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout),
                          SizedBox(width: 8),
                          Text('Logout'),
                        ],
                      ),
                    ),
                  ];
                },

                child: CircleAvatar(
                  backgroundImage:
                  widget.user.photoUrl != null
                      ? NetworkImage(widget.user.photoUrl!)
                      : null,

                  child: widget.user.photoUrl == null
                      ? Text(
                    widget.user.name.isEmpty
                        ? 'U'
                        : widget.user.name[0]
                        .toUpperCase(),
                  )
                      : null,
                ),
              ),
            ),
          ],
        ),

        floatingActionButton:
        FloatingActionButton.extended(
          onPressed: () => _edit(null),
          icon: const Icon(Icons.add),
          label: const Text('Add Employee'),
        ),

        body: BlocBuilder<EmployeeCubit, EmployeeState>(
          bloc: cubit,

          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: cubit.load,

              child: CustomScrollView(
                physics:
                const AlwaysScrollableScrollPhysics(),

                slivers: [
                  // -------------------------------------------------
                  // FILTER SECTION
                  // -------------------------------------------------

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        16,
                        16,
                        8,
                      ),
                      child: _filters(context),
                    ),
                  ),

                  // -------------------------------------------------
                  // LOADING
                  // -------------------------------------------------

                  if (state is EmployeeLoading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )

                  // -------------------------------------------------
                  // ERROR
                  // -------------------------------------------------

                  else if (state is EmployeeError)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding:
                          const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize:
                            MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons
                                    .error_outline,
                                size: 48,
                              ),

                              const SizedBox(
                                height: 12,
                              ),

                              Text(
                                state.message,
                                textAlign:
                                TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge,
                              ),

                              const SizedBox(
                                height: 16,
                              ),

                              FilledButton.icon(
                                onPressed:
                                cubit.load,
                                icon: const Icon(
                                  Icons.refresh,
                                ),
                                label: const Text(
                                  'Retry',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )

                  // -------------------------------------------------
                  // EMPTY
                  // -------------------------------------------------

                  else if (state is EmployeeEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding:
                            EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize:
                              MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons
                                      .people_outline,
                                  size: 56,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'No employees found.',
                                ),
                              ],
                            ),
                          ),
                        ),
                      )

                    // -------------------------------------------------
                    // LOADED
                    // -------------------------------------------------

                    else if (state is EmployeeLoaded)
                        _buildEmployeeContent(state)

                      // -------------------------------------------------
                      // INITIAL / UNKNOWN STATE
                      // -------------------------------------------------

                      else
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: SizedBox(),
                        ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ===============================================================
  // EMPLOYEE CONTENT
  // ===============================================================

  Widget _buildEmployeeContent(
      EmployeeLoaded state,
      ) {
    final List<Employee> list = state.visible;

    // No matching employees after search/filter.
    if (list.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search_off,
                  size: 56,
                ),
                SizedBox(height: 12),
                Text(
                  'No matching employees.',
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        10,
      ),

      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          final double width =
              constraints.crossAxisExtent;

          int columns;

          if (width > 1100) {
            columns = 3;
          } else if (width > 650) {
            columns = 2;
          } else {
            columns = 1;
          }

          return SliverGrid(
            delegate:
            SliverChildBuilderDelegate(
                  (context, index) {
                final Employee employee =
                list[index];

                return EmployeeCard(
                  employee: employee,

                  onView: () {
                    _view(employee);
                  },

                  onEdit: () {
                    _edit(employee);
                  },

                  onDelete: () {
                    _delete(employee.id);
                  },
                );
              },

              childCount: list.length,
            ),

            gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,

              crossAxisSpacing: 12,

              mainAxisSpacing: 12,

              childAspectRatio:
              columns == 1
                  ? 2.2
                  : columns == 2
                  ? 1.55
                  : 1.45,
            ),
          );
        },
      ),
    );
  }

  // ===============================================================
  // FILTERS
  // ===============================================================

  Widget _filters(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),

        child: LayoutBuilder(
          builder: (context, constraints) {
            final double availableWidth =
                constraints.maxWidth;

            final bool isWide =
                availableWidth > 600;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment:
              WrapCrossAlignment.center,

              children: [
                // ---------------------------------------------------
                // EMPLOYEE ID SEARCH
                // ---------------------------------------------------

                SizedBox(
                  width: isWide
                      ? 260
                      : availableWidth,

                  child: TextField(
                    controller: search,

                    onChanged: cubit.searchId,

                    textInputAction:
                    TextInputAction.search,

                    decoration:
                    const InputDecoration(
                      labelText:
                      'Search by Employee ID',

                      hintText:
                      'Enter employee ID',

                      prefixIcon:
                      Icon(Icons.search),

                      border:
                      OutlineInputBorder(),
                    ),
                  ),
                ),

                // ---------------------------------------------------
                // FILTER DROPDOWN
                // ---------------------------------------------------

                SizedBox(
                  width: isWide
                      ? 150
                      : availableWidth,

                  child:
                  DropdownButtonFormField<String>(
                    value: filter,

                    decoration:
                    const InputDecoration(
                      labelText: 'Filter by',

                      border:
                      OutlineInputBorder(),
                    ),

                    items: const [
                      DropdownMenuItem(
                        value: 'All',
                        child: Text('All'),
                      ),
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
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        filter = value;

                        // Clear previous filter text
                        // when changing filter type.
                        if (filter == 'All') {
                          filterText.clear();
                        }
                      });

                      cubit.filter(
                        filter,
                        filterText.text,
                      );
                    },
                  ),
                ),

                // ---------------------------------------------------
                // FILTER SEARCH
                // ---------------------------------------------------

                if (filter != 'All')
                  SizedBox(
                    width: isWide
                        ? 220
                        : availableWidth,

                    child: TextField(
                      controller: filterText,

                      onChanged: (value) {
                        cubit.filter(
                          filter,
                          value,
                        );
                      },

                      decoration:
                      InputDecoration(
                        labelText:
                        'Search $filter',

                        hintText:
                        'Enter $filter',

                        prefixIcon:
                        const Icon(
                          Icons
                              .filter_alt_outlined,
                        ),

                        suffixIcon:
                        filterText
                            .text
                            .isNotEmpty
                            ? IconButton(
                          onPressed: () {
                            filterText
                                .clear();

                            cubit.filter(
                              filter,
                              '',
                            );

                            setState(() {});
                          },
                          icon:
                          const Icon(
                            Icons.clear,
                          ),
                        )
                            : null,

                        border:
                        const OutlineInputBorder(),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ===============================================================
  // ADD / EDIT
  // ===============================================================

  Future<void> _edit(
      Employee? employee,
      ) async {
    final Employee? result =
    await Navigator.push<Employee>(
      context,

      MaterialPageRoute(
        builder: (_) => EmployeeFormPage(
          employee: employee,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    if (result == null) {
      return;
    }

    final saved = await cubit.save(result);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            saved == null
                ? 'Unable to save employee'
                : 'Employee saved successfully',
          ),

          behavior:
          SnackBarBehavior.floating,

          action: saved == null
              ? SnackBarAction(
            label: 'Retry',
            onPressed: () async {
              final retry =
              await cubit.save(
                result,
              );

              if (!mounted) {
                return;
              }

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(
                SnackBar(
                  content: Text(
                    retry == null
                        ? 'Unable to save employee'
                        : 'Employee saved successfully',
                  ),
                ),
              );
            },
          )
              : null,
        ),
      );
  }

  // ===============================================================
  // VIEW EMPLOYEE
  // ===============================================================

  Future<void> _view(
      Employee employee,
      ) async {
    await showDialog<void>(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              const CircleAvatar(
                child: Icon(Icons.person),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  employee.name,
                  overflow:
                  TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize:
              MainAxisSize.min,

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                _detailRow(
                  'Employee ID',
                  employee.id,
                ),

                _detailRow(
                  'Name',
                  employee.name,
                ),

                _detailRow(
                  'Email',
                  employee.email,
                ),

                _detailRow(
                  'Mobile',
                  employee.mobile,
                ),

                _detailRow(
                  'Country',
                  employee.country,
                ),

                _detailRow(
                  'State',
                  employee.state,
                ),

                _detailRow(
                  'District',
                  employee.district,
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child: const Text('Close'),
            ),

            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );

                _edit(employee);
              },
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  // ===============================================================
  // DETAIL ROW
  // ===============================================================

  Widget _detailRow(
      String label,
      String value,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(bottom: 12),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelMedium,
          ),

          const SizedBox(height: 3),

          Text(
            value.isEmpty
                ? '-'
                : value,
            style: Theme.of(context)
                .textTheme
                .bodyLarge,
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // DELETE
  // ===============================================================

  Future<void> _delete(
      String id,
      ) async {
    final bool? confirmed =
    await showDialog<bool>(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.warning_amber_rounded,
            size: 40,
          ),

          title: const Text(
            'Delete employee?',
          ),

          content: const Text(
            'This action cannot be undone. '
                'Are you sure you want to delete this employee?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },

              child: const Text(
                'Cancel',
              ),
            ),

            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor:
                Theme.of(context)
                    .colorScheme
                    .error,
                foregroundColor:
                Theme.of(context)
                    .colorScheme
                    .onError,
              ),

              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },

              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final bool success =
    await cubit.remove(id);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Employee deleted successfully'
                : 'Delete failed',
          ),

          behavior:
          SnackBarBehavior.floating,

          action: success
              ? null
              : SnackBarAction(
            label: 'Retry',
            onPressed: () async {
              final retry =
              await cubit.remove(
                id,
              );

              if (!mounted) {
                return;
              }

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(
                SnackBar(
                  content: Text(
                    retry
                        ? 'Employee deleted successfully'
                        : 'Delete failed',
                  ),
                ),
              );
            },
          ),
        ),
      );
  }
}
