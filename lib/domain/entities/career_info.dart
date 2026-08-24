class CareerInfo {
  const CareerInfo({
    this.highestEducation = 'Bachelors',
    this.university = '',
    this.currentJobTitle = '',
    this.company = '',
    this.yearsOfExperience = '',
    this.expectedSalary = '',
    this.skills = '',
    this.careerGoal = '',
  });

  final String highestEducation;
  final String university;
  final String currentJobTitle;
  final String company;
  final String yearsOfExperience;
  final String expectedSalary;
  final String skills;
  final String careerGoal;

  CareerInfo copyWith({
    String? highestEducation,
    String? university,
    String? currentJobTitle,
    String? company,
    String? yearsOfExperience,
    String? expectedSalary,
    String? skills,
    String? careerGoal,
  }) {
    return CareerInfo(
      highestEducation: highestEducation ?? this.highestEducation,
      university: university ?? this.university,
      currentJobTitle: currentJobTitle ?? this.currentJobTitle,
      company: company ?? this.company,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      expectedSalary: expectedSalary ?? this.expectedSalary,
      skills: skills ?? this.skills,
      careerGoal: careerGoal ?? this.careerGoal,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'highestEducation': highestEducation,
      'university': university,
      'currentJobTitle': currentJobTitle,
      'company': company,
      'yearsOfExperience': yearsOfExperience,
      'expectedSalary': expectedSalary,
      'skills': skills,
      'careerGoal': careerGoal,
    };
  }
}