import '../entities/maker_models.dart';

abstract class MakerRepository {
  Future<List<MakerProduct>> getMakerProducts();
  Future<List<MakerForm>> getMakerForms(String productId);
  Future<List<DynamicFormField>> getFormFields(String formId);
  Future<ApplicationSubmissionResponse> submitApplication({
    required String formId,
    required Map<String, dynamic> answers,
  });
}