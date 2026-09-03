import 'package:flutter/material.dart';
import '../../models/chart_config.dart';
import '../../models/chart_type.dart';

class ChartHeaderToolbar extends StatelessWidget {
  const ChartHeaderToolbar({
    super.key,
    required this.config,
    required this.activeChartType,
    required this.isFullscreenMode,
    required this.onTypeSelected,
    required this.onExportImage,
    this.onFullscreenTap,
  });

  final ChartConfig config;
  final UniversalChartType activeChartType;
  final bool isFullscreenMode;
  final ValueChanged<UniversalChartType> onTypeSelected;
  final VoidCallback onExportImage;
  final VoidCallback? onFullscreenTap;

  @override
  Widget build(BuildContext context) {
    if (config.title == null) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                config.title!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF0F172A),
                ),
              ),
              if (config.subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  config.subtitle!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (config.enableFullscreen && !isFullscreenMode && onFullscreenTap != null)
              IconButton(
                icon: const Icon(
                  Icons.fullscreen_rounded,
                  size: 20,
                  color: Color(0xFF64748B),
                ),
                tooltip: 'Full Screen View',
                onPressed: onFullscreenTap,
              ),
            if (config.enableChartTypeSwitching || config.enableExport)
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  size: 20,
                  color: Color(0xFF64748B),
                ),
                onSelected: (action) {
                  if (action == 'fullscreen') {
                    onFullscreenTap?.call();
                  } else if (action == 'export_image') {
                    onExportImage();
                  } else if (action.startsWith('type_')) {
                    final typeName = action.replaceFirst('type_', '');
                    final match = UniversalChartType.values.firstWhere(
                      (e) => e.name == typeName,
                      orElse: () => activeChartType,
                    );
                    onTypeSelected(match);
                  }
                },
                itemBuilder: (ctx) => [
                  if (config.enableFullscreen && !isFullscreenMode && onFullscreenTap != null)
                    const PopupMenuItem(
                      value: 'fullscreen',
                      child: Row(
                        children: [
                          Icon(Icons.fullscreen, size: 16),
                          SizedBox(width: 8),
                          Text('View Full Screen'),
                        ],
                      ),
                    ),
                  if (config.supportedChartTypes.isNotEmpty) ...[
                    const PopupMenuDivider(),
                    ...config.supportedChartTypes.map(
                      (type) => PopupMenuItem(
                        value: 'type_${type.name}',
                        child: Text('Chart Type: ${type.name.toUpperCase()}'),
                      ),
                    ),
                  ],
                  if (config.enableExport) ...[
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'export_image',
                      child: Row(
                        children: [
                          Icon(Icons.image_outlined, size: 16),
                          SizedBox(width: 8),
                          Text('Export Chart Image'),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ],
    );
  }
}