import 'package:flutter/material.dart';

/// Shared visual language for the Investment Baskets catalogue and detail view.
class BasketColors {
  static const navy = Color(0xFF0D1F3A);
  static const navyLight = Color(0xFF203D6B);
  static const blue = Color(0xFF2F73EA);
  static const canvas = Color(0xFFF6F8FC);
  static const ink = Color(0xFF142640);
  static const secondary = Color(0xFF64738A);
  static const outline = Color(0xFFE4EAF2);
  static const green = Color(0xFF128568);
}

class BasketPageFrame extends StatelessWidget {
  const BasketPageFrame({super.key, required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BasketColors.canvas,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: BasketColors.ink,
        centerTitle: false,
        title: Text(title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 17,
              letterSpacing: -.2,
            )),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 19, 18, 36),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BasketPill extends StatelessWidget {
  const BasketPill({
    super.key,
    required this.text,
    this.icon,
    this.background = const Color(0xFFE9F3FF),
    this.foreground = BasketColors.blue,
  });
  final String text;
  final IconData? icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: foreground),
              const SizedBox(width: 5),
            ],
            Text(text,
                style: TextStyle(
                    fontSize: 11,
                    color: foreground,
                    fontWeight: FontWeight.w800)),
          ]),
        ),
      );
}

class BasketInfoCard extends StatelessWidget {
  const BasketInfoCard({
    super.key,
    required this.icon,
    required this.heading,
    required this.value,
    this.accent = BasketColors.blue,
  });
  final IconData icon;
  final String heading;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: BasketColors.outline),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: accent, size: 22),
        const SizedBox(height: 12),
        Text(heading,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: BasketColors.secondary)),
        const SizedBox(height: 5),
        Text(value,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: BasketColors.ink)),
      ]),
    );
  }
}

class BasketEducationNote extends StatelessWidget {
  const BasketEducationNote({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF1FC),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.info_outline_rounded,
              color: BasketColors.navyLight, size: 19),
          const SizedBox(width: 10),
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      color: BasketColors.navyLight,
                      fontSize: 11.5,
                      height: 1.55))),
        ]),
      );
}

/// Authentication is deliberately NOT simulated: no login API was provided.
Future<void> showBasketLoginPending(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text('Investor Login'),
      content: const Text(
        'Basket investor login is not connected yet. '
        'This Feature is UnderDevelopment.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

/// Inform users when comprehensive basket documentation is not yet available.
/// Separate from investor-login navigation used by the catalogue page.
Future<void> showBasketFullDetailsPending(
  BuildContext context,
  String basketName,
) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text('Full Basket Details'),
      content: Text(
        // 'Detailed strategy information for $basketName is being prepared. '
        'This Feature is UnderDevelopment.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
