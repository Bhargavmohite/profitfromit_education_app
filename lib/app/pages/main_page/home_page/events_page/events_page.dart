import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webinar/app/services/user_service/user_service.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/common/utils/object_instance.dart';
import 'package:webinar/config/assets.dart';

class EventsPage extends StatefulWidget {
  static const String pageName = '/event_page';

  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
      isInspectable: kDebugMode,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      javaScriptEnabled: true,
      useHybridComposition: true,
      javaScriptCanOpenWindowsAutomatically: true,
      iframeAllowFullscreen: true);

  String url = "";
  String latestEventUrl = "";

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.wait([UserService.getLatestEvents()]).then((List<String> value) {
      debugPrint("data at event page ===========> ${value.toString()}");
      setState(() {
        url = value[0];
        latestEventUrl = value[0];
        isLoading = false;
      });
    });
  }

  Future<void> _shareLatestEvent() async {
    final String eventUrl = latestEventUrl.trim();

    if (eventUrl.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Latest event link is not available right now.'),
        ),
      );
      return;
    }

    final String shareText =
        'Check out the latest event from Profit From It\n\n$eventUrl';

    try {
      await Share.share(shareText);
    } catch (e) {
      debugPrint('LATEST EVENT SHARE ERROR ======> $e');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to share the event right now.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return directionality(
      child: Scaffold(
        drawerEnableOpenDragGesture: false,
        // drawerEdgeDragWidth: 20,
        appBar: appbar(
          title: appText.latestEvents,
          leftIcon: AppAssets.menuSvg,
          onTapLeftIcon: () {
            drawerController.showDrawer();
          },
          rightIcon: AppAssets.shareSvg,
          onTapRightIcon: _shareLatestEvent,
        ),
        body: isLoading
            ? loading()
            : InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(url)),
                initialSettings: settings,
                onWebViewCreated: (controller) async {
                  webViewController = controller;
                },
                onLoadStart: (controller, url) {
                  setState(() {
                    this.url = url.toString();
                    debugPrint("onLoadStart url ==========> ${url.toString()}");
                  });
                },
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  return NavigationActionPolicy.ALLOW;
                },
                onLoadStop: (controller, WebUri? url) {
                  setState(() {
                    this.url = url.toString();
                    debugPrint("onLoadStop url ==========> ${url.toString()}");
                  });
                },
                onReceivedError: (controller, request, error) {
                  debugPrint(
                      "received url onReceivedError description ==========> ${error.description}");
                },
                onReceivedHttpError: (controller, request, errorResponse) {
                  debugPrint(
                      "received url onReceivedHttpError reasonPhrase ==========> ${errorResponse.reasonPhrase}");
                  debugPrint(
                      "received url onReceivedHttpError statusCode ==========> ${errorResponse.statusCode}");
                },
                onConsoleMessage: (controller, consoleMessage) {
                  debugPrint(
                      "received url onConsoleMessage ==========> ${consoleMessage.message}");
                },
              ),
      ),
    );
  }
}

// old code for side menu comment on 06-05-2026
// @override
// Widget build(BuildContext context) {
//   return PopScope(
//     canPop: false, // we’ll handle back manually
//     onPopInvokedWithResult: (bool didPop, Object? result) async {
//       if (didPop) return; // already handled by system
//       if (webViewController != null) {
//         bool canGoBack = await webViewController!.canGoBack();
//         if (canGoBack) {
//           // go back inside webview
//           webViewController!.goBack();
//           return;
//         }
//       }
//       // no history → close the page
//       Navigator.of(context).pop();
//     },
//     child: Scaffold(
//       appBar: appbar(title: appText.latestEvents, onTapLeftIcon: () async {
//         if (webViewController != null) {
//           bool canGoBack = await webViewController!.canGoBack();
//           if (canGoBack) {
//             // go back inside webview
//             webViewController!.goBack();
//             return;
//           }
//         }
//         // no history → close the page
//         Navigator.of(context).pop();
//       }),
//       body: isLoading
//           ? loading()
//           : InAppWebView(
//         initialUrlRequest:
//         URLRequest(url: WebUri(url)),
//         initialSettings: settings,
//         onWebViewCreated: (controller) async {
//           webViewController = controller;
//         },
//         onLoadStart: (controller, url) {
//           setState(() {
//             this.url = url.toString();
//             debugPrint("onLoadStart url ==========> ${url.toString()}");
//           });
//         },
//         shouldOverrideUrlLoading: (controller, navigationAction) async {
//           return NavigationActionPolicy.ALLOW;
//         },
//         onLoadStop: (controller, WebUri? url) {
//           setState(() {
//             this.url = url.toString();
//             debugPrint("onLoadStop url ==========> ${url.toString()}");
//           });
//         },
//         onReceivedError: (controller, request, error) {
//           debugPrint("received url onReceivedError description ==========> ${error.description}");
//         },
//         onReceivedHttpError: (controller, request, errorResponse) {
//           debugPrint("received url onReceivedHttpError reasonPhrase ==========> ${errorResponse.reasonPhrase}");
//           debugPrint("received url onReceivedHttpError statusCode ==========> ${errorResponse.statusCode}");
//         },
//         onConsoleMessage: (controller, consoleMessage) {
//           debugPrint("received url onConsoleMessage ==========> ${consoleMessage.message}");
//         },
//       ),
//     ),
//   );
// }
