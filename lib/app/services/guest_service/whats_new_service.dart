import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:webinar/app/models/whats_new_model.dart';
import 'package:webinar/common/utils/constants.dart';

class WhatsNewService {
  WhatsNewService._();

  static const String _seenKey = 'whats_new_last_seen_install';

  /// Version from the *installed application*, not a hardcoded Dart constant.
  static Future<PackageInfo> installedPackage() => PackageInfo.fromPlatform();

  /// Safely load release notes. An unavailable backend must not interrupt
  /// app startup or trigger an unhandled Future error in FutureBuilder.
  /// null means the release feed could not be loaded.
  static String? lastError;
  static String? lastRevision;
  static DateTime? lastSuccessfulFetch;

  static Future<WhatsNewRelease?> fetch() async {
    lastError = null;
    try {
      // A unique query value prevents intermediary caches from returning
      // yesterday's release notes after an edit in Laravel.
      final endpoint = Uri.parse('${Constants.baseUrl}whats-new');
      final url = endpoint.replace(queryParameters: {
        ...endpoint.queryParameters,
        '_refresh': DateTime.now().millisecondsSinceEpoch.toString(),
      });
      final response = await http.get(
        url,
        headers: {
          'x-api-key': Constants.apiKey,
          'Accept': 'application/json',
          'Cache-Control': 'no-cache, no-store',
          'Pragma': 'no-cache',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        lastError = 'Server returned HTTP ${response.statusCode}.';
        if (kDebugMode) {
          debugPrint("What's New API HTTP ${response.statusCode}: ${url.path}");
        }
        return null;
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map ||
          decoded['success'] != true ||
          decoded['data'] is! Map) {
        lastError = 'Unexpected response from release-notes API.';
        debugPrint("What's New: $lastError");
        return null;
      }

      final release = WhatsNewRelease.fromJson(
        Map<String, dynamic>.from(decoded['data'] as Map),
      );
      lastRevision = (decoded['revision'] ?? '').toString();
      lastSuccessfulFetch = DateTime.now();
      if (kDebugMode) {
        debugPrint("What's New API OK: version=${release.version}, "
            'cards=${release.cards.length}, revision=$lastRevision');
      }
      return release;
    } on TimeoutException {
      lastError = 'Connection timed out.';
    } on FormatException {
      lastError = 'Release-notes API returned invalid JSON.';
    } catch (error) {
      // Avoid logging the request headers, API key, or server response body.
      lastError = 'Could not connect to release-notes API.';
      debugPrint("What's New request failed: ${error.runtimeType}");
    }
    debugPrint("What's New: $lastError");
    return null;
  }

  /// A unique installed build is shown once. A new build triggers a fresh check.
  static String installedKey(PackageInfo info) =>
      '${info.packageName}:${info.version}+${info.buildNumber}';

  static Future<bool> hasSeen(PackageInfo info) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_seenKey) == installedKey(info);
  }

  static Future<bool> shouldShow(
      WhatsNewRelease release, PackageInfo info) async {
    if (!release.enabled || release.cards.isEmpty) return false;
    // The server must publish this installed release, not an unrelated one.
    if (release.version != info.version) return false;
    return !(await hasSeen(info));
  }

  static Future<void> markSeen(PackageInfo info) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_seenKey, installedKey(info));
    debugPrint('Whats New acknowledged for ${installedKey(info)}');
  }
}
