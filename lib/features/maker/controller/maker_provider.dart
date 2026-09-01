import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_app/domain/entities/maker_models.dart';

import '../../../core/network/dio_client.dart';
import '../../../data/datasources/maker/api_maker_service.dart';

final makerServiceProvider = Provider<ApiMakerService>((ref) {
  return ApiMakerService(ref.watch(dioProvider));
});

/// Submission result model holding required confirmation metadata
class SubmissionResult {
  final String applicationId;
  final String referenceNumber;
  final String status;

  const SubmissionResult({
    required this.applicationId,
    required this.referenceNumber,
    required this.status,
  });
}

/// AsyncNotifier for Maker products allowing both state watching and .notifier.loadProducts() / refresh()
class MakerProductsNotifier extends AsyncNotifier<List<MakerProduct>> {
  @override
  Future<List<MakerProduct>> build() async {
    return ref.read(makerServiceProvider).getMakerProducts();
  }

  Future<void> loadProducts() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(makerServiceProvider).getMakerProducts(),
    );
  }

  Future<void> refresh() async => loadProducts();
}

final makerProductsProvider =
    AsyncNotifierProvider<MakerProductsNotifier, List<MakerProduct>>(
      MakerProductsNotifier.new,
    );

final makerFormsProvider = FutureProvider.family<List<MakerForm>, String>((
  ref,
  productId,
) async {
  return ref.watch(makerServiceProvider).getFormsByProduct(productId);
});

final dynamicFieldsProvider =
    FutureProvider.family<List<DynamicFormField>, String>((ref, formId) async {
      return ref.watch(makerServiceProvider).getFieldsByForm(formId);
    });

class DynamicFormState {
  final Map<String, dynamic> answers;
  final bool isSubmitting;
  final SubmissionResult? submissionResult;
  final String? errorMessage;

  const DynamicFormState({
    this.answers = const {},
    this.isSubmitting = false,
    this.submissionResult,
    this.errorMessage,
  });

  DynamicFormState copyWith({
    Map<String, dynamic>? answers,
    bool? isSubmitting,
    SubmissionResult? submissionResult,
    String? errorMessage,
  }) {
    return DynamicFormState(
      answers: answers ?? this.answers,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submissionResult: submissionResult ?? this.submissionResult,
      errorMessage: errorMessage,
    );
  }
}

class DynamicFormNotifier extends Notifier<DynamicFormState> {
  final String formId;
  DynamicFormNotifier(this.formId);

  @override
  DynamicFormState build() => const DynamicFormState();

  void updateField(String key, dynamic value) {
    final updated = Map<String, dynamic>.from(state.answers);
    updated[key] = value;
    state = state.copyWith(answers: updated);
  }

  Future<bool> submit() async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final appId = await ref
          .read(makerServiceProvider)
          .submitApplication(formId, state.answers);

      final result = SubmissionResult(
        applicationId: appId,
        referenceNumber:
            'REF-${appId.length > 8 ? appId.substring(0, 8).toUpperCase() : appId.toUpperCase()}',
        status: 'Submitted',
      );

      state = state.copyWith(isSubmitting: false, submissionResult: result);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }
}

final dynamicFormControllerProvider =
    NotifierProvider.family<DynamicFormNotifier, DynamicFormState, String>(
      DynamicFormNotifier.new,
    );
