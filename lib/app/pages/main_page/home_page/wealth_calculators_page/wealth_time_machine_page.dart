import 'package:flutter/material.dart';
import 'package:webinar/app/pages/main_page/home_page/wealth_calculators_page/wealth_calculator_widgets.dart';
import 'package:webinar/common/utils/wealth_calculator_logic.dart';

class WealthTimeMachinePage extends StatefulWidget {
  const WealthTimeMachinePage({super.key});

  @override
  State<WealthTimeMachinePage> createState() => _WealthTimeMachinePageState();
}

class _WealthTimeMachinePageState extends State<WealthTimeMachinePage> {
  final _daily = TextEditingController(text: '450');
  int _years = 15;
  int _return = 12;
  String _habit = 'Eating out';

  static const _habits = <String, IconData>{
    'Eating out': Icons.restaurant_outlined,
    'Coffee': Icons.local_cafe_outlined,
    'Cab rides': Icons.local_taxi_outlined,
    'Subscriptions': Icons.subscriptions_outlined,
    'Custom': Icons.tune_rounded,
  };

  @override
  void dispose() {
    _daily.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dailySpend = WealthCalculatorLogic.parseMoney(_daily.text);
    final result = WealthCalculatorLogic.timeMachine(
      dailySpend: dailySpend,
      years: _years,
      annualReturnPercent: _return.toDouble(),
    );
    final invested = result.totalSpent;
    final gain = result.wealthGain;
    final fraction = result.futureWealth > 0
        ? (invested / result.futureWealth).clamp(0.0, 1.0).toDouble()
        : 0.0;

    return WealthPageFrame(
      title: 'Wealth Time Machine',
      child: WealthContent(children: [
        WealthResultBanner(
          eyebrow: 'POTENTIAL VALUE IF INVESTED',
          value: WealthCalculatorLogic.rupees(result.futureWealth,
              compact: true),
          description:
              'Redirecting your daily ₹${dailySpend.round()} ${_habit.toLowerCase()} habit for $_years years',
          icon: Icons.auto_awesome_rounded,
          accent: const Color(0xFF67E0BD),
          bottom: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: 11,
                child: Row(children: [
                  if (fraction > 0)
                    Expanded(
                        flex: (fraction * 1000).round().clamp(1, 999).toInt(),
                        child: Container(color: const Color(0xFF7098FC))),
                  Expanded(
                      flex: ((1 - fraction) * 1000).round().clamp(1, 1000).toInt(),
                      child: Container(color: const Color(0xFF56D9B8))),
                ]),
              ),
            ),
            const SizedBox(height: 11),
            const Text('Blue: contributions     Green: hypothetical growth',
                style: TextStyle(color: Color(0xFFD9E3F6), fontSize: 11)),
          ]),
        ),
        const SizedBox(height: 17),
        WealthSection(
          title: 'Design your scenario',
          subtitle: 'Choose a spending habit, amount and investment horizon.',
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('What could you cut back on?',
                style: TextStyle(
                    color: WealthUi.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 11),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _habits.entries
                  .map((entry) => _HabitChoice(
                        label: entry.key,
                        icon: entry.value,
                        selected: entry.key == _habit,
                        onTap: () => setState(() => _habit = entry.key),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 22),
            WealthMoneyInput(
              label: 'Daily amount you could invest',
              controller: _daily,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 22),
            WealthSlider(
              label: 'Time horizon',
              valueText: '$_years years',
              value: _years.toDouble(),
              min: 1,
              max: 40,
              divisions: 39,
              accent: WealthUi.teal,
              onChanged: (value) => setState(() => _years = value.round()),
            ),
            const SizedBox(height: 13),
            WealthSlider(
              label: 'Assumed annual return',
              valueText: '$_return%',
              value: _return.toDouble(),
              min: 0,
              max: 20,
              divisions: 20,
              accent: WealthUi.teal,
              onChanged: (value) => setState(() => _return = value.round()),
            ),
          ]),
        ),
        const SizedBox(height: 17),
        WealthSection(
          title: 'Your money, two possibilities',
          child: Column(children: [
            Row(children: [
              Expanded(
                  child: WealthStat(
                label: 'Spent over $_years years',
                value: WealthCalculatorLogic.rupees(invested, compact: true),
                icon: Icons.receipt_long_outlined,
                tint: const Color(0xFFFFF2E5),
                accent: WealthUi.amber,
              )),
              const SizedBox(width: 11),
              Expanded(
                  child: WealthStat(
                label: 'Potential growth',
                value: WealthCalculatorLogic.rupees(gain, compact: true),
                icon: Icons.trending_up_rounded,
                tint: const Color(0xFFE4F8F1),
                accent: WealthUi.teal,
              )),
            ]),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: WealthUi.background,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(children: [
                const Icon(Icons.lightbulb_outline_rounded,
                    color: WealthUi.teal),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    'Investing the same amount instead of spending it could create ${WealthCalculatorLogic.rupees(result.futureWealth, compact: true)} at the assumed $_return% return.',
                    style: const TextStyle(
                        color: WealthUi.ink, fontSize: 12, height: 1.45),
                  ),
                ),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 18),
        const WealthNote(
          text: 'Assumes 365 spending days/year and deposits at each month-end. Annual return is converted to its effective monthly equivalent; projections exclude taxes, fees and inflation. Actual investment returns are uncertain and may be negative.',
        ),
      ]),
    );
  }
}

class _HabitChoice extends StatelessWidget {
  const _HabitChoice({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: selected ? const Color(0xFFE2F7F1) : WealthUi.background,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(
                    color: selected ? WealthUi.teal : WealthUi.line),
                borderRadius: BorderRadius.circular(13)),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon,
                  size: 16,
                  color: selected ? WealthUi.teal : WealthUi.muted),
              const SizedBox(width: 7),
              Text(label,
                  style: TextStyle(
                      color: selected ? WealthUi.teal : WealthUi.ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 11.5)),
            ]),
          ),
        ),
      );
}
