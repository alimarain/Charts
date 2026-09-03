import 'package:flutter/material.dart';

class HomeTelemetryConsole extends StatelessWidget {
  const HomeTelemetryConsole({
    super.key,
    required this.statusLog,
    required this.hasError,
    required this.isLoading,
    required this.onTestGet,
    required this.onTestError,
  });

  final String statusLog;
  final bool hasError;
  final bool isLoading;
  final VoidCallback onTestGet;
  final VoidCallback onTestError;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.terminal_rounded, size: 16, color: Color(0xFF1B1638)),
              SizedBox(width: 8),
              Text(
                'LIVE API & NETWORKING CONSOLE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasError
                    ? const Color(0xFFDC2626)
                    : const Color(0xFF334155),
              ),
            ),
            child: Text(
              statusLog,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: hasError
                    ? const Color(0xFFFCA5A5)
                    : const Color(0xFF38BDF8),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B1638),
                  foregroundColor: Colors.white,
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: isLoading ? null : onTestGet,
                icon: const Icon(Icons.cloud_download_rounded, size: 14),
                label: const Text(
                  'Test 200 GET /products',
                  style: TextStyle(fontSize: 11),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  side: const BorderSide(color: Color(0xFFFECACA)),
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: isLoading ? null : onTestError,
                icon: const Icon(Icons.warning_amber_rounded, size: 14),
                label: const Text(
                  'Test Error Handling',
                  style: TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
