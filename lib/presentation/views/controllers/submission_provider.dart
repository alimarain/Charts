import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_app/core/network/dio_client.dart';
import 'package:new_app/data/datasources/form/form_submission_service.dart';
import 'form_provider.dart';
import 'form_state.dart';
import 'submission_state.dart';

final formSubmissionServiceProvider = Provider<FormSubmissionService>((ref) {
  final dio = ref.watch(dioProvider);
  return FormSubmissionService(dio);
});

final submissionProvider =
    NotifierProvider<SubmissionNotifier, SubmissionState>(() {
  return SubmissionNotifier();
});

class SubmissionNotifier extends Notifier<SubmissionState> {
  StreamSubscription<SubmissionProgress>? _subscription;

  @override
  SubmissionState build() {
    // Auto-clean any active stream subscriptions when provider is disposed
    ref.onDispose(() {
      _subscription?.cancel();
    });
    return const SubmissionState();
  }

  Future<void> submit() async {
    // Prevent duplicate triggers while submission is actively running
    if (state.isSubmitting) return;

    final formState = ref.read(formProvider);

    state = const SubmissionState(
      status: SubmissionStatus.submitting,
      progress: 0.0,
      message: 'Initializing...',
    );

    await _subscription?.cancel();

    final submissionService = ref.read(formSubmissionServiceProvider);
    final progressStream = submissionService.submitFormStream(formState);

    _subscription = progressStream.listen(
      (progressEvent) {
        state = state.copyWith(
          status: progressEvent.progress >= 1.0
              ? SubmissionStatus.success
              : SubmissionStatus.submitting,
          progress: progressEvent.progress,
          message: progressEvent.message,
          clearError: true,
        );
      },
      onError: (dynamic error) {
        final errorMessage = error is Exception
            ? error.toString().replaceFirst('ApiException', '').replaceAll(RegExp(r'[\[\]:]'), '').trim()
            : 'Submission failed. Please try again.';

        state = state.copyWith(
          status: SubmissionStatus.failure,
          errorMessage: errorMessage,
        );
      },
      cancelOnError: true,
    );
  }

  void reset() {
    _subscription?.cancel();
    state = const SubmissionState();
  }
}