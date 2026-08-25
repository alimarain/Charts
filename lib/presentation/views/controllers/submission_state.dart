enum SubmissionStatus { idle, submitting, success, failure }

class SubmissionProgress {
  const SubmissionProgress({required this.progress, required this.message});

  final double progress; // 0.0 to 1.0
  final String message;
}

class SubmissionState {
  const SubmissionState({
    this.status = SubmissionStatus.idle,
    this.progress = 0.0,
    this.message = '',
    this.errorMessage,
  });

  final SubmissionStatus status;
  final double progress;
  final String message;
  final String? errorMessage;

  bool get isSubmitting => status == SubmissionStatus.submitting;
  bool get isSuccess => status == SubmissionStatus.success;
  bool get isFailure => status == SubmissionStatus.failure;

  SubmissionState copyWith({
    SubmissionStatus? status,
    double? progress,
    String? message,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SubmissionState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      message: message ?? this.message,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
