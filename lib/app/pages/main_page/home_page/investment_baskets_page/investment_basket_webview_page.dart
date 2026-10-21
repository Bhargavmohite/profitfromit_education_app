import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webinar/app/pages/main_page/home_page/investment_baskets_page/investment_basket_data.dart';
import 'package:webinar/app/pages/main_page/home_page/investment_baskets_page/investment_basket_widgets.dart';

/// Displays the official Maxfolio basket URL without changing the site's
/// login/OTP or navigation flow. If the website cannot load in WebView,
/// the user can open the same URL in their device browser.
class InvestmentBasketWebViewPage extends StatefulWidget {
  const InvestmentBasketWebViewPage({
    super.key,
    required this.basket,
  });

  final InvestmentBasket basket;

  @override
  State<InvestmentBasketWebViewPage> createState() =>
      _InvestmentBasketWebViewPageState();
}

class _InvestmentBasketWebViewPageState
    extends State<InvestmentBasketWebViewPage> {
  late final WebViewController _controller;
  late final Uri _basketUrl;

  bool _isLoading = true;
  bool _showReturnToBasket = false;
  int _progress = 0;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _basketUrl = Uri.parse(widget.basket.detailsUrl);
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          // Maxfolio owns its OTP/login flow. Never cancel those requests or
          // automatically load another URL while verification is in progress.
          onNavigationRequest: (_) => NavigationDecision.navigate,
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _isLoading = true;
              _progress = 0;
              _loadError = null;
              _showReturnToBasket = false;
            });
          },
          onProgress: (value) {
            if (!mounted) return;
            setState(() => _progress = value);
          },
          onPageFinished: (url) {
            if (!mounted) return;
            final location = Uri.tryParse(url);
            final isMaxfolioPage = location != null &&
                (location.host.toLowerCase() == _basketUrl.host.toLowerCase() ||
                    location.host.toLowerCase().endsWith('.maxfolio.in'));
            final path = location?.path.toLowerCase() ?? '';
            final onAuthScreen = const [
              'login',
              'sign-in',
              'signin',
              'otp',
              'verify',
              'auth',
              'register',
              'callback',
            ].any((segment) => path.contains(segment));
            setState(() {
              _isLoading = false;
              _progress = 100;
              // Offer a manual return only from another Maxfolio page,
              // never from OTP/login. Automatic refresh can break sessions.
              _showReturnToBasket =
                  isMaxfolioPage && !onAuthScreen && !_isSelectedUrl(url);
            });
          },
          onWebResourceError: (error) {
            if (!mounted || error.isForMainFrame != true) return;
            setState(() {
              _isLoading = false;
              _loadError = 'Maxfolio could not open this page in the app. '
                  '${error.description} (Code ${error.errorCode}).';
            });
          },
        ),
      );
    _openBasket();
  }

  bool _isSelectedUrl(String url) {
    final location = Uri.tryParse(url);
    if (location == null) return false;
    return location.host.toLowerCase() == _basketUrl.host.toLowerCase() &&
        location.path.replaceAll(RegExp(r'/+$'), '') == '/details' &&
        location.queryParameters['pc'] == _basketUrl.queryParameters['pc'] &&
        location.queryParameters['bc'] == _basketUrl.queryParameters['bc'];
  }

  Future<void> _openBasket() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _progress = 0;
      _loadError = null;
      _showReturnToBasket = false;
    });
    try {
      await _controller.loadRequest(_basketUrl);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = 'Unable to open the selected basket: $error';
      });
    }
  }

  Future<void> _reload() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _progress = 0;
      _loadError = null;
    });
    try {
      await _controller.reload();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = 'Unable to refresh Maxfolio: $error';
      });
    }
  }

  Future<void> _openInBrowser() async {
    try {
      final launched = await launchUrl(
        _basketUrl,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) throw Exception('No browser could open this URL.');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to open browser: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: BasketColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.basket.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: BasketColors.ink,
              ),
            ),
            const Text(
              'Full Basket Details',
              style: TextStyle(fontSize: 11, color: BasketColors.secondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _reload,
            tooltip: 'Refresh page',
            icon: const Icon(Icons.refresh_rounded),
          ),
          PopupMenuButton<String>(
            tooltip: 'More options',
            onSelected: (action) {
              if (action == 'basket') _openBasket();
              if (action == 'browser') _openInBrowser();
            },
            itemBuilder: (_) => const [
              PopupMenuItem<String>(
                value: 'basket',
                child: Text('Open selected basket'),
              ),
              PopupMenuItem<String>(
                value: 'browser',
                child: Text('Open in device browser'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_showReturnToBasket && _loadError == null)
              Material(
                color: const Color(0xFFEDF5FF),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Maxfolio opened another page after login.',
                          style: TextStyle(
                            color: BasketColors.ink,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _openBasket,
                        child: const Text('View Basket'),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: WebViewWidget(controller: _controller),
                  ),
                  if (_isLoading)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(
                        minHeight: 3,
                        value: _progress > 0 && _progress < 100
                            ? _progress / 100
                            : null,
                        color: BasketColors.blue,
                        backgroundColor: BasketColors.canvas,
                      ),
                    ),
                  if (_loadError != null)
                    Positioned.fill(
                      child: ColoredBox(
                        color: Colors.white,
                        child: Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.language_rounded,
                                  color: BasketColors.secondary,
                                  size: 48,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Web page unavailable',
                                  style: TextStyle(
                                    color: BasketColors.ink,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _loadError!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: BasketColors.secondary,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                FilledButton.icon(
                                  onPressed: _openBasket,
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: const Text('Retry in App'),
                                ),
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  onPressed: _openInBrowser,
                                  icon:
                                      const Icon(Icons.open_in_browser_rounded),
                                  label: const Text('Open in Browser'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
