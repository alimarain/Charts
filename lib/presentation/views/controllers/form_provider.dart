import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'form_state.dart';

// Non-autoDispose notifier ensures session-scoped retention across UI rebuilds/navigation
final formProvider = NotifierProvider<MultiStepFormNotifier, MultiStepFormState>(() {
  return MultiStepFormNotifier();
});

class MultiStepFormNotifier extends Notifier<MultiStepFormState> {
  @override
  MultiStepFormState build() {
    return const MultiStepFormState();
  }

  // Navigation handlers
  void setStep(int step) {
    if (step >= 0 && step <= 1) {
      state = state.copyWith(currentStep: step);
    }
  }

  void nextStep() {
    if (state.currentStep < 1) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  // Step 1: Basic Information Setters
  void updateFullName(String value) {
    state = state.copyWith(basicInfo: state.basicInfo.copyWith(fullName: value));
  }

  void updateFatherName(String value) {
    state = state.copyWith(basicInfo: state.basicInfo.copyWith(fatherName: value));
  }

  void updateEmail(String value) {
    state = state.copyWith(basicInfo: state.basicInfo.copyWith(email: value));
  }

  void updatePhone(String value) {
    state = state.copyWith(basicInfo: state.basicInfo.copyWith(phone: value));
  }

  void updateDateOfBirth(DateTime? value) {
    state = state.copyWith(basicInfo: state.basicInfo.copyWith(dateOfBirth: value));
  }

  void updateGender(String value) {
    state = state.copyWith(basicInfo: state.basicInfo.copyWith(gender: value));
  }

  void updateCity(String value) {
    state = state.copyWith(basicInfo: state.basicInfo.copyWith(city: value));
  }

  void updateAddress(String value) {
    state = state.copyWith(basicInfo: state.basicInfo.copyWith(address: value));
  }

  // Step 2: Career Information Setters
  void updateHighestEducation(String value) {
    state = state.copyWith(careerInfo: state.careerInfo.copyWith(highestEducation: value));
  }

  void updateUniversity(String value) {
    state = state.copyWith(careerInfo: state.careerInfo.copyWith(university: value));
  }

  void updateCurrentJobTitle(String value) {
    state = state.copyWith(careerInfo: state.careerInfo.copyWith(currentJobTitle: value));
  }

  void updateCompany(String value) {
    state = state.copyWith(careerInfo: state.careerInfo.copyWith(company: value));
  }

  void updateYearsOfExperience(String value) {
    state = state.copyWith(careerInfo: state.careerInfo.copyWith(yearsOfExperience: value));
  }

  void updateExpectedSalary(String value) {
    state = state.copyWith(careerInfo: state.careerInfo.copyWith(expectedSalary: value));
  }

  void updateSkills(String value) {
    state = state.copyWith(careerInfo: state.careerInfo.copyWith(skills: value));
  }

  void updateCareerGoal(String value) {
    state = state.copyWith(careerInfo: state.careerInfo.copyWith(careerGoal: value));
  }

  // Data Submission
  Map<String, dynamic> getCompleteFormData() {
    final payload = {
      'basic_information': state.basicInfo.toMap(),
      'career_information': state.careerInfo.toMap(),
    };
    developer.log('Collected Form Payload: $payload', name: 'MultiStepForm');
    return payload;
  }

  void resetForm() {
    state = const MultiStepFormState();
  }
}