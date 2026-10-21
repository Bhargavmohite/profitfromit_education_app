import 'package:flutter/material.dart';
import 'package:webinar/app/pages/main_page/home_page/wealth_calculators_page/wealth_calculator_widgets.dart';
import 'package:webinar/common/utils/wealth_calculator_logic.dart';

class CrorepatiCountdownPage extends StatefulWidget {
  const CrorepatiCountdownPage({super.key});

  @override
  State<CrorepatiCountdownPage> createState() => _CrorepatiCountdownPageState();
}

class _CrorepatiCountdownPageState extends State<CrorepatiCountdownPage> {
  final _corpus = TextEditingController(text: '500000');
  final _sip = TextEditingController(text: '25000');
  final _target = TextEditingController(text: '10000000');
  int _annualReturn = 12;

  static const _months = <String>[
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  void dispose() {
    _corpus.dispose();
    _sip.dispose();
    _target.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final corpus = WealthCalculatorLogic.parseMoney(_corpus.text);
    final sip = WealthCalculatorLogic.parseMoney(_sip.text);
    final target = WealthCalculatorLogic.parseMoney(_target.text);
    final months = target == 0
        ? null
        : WealthCalculatorLogic.monthsToTarget(
            currentCorpus: corpus,
            monthlySip: sip,
            targetCorpus: target,
            annualReturnPercent: _annualReturn.toDouble(),
          );
    final fasterMonths = target == 0
        ? null
        : WealthCalculatorLogic.monthsToTarget(
            currentCorpus: corpus,
            monthlySip: sip * 1.10,
            targetCorpus: target,
            annualReturnPercent: _annualReturn.toDouble(),
          );
    final targetDate = months == null
        ? null
        : DateTime(DateTime.now().year, DateTime.now().month + months);
    final timeline = months == null
        ? 'Not reachable'
        : months == 0
            ? 'Goal reached!'
            : '${months ~/ 12} yr  ${months % 12} mo';
    final dateText = months == null
        ? 'Try a higher SIP or different target'
        : months == 0
            ? 'Already achieved with your current savings'
            : '${_months[targetDate!.month - 1]} ${targetDate.year}';
    final savedMonths = months != null && fasterMonths != null
        ? months - fasterMonths
        : null;

    return WealthPageFrame(
      title: 'Crorepati Countdown',
      child: WealthContent(children: [
        WealthResultBanner(
          eyebrow: 'ESTIMATED TIME TO TARGET',
          value: timeline,
          description: months == null
              ? 'The goal is not projected within 100 years under these assumptions.'
              : 'Target arrival: $dateText',
          icon: Icons.emoji_events_outlined,
          accent: const Color(0xFFFFD07B),
          bottom: Row(children: [
            const Icon(Icons.flag_outlined,
                color: Color(0xFFFFD07B), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Goal  ${WealthCalculatorLogic.rupees(target, compact: true)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800)),
            ),
          ]),
        ),
        const SizedBox(height: 17),
        WealthSection(
          title: 'Set your wealth milestone',
          subtitle: 'See how your existing savings and monthly SIP work together.',
          child: Column(children: [
            WealthMoneyInput(
              label: 'Current savings / portfolio',
              controller: _corpus,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 19),
            WealthMoneyInput(
              label: 'Monthly SIP / investment',
              controller: _sip,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 19),
            WealthMoneyInput(
              label: 'Target wealth',
              controller: _target,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 22),
            WealthSlider(
              label: 'Expected annual return',
              valueText: '$_annualReturn%',
              value: _annualReturn.toDouble(),
              min: 0,
              max: 20,
              divisions: 20,
              accent: WealthUi.amber,
              onChanged: (value) =>
                  setState(() => _annualReturn = value.round()),
            ),
          ]),
        ),
        const SizedBox(height: 17),
        WealthSection(
          title: 'Small increase, meaningful difference',
          subtitle: 'What happens if you raise your monthly SIP by 10%?',
          child: Column(children: [
            Row(children: [
              Expanded(
                child: WealthStat(
                  label: 'New monthly SIP',
                  value: WealthCalculatorLogic.rupees(sip * 1.1, compact: true),
                  tint: const Color(0xFFFFF3E6),
                  icon: Icons.add_chart_rounded,
                  accent: WealthUi.amber,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: WealthStat(
                  label: 'Time saved',
                  value: savedMonths == null
                      ? '—'
                      : '${savedMonths ~/ 12} yr ${savedMonths % 12} mo',
                  tint: const Color(0xFFE3F7F1),
                  icon: Icons.timelapse_rounded,
                  accent: WealthUi.teal,
                ),
              ),
            ]),
            if (months != null && months > 0 && target > 0) ...[
              const SizedBox(height: 17),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: LinearProgressIndicator(
                  value: (corpus / target).clamp(0.0, 1.0).toDouble(),
                  minHeight: 9,
                  backgroundColor: const Color(0xFFE8EEF6),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(WealthUi.teal),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                    '${((corpus / target).clamp(0.0, 1.0) * 100).toStringAsFixed(1)}% of target already saved',
                    style: const TextStyle(
                        fontSize: 11.5, color: WealthUi.muted)),
              ),
            ],
          ]),
        ),
        const SizedBox(height: 17),
        const WealthNote(
          text: 'Illustrative end-of-month SIP and monthly compounding, using an effective monthly rate derived from the annual rate. Target timing is calculated from the current month. It excludes inflation, taxes, fees and market volatility. Returns are not guaranteed. An empty/zero target is not calculated.',
        ),
      ]),
    );
  }
}
