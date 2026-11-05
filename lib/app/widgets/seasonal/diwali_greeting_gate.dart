import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Observes the actual navigator route so the celebration never interrupts
/// splash, onboarding, payment, course playback, or What's New pages.
/// Only Login (/login) or Main/Home (/main) can trigger the animation.
class DiwaliRouteObserver extends NavigatorObserver {
  final ValueNotifier<bool> _isEligible = ValueNotifier<bool>(false);
  final List<Route<dynamic>> _routeStack = <Route<dynamic>>[];

  bool get isLoginOrHome => _isEligible.value;

  void addListener(VoidCallback listener) => _isEligible.addListener(listener);
  void removeListener(VoidCallback listener) =>
      _isEligible.removeListener(listener);
  void dispose() => _isEligible.dispose();

  void _updateActiveScreen() {
    final name = _routeStack.isEmpty ? null : _routeStack.last.settings.name;
    _isEligible.value = name == '/login' || name == '/main';
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _routeStack.remove(route);
    _routeStack.add(route);
    _updateActiveScreen();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _routeStack.remove(route);
    _updateActiveScreen();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    final index = oldRoute == null ? -1 : _routeStack.indexOf(oldRoute);
    if (index >= 0) {
      if (newRoute == null) {
        _routeStack.removeAt(index);
      } else {
        _routeStack[index] = newRoute;
      }
    } else if (newRoute != null) {
      _routeStack.add(newRoute);
    }
    _updateActiveScreen();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    // pushNamedAndRemoveUntil removes the previous pages AFTER pushing the
    // destination. Always check the real top, not `previousRoute` here.
    _routeStack.remove(route);
    _updateActiveScreen();
  }
}

/// A polished, package-free animated Diwali popup for the existing app.
/// It is automatically displayed only on Login or Home, November 5–13, 2026
/// inclusive in IST, once per installation. SharedPreferences is already
/// used elsewhere in this app, so no new dependency is required.
///
/// For local developer review before the campaign starts:
///   flutter run --dart-define=DIWALI_PREVIEW=true
///   flutter run --profile --dart-define=DIWALI_PREVIEW=true
/// Preview is permitted in debug and profile modes only. Release builds
/// always enforce the calendar window and stored seen flag.
class DiwaliGreetingGate extends StatefulWidget {
  const DiwaliGreetingGate({
    super.key,
    required this.child,
    required this.routeObserver,
  });

  final Widget child;
  final DiwaliRouteObserver routeObserver;

  @override
  State<DiwaliGreetingGate> createState() => _DiwaliGreetingGateState();
}

class _DiwaliGreetingGateState extends State<DiwaliGreetingGate>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  static const _seenKey = 'profit_from_it_diwali_2026_seen_v1';
  static const _startDate = 20261105;
  static const _endDate = 20261113;
  static const _devPreview = bool.fromEnvironment('DIWALI_PREVIEW');

  // This guard survives route/widget reconstruction within the running app.
  // A greeting that has appeared once must not reappear after the user opens
  // another sidebar page and returns Home. It also applies to DIWALI_PREVIEW,
  // which intentionally skips the persistent SharedPreferences seen flag.
  // It resets only on a fresh app process (including a debug hot restart).
  static bool _shownThisAppSession = false;

  // Allow a profile-mode visual comparison to distinguish Flutter debug
  // highlights from an actual Android/GPU rendering problem. Never allow
  // preview to bypass the seasonal date gate in a production release.
  static bool get _previewEnabled => !kReleaseMode && _devPreview;

  late final AnimationController _ambient = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  );
  late final AnimationController _celebration = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 6800),
  )..addStatusListener(_celebrationStatus);

  Timer? _routeSettleTimer;
  Timer? _midnightTimer;
  int _visibilityRequestId = 0;
  bool _visible = false;
  bool _launching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.routeObserver.addListener(_routeNotification);
    _scheduleIstMidnightCheck();
    WidgetsBinding.instance.addPostFrameCallback((_) => _routeChanged());
  }

  static bool _isInDiwaliWindow() {
    // IST remains UTC+05:30 throughout the year (no DST).
    final istNow = DateTime.now().toUtc().add(
          const Duration(hours: 5, minutes: 30),
        );
    final ymd = istNow.year * 10000 + istNow.month * 100 + istNow.day;
    return ymd >= _startDate && ymd <= _endDate;
  }

  void _scheduleIstMidnightCheck() {
    _midnightTimer?.cancel();
    final ist = DateTime.now().toUtc().add(
          const Duration(hours: 5, minutes: 30),
        );
    final nextMidnight = DateTime.utc(ist.year, ist.month, ist.day + 1);
    final untilMidnight = nextMidnight.difference(ist);
    _midnightTimer =
        Timer(untilMidnight + const Duration(milliseconds: 200), () {
      if (!mounted) return;
      if (!_previewEnabled && !_isInDiwaliWindow() && _visible) {
        _hide(markSeen: false);
      }
      _routeChanged();
      _scheduleIstMidnightCheck();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!_previewEnabled && !_isInDiwaliWindow() && _visible) {
        _hide(markSeen: false);
      }
      _routeChanged();
    }
  }

  // NavigatorObserver callbacks may occur during a Navigator build. Process
  // after the frame so closing or opening the overlay never calls setState
  // from inside that build.
  void _routeNotification() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _routeChanged();
    });
  }

  void _routeChanged() {
    _routeSettleTimer?.cancel();
    final requestId = ++_visibilityRequestId;

    if (!widget.routeObserver.isLoginOrHome ||
        (!_previewEnabled && !_isInDiwaliWindow())) {
      if (_visible) _hide(markSeen: false);
      return;
    }

    if (_visible || _shownThisAppSession) return;

    // Allow Splash -> Login/Home and What's New route transitions to settle.
    _routeSettleTimer = Timer(const Duration(milliseconds: 1100), () {
      _evaluateVisibility(requestId);
    });
  }

  Future<void> _evaluateVisibility(int requestId) async {
    if (!mounted ||
        requestId != _visibilityRequestId ||
        _visible ||
        _shownThisAppSession ||
        !widget.routeObserver.isLoginOrHome ||
        (!_previewEnabled && !_isInDiwaliWindow())) {
      return;
    }

    if (!_previewEnabled) {
      try {
        final preferences = await SharedPreferences.getInstance();
        if (preferences.getBool(_seenKey) ?? false) return;
      } catch (error) {
        // If storage is unavailable, the greeting can still be dismissed.
        debugPrint('Diwali popup preferences unavailable: $error');
      }
    }

    if (!mounted ||
        requestId != _visibilityRequestId ||
        _visible ||
        _shownThisAppSession ||
        !widget.routeObserver.isLoginOrHome ||
        (!_previewEnabled && !_isInDiwaliWindow())) {
      return;
    }

    // Mark this session before showing the animation. In particular, routing
    // away while it is visible must not trigger it again when Home is revisited.
    _shownThisAppSession = true;
    setState(() {
      _visible = true;
      _launching = false;
    });
    _ambient.repeat();
  }

  Future<void> _recordSeen() async {
    if (_previewEnabled) return;
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool(_seenKey, true);
    } catch (error) {
      debugPrint('Could not persist Diwali greeting: $error');
    }
  }

  void _startLaunch() {
    if (!_visible || _launching) return;
    unawaited(_recordSeen());
    setState(() => _launching = true);
    _celebration.forward(from: 0);
  }

  void _celebrationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) _hide(markSeen: true);
  }

  void _hide({required bool markSeen}) {
    if (!_visible) return;
    if (markSeen) unawaited(_recordSeen());
    _ambient.stop();
    _celebration.stop();
    if (mounted) {
      setState(() {
        _visible = false;
        _launching = false;
      });
    }
  }

  void _dismiss() => _hide(markSeen: true);

  @override
  void dispose() {
    widget.routeObserver.removeListener(_routeNotification);
    WidgetsBinding.instance.removeObserver(this);
    _routeSettleTimer?.cancel();
    _midnightTimer?.cancel();
    _ambient.dispose();
    _celebration.dispose();
    super.dispose();
  }

  double get _launchTime => _celebration.value * 6.8;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (_visible) Positioned.fill(child: _buildOverlay()),
      ],
    );
  }

  Widget _buildOverlay() {
    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-.1, -.25),
                radius: 1.35,
                colors: [
                  Color(0xFF3B2848),
                  Color(0xFF171E39),
                  Color(0xFF090F22)
                ],
                stops: [0, .58, 1],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: Listenable.merge([_ambient, _celebration]),
            builder: (context, _) => RepaintBoundary(
              child: CustomPaint(
                painter: _DiwaliSkyPainter(
                  ambientSeconds: _ambient.value * 12,
                  launchSeconds: _launchTime,
                  launching: _launching,
                ),
                size: Size.infinite,
              ),
            ),
          ),
          IgnorePointer(
            ignoring: _launching,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 380),
              curve: Curves.easeOut,
              opacity: _launching ? 0 : 1,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOutCubic,
                scale: _launching ? .93 : 1,
                child: _buildCard(),
              ),
            ),
          ),
          if (_launching)
            AnimatedBuilder(
              animation: _celebration,
              builder: (context, _) {
                final t = _launchTime;
                final fadeIn = ((t - 2.05) / .7).clamp(0.0, 1.0);
                final fadeOut = ((6.6 - t) / .5).clamp(0.0, 1.0);
                final alpha = math.min(fadeIn, fadeOut);
                return IgnorePointer(
                  child: Center(
                    child: Opacity(
                      opacity: alpha,
                      child: Transform.scale(
                        scale: .93 + .07 * fadeIn,
                        child: _buildFinale(),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCard() {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 470),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(27),
                  border: Border.all(color: const Color(0x96EBC391), width: 1),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0xA0000000),
                        blurRadius: 67,
                        offset: Offset(0, 25)),
                  ],
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF39283E),
                      Color(0xFF1D223B),
                      Color(0xFF2A2038)
                    ],
                    stops: [0, .57, 1],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(9),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0x20FFD89B)),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(27, 26, 27, 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _GoldRule(),
                              SizedBox(width: 11),
                              Flexible(
                                child: Text(
                                  'THE FESTIVAL OF LIGHTS',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Color(0xFFE5C296),
                                    letterSpacing: 2.25,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              SizedBox(width: 11),
                              _GoldRule(),
                            ],
                          ),
                          const SizedBox(height: 3),
                          AnimatedBuilder(
                            animation: _ambient,
                            builder: (context, _) => Transform.translate(
                              offset: Offset(0,
                                  -2 * math.sin(_ambient.value * math.pi * 2)),
                              child: SizedBox(
                                height: 150,
                                width: 190,
                                child: CustomPaint(
                                  painter: _DiyaPainter(_ambient.value),
                                ),
                              ),
                            ),
                          ),
                          const Text(
                            'A SEASON OF NEW BEGINNINGS',
                            style: TextStyle(
                              color: Color(0xFFCCA87D),
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2.1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text.rich(
                              TextSpan(children: [
                                TextSpan(
                                    text: 'Happy ',
                                    style: TextStyle(color: Color(0xFFFFF4E6))),
                                TextSpan(
                                    text: 'Diwali',
                                    style: TextStyle(
                                        color: Color(0xFFF5C37D),
                                        fontStyle: FontStyle.italic)),
                              ]),
                              maxLines: 1,
                              style: TextStyle(
                                fontFamily: 'serif',
                                fontSize: 51,
                                fontWeight: FontWeight.w400,
                                height: 1.12,
                                letterSpacing: -2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 11),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _GoldRule(width: 47),
                              SizedBox(width: 12),
                              Icon(Icons.auto_awesome,
                                  color: Color(0xFFE6BC82), size: 13),
                              SizedBox(width: 12),
                              _GoldRule(width: 47),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Wishing you and your family a Diwali filled with light, happiness, and prosperity.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xFFE9D7CA),
                                fontSize: 14,
                                height: 1.7),
                          ),
                          const SizedBox(height: 12),
                          const Text.rich(
                            TextSpan(children: [
                              TextSpan(
                                  text: 'With warm wishes from ',
                                  style: TextStyle(color: Color(0xFFBAA9AE))),
                              TextSpan(
                                  text: 'Profit From It',
                                  style: TextStyle(
                                      color: Color(0xFFF2D1A1),
                                      fontWeight: FontWeight.w800)),
                            ]),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, height: 1.5),
                          ),
                          const SizedBox(height: 23),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 322),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(13),
                                onTap: _startLaunch,
                                child: Ink(
                                  height: 55,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(13),
                                    border: Border.all(
                                        color: const Color(0xFFFFDE9C)),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFD69B52),
                                        Color(0xFFFFEBB3),
                                        Color(0xFFF0BB75)
                                      ],
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Color(0x55ECA854),
                                          blurRadius: 22,
                                          offset: Offset(0, 7))
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.rocket_launch_outlined,
                                          color: Color(0xFF523425), size: 21),
                                      SizedBox(width: 11),
                                      Flexible(
                                        child: Text('LIGHT UP THE SKY',
                                            maxLines: 1,
                                            style: TextStyle(
                                                color: Color(0xFF422A1F),
                                                fontWeight: FontWeight.w900,
                                                fontSize: 12,
                                                letterSpacing: 1.5)),
                                      ),
                                      SizedBox(width: 12),
                                      Icon(Icons.north_east_rounded,
                                          color: Color(0xFF523425), size: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 13),
                          const Text('A little celebration awaits.',
                              style: TextStyle(
                                  color: Color(0xFFB9A6A7),
                                  fontSize: 10,
                                  letterSpacing: .3)),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 12,
                      // The gate is rendered by GetMaterialApp.builder, outside
                      // the Navigator's Overlay. An IconButton tooltip would
                      // create RawTooltip and throw "No Overlay widget found".
                      // Semantics retains an accessible close-button label
                      // without requiring any Overlay ancestor.
                      child: Semantics(
                        label: 'Dismiss greeting',
                        button: true,
                        child: IconButton(
                          onPressed: _dismiss,
                          icon: const Icon(Icons.close_rounded,
                              color: Color(0xFFE8D5C3), size: 20),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0x16FFFFFF),
                            side: const BorderSide(color: Color(0x25FFFFFF)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinale() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_rounded,
              color: Color(0xFFFFDDA0), size: 28),
          SizedBox(height: 12),
          Text('WITH LOVE & LIGHT',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(0xFFF8D69F),
                  letterSpacing: 3.1,
                  fontWeight: FontWeight.w700,
                  fontSize: 10)),
          SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text.rich(
              TextSpan(children: [
                TextSpan(
                    text: 'Happy ', style: TextStyle(color: Color(0xFFFFF6E6))),
                TextSpan(
                    text: 'Diwali',
                    style: TextStyle(
                        color: Color(0xFFF5C47C), fontStyle: FontStyle.italic)),
              ]),
              style: TextStyle(
                  fontFamily: 'serif', fontSize: 72, letterSpacing: -3),
            ),
          ),
          SizedBox(height: 8),
          Text('To you and your family',
              style: TextStyle(
                  color: Color(0xFFFFE9C8), fontSize: 17, fontFamily: 'serif')),
          SizedBox(height: 27),
          Text('PROFIT FROM IT',
              style: TextStyle(
                  color: Color(0xFFF4C78A),
                  letterSpacing: 3.4,
                  fontWeight: FontWeight.w700,
                  fontSize: 11)),
        ],
      ),
    );
  }
}

class _GoldRule extends StatelessWidget {
  const _GoldRule({this.width = 19});
  final double width;

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: 1,
        color: const Color(0x88D4AA75),
      );
}

class _DiyaPainter extends CustomPainter {
  const _DiyaPainter(this.phase);
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 190, size.height / 150);
    const center = Offset(95, 70);
    final intensity = .88 + math.sin(phase * math.pi * 2) * .07;
    canvas.drawCircle(
      center,
      73,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Color.fromRGBO(255, 187, 106, .24 * intensity),
            const Color(0x00FFBD7E)
          ],
        ).createShader(Rect.fromCircle(center: center, radius: 73)),
    );
    final flame = Path()
      ..moveTo(96, 23)
      ..cubicTo(77, 46, 80, 61, 95, 81)
      ..cubicTo(112, 63, 112, 44, 96, 23)
      ..close();
    canvas.drawPath(
        flame,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF8D7), Color(0xFFFFD28A), Color(0xFFE9824B)],
          ).createShader(const Rect.fromLTWH(80, 22, 32, 60)));
    final innerFlame = Path()
      ..moveTo(96, 44)
      ..quadraticBezierTo(84, 63, 96, 72)
      ..quadraticBezierTo(107, 62, 96, 44);
    canvas.drawPath(innerFlame, Paint()..color = const Color(0xFFFFFAE4));
    final bowl = Path()
      ..moveTo(34, 105)
      ..quadraticBezierTo(95, 123, 156, 105)
      ..cubicTo(145, 138, 121, 142, 95, 141)
      ..cubicTo(68, 141, 44, 135, 34, 105)
      ..close();
    canvas.drawPath(
        bowl,
        Paint()
          ..shader = const LinearGradient(
            colors: [
              Color(0xFF9B523B),
              Color(0xFFDA9554),
              Color(0xFFF1BE76),
              Color(0xFF8B4432)
            ],
          ).createShader(const Rect.fromLTWH(30, 105, 130, 42)));
    canvas.drawPath(
        bowl,
        Paint()
          ..color = const Color(0xFFFFD49A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4);
    canvas.drawOval(const Rect.fromLTWH(33, 97, 124, 22),
        Paint()..color = const Color(0xFFC78451));
    canvas.drawOval(
        const Rect.fromLTWH(33, 97, 124, 22),
        Paint()
          ..color = const Color(0xFFFFD39A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6);
    final flourish = Path()
      ..moveTo(56, 126)
      ..quadraticBezierTo(95, 142, 134, 126);
    canvas.drawPath(
        flourish,
        Paint()
          ..color = const Color(0x99FFDBA5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
    final rays = <(Offset, Offset)>[
      (const Offset(95, 10), const Offset(95, 2)),
      (const Offset(67, 23), const Offset(58, 16)),
      (const Offset(123, 23), const Offset(132, 16)),
      (const Offset(51, 53), const Offset(42, 50)),
      (const Offset(139, 53), const Offset(148, 50)),
    ];
    for (final ray in rays) {
      canvas.drawLine(
          ray.$1,
          ray.$2,
          Paint()
            ..color = const Color(0xC4FFE0A2)
            ..strokeWidth = 1.7
            ..strokeCap = StrokeCap.round);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DiyaPainter oldDelegate) =>
      oldDelegate.phase != phase;
}

class _DiwaliSkyPainter extends CustomPainter {
  const _DiwaliSkyPainter({
    required this.ambientSeconds,
    required this.launchSeconds,
    required this.launching,
  });

  final double ambientSeconds;
  final double launchSeconds;
  final bool launching;

  static double _hash(int n) {
    final raw = math.sin(n * 127.1 + 74.7) * 43758.5453;
    return raw - raw.floor();
  }

  static double _ease(double t) =>
      1 - math.pow(1 - t.clamp(0.0, 1.0), 3).toDouble();

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 55; i++) {
      final x = _hash(i + 12) * size.width;
      final y = _hash(i + 222) * size.height;
      final brightness = .17 +
          (.5 + .5 * math.sin(ambientSeconds * (1 + _hash(i + 50)) + i)) * .38;
      canvas.drawCircle(Offset(x, y), .5 + _hash(i + 99) * 1.2,
          Paint()..color = const Color(0xFFFFDCA3).withValues(alpha: brightness));
    }

    _burst(canvas, Offset(size.width * .13, size.height * .24), 50,
        (ambientSeconds + 3.4) % 5.2, 2.25, 0, .28, 42);
    _burst(canvas, Offset(size.width * .86, size.height * .36), 60,
        (ambientSeconds + .8) % 5.2, 2.25, 1, .28, 48);

    if (!launching) return;
    final t = launchSeconds;
    final top = math.max(size.height * .26, 105.0);
    if (t < 1.92) _rocket(canvas, size, t, top);
    if (t >= 1.74) {
      _burst(
          canvas,
          Offset(size.width * .50, top),
          math.min(math.min(size.width * .43, size.height * .29), 275),
          t - 1.74,
          3.5,
          0,
          1,
          140);
    }
    if (t >= 2.25) {
      _burst(canvas, Offset(size.width * .29, size.height * .28),
          math.min(size.width * .24, 150), t - 2.25, 2.7, 1, .9, 94);
    }
    if (t >= 2.60) {
      _burst(canvas, Offset(size.width * .72, size.height * .22),
          math.min(size.width * .26, 160), t - 2.60, 2.8, 2, .89, 94);
    }
    if (t >= 3.26) {
      _burst(canvas, Offset(size.width * .49, size.height * .17),
          math.min(size.width * .17, 95), t - 3.26, 2, 0, .7, 72);
    }
  }

  static const _palette = <List<Color>>[
    [Color(0xFFFFF4C6), Color(0xFFF3C978), Color(0xFFD99766)],
    [Color(0xFFFFF7DA), Color(0xFFF6B5B0), Color(0xFFD985B9)],
    [Color(0xFFE6FFFF), Color(0xFF88D3CE), Color(0xFFC5A6F4)],
  ];

  void _burst(Canvas canvas, Offset center, double radius, double seconds,
      double duration, int paletteIndex, double opacity, int count) {
    if (seconds < 0 || seconds > duration) return;
    final progress = (seconds / duration).clamp(0.0, 1.0);
    final r = radius * _ease(progress);
    final fade = opacity * math.pow(1 - progress, .72).toDouble();
    final shades = _palette[paletteIndex % _palette.length];
    _glow(canvas, center, 43 * (1 - progress) + 15, const Color(0xFFFFDDA1),
        fade * .35);
    for (var i = 0; i < count; i++) {
      final theta = i / count * math.pi * 2 + _hash(i + 21) * .09;
      final length = r * (.78 + _hash(i * 11 + 18) * .35);
      final direction = Offset(math.cos(theta), math.sin(theta));
      final location =
          center + direction * length + Offset(0, 19 * progress * progress);
      final tail = (5 + _hash(i * 7) * 10) * (1 - progress);
      final color = shades[i % shades.length]
          .withValues(alpha: (fade * (.5 + _hash(i + 300) * .5)).clamp(0.0, 1.0));
      canvas.drawLine(
          location - direction * tail,
          location,
          Paint()
            ..color = color
            ..strokeWidth = i % 6 == 0 ? 2.0 : 1.0);
      if (i % 5 == 0) {
        canvas.drawCircle(
            location,
            1.9 * (1 - progress) + .2,
            Paint()
              ..color =
                  const Color(0xFFFFFBE3).withValues(alpha: fade.clamp(0.0, 1.0)));
      }
    }
  }

  Offset _rocketAt(Size size, double progress, double top) {
    final p = _ease(progress);
    return Offset(
      size.width / 2 +
          math.sin(progress * math.pi * 1.5) * math.min(size.width * .045, 18),
      size.height * .94 - (size.height * .94 - top) * p,
    );
  }

  void _rocket(Canvas canvas, Size size, double seconds, double top) {
    final p = (seconds / 1.82).clamp(0.0, 1.0);
    for (var i = 27; i >= 1; i--) {
      final prior = math.max(0.0, p - i * .008);
      if (prior == 0 && p < i * .008) continue;
      final point = _rocketAt(size, prior, top);
      final alpha = (1 - i / 28) * math.min(seconds * 2.5, 1);
      final color =
          i % 5 == 0 ? const Color(0xFFFFF6CB) : const Color(0xFFFFAA54);
      canvas.drawCircle(point, .5 + alpha * (2.3 + _hash(i) * 1.6),
          Paint()..color = color.withValues(alpha: alpha.clamp(0.0, 1.0)));
    }
    final point = _rocketAt(size, p, top);
    _glow(canvas, point, 55, const Color(0xFFFFD380), .52);
    _glow(canvas, point, 21, const Color(0xFFFFF7DA), .75);
    canvas.drawCircle(point, 4.2, Paint()..color = const Color(0xFFFFFCE7));
  }

  void _glow(
      Canvas canvas, Offset center, double radius, Color color, double alpha) {
    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: alpha.clamp(0.0, 1.0)),
              color.withValues(alpha: 0)
            ],
          ).createShader(Rect.fromCircle(center: center, radius: radius)));
  }

  @override
  bool shouldRepaint(covariant _DiwaliSkyPainter oldDelegate) =>
      oldDelegate.ambientSeconds != ambientSeconds ||
      oldDelegate.launchSeconds != launchSeconds ||
      oldDelegate.launching != launching;
}
