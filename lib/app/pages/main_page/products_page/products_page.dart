import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/common/data/app_data.dart';

class ProductsPage extends StatefulWidget {
  static const String pageName = '/productsPage';

  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  InAppWebViewController? webViewController;

  InAppWebViewSettings settings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    javaScriptEnabled: true,
    useHybridComposition: true,
    javaScriptCanOpenWindowsAutomatically: true,
    iframeAllowFullscreen: true,
  );

  String? webUrl;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserAndUrl();
  }

  Future<void> loadUserAndUrl() async {
    final String userId = await AppData.getAccessToken();
    final String url = 'https://profitfromit.co.in/products?user_token=$userId';
    setState(() {
      webUrl = url;
    });
    debugPrint("Web URL: $url");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(
          title: "Products",
          onTapLeftIcon: () {
            backRoute();
          }),
      body: webUrl == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: WebUri(webUrl!),
                  ),
                  initialSettings: settings,
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                  },
                  onLoadStart: (controller, url) {
                    setState(() {
                      isLoading = true;
                    });

                    debugPrint("Loading Started: $url");
                  },
                  onLoadStop: (controller, url) async {
                    setState(() {
                      isLoading = false;
                    });

                    debugPrint("Loading Finished: $url");
                  },
                  onReceivedError: (controller, request, error) {
                    setState(() {
                      isLoading = false;
                    });

                    debugPrint("Error: ${error.description}");
                  },
                ),

                // Loader
                if (isLoading)
                  Container(
                    color: Colors.white,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
    );
  }
}
