import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class MongoDBService {
  // Parsing the concatenated MongoDB credentials:
  // App ID = first 8 characters (al-6b7c5)
  // API Key = remaining characters (KUI7UKU2L1zkD0VMs65OjDNkxJbc80eQ3XROP3)
  static const String _appId = 'al-6b7c5';
  static const String _apiKey = 'KUI7UKU2L1zkD0VMs65OjDNkxJbc80eQ3XROP3';
  
  static const String _baseUrl = 'https://data.mongodb-api.com/app/$_appId/endpoint/data/v1/action';
  static const String _dataSource = 'Cluster0';
  static const String _database = 'SYSTEM';
  static const String _collection = 'player_state';
  static const String _playerName = 'Shiva';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Access-Control-Request-Headers': '*',
        'api-key': _apiKey,
      };

  /// Fetches the player state document from MongoDB
  static Future<Map<String, dynamic>?> fetchPlayerState() async {
    try {
      final url = Uri.parse('$_baseUrl/findOne');
      final payload = jsonEncode({
        'dataSource': _dataSource,
        'database': _database,
        'collection': _collection,
        'filter': {'playerName': _playerName},
      });

      final response = await http.post(url, headers: _headers, body: payload);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['document'] != null) {
          return data['document'] as Map<String, dynamic>;
        }
      } else {
        debugPrint('MongoDB fetch failed: Status Code ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      debugPrint('MongoDB fetch error: $e');
    }
    return null;
  }

  /// Saves the player state document to MongoDB using upsert (insert or update)
  static Future<bool> savePlayerState(Map<String, dynamic> state) async {
    try {
      final url = Uri.parse('$_baseUrl/updateOne');
      
      // Ensure player identifier is locked in the document
      final cleanState = Map<String, dynamic>.from(state);
      cleanState['playerName'] = _playerName;

      final payload = jsonEncode({
        'dataSource': _dataSource,
        'database': _database,
        'collection': _collection,
        'filter': {'playerName': _playerName},
        'update': {
          '\$set': cleanState,
        },
        'upsert': true,
      });

      final response = await http.post(url, headers: _headers, body: payload);

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('MongoDB save failed: Status Code ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      debugPrint('MongoDB save error: $e');
    }
    return false;
  }
}
