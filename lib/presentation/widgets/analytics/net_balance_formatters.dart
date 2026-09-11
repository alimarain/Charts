class NetBalanceFormatters {
  static String currency(double amount) {
    return 'Rs. ${amount.abs().toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  static String compact(double amount) {
    return 'RS. ${(amount.abs() / 1000).toStringAsFixed(0)}K';
  }

  static String yAxisLabel(double val) {
    final sign = val < 0 ? '-' : '';
    final absVal = val.abs();
    final formatted = absVal >= 1000000
        ? '${(absVal / 1000000).toStringAsFixed(1)}M'
        : '${(absVal / 1000).toStringAsFixed(0)}K';
    return '$sign$formatted';
  }
}
