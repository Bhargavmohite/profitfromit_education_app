import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:webinar/app/models/live_market_model.dart';
import 'package:webinar/common/utils/constants.dart';
import 'package:webinar/common/utils/http_handler.dart';

class LiveMarketService {
  const LiveMarketService._();

  static const Duration _timeout = Duration(seconds: 30);

  static Future<LiveMarketOverviewModel> overview() async {
    final response = await httpGet(
      '${Constants.baseUrl}live-market/overview',
      isRedirectingStatusCode: false,
    ).timeout(_timeout);

    final Map<String, dynamic> json = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(json['message'] ?? 'Unable to load live market data.');
    }

    final Map<String, dynamic> data = _asMap(json['data']);
    return LiveMarketOverviewModel.fromJson(data);
  }

  static Future<List<Map<String, dynamic>>> search(String query) async {
    final String clean = query.trim();
    if (clean.length < 2) return const <Map<String, dynamic>>[];

    final response = await httpGet(
      '${Constants.baseUrl}live-market/search/${Uri.encodeComponent(clean)}',
      isRedirectingStatusCode: false,
    ).timeout(_timeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return const <Map<String, dynamic>>[];
    }

    final Map<String, dynamic> json = _decode(response.body);
    final dynamic results = json['results'];
    if (results is! List) return const <Map<String, dynamic>>[];

    return results
        .whereType<Map>()
        .map((Map e) => Map<String, dynamic>.from(e))
        .toList();
  }

  static Future<Map<String, dynamic>> compare({
    required List<String> symbols,
    required int months,
  }) async {
    final String joined = symbols.join(',');
    final response = await httpGet(
      '${Constants.baseUrl}live-market/compare?symbols=${Uri.encodeQueryComponent(joined)}&months=$months',
      isRedirectingStatusCode: false,
    ).timeout(_timeout);

    final Map<String, dynamic> json = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
          json['message'] ?? json['error'] ?? 'Unable to compare stocks.');
    }
    return json;
  }

  static Future<Map<String, dynamic>> stock(String symbol) async {
    final String clean =
        symbol.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z0-9&\-]'), '');
    if (clean.isEmpty) throw Exception('Enter a valid symbol.');

    final response = await httpGet(
      '${Constants.baseUrl}live-market/stock/${Uri.encodeComponent(clean)}',
      isRedirectingStatusCode: false,
    ).timeout(_timeout);

    final Map<String, dynamic> json = _decode(response.body);
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        json['success'] == false) {
      throw Exception(json['message'] ?? 'Unable to load stock data.');
    }

    return json;
  }

  static Map<String, dynamic> _decode(String body) {
    try {
      final dynamic decoded = jsonDecode(body);
      return _asMap(decoded);
    } catch (e) {
      debugPrint('LiveMarketService JSON error: $e');
      return <String, dynamic>{};
    }
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }
}
