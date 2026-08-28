import 'dart:async';
import 'dart:math';

import '../../../domain/entities/analytics.dart';
import '../../../presentation/controllers/analytics_state.dart';

class AnalyticsService {
  Stream<AnalyticsData> watchAnalytics(AnalyticsPeriod period) async* {
    final random = Random();

    List<SalesData> generateSales() {
      final multiplier = period == AnalyticsPeriod.ninetyDays
          ? 3.2
          : (period == AnalyticsPeriod.thirtyDays ? 1.8 : 1.0);
      final base = 12000.0 * multiplier;

      return [
        SalesData(label: 'Mon', value: base + random.nextInt(5600)),
        SalesData(label: 'Tue', value: base + random.nextInt(45000)),
        SalesData(label: 'Wed', value: base + random.nextInt(24500)),
        SalesData(label: 'Thu', value: base + random.nextInt(35500)),
        SalesData(label: 'Fri', value: base + random.nextInt(400)),
        SalesData(label: 'Sat', value: base + random.nextInt(500)),
        SalesData(label: 'Sun', value: base + random.nextInt(8800)),
      ];
    }

    List<CategorySalesData> generateCategorySales() {
      final mult = period == AnalyticsPeriod.ninetyDays
          ? 2.8
          : (period == AnalyticsPeriod.thirtyDays ? 1.6 : 1.0);

      return [
        CategorySalesData(
          category: 'Shirts',
          sales: (32000 + random.nextInt(4000)) * mult,
        ),
        CategorySalesData(
          category: 'Hoodies',
          sales: (68000 + random.nextInt(5000)) * mult,
        ),
        CategorySalesData(
          category: 'Jackets',
          sales: (44000 + random.nextInt(6000)) * mult,
        ),
        CategorySalesData(
          category: 'Jeans',
          sales: (59000 + random.nextInt(4000)) * mult,
        ),
        CategorySalesData(
          category: 'Sneakers',
          sales: (81000 + random.nextInt(7000)) * mult,
        ),
        CategorySalesData(
          category: 'Accessories',
          sales: (23000 + random.nextInt(2000)) * mult,
        ),
      ];
    }

    const initialDistribution = [
      ProductDistributionData(category: 'T-Shirts', count: 33),
      ProductDistributionData(category: 'Hoodies', count: 25),
      ProductDistributionData(category: 'Jackets', count: 12),
      ProductDistributionData(category: 'Jeans', count: 18),
      ProductDistributionData(category: 'Sneakers', count: 15),
      ProductDistributionData(category: 'Accessories', count: 10),
    ];

    AnalyticsData createSnapshot() {
      final sales = generateSales();
      final total = sales.fold<double>(0.0, (sum, item) => sum + item.value);

      return AnalyticsData(
        salesData: sales,
        categorySales: generateCategorySales(),
        distribution: initialDistribution,
        totalSales: total,
        totalOrders: 142 + random.nextInt(15),
      );
    }

    await Future.delayed(const Duration(milliseconds: 400));
    yield createSnapshot();

    while (true) {
      await Future.delayed(const Duration(seconds: 10));
      yield createSnapshot();
    }
  }
}
