import 'dart:async';
import 'dart:collection';
import 'dart:convert';

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

/// Shows the latest event in an embedded WebView.
/// Displays a native confirmation immediately after the website's valid
/// registration-form submission event, without waiting for its success popup.
/// This is an acknowledgement of submission, NOT independently verified save.
class EventsPage extends StatefulWidget {
  static const String pageName = '/event_page';

  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  static const String _successHandler = 'pfiEventRegistrationSuccess';
  static const String _submitHandler = 'pfiEventRegistrationSubmitted';

  // Per-page token prevents success messages from earlier visits being replayed.
  final String _pageToken = DateTime.now().microsecondsSinceEpoch.toString();

  String get _watcherScript => _registrationWatcherScript.replaceAll(
        '__PFI_PAGE_TOKEN__',
        _pageToken,
      );

  InAppWebViewController? webViewController;

  final InAppWebViewSettings settings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    javaScriptEnabled: true,
    domStorageEnabled: true,
    databaseEnabled: true,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    useHybridComposition: true,
    javaScriptCanOpenWindowsAutomatically: true,
    supportMultipleWindows: true,
    useShouldOverrideUrlLoading: true,
    iframeAllowFullscreen: true,
  );

  String url = '';
  String latestEventUrl = '';
  String? _loadingError;
  bool isLoading = true;
  bool _isShowingRegistrationSuccess = false;

  // Confirmation is triggered by a valid user-initiated form submission.
  // Website AJAX/SweetAlert success callbacks are optional and are deduplicated.
  // NOTE: A valid browser submission does not prove database persistence.
  DateTime? _lastValidSubmission;
  String? _lastSubmissionId;
  String? _lastConfirmedSubmissionId;

  bool get _hasRecentRegistrationSubmission {
    final date = _lastValidSubmission;
    if (date == null) return false;
    final age = DateTime.now().difference(date);
    return age.inMilliseconds >= -10000 && age < const Duration(minutes: 5);
  }

  @override
  void initState() {
    super.initState();
    _loadLatestEvent();
  }

  Future<void> _loadLatestEvent() async {
    if (!isLoading && mounted) {
      setState(() {
        isLoading = true;
        _loadingError = null;
      });
    }
    try {
      final eventUrl = (await UserService.getLatestEvents()).trim();
      if (!mounted) return;
      if (eventUrl.isEmpty) {
        throw StateError('No event URL was returned.');
      }
      final parsedUrl = Uri.tryParse(eventUrl);
      if (parsedUrl == null || parsedUrl.scheme != 'https') {
        throw StateError('Invalid event URL.');
      }
      setState(() {
        url = eventUrl;
        latestEventUrl = eventUrl;
        _loadingError = null;
        isLoading = false;
      });
    } catch (error) {
      if (kDebugMode) {
        debugPrint('EVENT WEBVIEW: Failed to retrieve latest event: $error');
      }
      if (!mounted) return;
      setState(() {
        isLoading = false;
        _loadingError = 'Unable to load the latest event. Please try again.';
      });
    }
  }

  Future<void> _shareLatestEvent() async {
    final eventUrl = latestEventUrl.trim();
    if (eventUrl.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Latest event link is not available right now.')),
      );
      return;
    }

    try {
      await Share.share(
          'Check out the latest event from Profit From It\n\n$eventUrl');
    } catch (error) {
      if (kDebugMode) debugPrint('EVENT SHARE: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to share the event right now.')),
      );
    }
  }

  /// Only the official site may request a native registration confirmation.
  bool _isOfficialEventUrl(WebUri? pageUrl) {
    if (pageUrl == null) return false;
    final page = Uri.tryParse(pageUrl.toString());
    if (page == null || page.scheme != 'https') return false;
    final host = page.host.toLowerCase();
    return host == 'profitfromit.co.in' || host == 'www.profitfromit.co.in';
  }

  void _onWebViewCreated(InAppWebViewController controller) {
    webViewController = controller;

    // The website saves registrations but does not reliably emit a success
    // callback in the embedded WebView. The user explicitly wants the native
    // dialog when a COMPLETED registration form is submitted. The injected JS
    // checks form validity and the actual form's Secure Your Spot button;
    // the navigation bar's anchor does NOT trigger this handler.
    controller.addJavaScriptHandler(
      handlerName: _submitHandler,
      callback: (arguments) async {
        if (!mounted || arguments.isEmpty || arguments.first is! Map) {
          return false;
        }
        // Check our known event origin rather than await getUrl(): a fast
        // registration redirect can already have changed the WebView URL.
        final eventUri = Uri.tryParse(latestEventUrl);
        if (eventUri == null ||
            eventUri.scheme != 'https' ||
            !{'profitfromit.co.in', 'www.profitfromit.co.in'}
                .contains(eventUri.host.toLowerCase())) {
          return false;
        }
        final data = arguments.first as Map;
        final submittedAtMs = int.tryParse('${data['submittedAt'] ?? ''}');
        final submissionId = '${data['submissionId'] ?? ''}'.trim();
        final pageToken = '${data['pageToken'] ?? ''}';
        if (pageToken != _pageToken ||
            submittedAtMs == null ||
            submissionId.isEmpty ||
            !_isRecentSubmittedAt(submittedAtMs)) {
          return false;
        }
        _acceptValidSubmission(submissionId, submittedAtMs);
        return true;
      },
    );

    controller.addJavaScriptHandler(
      handlerName: _successHandler,
      callback: (arguments) async {
        if (!mounted || arguments.isEmpty || arguments.first is! Map) {
          return false;
        }
        final currentUrl = await controller.getUrl();
        if (!mounted || !_isOfficialEventUrl(currentUrl)) return false;

        final data = arguments.first as Map;
        final pageToken = '${data['pageToken'] ?? ''}';
        final submittedAtMs = int.tryParse('${data['submittedAt'] ?? ''}');
        final submissionId = '${data['submissionId'] ?? ''}'.trim();
        final title = '${data['title'] ?? ''}';

        // A stored website flash success from a PREVIOUS visit must never
        // become a new Flutter success notification.
        if (pageToken != _pageToken ||
            submissionId.isEmpty ||
            submittedAtMs == null ||
            !_isRecentSubmittedAt(submittedAtMs) ||
            !RegExp(r'registration\s+(?:is\s+)?success', caseSensitive: false)
                .hasMatch(title)) {
          return false;
        }

        // Site navigation can cancel the asynchronous 'submitted' callback.
        // The document-start script carries the same page-token and validates
        // the form itself; recover its submission here if necessary.
        if (_lastSubmissionId != submissionId ||
            !_hasRecentRegistrationSubmission) {
          _lastSubmissionId = submissionId;
          _lastValidSubmission =
              DateTime.fromMillisecondsSinceEpoch(submittedAtMs);
        }
        if (_lastConfirmedSubmissionId == submissionId) return true;

        _lastConfirmedSubmissionId = submissionId;
        // Hide the website's copy, leaving just the Flutter success dialog.
        unawaited(_closeWebsiteSweetAlert());
        unawaited(_showRegistrationSuccess());
        return true;
      },
    );
  }

  bool _isRecentSubmittedAt(int millisecondsSinceEpoch) {
    final age = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch),
    );
    return age.inMilliseconds >= -10000 && age < const Duration(minutes: 2);
  }

  /// A valid form submission is all the user requires to see the confirmation.
  /// It does not wait for the website's unreliable SweetAlert/network signal.
  /// One submission ID can show the native dialog once only.
  void _acceptValidSubmission(String submissionId, int submittedAtMs) {
    if (!mounted || _lastConfirmedSubmissionId == submissionId) return;
    _lastSubmissionId = submissionId;
    _lastValidSubmission = DateTime.fromMillisecondsSinceEpoch(submittedAtMs);
    _lastConfirmedSubmissionId = submissionId;
    if (kDebugMode) {
      debugPrint('EVENT: Valid form submitted. Showing native confirmation.');
    }
    FocusManager.instance.primaryFocus?.unfocus();
    unawaited(_showRegistrationSuccess());
  }

  /// A form may cause an immediate document reload before JavaScript's
  /// Flutter bridge promise settles. Recover the current-visit form event
  /// from same-origin sessionStorage. Old-visit tokens are ignored.
  Future<void> _recoverSubmittedFormAfterReload(
    InAppWebViewController controller,
    WebUri? pageUrl,
  ) async {
    if (!mounted || !_isOfficialEventUrl(pageUrl)) return;
    try {
      final js = r'''(function(){
        try {
          var d = JSON.parse(sessionStorage.getItem(
            'pfi_event_pending_registration_v7') || 'null');
          if (!d || d.pageToken !== '__PFI_PAGE_TOKEN__') return null;
          var age = Date.now() - Number(d.submittedAt);
          if (!d.submissionId || !Number.isFinite(age) || age < -10000 ||
              age >= 120000) return null;
          return JSON.stringify(d);
        } catch (_) { return null; }
      })();'''
          .replaceAll('__PFI_PAGE_TOKEN__', _pageToken);
      final response = await controller.evaluateJavascript(source: js);
      if (!mounted || response is! String || response.trim().isEmpty) return;
      final data = jsonDecode(response);
      if (data is! Map) return;
      final id = '${data['submissionId'] ?? ''}'.trim();
      final submittedAt = int.tryParse('${data['submittedAt'] ?? ''}');
      if (id.isEmpty ||
          submittedAt == null ||
          !_isRecentSubmittedAt(submittedAt)) return;
      _acceptValidSubmission(id, submittedAt);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('EVENT: Could not recover submitted form: $error');
      }
    }
  }

  /// Install before the website renders its own popup; onLoadStop remains a
  /// fallback for Android WebViews without reliable document-start scripts.
  static const String _registrationWatcherScript = r'''
(function installPfiEventWatcher() {
  var host = String(location.hostname || '').toLowerCase();
  if (host !== 'profitfromit.co.in' && host !== 'www.profitfromit.co.in') return;
  if (window.__pfiEventWatcherV7) return;
  if (!document.documentElement) {
    setTimeout(installPfiEventWatcher, 20);
    return;
  }
  window.__pfiEventWatcherV7 = true;

  // This token belongs to ONE Flutter EventsPage visit, not the whole browser.
  var pageToken = '__PFI_PAGE_TOKEN__';
  var storageKey = 'pfi_event_pending_registration_v7';
  var activeSubmission = null;
  var lastSubmitTime = 0;
  var deliveredSuccess = false;
  var successReportBusy = false;
  var processedPopups = new WeakSet();

  function validRecent(item) {
    return !!(item && item.pageToken === pageToken && item.submissionId &&
      Number.isFinite(item.submittedAt) &&
      Date.now() - item.submittedAt >= -10000 &&
      Date.now() - item.submittedAt < 120000);
  }

  function getPending() {
    if (validRecent(activeSubmission)) return activeSubmission;
    try {
      var item = JSON.parse(sessionStorage.getItem(storageKey) || 'null');
      if (validRecent(item)) {
        activeSubmission = item;
        return item;
      }
      // Do not carry the former visit's confirmation into this one.
      if (item) sessionStorage.removeItem(storageKey);
    } catch (_) {}
    return null;
  }

  // Prefer Android WebView's ready event to avoid losing messages during page
  // redirects. Keep a short retry window for slow bridge initialization.
  function callNative(handler, data) {
    return new Promise(function (resolve) {
      var attempt = 0;
      function send() {
        var bridge = window.flutter_inappwebview;
        if (bridge && typeof bridge.callHandler === 'function') {
          Promise.resolve(bridge.callHandler(handler, data))
            .then(function (result) { resolve(result === true); })
            .catch(function () { resolve(false); });
          return;
        }
        if (++attempt > 40) { resolve(false); return; }
        setTimeout(send, 75);
      }
      send();
    });
  }

  function validForm(form) {
    if (!form || form.tagName !== 'FORM') return false;
    var buttons = Array.prototype.slice.call(
      form.querySelectorAll('button, input[type="submit"]'));
    if (!buttons.some(function (b) {
      return /secure\s+your\s+spot/i.test(
        String(b.textContent || b.value || '').replace(/\s+/g, ' '));
    })) return false;
    if (form.checkValidity && !form.checkValidity()) return false;

    var fields = Array.prototype.slice.call(form.querySelectorAll('input'))
      .filter(function (i) {
        return !i.disabled && /^(text|email|tel|number)$/i.test(i.type || 'text');
      });
    if (fields.length < 4 || fields.some(function (i) {
      return !String(i.value || '').trim();
    })) return false;
    var selects = Array.prototype.slice.call(form.querySelectorAll('select'));
    return selects.length > 0 && selects.every(function (s) {
      return !s.disabled && s.value && s.selectedIndex >= 0 &&
        !/^(select|choose)(\s+an\s+option)?$/i.test(
          String(s.options[s.selectedIndex].text || '').trim());
    });
  }

  function captureSubmission(form) {
    if (!validForm(form) || Date.now() - lastSubmitTime < 800) return;
    lastSubmitTime = Date.now();
    activeSubmission = {
      submittedAt: lastSubmitTime,
      submissionId: String(lastSubmitTime) + '-' +
        Math.random().toString(36).slice(2, 10),
      pageToken: pageToken
    };
    deliveredSuccess = false;
    successReportBusy = false;
    try { sessionStorage.setItem(storageKey, JSON.stringify(activeSubmission)); }
    catch (_) {}
    callNative('pfiEventRegistrationSubmitted', activeSubmission);
  }

  document.addEventListener('click', function (event) {
    var button = event.target && event.target.closest
      ? event.target.closest('button, input[type="submit"]') : null;
    if (!button || !/secure\s+your\s+spot/i.test(
        String(button.textContent || button.value || ''))) return;
    var form = button.form || (button.closest && button.closest('form'));
    if (!form) {
      var register = button.closest && button.closest('#register');
      form = register ? register.querySelector('form') : null;
    }
    captureSubmission(form);
  }, true);
  document.addEventListener('submit', function (event) {
    captureSubmission(event.target);
  }, true);

  function reportSuccess(title, message, popup) {
    var pending = getPending();
    // A stale website success may show on page open, but never tell Flutter
    // that a new registration succeeded unless THIS visit submitted a form.
    if (!pending || deliveredSuccess || successReportBusy) return;
    if (!/registration\s+(?:is\s+)?success/i.test(String(title || ''))) return;
    successReportBusy = true;
    callNative('pfiEventRegistrationSuccess', {
      title: 'Registration Successful',
      message: String(message || ''),
      pageToken: pageToken,
      submittedAt: pending.submittedAt,
      submissionId: pending.submissionId
    }).then(function (accepted) {
      successReportBusy = false;
      if (accepted) {
        deliveredSuccess = true;
        activeSubmission = null;
        try { sessionStorage.removeItem(storageKey); } catch (_) {}
        if (popup) hideWebsiteSuccessPopup(popup);
      }
      // If the bridge is unavailable, retain the website's genuine success
      // message rather than silently losing confirmation for the user.
    });
  }

  function hideWebsiteSuccessPopup(popup) {
    if (processedPopups.has(popup)) return;
    processedPopups.add(popup);
    // Only the registration SUCCESS modal is hidden. Validation failures and
    // other alerts remain on the website as usual.
    var swalContainer = popup.closest && popup.closest('.swal2-container');
    var holder = swalContainer || popup.closest &&
      popup.closest('.swal-overlay') || popup;
    if (holder && holder.style) holder.style.setProperty('display','none','important');
    setTimeout(function () {
      try {
        if (window.Swal && typeof window.Swal.close === 'function') {
          window.Swal.close();
        } else {
          var ok = popup.querySelector('.swal2-confirm, .swal-button--confirm');
          if (ok) ok.click();
        }
      } catch (_) {}
    }, 0);
  }

  function inspectPopup() {
    var dialogs = document.querySelectorAll(
      '.swal2-popup, .sweet-alert, .swal-modal, [role="alertdialog"]');
    for (var i = 0; i < dialogs.length; i++) {
      var d = dialogs[i];
      if (!d.isConnected) continue;
      var header = d.querySelector(
        '.swal2-title, .swal-title, h2, h3, [role="heading"]');
      var text = String(d.textContent || '').replace(/\s+/g, ' ').trim();
      var title = header ? String(header.textContent || '') : text;
      if (/registration\s+(?:is\s+)?success/i.test(title) ||
          /registration\s+(?:is\s+)?successful/i.test(text)) {
        if (getPending()) {
          reportSuccess('Registration Successful', text, d);
          // The website's dialog stays visible if Flutter cannot show its own.
        } else {
          // Old server-side flash shown on reopening the event.
          hideWebsiteSuccessPopup(d);
        }
      }
    }
  }

  function parsePositiveReply(body, requestUrl) {
    if (typeof body !== 'string' || body.length > 150000) return null;
    var t = body.trim();
    var registrationPath = /register|registration|event|webinar|rsvp|enroll/i
      .test(String(requestUrl || ''));
    try {
      var obj = JSON.parse(t);
      if (!obj || typeof obj !== 'object') return null;
      var message = String(obj.message || obj.msg || '');
      var hasRegistrationMessage = /registr|secure\s+your\s+spot/i.test(message);
      var ok = obj.success === true || obj.registered === true ||
        obj.status === 'success' || obj.status === 'registered' ||
        (obj.data && obj.data.registration_status === 'confirmed');
      if (ok && (hasRegistrationMessage || registrationPath)) {
        return message || 'Registration successful! We will contact you soon.';
      }
    } catch (_) {}
    if (/^registration\s+(?:is\s+)?successful[!.\s]*$/i.test(t)) return t;
    return null;
  }

  function reportPositiveNetwork(status, method, requestUrl, body) {
    if (status < 200 || status >= 300 ||
        String(method || 'GET').toUpperCase() !== 'POST' || !getPending()) {
      return;
    }
    var url;
    try { url = new URL(String(requestUrl || ''), location.href); }
    catch (_) { return; }
    if (url.hostname !== 'profitfromit.co.in' &&
        url.hostname !== 'www.profitfromit.co.in') return;
    var message = parsePositiveReply(body, url.pathname);
    if (message) reportSuccess('Registration Successful', message);
  }

  if (typeof window.fetch === 'function') {
    var oldFetch = window.fetch;
    window.fetch = function (input, init) {
      var method = (init && init.method) || (input && input.method) || 'GET';
      var url = typeof input === 'string' ? input : input && input.url || '';
      return oldFetch.apply(this, arguments).then(function (response) {
        if (getPending()) {
          response.clone().text().then(function (txt) {
            reportPositiveNetwork(response.status, method, url, txt);
          }).catch(function () {});
        }
        return response;
      });
    };
  }

  if (typeof XMLHttpRequest !== 'undefined') {
    var oldOpen = XMLHttpRequest.prototype.open;
    var oldSend = XMLHttpRequest.prototype.send;
    XMLHttpRequest.prototype.open = function (method, url) {
      this.__pfiMethod = method;
      this.__pfiUrl = url;
      return oldOpen.apply(this, arguments);
    };
    XMLHttpRequest.prototype.send = function () {
      var xhr = this;
      xhr.addEventListener('load', function () {
        if (!getPending()) return;
        var body = '';
        try { body = xhr.responseText || ''; } catch (_) {}
        reportPositiveNetwork(xhr.status, xhr.__pfiMethod, xhr.__pfiUrl, body);
      });
      return oldSend.apply(this, arguments);
    };
  }

  new MutationObserver(inspectPopup).observe(document.documentElement, {
    childList: true, subtree: true, characterData: true
  });
  window.__pfiEventCheckSuccess = inspectPopup;
  // This also dismisses any server-generated flash SUCCESS from a former visit.
  inspectPopup();
})();
''';

  Future<void> _injectRegistrationSuccessMonitor(
    InAppWebViewController controller,
    WebUri? pageUrl,
  ) async {
    if (!_isOfficialEventUrl(pageUrl)) return;

    // Fallback for Android versions that do not inject at document start.
    try {
      await controller.evaluateJavascript(source: _watcherScript);
      await controller.evaluateJavascript(
        source:
            "window.__pfiEventCheckSuccess && window.__pfiEventCheckSuccess();",
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('EVENT WEBVIEW: Could not install success monitor: $error');
      }
    }
  }

  Future<void> _showRegistrationSuccess() async {
    if (!mounted || _isShowingRegistrationSuccess) return;
    _isShowingRegistrationSuccess = true;
    if (!mounted) {
      _isShowingRegistrationSuccess = false;
      return;
    }

    // bool result: true = user asked to invite friends, false = OK.
    bool inviteFriends = false;
    try {
      inviteFriends = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 70,
                    color: Color(0xFF66BB6A),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Registration Successful!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF192232),
                    ),
                  ),
                ],
              ),
              content: const Text(
                '🎉 Registration successful! We will contact you soon.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.45,
                  color: Color(0xFF505765),
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFD7B53B),
                    foregroundColor: const Color(0xFF182033),
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('OK'),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF111827),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('Invite Friends'),
                ),
              ],
            ),
          ) ??
          false;
    } finally {
      _isShowingRegistrationSuccess = false;
      await _closeWebsiteSweetAlert();
    }

    if (inviteFriends && mounted) {
      await _shareLatestEvent();
    }
  }

  Future<void> _closeWebsiteSweetAlert() async {
    try {
      await webViewController?.evaluateJavascript(source: r'''
(function () {
  if (window.Swal && typeof window.Swal.close === 'function') {
    window.Swal.close();
  } else {
    var ok = document.querySelector('.swal2-popup .swal2-confirm');
    if (ok) ok.click();
  }
})();
''');
    } catch (error) {
      if (kDebugMode)
        debugPrint('EVENT WEBVIEW: Could not close website popup: $error');
    }
  }

  /// Only window.open()/target=_blank requests arrive here. SweetAlert2's
  /// in-page registration success is handled separately above.
  Future<bool> _onCreateWindow(CreateWindowAction action) async {
    if (!mounted || action.windowId == null) return false;

    final windowId = action.windowId!;
    // Do not wait for showDialog: the WebView must be told immediately that
    // its native popup window will be hosted by our Flutter dialog.
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 30),
        child: SizedBox(
          height: MediaQuery.of(dialogContext).size.height * 0.76,
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Event',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close popup',
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                ],
              ),
              const Divider(height: 1),
              Expanded(
                child: InAppWebView(
                  windowId: windowId,
                  initialSettings: InAppWebViewSettings(
                    javaScriptEnabled: true,
                    domStorageEnabled: true,
                    supportMultipleWindows: false,
                    useHybridComposition: true,
                  ),
                  onCloseWindow: (_) {
                    if (dialogContext.mounted &&
                        Navigator.of(dialogContext).canPop()) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return directionality(
      child: Scaffold(
        drawerEnableOpenDragGesture: false,
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
            : _loadingError != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_loadingError!, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _loadLatestEvent,
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  )
                : InAppWebView(
                    initialUrlRequest: URLRequest(url: WebUri(url)),
                    initialSettings: settings,
                    initialUserScripts: UnmodifiableListView<UserScript>([
                      UserScript(
                        source: _watcherScript,
                        injectionTime:
                            UserScriptInjectionTime.AT_DOCUMENT_START,
                        forMainFrameOnly: true,
                      ),
                    ]),
                    onWebViewCreated: _onWebViewCreated,
                    onLoadStart: (controller, pageUrl) {
                      if (kDebugMode) {
                        debugPrint('EVENT WEBVIEW: Page started loading');
                      }
                    },
                    shouldOverrideUrlLoading: (controller, action) async {
                      return NavigationActionPolicy.ALLOW;
                    },
                    onLoadStop: (controller, pageUrl) async {
                      await _injectRegistrationSuccessMonitor(
                          controller, pageUrl);
                      await _recoverSubmittedFormAfterReload(
                          controller, pageUrl);
                    },
                    onCreateWindow: (controller, action) =>
                        _onCreateWindow(action),
                    onJsAlert: (controller, request) async {
                      // Some sites also use window.alert. A stale alert must
                      // not be interpreted as a registration on page open.
                      final jsMessage = request.message ?? '';
                      if (RegExp(r'registration\s+successful',
                              caseSensitive: false)
                          .hasMatch(jsMessage)) {
                        final submissionId = _lastSubmissionId;
                        if (_hasRecentRegistrationSubmission &&
                            submissionId != null &&
                            _lastConfirmedSubmissionId != submissionId &&
                            !_isShowingRegistrationSuccess) {
                          _lastConfirmedSubmissionId = submissionId;
                          unawaited(_showRegistrationSuccess());
                        }
                        // The website alert is suppressed; only the current
                        // screen's verified submission gets a native dialog.
                        return JsAlertResponse(
                          action: JsAlertResponseAction.CONFIRM,
                        );
                      }
                      if (!mounted) {
                        return JsAlertResponse(
                          action: JsAlertResponseAction.CONFIRM,
                        );
                      }
                      await showDialog<void>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          content: Text(request.message ?? ''),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                      return JsAlertResponse(
                        action: JsAlertResponseAction.CONFIRM,
                      );
                    },
                    onReceivedError: (controller, request, error) {
                      if (kDebugMode && request.isForMainFrame == true) {
                        debugPrint(
                            'EVENT WEBVIEW: Navigation error: ${error.description}');
                      }
                    },
                    onReceivedHttpError: (controller, request, response) {
                      if (kDebugMode && request.isForMainFrame == true) {
                        debugPrint(
                            'EVENT WEBVIEW: HTTP ${response.statusCode}');
                      }
                    },
                    onConsoleMessage: (controller, message) {
                      if (kDebugMode) {
                        debugPrint('EVENT WEBVIEW CONSOLE: ${message.message}');
                      }
                    },
                  ),
      ),
    );
  }
 }
