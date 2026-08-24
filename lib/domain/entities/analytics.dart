class SalesData {
  const SalesData({
    required this.label,
    required this.value,
  });

  final String label;
  final double value;
}

class CategorySalesData {
  const CategorySalesData({
    required this.category,
    required this.sales,
  });

  final String category;
  final double sales;
}

class ProductDistributionData {
  const ProductDistributionData({
    required this.category,
    required this.count,
  });

  final String category;
  final int count;
}

class AnalyticsData {
  const AnalyticsData({
    required this.weeklySales,
    required this.categorySales,
    required this.distribution,
  });

  final List<SalesData> weeklySales;
  final List<CategorySalesData> categorySales;
  final List<ProductDistributionData> distribution;
}