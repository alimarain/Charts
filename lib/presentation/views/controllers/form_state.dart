import 'package:new_app/domain/entities/basic_info.dart';
import 'package:new_app/domain/entities/career_info.dart';


class MultiStepFormState {
  const MultiStepFormState({
    this.currentStep = 0,
    this.basicInfo = const BasicInfo(),
    this.careerInfo = const CareerInfo(),
    this.isStep1Valid = false,
    this.isStep2Valid = false,
  });

  final int currentStep;
  final BasicInfo basicInfo;
  final CareerInfo careerInfo;
  final bool isStep1Valid;
  final bool isStep2Valid;

  MultiStepFormState copyWith({
    int? currentStep,
    BasicInfo? basicInfo,
    CareerInfo? careerInfo,
    bool? isStep1Valid,
    bool? isStep2Valid,
  }) {
    return MultiStepFormState(
      currentStep: currentStep ?? this.currentStep,
      basicInfo: basicInfo ?? this.basicInfo,
      careerInfo: careerInfo ?? this.careerInfo,
      isStep1Valid: isStep1Valid ?? this.isStep1Valid,
      isStep2Valid: isStep2Valid ?? this.isStep2Valid,
    );
  }
}