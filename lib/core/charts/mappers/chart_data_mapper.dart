import '../models/chart_data.dart';

/// Signature for generic domain-to-chart data transformation functions.
typedef ChartDataMapper<T> = ChartDataPoint Function(T item);
