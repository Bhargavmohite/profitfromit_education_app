import 'package:flutter/material.dart';
import 'package:webinar/app/pages/main_page/home_page/wealth_calculators_page/age_allocation_calculator_page.dart';
import 'package:webinar/app/pages/main_page/home_page/wealth_calculators_page/crorepati_countdown_page.dart';
import 'package:webinar/app/pages/main_page/home_page/wealth_calculators_page/wealth_calculator_widgets.dart';
import 'package:webinar/app/pages/main_page/home_page/wealth_calculators_page/wealth_time_machine_page.dart';

/// Offline, educational calculators — no server, login or API calls.
class WealthCalculatorsPage extends StatelessWidget {
  static const String pageName = '/wealth-calculators';
  const WealthCalculatorsPage({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return WealthPageFrame(
      title: 'Wealth Calculators',
      child: WealthContent(
        children: [
          const WealthResultBanner(
            eyebrow: 'YOUR PERSONAL FINANCE WORKSPACE',
            value: 'Wealth Lab',
            description:
                'Explore meaningful money decisions through interactive, easy-to-understand projections.',
            icon: Icons.auto_graph_rounded,
            accent: Color(0xFF63E5C3),
            bottom: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _BenefitChip(icon: Icons.calculate_outlined, text: '3 tools'),
                _BenefitChip(icon: Icons.wifi_off_outlined, text: 'Works offline'),
                _BenefitChip(icon: Icons.lock_outline_rounded, text: 'On-device'),
              ],
            ),
          ),
          const SizedBox(height: 27),
          const Text('Choose your calculator',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: WealthUi.ink,
                  fontSize: 21)),
          const SizedBox(height: 7),
          const Text('Adjust the numbers and see your results instantly.',
              style: TextStyle(color: WealthUi.muted, fontSize: 13)),
          const SizedBox(height: 18),
          _CalculatorEntry(
            sequence: '01',
            title: 'Asset Allocation Compass',
            subtitle: 'Find an illustrative equity–debt mix for your age and risk appetite.',
            highlight: 'AGE  •  RISK  •  SAFETY NET',
            icon: Icons.donut_large_rounded,
            tint: const Color(0xFFE8EFFD),
            accent: WealthUi.blue,
            onTap: () => _open(context, const AgeAllocationCalculatorPage()),
          ),
          const SizedBox(height: 13),
          _CalculatorEntry(
            sequence: '02',
            title: 'Wealth Time Machine',
            subtitle: 'See what small daily spending could become if invested instead.',
            highlight: 'DAILY HABITS  •  COMPOUNDING',
            icon: Icons.hourglass_bottom_rounded,
            tint: const Color(0xFFE4F8F3),
            accent: WealthUi.teal,
            onTap: () => _open(context, const WealthTimeMachinePage()),
          ),
          const SizedBox(height: 13),
          _CalculatorEntry(
            sequence: '03',
            title: 'Crorepati Countdown',
            subtitle: 'Estimate the time needed to reach your first ₹1 crore.',
            highlight: 'CURRENT CORPUS  •  MONTHLY SIP',
            icon: Icons.flag_outlined,
            tint: const Color(0xFFFFF3E4),
            accent: WealthUi.amber,
            onTap: () => _open(context, const CrorepatiCountdownPage()),
          ),
          const SizedBox(height: 21),
          const WealthNote(
            text: 'Illustrations are educational, not investment advice. Actual returns vary; projections exclude tax, inflation and charges unless otherwise stated.',
          ),
        ],
      ),
    );
  }
}

class _BenefitChip extends StatelessWidget {
  const _BenefitChip({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
            color: const Color(0x22FFFFFF),
            borderRadius: BorderRadius.circular(30)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: const Color(0xFFDBE8FC), size: 14),
          const SizedBox(width: 6),
          Text(text,
              style: const TextStyle(
                  color: Color(0xFFF0F5FF),
                  fontWeight: FontWeight.w700,
                  fontSize: 11)),
        ]),
      );
}

class _CalculatorEntry extends StatelessWidget {
  const _CalculatorEntry({
    required this.sequence,
    required this.title,
    required this.subtitle,
    required this.highlight,
    required this.icon,
    required this.tint,
    required this.accent,
    required this.onTap,
  });
  final String sequence;
  final String title;
  final String subtitle;
  final String highlight;
  final IconData icon;
  final Color tint;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: WealthUi.line),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(19),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 57,
                  height: 57,
                  decoration: BoxDecoration(
                      color: tint, borderRadius: BorderRadius.circular(17)),
                  alignment: Alignment.center,
                  child: Icon(icon, color: accent, size: 29),
                ),
                const Spacer(),
                Text(sequence,
                    style: const TextStyle(
                        color: Color(0xFFD3DBEA),
                        fontWeight: FontWeight.w900,
                        fontSize: 28)),
              ]),
              const SizedBox(height: 17),
              Text(title,
                  style: const TextStyle(
                      color: WealthUi.ink,
                      fontWeight: FontWeight.w900,
                      fontSize: 18)),
              const SizedBox(height: 8),
              Text(subtitle,
                  style: const TextStyle(
                      color: WealthUi.muted, fontSize: 12.5, height: 1.5)),
              const SizedBox(height: 17),
              Row(children: [
                Expanded(
                  child: Text(highlight,
                      style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          letterSpacing: .3)),
                ),
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                      color: tint, borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.arrow_forward_rounded,
                      color: accent, size: 18),
                ),
              ]),
            ]),
          ),
        ),
      );
}
