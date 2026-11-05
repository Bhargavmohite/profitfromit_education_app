import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

/// Native app shell for the existing Profit From It onboarding and checkout.
///
/// Financial details, prices, discounts, payment status and portfolio uploads
/// remain under the control of the existing HTTPS website. This view does not
/// create a second payment order, interpret a payment result, or store card data.
class SecureServiceWebViewPage extends StatefulWidget {
  const SecureServiceWebViewPage({
    super.key,
    required this.title,
    required this.initialUrl,
    this.subtitle,
  }) : assert(initialUrl != '');

  final String title;
  final String? subtitle;
  final String initialUrl;

  @override
  State<SecureServiceWebViewPage> createState() =>
      _SecureServiceWebViewPageState();
}

class _SecureServiceWebViewPageState extends State<SecureServiceWebViewPage> {
  static const _navy = Color(0xFF102641);
  static const _blue = Color(0xFF1677E9);

  InAppWebViewController? _controller;
  bool _loading = true;
  int _progress = 0;
  bool _launchingBrowser = false;
  String? _error;

  InAppWebViewSettings get _settings => InAppWebViewSettings(
        javaScriptEnabled: true,
        useHybridComposition: true,
        isInspectable: kDebugMode,
        useShouldOverrideUrlLoading: true,
        supportMultipleWindows: true,
        javaScriptCanOpenWindowsAutomatically: true,
        allowsInlineMediaPlayback: true,
        mediaPlaybackRequiresUserGesture: true,
        iframeAllowFullscreen: true,
      );

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  /// Allow HTTPS destinations, including Easebuzz payment domains; hand off
  /// installed-app schemes (UPI/intent/etc). Never ignore TLS certificate errors.
  Future<NavigationActionPolicy> _handleNavigation(
    NavigationAction action,
  ) async {
    final raw = action.request.url?.toString();
    final uri = raw == null ? null : Uri.tryParse(raw);
    if (uri == null) return NavigationActionPolicy.CANCEL;

    final scheme = uri.scheme.toLowerCase();
    if (scheme == 'https' ||
        scheme == 'about' ||
        scheme == 'data' ||
        scheme == 'blob') {
      return NavigationActionPolicy.ALLOW;
    }

    if (scheme == 'http') {
      _message('An insecure payment link was blocked.');
      return NavigationActionPolicy.CANCEL;
    }

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!opened) _message('No installed app can open this payment link.');
    } catch (_) {
      _message('Unable to open this payment link on your device.');
    }
    return NavigationActionPolicy.CANCEL;
  }

  Future<void> _retry() async {
    if (!mounted) return;
    setState(() {
      _error = null;
      _loading = true;
      _progress = 0;
    });
    final controller = _controller;
    if (controller == null) return;
    try {
      // Reloading a POST-payment response may prompt a resubmission; only
      // offer retry after a real load error, not as a normal checkout control.
      await controller.reload();
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Unable to reload. Check your internet connection.';
        });
      }
    }
  }

  Future<void> _browserFallback() async {
    if (_launchingBrowser) return;
    setState(() => _launchingBrowser = true);
    try {
      // Start at the original GET form URL: never replay a submitted payment
      // URL or presume that an in-progress form will carry across browsers.
      final uri = Uri.parse(widget.initialUrl);
      var opened = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      if (!opened) {
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      if (!opened) _message('Unable to open the secure form.');
    } catch (_) {
      _message('No compatible browser is available.');
    } finally {
      if (mounted) setState(() => _launchingBrowser = false);
    }
  }

  Future<bool> _confirmExit() async {
    if (!mounted) return false;
    return (await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Leave this form?'),
            content: const Text(
              'Unsaved details may be lost. If a payment is in progress, '
              'wait for the payment confirmation before leaving.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Stay'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Leave'),
              ),
            ],
          ),
        )) ??
        false;
  }

  Future<bool> _onBack() async {
    try {
      final controller = _controller;
      if (controller != null && await controller.canGoBack()) {
        await controller.goBack();
        return false;
      }
    } catch (_) {
      // Fall through to a guarded exit.
    }
    return _confirmExit();
  }

  Future<void> _backButton() async {
    if (await _onBack() && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBack,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: _backButton,
            tooltip: 'Back',
          ),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          foregroundColor: _navy,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleSpacing: 0,
          title: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (widget.subtitle != null)
                Text(
                  widget.subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 3,
                child: _loading
                    ? LinearProgressIndicator(
                        value: _progress > 0 && _progress < 100
                            ? _progress / 100
                            : null,
                        color: _blue,
                        backgroundColor: const Color(0xFFE9F1FC),
                      )
                    : const SizedBox.shrink(),
              ),
              Expanded(
                child: Stack(
                  children: [
                    InAppWebView(
                      initialUrlRequest: URLRequest(
                        url: WebUri(widget.initialUrl),
                      ),
                      initialSettings: _settings,
                      onWebViewCreated: (controller) => _controller = controller,
                      shouldOverrideUrlLoading: (controller, action) =>
                          _handleNavigation(action),
                      onProgressChanged: (controller, progress) {
                        if (!mounted) return;
                        setState(() => _progress = progress);
                      },
                      onLoadStart: (controller, url) {
                        if (!mounted) return;
                        setState(() {
                          _loading = true;
                          _error = null;
                        });
                      },
                      onLoadStop: (controller, url) {
                        if (!mounted) return;
                        setState(() {
                          _loading = false;
                          _progress = 100;
                        });
                        // A URL change never counts as proof of payment.
                      },
                      onReceivedError: (controller, request, error) {
                        if (!mounted || request.isForMainFrame != true) return;
                        setState(() {
                          _loading = false;
                          _error = 'Could not load this page. Check your connection.';
                        });
                      },
                      onReceivedHttpError: (controller, request, response) {
                        if (!mounted || request.isForMainFrame != true) return;
                        final code = response.statusCode ?? 0;
                        if (code < 400) return;
                        setState(() {
                          _loading = false;
                          _error = 'Server error (HTTP $code). Please try again.';
                        });
                      },
                      onCreateWindow: (controller, action) async {
                        if (!mounted) return false;
                        Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (_) => _SecurePaymentPopup(
                              windowId: action.windowId,
                            ),
                          ),
                        );
                        return true;
                      },
                    ),
                    if (_error != null)
                      Positioned.fill(
                        child: ColoredBox(
                          color: const Color(0xFFF6F8FC),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 380),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.wifi_off_rounded,
                                        size: 44, color: _blue),
                                    const SizedBox(height: 14),
                                    const Text(
                                      'Unable to load the form',
                                      style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w800,
                                        color: _navy,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(_error!, textAlign: TextAlign.center),
                                    const SizedBox(height: 18),
                                    FilledButton.icon(
                                      onPressed: _retry,
                                      icon: const Icon(Icons.refresh_rounded),
                                      label: const Text('Try again'),
                                    ),
                                    const SizedBox(height: 6),
                                    TextButton(
                                      onPressed: _launchingBrowser
                                          ? null
                                          : _browserFallback,
                                      child: const Text('Open secure form in browser'),
                                    ),
                                  ],
                                ),
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
      ),
    );
  }
}

/// Gateway-created authentication window (for payment redirects / 3-D Secure).
class _SecurePaymentPopup extends StatelessWidget {
  const _SecurePaymentPopup({required this.windowId});

  final int windowId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF102641),
        title: const Text('Secure Payment'),
      ),
      body: SafeArea(
        child: InAppWebView(
          windowId: windowId,
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            useHybridComposition: true,
            useShouldOverrideUrlLoading: true,
          ),
          shouldOverrideUrlLoading: (controller, action) async {
            final raw = action.request.url?.toString();
            final uri = raw == null ? null : Uri.tryParse(raw);
            if (uri == null) return NavigationActionPolicy.CANCEL;
            if (const {'https', 'about', 'data', 'blob'}.contains(uri.scheme)) {
              return NavigationActionPolicy.ALLOW;
            }
            if (uri.scheme == 'http') return NavigationActionPolicy.CANCEL;
            try {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } catch (_) {
              // User can return to the checkout and use its error fallback.
            }
            return NavigationActionPolicy.CANCEL;
          },
        ),
      ),
    );
  }
}
