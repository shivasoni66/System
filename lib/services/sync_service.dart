import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SyncService {
  final String Function() getHost;
  final String Function() getPlayerName;
  
  WebSocketChannel? _channel;
  bool _isConnected = false;
  bool _isConnecting = false;
  
  final Function(Map<String, dynamic>) onStateReceived;
  final Function(bool) onConnectionStateChanged;

  SyncService({
    required this.getHost,
    required this.getPlayerName,
    required this.onStateReceived,
    required this.onConnectionStateChanged,
  });

  bool get isConnected => _isConnected;

  /// Connects to the Java WebSocket server dynamically
  void connect() {
    if (_isConnected || _isConnecting) return;
    _isConnecting = true;
    
    try {
      final String pName = getPlayerName();
      if (pName.trim().isEmpty) {
        debugPrint('[SYSTEM SYNC] Datalink delayed: Player ID empty.');
        _isConnecting = false;
        return;
      }

      final String rawHost = getHost();
      // Remove any user-typed protocol schemes to prevent URI format issues
      final String cleanedHost = rawHost
          .replaceAll('ws://', '')
          .replaceAll('wss://', '')
          .replaceAll('http://', '')
          .replaceAll('https://', '')
          .trim();

      // Automatically apply secure WebSocket (wss) for cloud hosts (like Render)
      final String scheme = cleanedHost.contains('localhost') || cleanedHost.contains('127.0.0.1') ? 'ws' : 'wss';
      
      final String encodedName = Uri.encodeComponent(pName);
      final String fullUrl = '$scheme://$cleanedHost/sync?name=$encodedName';

      debugPrint('[SYSTEM SYNC] Attempting datalink connection: $fullUrl');
      _channel = WebSocketChannel.connect(Uri.parse(fullUrl));
      _isConnected = true;
      _isConnecting = false;
      onConnectionStateChanged(true);

      _channel!.stream.listen(
        (message) {
          try {
            final Map<String, dynamic> stateMap = jsonDecode(message);
            onStateReceived(stateMap);
          } catch (e) {
            debugPrint('[SYSTEM SYNC] Error decoding sync message: $e');
          }
        },
        onError: (error) {
          debugPrint('[SYSTEM SYNC] WebSocket error: $error');
          _handleDisconnect();
        },
        onDone: () {
          debugPrint('[SYSTEM SYNC] WebSocket closed by server.');
          _handleDisconnect();
        },
      );
    } catch (e) {
      debugPrint('[SYSTEM SYNC] Connection failed: $e');
      _handleDisconnect();
    }
  }

  void _handleDisconnect() {
    _isConnected = false;
    _isConnecting = false;
    _channel = null;
    onConnectionStateChanged(false);
    
    // Auto-reconnect after 6 seconds
    Timer(const Duration(seconds: 6), () {
      connect();
    });
  }

  /// Sends the player state map to the WebSocket channel
  void sendState(Map<String, dynamic> state) {
    if (!_isConnected || _channel == null) {
      debugPrint('[SYSTEM SYNC] Outbox offline. Saved to local cache.');
      return;
    }
    try {
      _channel!.sink.add(jsonEncode(state));
    } catch (e) {
      debugPrint('[SYSTEM SYNC] Send error: $e');
    }
  }

  /// Closes the WebSocket channel
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    _isConnecting = false;
    onConnectionStateChanged(false);
  }
}
