import 'package:flutter/material.dart';

/// Shared visual framework for Login, Sign up and Forgot password.
/// Presentation only: authentication, routing and validation remain in the pages.
class AuthDesign {
  static const Color navy = Color(0xFF0B2344);
  static const Color navyLight = Color(0xFF183D6C);
  static const Color blue = Color(0xFF1767DF);
  static const Color muted = Color(0xFF62718A);
  static const Color ink = Color(0xFF15263C);
  static const Color surface = Color(0xFFF5F7FB);
  static const Color field = Color(0xFFF8FAFE);
}

class AuthPageFrame extends StatelessWidget {
  final String title;
  final String subtitle;
  final String eyebrow;
  final IconData icon;
  final Widget child;

  const AuthPageFrame({
    super.key,
    required this.title,
    required this.subtitle,
    required this.eyebrow,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthDesign.surface,
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 310,
            child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AuthDesign.navy, AuthDesign.navyLight, Color(0xFF18559A)],
                ),
              ),
              child: Stack(children: [
                Positioned(
                  right: -75,
                  top: -95,
                  child: Container(
                    width: 265,
                    height: 265,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: .09), width: 32),
                    ),
                  ),
                ),
                Positioned(
                  left: -85,
                  bottom: -115,
                  child: Container(
                    width: 230,
                    height: 230,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: .035),
                    ),
                  ),
                ),
              ]),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 510),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 38,
                              width: 38,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .13),
                                border: Border.all(color: Colors.white.withValues(alpha: .22)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.auto_stories_outlined, color: Colors.white, size: 21),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'PROFIT FROM IT',
                                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.2),
                              ),
                            ),
                            const Icon(Icons.verified_user_outlined, color: Color(0xFFB9D7FF), size: 21),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(eyebrow.toUpperCase(), style: const TextStyle(color: Color(0xFFAFD2FF), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.8)),
                                  const SizedBox(height: 8),
                                  Text(title, maxLines: 2, style: const TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w800, height: 1.18, letterSpacing: -.5)),
                                  const SizedBox(height: 9),
                                  Text(subtitle, maxLines: 3, style: const TextStyle(color: Color(0xFFD1E1F6), fontSize: 12.5, height: 1.5)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              height: 56,
                              width: 56,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .11),
                                borderRadius: BorderRadius.circular(19),
                                border: Border.all(color: Colors.white.withValues(alpha: .16)),
                              ),
                              child: Icon(icon, color: Colors.white, size: 27),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: const Color(0xFFE8EDF5)),
                            boxShadow: [
                              BoxShadow(color: AuthDesign.navy.withValues(alpha: .09), blurRadius: 32, offset: const Offset(0, 13)),
                            ],
                          ),
                          child: child,
                        ),
                        const SizedBox(height: 23),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.lock_outline_rounded, color: AuthDesign.muted, size: 13),
                            SizedBox(width: 7),
                            Flexible(
                              child: Text('Secure learning, built for your progress',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AuthDesign.muted, fontSize: 11.5)),
                            ),
                          ],
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
    );
  }
}

class AuthFormHeading extends StatelessWidget {
  final String title;
  final String? description;
  const AuthFormHeading(this.title, {super.key, this.description});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 17),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AuthDesign.ink)),
        if (description != null) ...[
          const SizedBox(height: 5),
          Text(description!, style: const TextStyle(fontSize: 12.5, color: AuthDesign.muted, height: 1.45)),
        ],
      ],
    ),
  );
}

class AuthFieldHeading extends StatelessWidget {
  final String title;
  const AuthFieldHeading(this.title, {super.key});
  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(title, style: const TextStyle(color: AuthDesign.ink, fontSize: 12.5, fontWeight: FontWeight.w700)),
    ),
  );
}

class AuthSocialDivider extends StatelessWidget {
  final String label;
  const AuthSocialDivider({super.key, this.label = 'OR CONTINUE WITH'});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Row(children: [
      const Expanded(child: Divider(color: Color(0xFFE3EAF3))),
      const SizedBox(width: 12),
      Text(label, style: const TextStyle(color: AuthDesign.muted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: .6)),
      const SizedBox(width: 12),
      const Expanded(child: Divider(color: Color(0xFFE3EAF3))),
    ]),
  );
}
