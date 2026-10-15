import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:webinar/app/models/q1_fy27_dashboard_model.dart';
import 'package:webinar/common/utils/constants.dart';

class Q1FY27DashboardService {
  const Q1FY27DashboardService._();

  static const Duration _timeout = Duration(seconds: 45);

  static Future<Q1FY27DashboardData> dashboard() async {
    const String url =
        '${Constants.dommain}/Quarterly-earnings-results-nifty-allcap?app_data=1';

    try {
      debugPrint('Q1 FY27 DATA URL ======> $url');

      final http.Response response = await http.get(
        Uri.parse(url),
        headers: const <String, String>{
          'Accept': 'application/json,text/html;q=0.9,*/*;q=0.8',
          'Cache-Control': 'no-cache',
        },
      ).timeout(_timeout);

      final String body = utf8.decode(
        response.bodyBytes,
        allowMalformed: true,
      );

      debugPrint(
        'Q1 FY27 DATA STATUS ======> ${response.statusCode}',
      );
      debugPrint(
        'Q1 FY27 DATA BODY LENGTH ======> ${body.length}',
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Q1 FY27 server returned HTTP ${response.statusCode}.',
        );
      }

      if (body.trim().isEmpty) {
        throw const FormatException(
          'Q1 FY27 server returned an empty response.',
        );
      }

      final Map<String, dynamic> data = _extractDashboardData(body);

      final Q1FY27DashboardData parsed = Q1FY27DashboardData.fromJson(data);

      debugPrint(
        'Q1 FY27 DATA SUCCESS ======> '
        '${parsed.companies.length} companies | '
        '${parsed.industries.length} industries | '
        '${parsed.themes.length} themes',
      );

      return parsed;
    } catch (e, stack) {
      debugPrint('Q1 FY27 DATA ERROR ======> $e');
      debugPrintStack(
        label: 'Q1 FY27 DATA STACK',
        stackTrace: stack,
      );
      rethrow;
    }
  }

  static Map<String, dynamic> _extractDashboardData(String body) {
    final String trimmed = body.trimLeft();
    final String lower = trimmed.toLowerCase();

    // Preferred response:
    // {"success":true,"data":{...}}
    if (!lower.startsWith('<!doctype html') && !lower.startsWith('<html')) {
      final dynamic decoded = jsonDecode(body);

      if (decoded is! Map) {
        throw const FormatException(
          'Q1 FY27 JSON response is not an object.',
        );
      }

      final Map<String, dynamic> root = Map<String, dynamic>.from(decoded);

      if (root['success'] == true && root['data'] is Map) {
        debugPrint('Q1 FY27 SOURCE ======> JSON API');

        return Map<String, dynamic>.from(
          root['data'] as Map,
        );
      }

      // Also allow the DATA object itself to be returned directly.
      if (_looksLikeDashboardData(root)) {
        debugPrint('Q1 FY27 SOURCE ======> DIRECT JSON DATA');
        return root;
      }

      throw FormatException(
        root['message']?.toString() ??
            'Q1 FY27 JSON response does not contain dashboard data.',
      );
    }

    // Current live-server fallback:
    // The route is returning the normal rendered Blade HTML.
    // The website already contains:
    //     var DATA = {...};
    // Extract that exact JSON object and feed the existing native Flutter UI.
    debugPrint(
      'Q1 FY27 SOURCE ======> WEBSITE HTML; extracting var DATA',
    );

    final String jsonObject = _extractDataJsonFromHtml(body);
    final dynamic decodedData = jsonDecode(jsonObject);

    if (decodedData is! Map) {
      throw const FormatException(
        'Q1 FY27 DATA extracted from HTML is not a JSON object.',
      );
    }

    final Map<String, dynamic> data = Map<String, dynamic>.from(decodedData);

    if (!_looksLikeDashboardData(data)) {
      throw const FormatException(
        'Q1 FY27 HTML DATA is missing required dashboard keys.',
      );
    }

    debugPrint(
      'Q1 FY27 HTML DATA EXTRACTED ======> '
      '${(data['companies'] as List?)?.length ?? 0} companies',
    );

    return data;
  }

  static bool _looksLikeDashboardData(
    Map<String, dynamic> data,
  ) {
    return data.containsKey('meta') &&
        data.containsKey('overview') &&
        data.containsKey('companies') &&
        data.containsKey('industries') &&
        data.containsKey('themes');
  }

  static String _extractDataJsonFromHtml(String html) {
    const String marker = 'var DATA =';

    final int markerIndex = html.indexOf(marker);

    if (markerIndex < 0) {
      throw const FormatException(
        'Q1 FY27 website HTML does not contain "var DATA =".',
      );
    }

    int start = markerIndex + marker.length;

    while (start < html.length && _isWhitespace(html.codeUnitAt(start))) {
      start++;
    }

    if (start >= html.length || html[start] != '{') {
      throw const FormatException(
        'Q1 FY27 website DATA does not start with a JSON object.',
      );
    }

    int depth = 0;
    bool inString = false;
    bool escaped = false;

    for (int i = start; i < html.length; i++) {
      final String char = html[i];

      if (inString) {
        if (escaped) {
          escaped = false;
          continue;
        }

        if (char == r'\') {
          escaped = true;
          continue;
        }

        if (char == '"') {
          inString = false;
        }

        continue;
      }

      if (char == '"') {
        inString = true;
        continue;
      }

      if (char == '{') {
        depth++;
        continue;
      }

      if (char == '}') {
        depth--;

        if (depth == 0) {
          return html.substring(start, i + 1);
        }
      }
    }

    throw const FormatException(
      'Q1 FY27 website DATA JSON object is incomplete.',
    );
  }

  static bool _isWhitespace(int codeUnit) {
    return codeUnit == 0x20 ||
        codeUnit == 0x09 ||
        codeUnit == 0x0A ||
        codeUnit == 0x0D;
  }
}
