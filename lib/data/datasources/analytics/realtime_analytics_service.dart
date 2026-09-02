import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:new_app/core/config/api_config.dart';
import 'package:new_app/core/storage/token_storage.dart';
import 'package:new_app/domain/entities/analytics.dart';
import 'package:signalr_netcore/signalr_client.dart';


class RealtimeAnalyticsService {
  RealtimeAnalyticsService(this._tokenStorage);

  final TokenStorage _tokenStorage;
  HubConnection? _hubConnection;
  final _analyticsController = StreamController<AnalyticsData>.broadcast();

  Stream<AnalyticsData> get telemetryStream => _analyticsController.stream;

  Future<void> connect() async {
    if (_hubConnection != null &&
        _hubConnection!.state == HubConnectionState.Connected) {
      return;
    }

    // Connect to your ASP.NET Core Hub: e.g. http://localhost:5238/hubs/analytics
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

    // Listen for live telemetry broadcasts from the backend
    _hubConnection!.on('ReceiveAnalyticsUpdate', _handleIncomingData);

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
      developer.log('Failed to parse live telemetry stream: $e\n$stack');
    }
  }

  Future<void> dispose() async {
    await _hubConnection?.stop();
    await _analyticsController.close();
  }
}