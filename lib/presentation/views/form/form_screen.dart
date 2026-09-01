import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_app/presentation/views/controllers/form_provider.dart';
import 'package:new_app/presentation/views/controllers/submission_provider.dart';
import 'package:new_app/presentation/views/controllers/submission_state.dart';

import '../../controllers/auth_provider.dart';
import '../../widgets/navigation/app_header.dart';
import '../../widgets/navigation/app_sidebar.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
    final authState = ref.watch(authProvider);
    final userRole = authState.user?.role == 'maker' ? 'Maker' : 'User';
    final hasToken = authState.token != null && authState.token!.isNotEmpty;

    ref.listen<SubmissionState>(submissionProvider, (previous, next) {
      if (next.isSuccess) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!context.mounted) return;
          ref.read(submissionProvider.notifier).reset();
          ref.read(formProvider.notifier).resetForm();
          context.goNamed(DashboardScreen.routeName);
        });
      }
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xFFF8F9FC),
          drawer: isDesktop
              ? null
              : Drawer(
                  child: AppSidebar(
                    currentRoute: '/form',
                    hasToken: hasToken,
                    userRole: userRole,
                    isMobileDrawer: true,
                  ),
                ),
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isDesktop)
                AppSidebar(
                  currentRoute: '/form',
                  hasToken: hasToken,
                  userRole: userRole,
                ),
              Expanded(
                child: Column(
                  children: [
                    AppHeader(
                      title: 'New Resource Creation',
                      showMenuButton: !isDesktop,
                      onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 32.0 : 16.0,
                          vertical: 24.0,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1040),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Create New Resource',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF111827),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Define operational parameters for a new enterprise project.',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFFE5E7EB)),
                                  ),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(28.0),
                                        child: currentStep == 0
                                            ? BasicInfoStep(formKey: _step1FormKey)
                                            : CareerInfoStep(formKey: _step2FormKey),
                                      ),
                                      const Divider(height: 1, color: Color(0xFFE5E7EB)),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                        child: Row(
                                          children: [
                                            const Expanded(
                                              child: Text(
                                                'Changes logged to Master Ledger ID: #LOG-8821',
                                                style: TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                  fontSize: 11,
                                                  color: Color(0xFF9CA3AF),
                                                ),
                                              ),
                                            ),
                                            if (currentStep > 0) ...[
                                              OutlinedButton(
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: const Color(0xFF374151),
                                                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                                                  minimumSize: Size.zero,
                                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                ),
                                                onPressed: submissionState.isSubmitting ? null : _onBack,
                                                child: const Text('Discard / Back', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                              ),
                                              const SizedBox(width: 10),
                                            ],
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF1B1638),
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                minimumSize: Size.zero,
                                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              ),
                                              onPressed: submissionState.isSubmitting
                                                  ? null
                                                  : (currentStep == 0 ? _onNext : _onSubmit),
                                              child: submissionState.isSubmitting
                                                  ? const SizedBox(
                                                      height: 16,
                                                      width: 16,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.white,
                                                      ),
                                                    )
                                                  : Text(
                                                      currentStep == 0 ? 'Continue to Career Info' : 'Finalize & Create',
                                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                                    ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}