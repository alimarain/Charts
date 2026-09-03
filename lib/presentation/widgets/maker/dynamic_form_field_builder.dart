import 'package:flutter/material.dart';
import 'package:new_app/presentation/controllers/maker_provider.dart';

import '../../../domain/entities/maker_models.dart';

class DynamicFormFieldBuilder extends StatelessWidget {
  const DynamicFormFieldBuilder({
    super.key,
    required this.field,
    required this.currentValue,
    required this.notifier,
  });

  final DynamicFormField field;
  final dynamic currentValue;
  final DynamicFormNotifier notifier;

  @override
  Widget build(BuildContext context) {
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
              ? (val) {
                  if (val == null || val.isEmpty) {
                    return '${field.label} is required';
                  }
                  return null;
                }
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
                  if (val == null || val.trim().isEmpty) {
                    return '${field.label} is required';
                  }
                  if (num.tryParse(val) == null) {
                    return 'Enter a valid number';
                  }
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
              ? (val) {
                  if (val == null || val.trim().isEmpty) {
                    return '${field.label} is required';
                  }
                  return null;
                }
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
              ? (val) {
                  if (val == null || val.trim().isEmpty) {
                    return '${field.label} is required';
                  }
                  return null;
                }
              : null,
        );
    }
  }
}
