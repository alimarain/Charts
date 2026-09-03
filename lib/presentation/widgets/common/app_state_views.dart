import 'package:flutter/material.dart';

/// Reusable full-container loading spinner adhering to brand primary color.
class AppLoadingView extends StatelessWidget {
  const AppLoadingView({
    super.key,
    this.color = const Color(0xFF1B1638),
    this.strokeWidth = 2.5,
  });

  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: color, strokeWidth: strokeWidth),
    );
  }
}

/// Standardized telemetry and network failure state view with retry capability.
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Retry Connection',
  });

  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Color(0xFFDC2626),
              size: 40,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Color(0xFF374151)),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 14),
              ElevatedButton(onPressed: onRetry, child: Text(retryLabel)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Standardized empty filter state when no metrics fall inside the active window.
class AppEmptyScopeView extends StatelessWidget {
  const AppEmptyScopeView({
    super.key,
    this.message = 'No telemetry available for selected scope.',
    this.onReset,
    this.resetLabel = 'Reset Filters',
  });

  final String message;
  final VoidCallback? onReset;
  final String resetLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.filter_alt_off_rounded,
            size: 40,
            color: Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
          ),
          if (onReset != null) ...[
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onReset, child: Text(resetLabel)),
          ],
        ],
      ),
    );
  }
}
