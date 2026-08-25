import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_app/presentation/views/controllers/form_provider.dart';
import 'package:new_app/presentation/views/controllers/submission_provider.dart';
import 'package:new_app/presentation/views/controllers/submission_state.dart';

import '../dashboard/dashboard_screen.dart';
import 'basic_info_step.dart';
import 'career_info_step.dart';

class FormScreen extends ConsumerStatefulWidget {
  const FormScreen({super.key});

  static const routeName = 'form';
  static const routePath = '/form';

  @override
  ConsumerState<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends ConsumerState<FormScreen> {
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();

  void _onNext() {
    if (_step1FormKey.currentState?.validate() ?? false) {
      ref.read(formProvider.notifier).nextStep();
    }
  }

  void _onBack() {
    ref.read(formProvider.notifier).previousStep();
  }

  void _onSubmit() {
    if (_step2FormKey.currentState?.validate() ?? false) {
      ref.read(submissionProvider.notifier).submit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = ref.watch(formProvider.select((s) => s.currentStep));
    final submissionState = ref.watch(submissionProvider);
    final isSubmitting = submissionState.isSubmitting;

    ref.listen<SubmissionState>(submissionProvider, (previous, next) {
      if (next.isSuccess) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!context.mounted) return;
          ref.read(submissionProvider.notifier).reset();
          ref.read(formProvider.notifier).resetForm();
          context.goNamed(DashboardScreen.routeName);
        });
      }
    });

    return PopScope(
      canPop: currentStep == 0 && !isSubmitting,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && currentStep > 0 && !isSubmitting) {
          _onBack();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Application Form'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: isSubmitting
                ? null
                : () {
                    if (currentStep > 0) {
                      _onBack();
                    } else {
                      context.pop();
                    }
                  },
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      const _StepCircle(
                        stepNumber: 1,
                        isActive: true,
                        label: 'Basic Info',
                      ),
                      Expanded(
                        child: Container(
                          height: 3,
                          color: currentStep >= 1
                              ? const Color(0xFF2563EB)
                              : Colors.grey.shade300,
                        ),
                      ),
                      _StepCircle(
                        stepNumber: 2,
                        isActive: currentStep >= 1,
                        label: 'Career Info',
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Step ${currentStep + 1} of 2',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 24),
            Expanded(
              child: IndexedStack(
                index: currentStep,
                children: [
                  BasicInfoStep(formKey: _step1FormKey),
                  CareerInfoStep(formKey: _step2FormKey),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (currentStep > 0) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isSubmitting ? null : _onBack,
                        child: const Text('Back'),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : (currentStep == 0 ? _onNext : _onSubmit),
                      child: isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              currentStep == 0
                                  ? 'Next'
                                  : (submissionState.isFailure
                                        ? 'Retry Submission'
                                        : 'Submit'),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  const _StepCircle({
    required this.stepNumber,
    required this.isActive,
    required this.label,
  });

  final int stepNumber;
  final bool isActive;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFF2563EB) : Colors.grey.shade300,
          ),
          alignment: Alignment.center,
          child: Text(
            '$stepNumber',
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isActive ? const Color(0xFF2563EB) : Colors.grey.shade600,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
