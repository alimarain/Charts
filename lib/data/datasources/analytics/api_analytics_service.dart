import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../core/network/api_response.dart';
import '../../../domain/entities/analytics.dart';
import '../../../domain/entities/basic_chart_data.dart';

class ApiAnalyticsService {
  final Dio _dio;
  ApiAnalyticsService(this._dio);

  Future<AnalyticsData> getAnalytics() async {
    try {
      final response = await _dio.get('/analytics');
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final data = apiResponse.data!;

        final sales = (data['salesData'] as List<dynamic>)
            .map((e) => SalesData(
                  label: e['label'] as String,
                  value: (e['value'] as num).toDouble(),
                ))
            .toList();

        final categorySales = (data['categorySales'] as List<dynamic>)
            .map((e) => CategorySalesData(
                  category: e['category'] as String,
                  sales: (e['sales'] as num).toDouble(),
                ))
            .toList();

        final distribution = (data['distribution'] as List<dynamic>)
            .map((e) => ProductDistributionData(
                  category: e['category'] as String,
                  count: (e['count'] as num).toInt(),
                ))
            .toList();

        return AnalyticsData(
          salesData: sales,
          categorySales: categorySales,
          distribution: distribution,
          totalSales: (data['totalSales'] as num?)?.toDouble() ?? 0.0,
          totalOrders: (data['totalOrders'] as num?)?.toInt() ?? 0,
        );
      }
      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to load analytics.');
    }
  }

  Future<List<BasicChartData>> getBasicMonthlySales() async {
    try {
      final response = await _dio.get('/charts/basic');
      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as List<dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!.map((item) {
          final map = item as Map<String, dynamic>;
          final hexColor = map['colorHex'] as String? ?? '#38BDF8';
          final parsedColor = Color(int.parse(hexColor.replaceFirst('#', '0xFF')));

          return BasicChartData(
            month: map['month'] as String,
            sales: (map['sales'] as num).toDouble(),
            growthTag: map['growthTag'] as String,
            color: parsedColor,
          );
        }).toList();
      }
      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to load chart data.');
    }
  }
}