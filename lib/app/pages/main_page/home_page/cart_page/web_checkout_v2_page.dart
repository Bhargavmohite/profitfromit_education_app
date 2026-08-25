import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:webinar/app/pages/main_page/main_page.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/common/utils/app_text.dart';

class WebCheckoutV2Page extends StatefulWidget {
  static const String pageName = '/web_checkout_v2';
  const WebCheckoutV2Page({super.key});

  @override
  State<WebCheckoutV2Page> createState() => _WebCheckoutV2PageState();
}

class _WebCheckoutV2PageState extends State<WebCheckoutV2Page> {

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

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      url = ModalRoute.of(context)!.settings.arguments as String;
      setState(() {
        isLoading = false;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(title: appText.checkout),
      body: isLoading
          ? loading()
          : InAppWebView(
        initialUrlRequest:
        URLRequest(url: WebUri(url)),
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
            if(this.url.toString().contains("https://profitfromit.co.in/payments/eventpaysucess")) {
              nextRoute(MainPage.pageName, isClearBackRoutes: true);
            } else if(this.url.toString().contains("https://profitfromit.co.in/payments/eventpayfail")) {
              backRoute();
            } else {

            }
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
