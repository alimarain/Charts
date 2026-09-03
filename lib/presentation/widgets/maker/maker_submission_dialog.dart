import 'package:flutter/material.dart';
import 'package:new_app/presentation/controllers/maker_provider.dart';

class MakerSubmissionDialog extends StatelessWidget {
  const MakerSubmissionDialog({
    super.key,
    required this.result,
    required this.onDismiss,
  });

  final SubmissionResult? result;
  final VoidCallback onDismiss;

  static void show(
    BuildContext context, {
    required SubmissionResult? result,
    required VoidCallback onDismiss,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          MakerSubmissionDialog(result: result, onDismiss: onDismiss),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.check_circle_rounded, color: Color(0xFF059669)),
          SizedBox(width: 8),
          Text('Application Submitted'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('App ID: ${result?.applicationId ?? "N/A"}'),
          Text('Ref No: ${result?.referenceNumber ?? "N/A"}'),
          Text('Status: ${result?.status ?? "N/A"}'),
          const SizedBox(height: 8),
          const Text(
            'Case routed to Credit Risk Officer (Checker Queue).',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: onDismiss,
          child: const Text('Return to Templates'),
        ),
      ],
    );
  }
}
