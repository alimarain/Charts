import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/chart_filter_models.dart';
import '../../presentation/controllers/chart_filter_provider.dart';
import 'analytics_csv_service.dart';
import 'analytics_pdf_service.dart';

class AnalyticsExportService {
  /// Captures any widget wrapped in a [RepaintBoundary] as PNG bytes
  static Future<Uint8List?> captureBoundaryAsPng(GlobalKey boundaryKey) async {
    try {
      final boundary =
          boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing widget boundary: $e');
      return null;
    }
  }

  /// Exports and shares the chart image
  static Future<void> exportAndShareImage({
    required GlobalKey boundaryKey,
    required String chartName,
  }) async {
    final imageBytes = await captureBoundaryAsPng(boundaryKey);
    if (imageBytes == null) {
      throw Exception('Could not capture chart as image.');
    }

    if (kIsWeb) {
      await Printing.sharePdf(
        bytes: imageBytes,
        filename: '$chartName-export.png',
      );
    } else {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$chartName-export.png');
      await file.writeAsBytes(imageBytes);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'VibeFlow Chart Export: $chartName',
      );
    }
  }

  /// Exports and shares the analytics CSV report
  static Future<void> exportAndShareCsv({
    required FilteredAnalyticsResult result,
    required ChartFilterState filter,
  }) async {
    final csvString = AnalyticsCsvService.generateCsv(
      result: result,
      filter: filter,
    );
    final bytes = Uint8List.fromList(utf8.encode(csvString));

    if (kIsWeb) {
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'vibeflow-analytics-report.csv',
      );
    } else {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/vibeflow-analytics-report.csv');
      await file.writeAsString(csvString);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'VibeFlow Analytics Data Export (CSV)',
      );
    }
  }

  /// Exports and shares the full PDF report
  static Future<void> exportAndSharePdf({
    required FilteredAnalyticsResult result,
    required ChartFilterState filter,
  }) async {
    final pdfBytes = await AnalyticsPdfService.generatePdfReport(
      result: result,
      filter: filter,
    );

    if (kIsWeb) {
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'vibeflow-analytics-report.pdf',
      );
    } else {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/vibeflow-analytics-report.pdf');
      await file.writeAsBytes(pdfBytes);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'VibeFlow Analytics Executive Report (PDF)',
      );
    }
  }
}