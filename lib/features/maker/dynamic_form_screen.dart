import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/maker_models.dart';
import '../../presentation/controllers/maker/maker_providers.dart';

class DynamicFormScreen extends ConsumerStatefulWidget {
  const DynamicFormScreen({required this.formId, this.formTitle, super.key});

  static const routeName = 'dynamic_form';
  static const routeSubPath = 'forms/:formId';

  final String formId;
  final String? formTitle;

  @override
  ConsumerState<DynamicFormScreen> createState() => _DynamicFormScreenState();
}

class _DynamicFormScreenState extends ConsumerState<DynamicFormScreen> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final notifier = ref.read(
        dynamicFormControllerProvider(widget.formId).notifier,
      );
      final success = await notifier.submit(widget.formId);

      if (success && mounted) {
        final result = ref
            .read(dynamicFormControllerProvider(widget.formId))
            .submissionResult;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Color(0xFF059669)),
                SizedBox(width: 8),
                Text('Application Submitted'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('App ID: ${result?.applicationId ?? "N/A"}'),
                Text('Ref No: ${result?.referenceNumber ?? "N/A"}'),
                Text('Status: ${result?.status ?? "N/A"}'),
                const SizedBox(height: 8),
                const Text(
                  'Case routed to Credit Risk Officer (Checker Queue).',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text('Return to Templates'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fieldsAsync = ref.watch(dynamicFieldsProvider(widget.formId));
    final formState = ref.watch(dynamicFormControllerProvider(widget.formId));
    final notifier = ref.read(
      dynamicFormControllerProvider(widget.formId).notifier,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: Text(widget.formTitle ?? 'Dynamic Form')),
      body: fieldsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
        ),
        error: (err, _) => Center(child: Text('Error generating fields: $err')),
        data: (fields) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (formState.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Text(
                      formState.errorMessage!,
                      style: const TextStyle(
                        color: Color(0xFFDC2626),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                ...fields.map((field) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 18.0),
                    child: _buildDynamicWidget(
                      field,
                      formState.answers[field.key],
                      notifier,
                    ),
                  );
                }),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: formState.isSubmitting ? null : _handleSubmit,
                  child: formState.isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Submit Application Payload'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDynamicWidget(
    DynamicFormField field,
    dynamic currentValue,
    DynamicFormNotifier notifier,
  ) {
    final isRequired = field.required;

    switch (field.type) {
      case 'dropdown':
        return DropdownButtonFormField<String>(
          initialValue: currentValue as String?,
          decoration: InputDecoration(
            labelText: '${field.label}${isRequired ? " *" : ""}',
          ),
          items: field.options
              .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
              .toList(),
          onChanged: (val) => notifier.updateField(field.key, val),
          validator: isRequired
              ? (val) => (val == null || val.isEmpty)
                    ? '${field.label} is required'
                    : null
              : null,
        );

      case 'radio':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${field.label}${isRequired ? " *" : ""}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            ...field.options.map((opt) {
              final isSelected = currentValue == opt;
              return InkWell(
                onTap: () => notifier.updateField(field.key, opt),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6.0,
                    horizontal: 4.0,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        size: 20,
                        color: isSelected
                            ? const Color(0xFF4F46E5)
                            : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 8),
                      Text(opt, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              );
            }),
          ],
        );

      case 'checkbox':
        return CheckboxListTile(
          title: Text(
            '${field.label}${isRequired ? " *" : ""}',
            style: const TextStyle(fontSize: 13),
          ),
          value: (currentValue as bool?) ?? false,
          dense: true,
          contentPadding: EdgeInsets.zero,
          activeColor: const Color(0xFF4F46E5),
          onChanged: (val) => notifier.updateField(field.key, val),
        );

      case 'date':
        return InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1980),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              notifier.updateField(
                field.key,
                picked.toIso8601String().split('T').first,
              );
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: '${field.label}${isRequired ? " *" : ""}',
              prefixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
            ),
            child: Text(
              currentValue != null ? currentValue.toString() : 'Select date',
              style: TextStyle(
                color: currentValue != null
                    ? const Color(0xFF0F172A)
                    : const Color(0xFF94A3B8),
              ),
            ),
          ),
        );

      case 'number':
        return TextFormField(
          keyboardType: TextInputType.number,
          initialValue: currentValue?.toString(),
          decoration: InputDecoration(
            labelText: '${field.label}${isRequired ? " *" : ""}',
            hintText: field.placeholder,
          ),
          onChanged: (val) =>
              notifier.updateField(field.key, num.tryParse(val) ?? val),
          validator: isRequired
              ? (val) {
                  if (val == null || val.trim().isEmpty)
                    return '${field.label} is required';
                  if (num.tryParse(val) == null) return 'Enter a valid number';
                  return null;
                }
              : null,
        );

      case 'multiline':
        return TextFormField(
          maxLines: 3,
          initialValue: currentValue?.toString(),
          decoration: InputDecoration(
            labelText: '${field.label}${isRequired ? " *" : ""}',
            hintText: field.placeholder,
          ),
          onChanged: (val) => notifier.updateField(field.key, val),
          validator: isRequired
              ? (val) => (val == null || val.trim().isEmpty)
                    ? '${field.label} is required'
                    : null
              : null,
        );

      case 'text':
      case 'email':
      case 'phone':
      default:
        return TextFormField(
          initialValue: currentValue?.toString(),
          decoration: InputDecoration(
            labelText: '${field.label}${isRequired ? " *" : ""}',
            hintText: field.placeholder,
          ),
          onChanged: (val) => notifier.updateField(field.key, val),
          validator: isRequired
              ? (val) => (val == null || val.trim().isEmpty)
                    ? '${field.label} is required'
                    : null
              : null,
        );
    }
  }
}
