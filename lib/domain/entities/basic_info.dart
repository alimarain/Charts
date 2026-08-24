class BasicInfo {
  const BasicInfo({
    this.fullName = '',
    this.fatherName = '',
    this.email = '',
    this.phone = '',
    this.dateOfBirth,
    this.gender = 'Male',
    this.city = 'Karachi',
    this.address = '',
  });

  final String fullName;
  final String fatherName;
  final String email;
  final String phone;
  final DateTime? dateOfBirth;
  final String gender;
  final String city;
  final String address;

  BasicInfo copyWith({
    String? fullName,
    String? fatherName,
    String? email,
    String? phone,
    DateTime? dateOfBirth,
    String? gender,
    String? city,
    String? address,
  }) {
    return BasicInfo(
      fullName: fullName ?? this.fullName,
      fatherName: fatherName ?? this.fatherName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      city: city ?? this.city,
      address: address ?? this.address,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'fatherName': fatherName,
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'city': city,
      'address': address,
    };
  }
}