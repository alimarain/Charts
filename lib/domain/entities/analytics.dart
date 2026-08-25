class SalesData {
  const SalesData({required this.label, required this.value});

  final String label;
  final double value;

  factory SalesData.fromJson(Map<String, dynamic> json) {
    return SalesData(
      label: json['label'] as String? ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CategorySalesData {
  const CategorySalesData({required this.category, required this.sales});

  final String category;
  final double sales;

  factory CategorySalesData.fromJson(Map<String, dynamic> json) {
    return CategorySalesData(
      category: json['category'] as String? ?? '',
      sales: (json['sales'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ProductDistributionData {
  const ProductDistributionData({required this.category, required this.count});

  final String category;
  final int count;

  factory ProductDistributionData.fromJson(Map<String, dynamic> json) {
    return ProductDistributionData(
      category: json['category'] as String? ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}

class AnalyticsData {
  const AnalyticsData({
    required this.salesData,
    required this.categorySales,
    required this.distribution,
    this.totalSales,
    this.totalOrders = 0,
  });

  final List<SalesData> salesData;
  final List<CategorySalesData> categorySales;
  final List<ProductDistributionData> distribution;
  final double? totalSales;
  final int totalOrders;

  // Compatibility getters
  List<SalesData> get weeklySales => salesData;
  List<SalesData> get sales => salesData;
  double get totalRevenue =>
      totalSales ??
      salesData.fold<double>(0.0, (sum, item) => sum + item.value);

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    return AnalyticsData(
      salesData:
          (json['salesData'] as List<dynamic>?)
              ?.map(
                (e) => SalesData.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .toList() ??
          (json['weeklySales'] as List<dynamic>?)
              ?.map(
                (e) => SalesData.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .toList() ??
          const [],
      categorySales:
          (json['categorySales'] as List<dynamic>?)
              ?.map(
                (e) => CategorySalesData.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList() ??
          const [],
      distribution:
          (json['distribution'] as List<dynamic>?)
              ?.map(
                (e) => ProductDistributionData.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList() ??
          const [],
      totalSales: (json['totalSales'] as num?)?.toDouble(),
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
    );
  }
}
