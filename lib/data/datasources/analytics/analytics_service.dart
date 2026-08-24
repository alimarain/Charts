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
        SalesData(label: 'Mon', value: base + random.nextInt(2000)),
        SalesData(label: 'Tue', value: base + random.nextInt(3000)),
        SalesData(label: 'Wed', value: base + random.nextInt(2500)),
        SalesData(label: 'Thu', value: base + random.nextInt(3500)),
        SalesData(label: 'Fri', value: base + random.nextInt(4500)),
        SalesData(label: 'Sat', value: base + random.nextInt(5500)),
        SalesData(label: 'Sun', value: base + random.nextInt(4800)),
      ];
    }

    List<CategorySalesData> generateCategorySales() {
      final mult = period == AnalyticsPeriod.ninetyDays
          ? 2.8
          : (period == AnalyticsPeriod.thirtyDays ? 1.6 : 1.0);

      return [
        CategorySalesData(category: 'T-Shirts', sales: (42000 + random.nextInt(4000)) * mult),
        CategorySalesData(category: 'Hoodies', sales: (58000 + random.nextInt(5000)) * mult),
        CategorySalesData(category: 'Jackets', sales: (64000 + random.nextInt(6000)) * mult),
        CategorySalesData(category: 'Jeans', sales: (49000 + random.nextInt(4000)) * mult),
        CategorySalesData(category: 'Sneakers', sales: (71000 + random.nextInt(7000)) * mult),
        CategorySalesData(category: 'Accessories', sales: (23000 + random.nextInt(2000)) * mult),
      ];
    }

    const initialDistribution = [
      ProductDistributionData(category: 'T-Shirts', count: 30),
      ProductDistributionData(category: 'Hoodies', count: 20),
      ProductDistributionData(category: 'Jackets', count: 12),
      ProductDistributionData(category: 'Jeans', count: 18),
      ProductDistributionData(category: 'Sneakers', count: 15),
      ProductDistributionData(category: 'Accessories', count: 10),
    ];

    await Future.delayed(const Duration(milliseconds: 400));
    yield AnalyticsData(
      weeklySales: generateSales(),
      categorySales: generateCategorySales(),
      distribution: initialDistribution,
    );

    while (true) {
      await Future.delayed(const Duration(seconds: 10));
      yield AnalyticsData(
        weeklySales: generateSales(),
        categorySales: generateCategorySales(),
        distribution: initialDistribution,
      );
    }
  }
}