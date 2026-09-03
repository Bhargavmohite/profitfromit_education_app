import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

import 'deep_link_model.dart';
import 'deep_link_type.dart';

class DeepLinkService {
  DeepLinkService._();

  static final DeepLinkService instance = DeepLinkService._();

  final AppLinks _appLinks = AppLinks();

  StreamSubscription<Uri>? _subscription;

  String? _lastHandledUri;
  DateTime? _lastHandledAt;

  static const Duration _dedupWindow = Duration(seconds: 2);

  /// Update with your domain
  static const String allowedHost = "profitfromit.co.in";

  final ValueNotifier<DeepLinkModel?> deepLinkNotifier =
      ValueNotifier<DeepLinkModel?>(null);

  DeepLinkModel? pendingDeepLink;

  Future<void> initialize() async {
    try {
      await _subscription?.cancel();

      /// Listen FIRST
      _subscription = _appLinks.uriLinkStream.listen(
        (Uri uri) {
          debugPrint("DeepLink Stream => $uri");
          _handleUri(uri);
        },
        onError: (error) {
          debugPrint("DeepLink Stream Error => $error");
        },
      );

      /// Then get initial link
      final Uri? initialUri = await _appLinks.getInitialLink().timeout(
            const Duration(seconds: 3),
            onTimeout: () => null,
          );

      if (initialUri != null) {
        debugPrint("DeepLink Initial => $initialUri");
        _handleUri(initialUri);
      }
    } catch (e) {
      debugPrint("DeepLink Init Error => $e");
    }
  }

  void _handleUri(Uri uri) {
    try {
      final uriString = uri.toString();

      final now = DateTime.now();

      if (_lastHandledUri == uriString &&
          _lastHandledAt != null &&
          now.difference(_lastHandledAt!) < _dedupWindow) {
        debugPrint("Duplicate deep link ignored");
        return;
      }

      _lastHandledUri = uriString;
      _lastHandledAt = now;

      /// Host validation
      final host = uri.host.toLowerCase();

      if (host.isNotEmpty && host != allowedHost) {
        debugPrint("Invalid Host => $host");
        return;
      }

      final segments =
          uri.pathSegments.where((e) => e.trim().isNotEmpty).toList();

      debugPrint("Segments => $segments");

      if (segments.isEmpty) {
        _notifyUnknown();
        return;
      }

      _parseRoute(segments);
    } catch (e) {
      debugPrint("Handle DeepLink Error => $e");
    }
  }

  void _parseRoute(List<String> segments) {
    try {
      final first = segments.first.toLowerCase();

      /// Blog
      /// https://profitfromit.co.in/blog/625
      if (first == "blog" && segments.length >= 2) {
        final blogId = segments[1];

        pendingDeepLink = DeepLinkModel(
          type: DeepLinkType.blog,
          blogId: blogId,
        );
        debugPrint("DeepLink Stored ========> ${pendingDeepLink?.blogId}");
        deepLinkNotifier.value = pendingDeepLink;
        return;
      }

      /// Course
      /// https://profitfromit.co.in/course/123
      // if (first == "course" && segments.length >= 2) {
      //   final courseId = segments[1];
      //
      //   pendingDeepLink = DeepLinkModel(
      //     type: DeepLinkType.course,
      //     courseId: courseId,
      //   );
      //
      //   deepLinkNotifier.value = pendingDeepLink;
      //
      //   return;
      // }

      /// Course Lesson
      /// https://profitfromit.co.in/course/123/lesson/10
      if (first == "course" &&
          segments.length >= 4 &&
          segments[2].toLowerCase() == "lesson") {
        final courseId = segments[1];
        final lessonId = segments[3];

        pendingDeepLink = DeepLinkModel(
          type: DeepLinkType.courseLesson,
          courseId: courseId,
          lessonId: lessonId,
        );

        deepLinkNotifier.value = pendingDeepLink;
        return;
      }

      /// Course
      /// https://profitfromit.co.in/course/123
      if (first == "course" && segments.length == 2) {
        final courseId = segments[1];

        pendingDeepLink = DeepLinkModel(
          type: DeepLinkType.course,
          courseId: courseId,
        );

        debugPrint("Course DeepLink Stored ======> $courseId");

        deepLinkNotifier.value = pendingDeepLink;
        return;
      }

      _notifyUnknown();
    } catch (e) {
      debugPrint("Parse Route Error => $e");
    }
  }

  void _notifyUnknown() {
    deepLinkNotifier.value = const DeepLinkModel(
      type: DeepLinkType.unknown,
    );
  }

  void clearPending() {
    pendingDeepLink = null;
    deepLinkNotifier.value = null;
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
  }
}
