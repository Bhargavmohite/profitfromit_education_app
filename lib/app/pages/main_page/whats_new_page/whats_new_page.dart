import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webinar/app/models/whats_new_model.dart';
import 'package:webinar/app/services/guest_service/whats_new_service.dart';
import 'package:webinar/app/widgets/main_widget/home_widget/single_course_widget/vimeo_video_player_widget.dart';

/// Pass a release for the automatic first-open screen, or omit it when opened
/// manually from the drawer (the latter fetches fresh data from the backend).
/// Result: selected CTA action, or '' when the user chooses Continue.
class WhatsNewPage extends StatefulWidget {
  const WhatsNewPage({
    super.key,
    this.release,
    this.isFirstOpen = false,
  });

  final WhatsNewRelease? release;
  final bool isFirstOpen;

  @override
  State<WhatsNewPage> createState() => _WhatsNewPageState();
}

class _WhatsNewPageState extends State<WhatsNewPage>
    with WidgetsBindingObserver {
  static const Color navy = Color(0xFF0F204D);
  static const Color royal = Color(0xFF2055DC);
  static const Color ink = Color(0xFF152449);
  static const Color muted = Color(0xFF687793);
  static const Color bg = Color(0xFFF5F7FD);
  static const Color line = Color(0xFFE7EBF5);

  // Production: 5 minutes. For a quick development test, compile with:
  // flutter run --dart-define=WHATS_NEW_REFRESH_SECONDS=15
  static const int _configuredRefreshSeconds = int.fromEnvironment(
    'WHATS_NEW_REFRESH_SECONDS',
    defaultValue: 300,
  );
  static const Duration _updateInterval = Duration(
    seconds: _configuredRefreshSeconds > 0 ? _configuredRefreshSeconds : 300,
  );

  Timer? _updateTimer;
  WhatsNewRelease? _release;
  String? _contentFingerprint;
  String? _loadError;
  String? _lastRefreshError;
  DateTime? _lastCheckedAt;
  bool _loading = true;
  bool _requestInFlight = false;

  String get _intervalLabel {
    final seconds = _updateInterval.inSeconds;
    return seconds == 300 ? '5 min' : '$seconds sec';
  }

  String get _checkStatus {
    final checked = _lastCheckedAt;
    if (checked == null) return 'Checking backend...';
    if (_lastRefreshError != null) return 'Connection issue · retrying';
    final hh = checked.hour.toString().padLeft(2, '0');
    final mm = checked.minute.toString().padLeft(2, '0');
    final ss = checked.second.toString().padLeft(2, '0');
    return 'Checked at $hh:$mm:$ss';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Use already-loaded startup data for instant display. In *all* cases,
    // fetch fresh data immediately and then keep checking while mounted.
    _release = widget.release;
    _contentFingerprint = _release == null ? null : _fingerprint(_release!);
    _loading = _release == null;

    _startPolling();
    unawaited(_checkForUpdates(reason: 'page opened'));
  }

  void _startPolling() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(_updateInterval, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      // Deliberately no _appInForeground guard here. A transient inactive/
      // paused lifecycle notification previously suppressed timer fetches
      // even while the Whats New page remained displayed on some devices.
      // Android pauses Dart timers when the process is suspended; on resume
      // we also fetch immediately below.
      debugPrint("What's New: scheduled backend poll #${timer.tick} "
          '(${_updateInterval.inSeconds}s interval)');
      unawaited(_checkForUpdates(reason: 'timer #${timer.tick}'));
    });
    debugPrint("What's New: live polling enabled "
        '(every ${_updateInterval.inSeconds}s)');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Do not wait for the remaining interval after app foregrounding.
      debugPrint("What's New: app resumed; checking backend now");
      unawaited(_checkForUpdates(reason: 'app resumed'));
    }
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // All visible fields are compared, including the optional Vimeo URL and
  // CTA destination. An unchanged response does not rebuild the card/video UI.
  String _fingerprint(WhatsNewRelease release) => jsonEncode([
        release.enabled,
        release.version,
        release.title,
        release.subtitle,
        release.publishedAt,
        for (final card in release.cards)
          [
            card.id,
            card.icon,
            card.title,
            card.subtitle,
            card.videoUrl,
            card.ctaLabel,
            card.ctaAction,
            card.tag,
          ],
      ]);

  Future<void> _checkForUpdates({required String reason}) async {
    if (!mounted) return;
    if (_requestInFlight) {
      debugPrint("What's New: $reason skipped (request in progress)");
      return;
    }

    _requestInFlight = true;
    debugPrint("What's New: fetching latest release ($reason)");
    try {
      final latest = await WhatsNewService.fetch();
      if (!mounted) return;

      final checkedAt = DateTime.now();
      if (latest == null) {
        final message = WhatsNewService.lastError ??
            'The update service is temporarily unavailable.';
        // Keep last-good content visible, but show a connection indicator.
        setState(() {
          _lastCheckedAt = checkedAt;
          _lastRefreshError = message;
          if (_release == null) {
            _loading = false;
            _loadError = message;
          }
        });
        debugPrint("What's New: fetch failed ($reason): $message");
        return;
      }

      final fingerprint = _fingerprint(latest);
      final changed = _contentFingerprint != fingerprint;
      setState(() {
        _lastCheckedAt = checkedAt;
        _lastRefreshError = null;
        _loading = false;
        _loadError = null;
        if (changed || _release == null) {
          _release = latest;
          _contentFingerprint = fingerprint;
        }
      });
      debugPrint("What's New: backend poll completed ($reason); "
          'changed=$changed, cards=${latest.cards.length}, '
          'revision=${WhatsNewService.lastRevision ?? 'not supplied'}');
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _lastCheckedAt = DateTime.now();
        _lastRefreshError = 'Unable to check for updates right now.';
        if (_release == null) {
          _loading = false;
          _loadError = _lastRefreshError;
        }
      });
      debugPrint("What's New: unexpected refresh error ($reason): "
          '${error.runtimeType}');
    } finally {
      _requestInFlight = false;
    }
  }

  void _close([String action = '']) =>
      Navigator.of(context).pop<String>(action);

  static IconData _iconFor(String key) {
    switch (key.toLowerCase()) {
      case 'calculator':
        return Icons.calculate_rounded;
      case 'portfolio':
        return Icons.pie_chart_rounded;
      case 'basket':
        return Icons.account_balance_rounded;
      case 'planning':
        return Icons.insights_rounded;
      case 'courses':
        return Icons.auto_stories_rounded;
      case 'video':
        return Icons.play_circle_fill_rounded;
      case 'dashboard':
        return Icons.dashboard_customize_rounded;
      case 'security':
        return Icons.verified_user_rounded;
      case 'gift':
        return Icons.card_giftcard_rounded;
      case 'update':
        return Icons.tips_and_updates_rounded;
      default:
        return Icons.auto_awesome_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.isFirstOpen,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: ink,
          surfaceTintColor: Colors.white,
          automaticallyImplyLeading: !widget.isFirstOpen,
          title: const Text("What's New",
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon(
                  //   _lastRefreshError == null
                  //       ? Icons.sync_rounded
                  //       : Icons.cloud_off_rounded,
                  //   color: _lastRefreshError == null
                  //       ? royal
                  //       : const Color(0xFFA76C13),
                  //   size: 18,
                  // ),
                  // const SizedBox(width: 6),
                  // Column(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Text('Auto · every $_intervalLabel',
                  //         style: const TextStyle(
                  //           color: royal,
                  //           fontSize: 10,
                  //           fontWeight: FontWeight.w800,
                  //         )),
                  //     const SizedBox(height: 2),
                  //     Text(_checkStatus,
                  //         style: const TextStyle(
                  //           color: muted,
                  //           fontSize: 9,
                  //         )),
                  //   ],
                  // ),
                ],
              ),
            ),
          ],
        ),
        body: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading && _release == null) {
      return const Center(child: CircularProgressIndicator(color: royal));
    }

    final release = _release;
    if (release == null) {
      return _messageState(
        icon: Icons.cloud_off_rounded,
        title: 'Updates temporarily unavailable',
        text: '${_loadError ?? 'Please check your connection.'}\n'
            'This page retries automatically every 5 minutes.',
        button: widget.isFirstOpen ? 'Continue to Home' : 'Go back',
        onPressed: _close,
      );
    }

    if (!release.enabled || release.cards.isEmpty) {
      return _messageState(
        icon: Icons.check_circle_outline_rounded,
        title: 'All caught up',
        text: 'There are no release notes to show right now. '
            'New announcements will appear automatically.',
        button: widget.isFirstOpen ? 'Continue to Home' : 'Go back',
        onPressed: _close,
      );
    }

    return _releaseView(release);
  }

  Widget _releaseView(WhatsNewRelease release) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 15, 18, 32),
            physics: const BouncingScrollPhysics(),
            children: [
              _hero(release),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Row(
                  children: [
                    const Icon(Icons.stars_rounded, color: royal, size: 22),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('Explore the improvements',
                          style: TextStyle(
                            color: ink,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          )),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EEFF),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text('${release.cards.length} updates',
                          style: const TextStyle(
                              color: royal,
                              fontWeight: FontWeight.w800,
                              fontSize: 11)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 13),
              for (final card in release.cards) ...[
                _featureCard(card),
                const SizedBox(height: 14),
              ],
              const SizedBox(height: 9),
              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _close,
                  icon: Icon(widget.isFirstOpen
                      ? Icons.arrow_forward_rounded
                      : Icons.check_rounded),
                  label: Text(widget.isFirstOpen ? 'Continue to Home' : 'Done'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: navy,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Profit From It  •  Built for better learning',
                textAlign: TextAlign.center,
                style: TextStyle(color: muted, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hero(WhatsNewRelease release) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [navy, Color(0xFF1F51C8), Color(0xFF2E71E6)],
        ),
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
              color: royal.withValues(alpha: .17),
              blurRadius: 22,
              offset: const Offset(0, 9)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -52,
            top: -62,
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 18,
            bottom: -80,
            child: Container(
              width: 155,
              height: 155,
              decoration: BoxDecoration(
                color: const Color(0xFF8DB2FF).withValues(alpha: .12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .16),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    'NEW IN VERSION ${release.version}',
                    style: const TextStyle(
                        color: Color(0xFFE9F0FF),
                        fontSize: 11,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(height: 26),
                Text(release.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 31,
                        letterSpacing: -.5,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 9),
                Text(release.subtitle,
                    style: const TextStyle(
                        color: Color(0xFFDFE8FF), height: 1.5, fontSize: 14)),
                const SizedBox(height: 22),
                const Row(
                  children: [
                    Icon(Icons.verified_rounded,
                        color: Color(0xFF94F4D0), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('Discover what has improved',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ),
                    Icon(Icons.auto_awesome_rounded,
                        color: Color(0xFFA8CBFF), size: 29),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureCard(WhatsNewCard card) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: line),
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
              color: navy.withValues(alpha: .035),
              blurRadius: 14,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            height: 55,
            width: 55,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF0FF),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(_iconFor(card.icon), color: royal, size: 29),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (card.tag.isNotEmpty) ...[
                  Text(card.tag.toUpperCase(),
                      style: const TextStyle(
                          color: royal,
                          fontSize: 10,
                          letterSpacing: 1.15,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 5),
                ],
                Text(card.title,
                    style: const TextStyle(
                        color: ink, fontWeight: FontWeight.w900, fontSize: 17)),
                const SizedBox(height: 7),
                Text(card.subtitle,
                    style: const TextStyle(
                        color: muted, height: 1.48, fontSize: 12.5)),
              ],
            ),
          ),
        ]),
        if (card.hasVideo) ...[
          const SizedBox(height: 14),
          VimeoVideoPlayerWidget(
            card.videoUrl!,
            key:
                ValueKey<String>('whats-new-video-${card.id}-${card.videoUrl}'),
          ),
        ],
        if (card.hasAction) ...[
          const SizedBox(height: 17),
          SizedBox(
            width: double.infinity,
            height: 43,
            child: OutlinedButton(
              onPressed: () => _close(card.ctaAction),
              style: OutlinedButton.styleFrom(
                foregroundColor: royal,
                side: const BorderSide(color: Color(0xFFD6E2FF)),
                backgroundColor: const Color(0xFFF7F9FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(card.ctaLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 9),
                  const Icon(Icons.arrow_forward_rounded, size: 17),
                ],
              ),
            ),
          ),
        ],
      ]),
    );
  }

  Widget _messageState({
    required IconData icon,
    required String title,
    required String text,
    required String button,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: royal, size: 64),
          const SizedBox(height: 14),
          Text(title,
              style: const TextStyle(
                  color: ink, fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: muted)),
          const SizedBox(height: 19),
          ElevatedButton(onPressed: onPressed, child: Text(button)),
          if (widget.isFirstOpen && button != 'Continue to Home')
            TextButton(
                onPressed: _close, child: const Text('Continue to Home')),
        ]),
      ),
    );
  }
}
