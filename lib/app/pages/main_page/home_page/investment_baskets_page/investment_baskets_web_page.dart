import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Displays the Maxfolio Investment Baskets dashboard directly from Home.
///
/// Maxfolio controls the website, authentication and its SSL certificate.
/// This screen does NOT bypass HTTPS certificate validation.
class InvestmentBasketsWebPage extends StatefulWidget {
  const InvestmentBasketsWebPage({super.key});

  @override
  State<InvestmentBasketsWebPage> createState() =>
      _InvestmentBasketsWebPageState();
}

class _InvestmentBasketsWebPageState extends State<InvestmentBasketsWebPage> {
  // Exact link supplied for the Institutional Models > Investment Baskets card.
  // CAUTION: 'cd' may be a short-lived access/session token. If it expires,
  // replace it with an authorized stable deep link supplied by Maxfolio.
  static final Uri _dashboardUri = Uri.parse(
    'https://profitfromit.maxfolio.in/Dashboard?'
    'pc=MA00022PFS2026D&up=&'
    'cd=9qNsjB0-VYS5G64eRYkjlmeMAiqHYIw1AYw2PoG4m1A-1_aMAcvEuWJddneUF_4f&lc=',
  );

  late final WebViewController _controller;
  bool _loading = true;
  int _progress = 0;
  String? _mainFrameError;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _loading = true;
              _progress = 0;
              _mainFrameError = null;
            });
          },
          onProgress: (value) {
            if (!mounted || _mainFrameError != null) return;
            setState(() => _progress = value);
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() {
              _loading = false;
              _progress = 100;
              // Do not erase errors here: Android may finish an error page.
            });
          },
          onWebResourceError: (error) {
            // Do not fail the whole page for blocked fonts, scripts, images.
            if (!mounted || error.isForMainFrame == false) return;
            debugPrint(
              'Maxfolio dashboard main-frame error: '
              '${error.errorCode} ${error.description}',
            );
            setState(() {
              _loading = false;
              _mainFrameError =
                  '${error.description} (code ${error.errorCode})';
            });
          },
        ),
      );
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _progress = 0;
      _mainFrameError = null;
    });
    try {
      await _controller.loadRequest(_dashboardUri);
    } catch (error) {
      if (!mounted) return;
      debugPrint('Maxfolio dashboard navigation failed: $error');
      setState(() {
        _loading = false;
        _mainFrameError = 'Unable to start this webpage.';
      });
    }
  }

  Future<void> _openInSecureBrowser() async {
    // Chrome Custom Tabs on Android or SFSafariViewController on iOS.
    // This is a browser-powered *in-app* experience and is useful when
    // Android WebView rejects Maxfolio TLS or its OTP login flow.
    var opened = false;
    try {
      opened = await launchUrl(
        _dashboardUri,
        mode: LaunchMode.inAppBrowserView,
      );
    } catch (error) {
      debugPrint('Maxfolio in-app browser failed: $error');
    }
    if (opened) return;

    try {
      opened = await launchUrl(
        _dashboardUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (error) {
      debugPrint('Maxfolio system browser failed: $error');
    }
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No compatible browser could open Maxfolio.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF0D2444);
    const blue = Color(0xFF1675E9);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Investment Baskets',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            Text(
              'Maxfolio Dashboard',
              style: TextStyle(fontSize: 11, color: Color(0xFF67788E)),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _loadDashboard,
            tooltip: 'Refresh dashboard',
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            onPressed: _openInSecureBrowser,
            tooltip: 'Open in secure in-app browser',
            icon: const Icon(Icons.open_in_browser_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: WebViewWidget(controller: _controller)),
            if (_loading && _mainFrameError == null)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  minHeight: 3,
                  backgroundColor: const Color(0xFFEAF0F8),
                  color: blue,
                  value:
                      _progress > 0 && _progress < 100 ? _progress / 100 : null,
                ),
              ),
            if (_mainFrameError != null)
              Positioned.fill(
                child: ColoredBox(
                  color: const Color(0xFFF7F9FD),
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFE2EAF3),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.language_rounded,
                                size: 44,
                                color: blue,
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'Unable to load in WebView',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: ink,
                                ),
                              ),
                              const SizedBox(height: 9),
                              const Text(
                                'This website may require browser-based SSL '
                                'or OTP authentication. You can still open '
                                'it securely without leaving the app.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                  color: Color(0xFF61728B),
                                ),
                              ),
                              const SizedBox(height: 9),
                              Text(
                                _mainFrameError!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF8B98AA),
                                ),
                              ),
                              const SizedBox(height: 22),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: _openInSecureBrowser,
                                  icon:
                                      const Icon(Icons.open_in_browser_rounded),
                                  label: const Text('Open in secure browser'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: ink,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: _loadDashboard,
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Try WebView again'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
