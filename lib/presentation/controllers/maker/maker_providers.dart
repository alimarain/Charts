import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../data/datasources/maker/maker_service.dart';
import '../../../domain/entities/maker_models.dart';
import '../../../domain/repositories/maker_repository.dart';

final makerRepositoryProvider = Provider<MakerRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return MakerService(dio);
});

// 1. Maker Products Provider
final makerProductsProvider =
    AsyncNotifierProvider<MakerProductsNotifier, List<MakerProduct>>(
      MakerProductsNotifier.new,
    );

class MakerProductsNotifier extends AsyncNotifier<List<MakerProduct>> {
  @override
  Future<List<MakerProduct>> build() async {
    final repository = ref.watch(makerRepositoryProvider);
    return repository.getMakerProducts();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(makerRepositoryProvider).getMakerProducts(),
    );
  }
}

// 2. Maker Forms Family Provider
final makerFormsProvider = FutureProvider.family<List<MakerForm>, String>((
  ref,
  productId,
) async {
  final repository = ref.watch(makerRepositoryProvider);
  return repository.getMakerForms(productId);
});

// 3. Dynamic Fields Family Provider
final dynamicFieldsProvider =
    FutureProvider.family<List<DynamicFormField>, String>((ref, formId) async {
      final repository = ref.watch(makerRepositoryProvider);
      return repository.getFormFields(formId);
    });

// 4. Dynamic Form State Model
class DynamicFormState {
  const DynamicFormState({
    this.answers = const {},
    this.isSubmitting = false,
    this.errorMessage,
    this.submissionResult,
  });

  final Map<String, dynamic> answers;
  final bool isSubmitting;
  final String? errorMessage;
  final ApplicationSubmissionResponse? submissionResult;

  DynamicFormState copyWith({
    Map<String, dynamic>? answers,
    bool? isSubmitting,
    String? errorMessage,
    ApplicationSubmissionResponse? submissionResult,
    bool clearError = false,
  }) {
    return DynamicFormState(
      answers: answers ?? this.answers,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      submissionResult: submissionResult ?? this.submissionResult,
    );
  }
}

// 5. Dynamic Form Notifier Provider (Family-scoped per formId)
final dynamicFormControllerProvider =
    NotifierProvider.family<DynamicFormNotifier, DynamicFormState, String>(
      (arg) => DynamicFormNotifier(),
    );

class DynamicFormNotifier extends Notifier<DynamicFormState> {
  @override
  DynamicFormState build() {
    return const DynamicFormState();
  }

  void updateField(String key, dynamic value) {
    final updated = Map<String, dynamic>.from(state.answers);
    updated[key] = value;
    state = state.copyWith(answers: updated);
  }

  Future<bool> submit(String formId) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final repository = ref.read(makerRepositoryProvider);
      final response = await repository.submitApplication(
        formId: formId,
        answers: state.answers,
      );
      state = state.copyWith(isSubmitting: false, submissionResult: response);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      return false;
    }
  }

  void reset() {
    state = const DynamicFormState();
  }
}
