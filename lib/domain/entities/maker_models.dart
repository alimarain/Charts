class MakerProduct {
  const MakerProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.status,
    required this.formCount,
    required this.iconName,
  });

  final String id;
  final String name;
  final String description;
  final String category;
  final String status;
  final int formCount;
  final String iconName;

  factory MakerProduct.fromJson(Map<String, dynamic> json) {
    return MakerProduct(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      formCount: (json['formCount'] as num?)?.toInt() ?? 0,
      iconName: json['iconName'] as String? ?? 'business',
    );
  }
}

class MakerForm {
  const MakerForm({
    required this.id,
    required this.productId,
    required this.title,
    required this.description,
    required this.fieldCount,
  });

  final String id;
  final String productId;
  final String title;
  final String description;
  final int fieldCount;

  factory MakerForm.fromJson(Map<String, dynamic> json) {
    return MakerForm(
      id: json['id'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      fieldCount: (json['fieldCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class DynamicFormField {
  const DynamicFormField({
    required this.id,
    required this.key,
    required this.label,
    required this.type,
    required this.required,
    this.options = const [],
    this.placeholder,
    this.defaultValue,
  });

  final String id;
  final String key;
  final String label;
  final String type;
  final bool required;
  final List<String> options;
  final String? placeholder;
  final dynamic defaultValue;

  factory DynamicFormField.fromJson(Map<String, dynamic> json) {
    return DynamicFormField(
      id: json['id'] as String? ?? '',
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '',
      type: json['type'] as String? ?? 'text',
      required: json['required'] as bool? ?? false,
      options:
          (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      placeholder: json['placeholder'] as String?,
      defaultValue: json['defaultValue'],
    );
  }
}

class ApplicationSubmissionResponse {
  const ApplicationSubmissionResponse({
    required this.applicationId,
    required this.referenceNumber,
    required this.status,
    required this.submittedAt,
  });

  final String applicationId;
  final String referenceNumber;
  final String status;
  final String submittedAt;

  factory ApplicationSubmissionResponse.fromJson(Map<String, dynamic> json) {
    return ApplicationSubmissionResponse(
      applicationId: json['applicationId'] as String? ?? '',
      referenceNumber: json['referenceNumber'] as String? ?? '',
      status: json['status'] as String? ?? '',
      submittedAt: json['submittedAt'] as String? ?? '',
    );
  }
}
