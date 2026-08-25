import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_app/presentation/views/controllers/form_provider.dart';
import 'package:new_app/presentation/views/controllers/submission_provider.dart';

class CareerInfoStep extends ConsumerStatefulWidget {
  const CareerInfoStep({required this.formKey, super.key});

  final GlobalKey<FormState> formKey;

  @override
  ConsumerState<CareerInfoStep> createState() => _CareerInfoStepState();
}

class _CareerInfoStepState extends ConsumerState<CareerInfoStep> {
  late final TextEditingController _universityController;
  late final TextEditingController _jobTitleController;
  late final TextEditingController _companyController;
  late final TextEditingController _experienceController;
  late final TextEditingController _salaryController;
  late final TextEditingController _skillsController;
  late final TextEditingController _goalController;

  static const List<String> _educationLevels = [
    'Matric / O-Levels',
    'Intermediate / A-Levels',
    'Bachelors',
    'Masters',
    'PhD'
  ];

  @override
  void initState() {
    super.initState();
    final careerInfo = ref.read(formProvider).careerInfo;
    _universityController = TextEditingController(text: careerInfo.university);
    _jobTitleController = TextEditingController(text: careerInfo.currentJobTitle);
    _companyController = TextEditingController(text: careerInfo.company);
    _experienceController = TextEditingController(text: careerInfo.yearsOfExperience);
    _salaryController = TextEditingController(text: careerInfo.expectedSalary);
    _skillsController = TextEditingController(text: careerInfo.skills);
    _goalController = TextEditingController(text: careerInfo.careerGoal);
  }

  @override
  void dispose() {
    _universityController.dispose();
    _jobTitleController.dispose();
    _companyController.dispose();
    _experienceController.dispose();
    _salaryController.dispose();
    _skillsController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(formProvider.notifier);
    final careerInfo = ref.watch(formProvider.select((s) => s.careerInfo));
    final submissionState = ref.watch(submissionProvider);
    final isLocked = submissionState.isSubmitting;

    return Form(
      key: widget.formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Professional Experience & Education',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: careerInfo.highestEducation,
              decoration: const InputDecoration(labelText: 'Highest Education *', prefixIcon: Icon(Icons.school_outlined)),
              items: _educationLevels.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: isLocked ? null : (val) => val != null ? notifier.updateHighestEducation(val) : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _universityController,
              enabled: !isLocked,
              decoration: const InputDecoration(labelText: 'University / Institute *', prefixIcon: Icon(Icons.account_balance_outlined)),
              onChanged: notifier.updateUniversity,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'University is required' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _jobTitleController,
                    enabled: !isLocked,
                    decoration: const InputDecoration(labelText: 'Current Job Title', prefixIcon: Icon(Icons.work_outline)),
                    onChanged: notifier.updateCurrentJobTitle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _companyController,
                    enabled: !isLocked,
                    decoration: const InputDecoration(labelText: 'Company Name', prefixIcon: Icon(Icons.business_outlined)),
                    onChanged: notifier.updateCompany,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _experienceController,
                    enabled: !isLocked,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Experience (Years) *', prefixIcon: Icon(Icons.timelapse_outlined)),
                    onChanged: notifier.updateYearsOfExperience,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (double.tryParse(v.trim()) == null) return 'Must be a number';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _salaryController,
                    enabled: !isLocked,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Exp. Salary (PKR) *', prefixIcon: Icon(Icons.payments_outlined)),
                    onChanged: notifier.updateExpectedSalary,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (double.tryParse(v.trim()) == null) return 'Must be a number';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _skillsController,
              enabled: !isLocked,
              decoration: const InputDecoration(
                labelText: 'Key Skills (e.g. Flutter, Dart, Riverpod) *',
                prefixIcon: Icon(Icons.star_outline),
              ),
              onChanged: notifier.updateSkills,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Skills are required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _goalController,
              enabled: !isLocked,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Career Goal *',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              onChanged: notifier.updateCareerGoal,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Career goal is required' : null,
            ),
            if (submissionState.isSubmitting || submissionState.isSuccess) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          submissionState.message,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        Text(
                          '${(submissionState.progress * 100).toInt()}%',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: submissionState.progress,
                      backgroundColor: Colors.blue.shade100,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ],
            if (submissionState.isFailure && submissionState.errorMessage != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        submissionState.errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}