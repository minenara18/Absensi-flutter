import 'package:absensi_dashboard/core/clock.dart';
import 'package:absensi_dashboard/core/result.dart';
import 'package:absensi_dashboard/data/dummy_data.dart';
import 'package:absensi_dashboard/data/models.dart';
import 'package:absensi_dashboard/data/repositories.dart';
import 'package:absensi_dashboard/features/employees/presentation/employees_notifier.dart';
import 'package:absensi_dashboard/l10n/gen/app_localizations.dart';
import 'package:absensi_dashboard/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Add/edit employee form with sync validators, focus order and
/// PopScope guard for unsaved changes. Watches no list state.
final class EmployeeFormScreen extends ConsumerStatefulWidget {
  const EmployeeFormScreen({super.key, this.employeeId});

  final String? employeeId;

  @override
  ConsumerState<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

final class _EmployeeFormScreenState extends ConsumerState<EmployeeFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _position = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _positionFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final ValueNotifier<bool> _dirty = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _valid = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _saving = ValueNotifier<bool>(false);
  final ValueNotifier<String> _department = ValueNotifier<String>(
    DummyData.departments.first,
  );
  bool _loaded = false;

  @override
  void dispose() {
    _name.dispose();
    _position.dispose();
    _email.dispose();
    _phone.dispose();
    _nameFocus.dispose();
    _positionFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _dirty.dispose();
    _valid.dispose();
    _saving.dispose();
    _department.dispose();
    super.dispose();
  }

  void _markDirty() {
    _dirty.value = true;
    _valid.value = _formKey.currentState?.validate() ?? false;
  }

  Future<bool> _confirmDiscard(AppLocalizations strings) async {
    if (!_dirty.value) {
      return true;
    }
    final bool? discard = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(strings.unsavedTitle),
          content: Text(strings.unsavedBody),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(strings.keepEditing),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(strings.discard),
            ),
          ],
        );
      },
    );
    return discard ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final String? employeeId = widget.employeeId;

    if (employeeId != null && !_loaded) {
      final AsyncValue<EmployeesState> staffState = ref.watch(
        employeesProvider,
      );
      final EmployeesState? data = staffState.value;
      Employee? found;
      if (data != null) {
        for (final Employee e in data.staff) {
          if (e.id == employeeId) {
            found = e;
          }
        }
      }
      if (found != null) {
        final Employee employee = found;
        _loaded = true;
        _name.text = employee.name;
        _position.text = employee.position;
        _email.text = employee.email;
        _phone.text = employee.phone;
        _department.value = employee.department;
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }
        if (await _confirmDiscard(strings)) {
          if (context.mounted) {
            context.pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            employeeId == null ? strings.addEmployee : strings.editEmployee,
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsetsDirectional.all(AppSpacing.md),
            children: <Widget>[
              Form(
                key: _formKey,
                onChanged: _markDirty,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _name,
                      focusNode: _nameFocus,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _positionFocus.requestFocus(),
                      decoration: InputDecoration(labelText: strings.fieldName),
                      validator: (String? value) =>
                          (value == null || value.trim().isEmpty)
                          ? strings.requiredField
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _position,
                      focusNode: _positionFocus,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                      decoration: InputDecoration(
                        labelText: strings.fieldPosition,
                      ),
                      validator: (String? value) =>
                          (value == null || value.trim().isEmpty)
                          ? strings.requiredField
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ValueListenableBuilder<String>(
                      valueListenable: _department,
                      builder:
                          (BuildContext context, String value, Widget? child) {
                            return DropdownButtonFormField<String>(
                              initialValue: value,
                              decoration: InputDecoration(
                                labelText: strings.fieldDepartment,
                              ),
                              items: <DropdownMenuItem<String>>[
                                for (final String dept in DummyData.departments)
                                  DropdownMenuItem<String>(
                                    value: dept,
                                    child: Text(dept),
                                  ),
                              ],
                              onChanged: (String? next) {
                                if (next != null) {
                                  _department.value = next;
                                  _markDirty();
                                }
                              },
                            );
                          },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _email,
                      focusNode: _emailFocus,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _phoneFocus.requestFocus(),
                      decoration: InputDecoration(
                        labelText: strings.fieldEmail,
                      ),
                      validator: (String? value) {
                        if (value == null || value.trim().isEmpty) {
                          return strings.requiredField;
                        }
                        if (!RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        ).hasMatch(value.trim())) {
                          return strings.invalidEmail;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _phone,
                      focusNode: _phoneFocus,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: strings.fieldPhone,
                      ),
                      validator: (String? value) {
                        if (value == null || value.trim().isEmpty) {
                          return strings.requiredField;
                        }
                        if (!RegExp(
                          r'^[0-9+ ]{9,16}$',
                        ).hasMatch(value.trim())) {
                          return strings.invalidPhone;
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ValueListenableBuilder<bool>(
                valueListenable: _saving,
                builder: (BuildContext context, bool saving, Widget? child) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: _valid,
                    builder: (BuildContext context, bool valid, Widget? child) {
                      return SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: (valid && !saving)
                              ? () => _save(strings)
                              : null,
                          child: saving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(strings.save),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save(AppLocalizations strings) async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    _saving.value = true;
    final EmployeeRepository repo = ref.read(employeeRepositoryProvider);
    final DateTime now = ref.read(clockProvider).now();
    final String id =
        widget.employeeId ?? 'emp-new-${now.millisecondsSinceEpoch}';
    final Result<Employee> result = await repo.save(
      Employee(
        id: id,
        name: _name.text.trim(),
        position: _position.text.trim(),
        department: _department.value,
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        active: true,
        joinDate: now,
      ),
    );
    _saving.value = false;
    if (!mounted) {
      return;
    }
    switch (result) {
      case Ok():
        _dirty.value = false;
        ref.invalidate(employeesProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.saved)),
        );
        context.pop();
      case Err():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.errorUnknown)),
        );
    }
  }
}
