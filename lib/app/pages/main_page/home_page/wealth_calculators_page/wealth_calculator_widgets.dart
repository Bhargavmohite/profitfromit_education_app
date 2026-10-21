import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webinar/common/utils/wealth_calculator_logic.dart';

class WealthUi {
  static const ink = Color(0xFF172643);
  static const muted = Color(0xFF6B7890);
  static const background = Color(0xFFF5F7FC);
  static const line = Color(0xFFE6EBF4);
  static const navy = Color(0xFF162A53);
  static const blue = Color(0xFF315CDA);
  static const teal = Color(0xFF119F84);
  static const amber = Color(0xFFE49A32);
}

class WealthPageFrame extends StatelessWidget {
  const WealthPageFrame({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WealthUi.background,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: Text(title,
            style: const TextStyle(
                color: WealthUi.ink, fontWeight: FontWeight.w800, fontSize: 17)),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 19, color: WealthUi.ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: child,
        ),
      ),
    );
  }
}

class WealthContent extends StatelessWidget {
  const WealthContent({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 38),
        children: children,
      );
}

class WealthSection extends StatelessWidget {
  const WealthSection({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.padding = const EdgeInsets.all(19),
  });
  final String? title;
  final String? subtitle;
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: WealthUi.line),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A162A53), blurRadius: 18, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!,
                style: const TextStyle(
                    color: WealthUi.ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w800)),
            if (subtitle != null) ...[
              const SizedBox(height: 5),
              Text(subtitle!,
                  style: const TextStyle(
                      color: WealthUi.muted, fontSize: 12.5, height: 1.45)),
            ],
            const SizedBox(height: 20),
          ],
          child,
        ],
      ),
    );
  }
}

class WealthResultBanner extends StatelessWidget {
  const WealthResultBanner({
    super.key,
    required this.eyebrow,
    required this.value,
    required this.description,
    required this.icon,
    this.accent = WealthUi.teal,
    this.bottom,
  });
  final String eyebrow;
  final String value;
  final String description;
  final IconData icon;
  final Color accent;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF122244), Color(0xFF2B4575)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -68,
            right: -56,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0x28FFFFFF), width: 25),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0x20FFFFFF),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(icon, size: 19, color: accent),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(eyebrow.toUpperCase(),
                          style: const TextStyle(
                              color: Color(0xFFC9D6F3),
                              fontSize: 11,
                              letterSpacing: 1.0,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(value,
                      style: const TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                          color: Colors.white)),
                ),
                const SizedBox(height: 9),
                Text(description,
                    style: const TextStyle(
                        color: Color(0xFFCAD6ED), fontSize: 13, height: 1.45)),
                if (bottom != null) ...[
                  const SizedBox(height: 18),
                  const Divider(color: Color(0x32FFFFFF), height: 1),
                  const SizedBox(height: 17),
                  bottom!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WealthMoneyInput extends StatelessWidget {
  const WealthMoneyInput({
    super.key,
    required this.label,
    required this.controller,
    required this.onChanged,
    this.hint = 'Enter amount',
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: WealthUi.ink, fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(
              color: WealthUi.ink, fontSize: 16, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const SizedBox(
              width: 42,
              child: Center(
                child: Text('₹',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: WealthUi.blue)),
              ),
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 42, maxWidth: 48),
            filled: true,
            fillColor: WealthUi.background,
            contentPadding: const EdgeInsets.symmetric(
                vertical: 17, horizontal: 15),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(color: WealthUi.line)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(color: WealthUi.blue, width: 1.7)),
          ),
        ),
      ],
    );
  }
}

class WealthSlider extends StatelessWidget {
  const WealthSlider({
    super.key,
    required this.label,
    required this.valueText,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
    this.accent = WealthUi.blue,
  });
  final String label;
  final String valueText;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final Color accent;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label,
                    style: const TextStyle(
                        color: WealthUi.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ),
              Text(valueText,
                  style: TextStyle(
                      color: accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w800)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: accent,
              inactiveTrackColor: const Color(0xFFE4EAF5),
              thumbColor: accent,
              overlayColor: accent.withValues(alpha: .12),
              trackHeight: 5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              min: min,
              max: max,
              value: value.clamp(min, max).toDouble(),
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      );
}

class WealthStat extends StatelessWidget {
  const WealthStat({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.tint = const Color(0xFFEAF0FF),
    this.accent = WealthUi.blue,
  });
  final String label;
  final String value;
  final IconData? icon;
  final Color tint;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(17),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(icon, color: accent, size: 20),
              const SizedBox(height: 12),
            ],
            Text(label,
                style: const TextStyle(
                    color: WealthUi.muted, fontSize: 11.5, height: 1.3)),
            const SizedBox(height: 7),
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(value,
                  style: const TextStyle(
                      color: WealthUi.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      );
}

class WealthNote extends StatelessWidget {
  const WealthNote({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.info_outline_rounded,
              color: WealthUi.muted, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: WealthUi.muted, fontSize: 11.5, height: 1.55)),
          ),
        ]),
      );
}

String formattedMoney(String input) =>
    WealthCalculatorLogic.rupees(WealthCalculatorLogic.parseMoney(input));
