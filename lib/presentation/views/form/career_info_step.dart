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
    'PhD',
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Education Configuration
          _CareerFormSection(
            title: 'Education Profile',
            subtitle: 'Academic background and credentials.',
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _CareerLabel(label: 'Highest Education', isRequired: true),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: careerInfo.highestEducation,
                          decoration: _inputDecoration(),
                          items: _educationLevels
                              .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13))))
                              .toList(),
                          onChanged: isLocked ? null : (val) => val != null ? notifier.updateHighestEducation(val) : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _CareerLabel(label: 'University / Institute', isRequired: true),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _universityController,
                          enabled: !isLocked,
                          style: const TextStyle(fontSize: 13),
                          decoration: _inputDecoration(hint: 'e.g. University of Karachi'),
                          onChanged: notifier.updateUniversity,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'University is required' : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 48, color: Color(0xFFE5E7EB)),

          // Section 2: Professional Details
          _CareerFormSection(
            title: 'Professional Details',
            subtitle: 'Employment experience and salary.',
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _CareerLabel(label: 'Current Job Title'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _jobTitleController,
                          enabled: !isLocked,
                          style: const TextStyle(fontSize: 13),
                          decoration: _inputDecoration(hint: 'e.g. Software Engineer'),
                          onChanged: notifier.updateCurrentJobTitle,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _CareerLabel(label: 'Company Name'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _companyController,
                          enabled: !isLocked,
                          style: const TextStyle(fontSize: 13),
                          decoration: _inputDecoration(hint: 'e.g. Acme Tech'),
                          onChanged: notifier.updateCompany,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _CareerLabel(label: 'Years of Experience', isRequired: true),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _experienceController,
                          enabled: !isLocked,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 13),
                          decoration: _inputDecoration(hint: 'e.g. 3'),
                          onChanged: notifier.updateYearsOfExperience,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            if (double.tryParse(v.trim()) == null) return 'Enter number';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _CareerLabel(label: 'Expected Salary (PKR)', isRequired: true),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _salaryController,
                          enabled: !isLocked,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 13),
                          decoration: _inputDecoration(hint: 'e.g. 150000'),
                          onChanged: notifier.updateExpectedSalary,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            if (double.tryParse(v.trim()) == null) return 'Enter number';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 48, color: Color(0xFFE5E7EB)),

          // Section 3: Skills & Goals
          _CareerFormSection(
            title: 'Skills & Disclosure',
            subtitle: 'Competencies and objectives.',
            children: [
              const _CareerLabel(label: 'Key Skills', isRequired: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _skillsController,
                enabled: !isLocked,
                style: const TextStyle(fontSize: 13),
                decoration: _inputDecoration(hint: 'e.g. Flutter, ASP.NET Core, SQL'),
                onChanged: notifier.updateSkills,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Skills are required' : null,
              ),
              const SizedBox(height: 16),
              const _CareerLabel(label: 'Career Goal', isRequired: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _goalController,
                enabled: !isLocked,
                maxLines: 2,
                style: const TextStyle(fontSize: 13),
                decoration: _inputDecoration(hint: 'Brief summary of objectives...'),
                onChanged: notifier.updateCareerGoal,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Goal is required' : null,
              ),

              // Upload stream progress
              if (submissionState.isSubmitting || submissionState.isSuccess) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFC7D2FE)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            submissionState.message,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF3730A3)),
                          ),
                          Text(
                            '${(submissionState.progress * 100).toInt()}%',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF4F46E5)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: submissionState.progress,
                        backgroundColor: const Color(0xFFE0E7FF),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF1B1638), width: 1.5),
      ),
    );
  }
}

class _CareerFormSection extends StatelessWidget {
  const _CareerFormSection({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 700;

        final header = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
            ),
          ],
        );

        final fields = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        );

        if (isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: header),
              const SizedBox(width: 24),
              Expanded(flex: 7, child: fields),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            const SizedBox(height: 16),
            fields,
          ],
        );
      },
    );
  }
}

class _CareerLabel extends StatelessWidget {
  const _CareerLabel({required this.label, this.isRequired = false});

  final String label;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF374151),
        ),
        children: [
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }
}