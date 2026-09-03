import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_app/presentation/controllers/maker_provider.dart';
import 'package:new_app/presentation/widgets/maker/dynamic_form_field_builder.dart';
import 'package:new_app/presentation/widgets/maker/maker_submission_dialog.dart';

import '../../widgets/common/app_state_views.dart';

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
      final success = await notifier.submit();

      if (success && mounted) {
        final result = ref
            .read(dynamicFormControllerProvider(widget.formId))
            .submissionResult;

        MakerSubmissionDialog.show(
          context,
          result: result,
          onDismiss: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
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
        loading: () => const AppLoadingView(color: Color(0xFF4F46E5)),
        error: (err, _) => AppErrorView(
          message: 'Error generating fields: $err',
          onRetry: () => ref.refresh(dynamicFieldsProvider(widget.formId)),
        ),
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
                    child: DynamicFormFieldBuilder(
                      field: field,
                      currentValue: formState.answers[field.key],
                      notifier: notifier,
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
}
