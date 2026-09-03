import 'package:flutter/material.dart';

class AnalyticsExportMenu extends StatelessWidget {
  const AnalyticsExportMenu({super.key, required this.onExportSelected});

  final ValueChanged<String> onExportSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.ios_share_rounded,
        size: 18,
        color: Color(0xFF6B7280),
      ),
      tooltip: 'Export Reports',
      onSelected: onExportSelected,
      itemBuilder: (ctx) => const [
        PopupMenuItem(
          value: 'pdf',
          child: Row(
            children: [
              Icon(Icons.picture_as_pdf_outlined, color: Colors.red, size: 16),
              SizedBox(width: 8),
              Text('Export PDF Report', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'csv',
          child: Row(
            children: [
              Icon(Icons.table_chart_outlined, color: Colors.green, size: 16),
              SizedBox(width: 8),
              Text('Export Clean CSV', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}
