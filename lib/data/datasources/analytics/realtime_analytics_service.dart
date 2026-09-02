import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:new_app/core/config/api_config.dart';
import 'package:new_app/core/storage/token_storage.dart';
import 'package:new_app/domain/entities/analytics.dart';
import 'package:new_app/domain/entities/basic_chart_data.dart';
import 'package:signalr_netcore/signalr_client.dart';

class RealtimeAnalyticsService {
  RealtimeAnalyticsService(this._tokenStorage);

  final TokenStorage _tokenStorage;
  HubConnection? _hubConnection;

  // Broadcast stream controllers
  final _analyticsController = StreamController<AnalyticsData>.broadcast();
  final _basicChartController = StreamController<List<BasicChartData>>.broadcast();

  // Public streams exposed to Riverpod providers and UI widgets
  Stream<AnalyticsData> get telemetryStream => _analyticsController.stream;
  Stream<List<BasicChartData>> get basicChartStream => _basicChartController.stream;

  /// Establishes the WebSocket connection with the ASP.NET Core SignalR hub.
  Future<void> connect() async {
    if (_hubConnection != null &&
        _hubConnection!.state == HubConnectionState.Connected) {
      return;
    }

    // Resolves hub URL (e.g., http://localhost:5238/hubs/analytics)
    final hubUrl = '${ApiConfig.baseUrl.replaceAll('/api', '')}/hubs/analytics';

    _hubConnection = HubConnectionBuilder()
        .withUrl(
          hubUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async {
              return await _tokenStorage.getToken() ?? '';
            },
          ),
        )
        .withAutomaticReconnect()
        .build();

    // Register incoming SignalR event handlers
    _hubConnection!.on('ReceiveAnalyticsUpdate', _handleIncomingData);
    _hubConnection!.on('ReceiveBasicChartUpdate', _handleBasicChartData);

    _hubConnection!.onclose(({error}) {
      developer.log('SignalR connection closed: $error', name: 'RealtimeService');
    });

    try {
      await _hubConnection!.start();
      developer.log('SignalR Connected to Telemetry Hub.', name: 'RealtimeService');
    } catch (e) {
      developer.log('Error connecting to Hub: $e', name: 'RealtimeService');
    }
  }

  /// Handles full dashboard telemetry updates (KPIs, lines, categories, donut).
  void _handleIncomingData(List<Object?>? parameters) {
    if (parameters == null || parameters.isEmpty) return;

    try {
      final rawData = parameters.first;
      final Map<String, dynamic> jsonMap = rawData is String
          ? jsonDecode(rawData) as Map<String, dynamic>
          : rawData as Map<String, dynamic>;

      final liveUpdate = AnalyticsData.fromJson(jsonMap);
      _analyticsController.add(liveUpdate);
    } catch (e, stack) {
      developer.log('Failed to parse live telemetry stream: $e\n$stack', name: 'RealtimeService');
    }
  }

  /// Handles lightweight chart coordinate updates.
  void _handleBasicChartData(List<Object?>? parameters) {
    if (parameters == null || parameters.isEmpty) return;

    try {
      final rawData = parameters.first;
      final List<dynamic> list = rawData is String
          ? jsonDecode(rawData) as List<dynamic>
          : rawData as List<dynamic>;

      final dataPoints = list.asMap().entries.map((entry) {
          final index = entry.key;
      final map = entry.value as Map<String, dynamic>;
      return BasicChartData.fromJson(map, index);
    }).toList();

    _basicChartController.add(dataPoints);
  } catch (e, stack) {
    developer.log('Failed to parse live basic chart update: $e\n$stack', name: 'RealtimeService');
  }
  }

  /// Closes the socket session and frees all stream controllers.
  Future<void> dispose() async {
    await _hubConnection?.stop();
    await _analyticsController.close();
    await _basicChartController.close();
  }
}