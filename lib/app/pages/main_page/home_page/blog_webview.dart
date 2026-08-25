import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/common/utils/app_text.dart';

class BlogWebview extends StatefulWidget {
  static const String pageName = '/blog_webview';
  const BlogWebview({super.key});

  @override
  State<BlogWebview> createState() => _BlogWebviewState();
}

class _BlogWebviewState extends State<BlogWebview> {

  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
      isInspectable: kDebugMode,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      javaScriptEnabled: true,
      useHybridComposition: true,
      javaScriptCanOpenWindowsAutomatically: true,
      iframeAllowFullscreen: true);

  String blogUrl = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      blogUrl = ModalRoute.of(context)!.settings.arguments as String;
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(
        title: appText.blogPost,
        onTapLeftIcon: () {
          backRoute();
        }),
      body: isLoading
          ? loading()
          : InAppWebView(
        initialUrlRequest:
        URLRequest(url: WebUri(blogUrl)),
        initialSettings: settings,
        onWebViewCreated: (controller) async {
          webViewController = controller;
        },
        onLoadStart: (controller, url) {
          setState(() {
            blogUrl = url.toString();
            debugPrint("onLoadStart url ==========> ${url.toString()}");
          });
        },
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          return NavigationActionPolicy.ALLOW;
        },
        onLoadStop: (controller, WebUri? url) {
          setState(() {
            blogUrl = url.toString();
            debugPrint("onLoadStop url ==========> ${url.toString()}");
          });
        },
        onReceivedError: (controller, request, error) {
          debugPrint("received url onReceivedError description ==========> ${error.description}");
        },
        onReceivedHttpError: (controller, request, errorResponse) {
          debugPrint("received url onReceivedHttpError reasonPhrase ==========> ${errorResponse.reasonPhrase}");
          debugPrint("received url onReceivedHttpError statusCode ==========> ${errorResponse.statusCode}");
        },
        onConsoleMessage: (controller, consoleMessage) {
          debugPrint("received url onConsoleMessage ==========> ${consoleMessage.message}");
        },
      ),
    );
  }
}
