class InsightsResponseDto {
  const InsightsResponseDto({
    required this.clientId,
    required this.period,
    required this.sections,
  });

  final String clientId;
  final String period;
  final List<InsightSectionDto> sections;

  factory InsightsResponseDto.fromJson(Map<String, dynamic> json) {
    return InsightsResponseDto(
      clientId: json['clientId']?.toString() ?? '',
      period: json['period']?.toString() ?? '',
      sections: (json['sections'] as List<dynamic>? ?? [])
          .map((s) => InsightSectionDto.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  InsightSectionDto? getSection(String name) {
    try {
      return sections.firstWhere(
        (s) => s.sectionName.trim().toLowerCase() == name.trim().toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  // --- Card 1: Spending Mappers ---
  double get totalSpent => getSection('Spending')?.total ?? 0.0;
  double get billsSpent => getSection('Spending')?.getNumericField('Bills & Utilities') ?? 0.0;
  double get grocerySpent => getSection('Spending')?.getNumericField('Grocery') ?? 0.0;
  double get shoppingSpent => getSection('Spending')?.getNumericField('Shopping') ?? 0.0;
  double get otherSpent {
    final s = getSection('Spending');
    if (s == null) return 0.0;
    // Sum all non-major fields
    double others = 0.0;
    for (final f in s.fields) {
      if (['Food & Dining', 'Travel & Hotels', 'Transport', 'Healthcare', 'Donations', 'Entertainment', 'Other Spending']
          .contains(f.name)) {
        others += f.numericValue;
      }
    }
    return others;
  }

  // --- Card 2: Cash Flow Mappers ---
  double get cashFlowNet => getSection('Cash Flow')?.total ?? 0.0;
  double get moneyIn => getSection('Cash Flow')?.getNumericField('Money In') ?? 0.0;
  double get moneyOut => getSection('Cash Flow')?.getNumericField('Money Out') ?? 0.0;

  // --- Card 3: Profit Mappers ---
  double get totalProfit => getSection('Profit')?.total ?? 0.0;
  double get accountsProfit => getSection('Profit')?.getNumericField('Accounts Profit') ?? 0.0;
  double get mudarabahProfit => getSection('Profit')?.getNumericField('Mudarabah Profit') ?? 0.0;
  double get potsProfit => getSection('Profit')?.getNumericField('Pots Profit') ?? 0.0;

  // --- Card 4: Assets & Asset Allocation Mappers ---
  double get totalAssets => getSection('Assets')?.total ?? 0.0;
  double get accountsAllocationRatio {
    final raw = getSection('Asset Allocation')?.getNumericField('Accounts Allocation %') ?? 50.0;
    return raw / 100.0;
  }
  double get mudarabahAllocationRatio {
    final raw = getSection('Asset Allocation')?.getNumericField('Mudarabah Allocation %') ?? 50.0;
    return raw / 100.0;
  }
}

class InsightSectionDto {
  const InsightSectionDto({
    required this.sectionName,
    this.total,
    required this.fields,
  });

  final String sectionName;
  final double? total;
  final List<InsightFieldDto> fields;

  factory InsightSectionDto.fromJson(Map<String, dynamic> json) {
    return InsightSectionDto(
      sectionName: json['sectionName']?.toString() ?? '',
      total: (json['total'] as num?)?.toDouble(),
      fields: (json['fields'] as List<dynamic>? ?? [])
          .map((f) => InsightFieldDto.fromJson(f as Map<String, dynamic>))
          .toList(),
    );
  }

  double getNumericField(String name) {
    try {
      final f = fields.firstWhere(
        (e) => e.name.trim().toLowerCase() == name.trim().toLowerCase(),
      );
      return f.numericValue;
    } catch (_) {
      return 0.0;
    }
  }

  String getStringField(String name) {
    try {
      final f = fields.firstWhere(
        (e) => e.name.trim().toLowerCase() == name.trim().toLowerCase(),
      );
      return f.value?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }
}

class InsightFieldDto {
  const InsightFieldDto({required this.name, required this.value});

  final String name;
  final dynamic value;

  factory InsightFieldDto.fromJson(Map<String, dynamic> json) {
    return InsightFieldDto(
      name: json['name']?.toString() ?? '',
      value: json['value'],
    );
  }

  double get numericValue {
    if (value is num) return (value as num).toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}