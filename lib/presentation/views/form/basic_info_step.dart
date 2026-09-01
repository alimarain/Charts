import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_app/presentation/views/controllers/form_provider.dart';
import '../../../core/utils/validators.dart';

class BasicInfoStep extends ConsumerStatefulWidget {
  const BasicInfoStep({required this.formKey, super.key});

  final GlobalKey<FormState> formKey;

  @override
  ConsumerState<BasicInfoStep> createState() => _BasicInfoStepState();
}

class _BasicInfoStepState extends ConsumerState<BasicInfoStep> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _fatherNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  static const List<String> _genders = ['Male', 'Female', 'Other'];
  static const List<String> _cities = [
    'Karachi',
    'Lahore',
    'Islamabad',
    'Rawalpindi',
    'Peshawar',
    'Quetta',
  ];

  @override
  void initState() {
    super.initState();
    final basicInfo = ref.read(formProvider).basicInfo;
    _fullNameController = TextEditingController(text: basicInfo.fullName);
    _fatherNameController = TextEditingController(text: basicInfo.fatherName);
    _emailController = TextEditingController(text: basicInfo.email);
    _phoneController = TextEditingController(text: basicInfo.phone);
    _addressController = TextEditingController(text: basicInfo.address);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _fatherNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final currentDob =
        ref.read(formProvider).basicInfo.dateOfBirth ?? DateTime(2000, 1, 1);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDob,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      ref.read(formProvider.notifier).updateDateOfBirth(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(formProvider.notifier);
    final basicInfo = ref.watch(formProvider.select((s) => s.basicInfo));

    return Form(
      key: widget.formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Basic Identification
          _FormSection(
            title: 'Basic Configuration',
            subtitle: 'Identification and classification details.',
            children: [
              const _FieldLabel(label: 'Full Legal Name', isRequired: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _fullNameController,
                style: const TextStyle(fontSize: 13),
                decoration: _inputDecoration(hint: 'e.g. Ali Muhammad'),
                onChanged: notifier.updateFullName,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Full name is required'
                    : null,
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 450;

                  final emailField = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FieldLabel(label: 'Official Email', isRequired: true),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(fontSize: 13),
                        decoration: _inputDecoration(hint: 'name@company.com'),
                        onChanged: notifier.updateEmail,
                        validator: Validators.validateEmail,
                      ),
                    ],
                  );

                  final genderField = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FieldLabel(label: 'Gender'),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _genders.map((g) {
                          final isSelected = basicInfo.gender == g;
                          return ChoiceChip(
                            label: Text(
                              g,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF4B5563),
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: const Color(0xFF1B1638),
                            backgroundColor: const Color(0xFFF3F4F6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            onSelected: (sel) {
                              if (sel) notifier.updateGender(g);
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  );

                  if (isNarrow) {
                    return Column(
                      children: [
                        emailField,
                        const SizedBox(height: 14),
                        genderField,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: emailField),
                      const SizedBox(width: 16),
                      Expanded(child: genderField),
                    ],
                  );
                },
              ),
            ],
          ),
          const Divider(height: 48, color: Color(0xFFE5E7EB)),

          // Section 2: Allocation & Demographics
          _FormSection(
            title: 'Allocation Details',
            subtitle: 'Contact and location parameters.',
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 450;

                  final guardianField = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FieldLabel(
                        label: 'Father / Guardian Name',
                        isRequired: true,
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _fatherNameController,
                        style: const TextStyle(fontSize: 13),
                        decoration: _inputDecoration(hint: 'Guardian Full Name'),
                        onChanged: notifier.updateFatherName,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Father name is required'
                            : null,
                      ),
                    ],
                  );

                  final cityField = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FieldLabel(
                        label: 'Residential City',
                        isRequired: true,
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: basicInfo.city,
                        decoration: _inputDecoration(),
                        items: _cities
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c,
                                      style: const TextStyle(fontSize: 13)),
                                ))
                            .toList(),
                        onChanged: (val) =>
                            val != null ? notifier.updateCity(val) : null,
                      ),
                    ],
                  );

                  if (isNarrow) {
                    return Column(
                      children: [
                        guardianField,
                        const SizedBox(height: 14),
                        cityField,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: guardianField),
                      const SizedBox(width: 16),
                      Expanded(child: cityField),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 450;

                  final dobField = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FieldLabel(
                        label: 'Date of Birth',
                        isRequired: true,
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () => _pickDate(context),
                        borderRadius: BorderRadius.circular(8),
                        child: InputDecorator(
                          decoration: _inputDecoration(
                            suffixIcon: const Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                            ),
                          ),
                          child: Text(
                            basicInfo.dateOfBirth != null
                                ? '${basicInfo.dateOfBirth!.year}-${basicInfo.dateOfBirth!.month.toString().padLeft(2, '0')}-${basicInfo.dateOfBirth!.day.toString().padLeft(2, '0')}'
                                : 'yyyy-mm-dd',
                            style: TextStyle(
                              fontSize: 13,
                              color: basicInfo.dateOfBirth != null
                                  ? const Color(0xFF111827)
                                  : const Color(0xFF9CA3AF),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );

                  final phoneField = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FieldLabel(label: 'Phone Contact', isRequired: true),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(fontSize: 13),
                        decoration: _inputDecoration(hint: '+92 300 1234567'),
                        onChanged: notifier.updatePhone,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Phone is required'
                            : null,
                      ),
                    ],
                  );

                  if (isNarrow) {
                    return Column(
                      children: [
                        dobField,
                        const SizedBox(height: 14),
                        phoneField,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: dobField),
                      const SizedBox(width: 16),
                      Expanded(child: phoneField),
                    ],
                  );
                },
              ),
            ],
          ),
          const Divider(height: 48, color: Color(0xFFE5E7EB)),

          // Section 3: Notes & Location
          _FormSection(
            title: 'Notes & Disclosure',
            subtitle: 'Supplementary address information.',
            children: [
              TextFormField(
                controller: _addressController,
                maxLines: 3,
                style: const TextStyle(fontSize: 13),
                decoration: _inputDecoration(
                  hint: 'Residential address or location details...',
                ),
                onChanged: notifier.updateAddress,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Address is required' : null,
              ),
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: Color(0xFF059669),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Auto-Audit is enabled by default for applicant identity records.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF047857),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      suffixIcon: suffixIcon,
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

class _FormSection extends StatelessWidget {
  const _FormSection({
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
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
            ),
          ],
        );

        final formFields = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        );

        if (isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: header),
              const SizedBox(width: 24),
              Expanded(flex: 7, child: formFields),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            const SizedBox(height: 16),
            formFields,
          ],
        );
      },
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, this.isRequired = false});

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
              style: TextStyle(
                color: Color(0xFFDC2626),
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}