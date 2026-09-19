import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vimeo_video_player/vimeo_video_player.dart';
import 'package:webinar/common/common.dart';

class VimeoVideoPlayerWidget extends StatelessWidget {
  final String url;

  const VimeoVideoPlayerWidget(
    this.url, {
    super.key,
  });

  String _extractVideoId(String value) {
    final String trimmedValue = value.trim();

    // If API directly returns only Vimeo ID.
    if (RegExp(r'^\d+$').hasMatch(trimmedValue)) {
      return trimmedValue;
    }

    try {
      final Uri uri = Uri.parse(trimmedValue);

      for (final String segment in uri.pathSegments.reversed) {
        if (RegExp(r'^\d+$').hasMatch(segment)) {
          return segment;
        }
      }
    } catch (e) {
      debugPrint('VIMEO URL PARSE ERROR ======> $e');
    }

    return '';
  }

  // String? _extractPrivacyHash(String value) {
  //   final String trimmedValue = value.trim();

  //   try {
  //     final Uri uri = Uri.parse(trimmedValue);
  //     final List<String> segments = uri.pathSegments;

  //     // Example:
  //     // https://vimeo.com/1223571409/6ff7ce0cfc
  //     //
  //     // segments[0] = 1223571409
  //     // segments[1] = 6ff7ce0cfc

  //     if (segments.length >= 2 &&
  //         RegExp(r'^\d+$').hasMatch(segments[0]) &&
  //         segments[1].isNotEmpty) {
  //       return segments[1];
  //     }
  //   } catch (e) {
  //     debugPrint('VIMEO PRIVACY HASH PARSE ERROR ======> $e');
  //   }

  //   return null;
  // }

  String? _extractPrivacyHash(String value) {
    final String trimmedValue = value.trim();

    try {
      final Uri uri = Uri.parse(trimmedValue);

      // Case 1:
      // https://player.vimeo.com/video/123456789?h=abcdef1234
      // https://vimeo.com/123456789?h=abcdef1234
      final String? queryHash = uri.queryParameters['h'];

      if (queryHash != null && queryHash.trim().isNotEmpty) {
        return queryHash.trim();
      }

      // Case 2:
      // https://vimeo.com/123456789/abcdef1234
      final List<String> segments = uri.pathSegments
          .where((segment) => segment.trim().isNotEmpty)
          .toList();

      for (int i = 0; i < segments.length; i++) {
        if (RegExp(r'^\d+$').hasMatch(segments[i])) {
          if (i + 1 < segments.length) {
            final String possibleHash = segments[i + 1].trim();

            if (possibleHash.isNotEmpty &&
                !RegExp(r'^\d+$').hasMatch(possibleHash)) {
              return possibleHash;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('VIMEO PRIVACY HASH PARSE ERROR ======> $e');
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final String videoId = _extractVideoId(url);
    final String? privacyHash = _extractPrivacyHash(url);

    debugPrint('VIMEO URL ======> $url');
    debugPrint('VIMEO VIDEO ID ======> $videoId');
    debugPrint('VIMEO PRIVACY HASH ======> $privacyHash');

    if (videoId.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text('Unable to load Vimeo video'),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: ClipRRect(
        borderRadius: borderRadius(),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: VimeoVideoPlayer(
            videoId: videoId,
            privacyHash: privacyHash,
            // isAutoPlay: true
            isAutoPlay: defaultTargetPlatform != TargetPlatform.iOS,
            isLooping: false,
            isMuted: false,
            showTitle: false,
            showByline: false,
            showControls: true,
            enableDNT: true,
            enableFullScreenOnPlay: false,
            backgroundColor: Colors.black,
            onReady: () {
              debugPrint('VIMEO PLAYER READY ======> $videoId');
            },
            onInAppWebViewCreated: (controller) {
              debugPrint('VIMEO WEBVIEW CREATED ======> $videoId');
            },
            onInAppWebViewLoadStart: (controller, uri) {
              debugPrint('VIMEO WEBVIEW LOAD START ======> $uri');
            },
            onInAppWebViewLoadStop: (controller, uri) {
              debugPrint('VIMEO WEBVIEW LOAD STOP ======> $uri');
            },
            onInAppWebViewReceivedError: (controller, request, error) {
              debugPrint(
                'VIMEO WEBVIEW ERROR ======> '
                'URL: ${request.url} | ERROR: ${error.description}',
              );
            },
            onPlay: () {
              debugPrint('VIMEO PLAYER PLAY ======> $videoId');
            },
            onPause: () {
              debugPrint('VIMEO PLAYER PAUSE ======> $videoId');
            },
            onFinish: () {
              debugPrint('VIMEO PLAYER FINISHED ======> $videoId');
            },
          ),
        ),
      ),
    );
  }
}
