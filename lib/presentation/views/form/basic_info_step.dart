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
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Basic Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                prefixIcon: Icon(Icons.person_outline),
              ),
              onChanged: notifier.updateFullName,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Full name is required'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _fatherNameController,
              decoration: const InputDecoration(
                labelText: 'Father Name *',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              onChanged: notifier.updateFatherName,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Father name is required'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Address *',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              onChanged: notifier.updateEmail,
              validator: Validators.validateEmail,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              onChanged: notifier.updatePhone,
              validator: (v) {
                if (v == null || v.trim().isEmpty)
                  return 'Phone number is required';
                if (v.trim().length < 10) return 'Enter a valid phone number';
                return null;
              },
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _pickDate(context),
              borderRadius: BorderRadius.circular(10),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date of Birth *',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                child: Text(
                  basicInfo.dateOfBirth != null
                      ? '${basicInfo.dateOfBirth!.day}/${basicInfo.dateOfBirth!.month}/${basicInfo.dateOfBirth!.year}'
                      : 'Select Date of Birth',
                  style: TextStyle(
                    color: basicInfo.dateOfBirth != null
                        ? Colors.black87
                        : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: basicInfo.gender,
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items: _genders
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (val) =>
                        val != null ? notifier.updateGender(val) : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: basicInfo.city,
                    decoration: const InputDecoration(labelText: 'City'),
                    items: _cities
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) =>
                        val != null ? notifier.updateCity(val) : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Residential Address *',
                prefixIcon: Icon(Icons.home_outlined),
              ),
              onChanged: notifier.updateAddress,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Address is required'
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
