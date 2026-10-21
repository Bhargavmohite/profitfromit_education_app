import 'package:flutter/material.dart';
import 'package:webinar/app/pages/main_page/home_page/wealth_calculators_page/wealth_calculator_widgets.dart';
import 'package:webinar/common/utils/wealth_calculator_logic.dart';

class AgeAllocationCalculatorPage extends StatefulWidget {
  const AgeAllocationCalculatorPage({super.key});

  @override
  State<AgeAllocationCalculatorPage> createState() =>
      _AgeAllocationCalculatorPageState();
}

class _AgeAllocationCalculatorPageState
    extends State<AgeAllocationCalculatorPage> {
  int _age = 35;
  int _riskLevel = 1;
  final _income = TextEditingController(text: '150000');
  final _expenses = TextEditingController(text: '60000');

  @override
  void dispose() {
    _income.dispose();
    _expenses.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final equity = WealthCalculatorLogic.equityShare(_age, _riskLevel);
    final debt = 100 - equity;
    final expense = WealthCalculatorLogic.parseMoney(_expenses.text);
    final reserve = expense * 6;
    final focus = _age < 45
        ? 'Wealth accumulation'
        : _age < 60
            ? 'Balance growth & protection'
            : 'Capital preservation';

    return WealthPageFrame(
      title: 'Asset Allocation Compass',
      child: WealthContent(children: [
        WealthResultBanner(
          eyebrow: 'ILLUSTRATIVE BASELINE',
          value: '$equity% Equity',
          description: '$debt% debt  •  Based on your age and chosen risk appetite',
          icon: Icons.pie_chart_outline_rounded,
          accent: const Color(0xFF76E5C5),
          bottom: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: Row(children: [
                Expanded(
                  flex: equity,
                  child: Container(height: 12, color: const Color(0xFF5C8FF8)),
                ),
                Expanded(
                  flex: debt,
                  child: Container(height: 12, color: const Color(0xFF5FE2C1)),
                ),
              ]),
            ),
            const SizedBox(height: 11),
            const Row(children: [
              _Legend(color: Color(0xFF5C8FF8), text: 'Equity'),
              SizedBox(width: 21),
              _Legend(color: Color(0xFF5FE2C1), text: 'Debt'),
            ]),
          ]),
        ),
        const SizedBox(height: 17),
        WealthSection(
          title: 'Your financial snapshot',
          subtitle: 'Change your inputs to see the suggested mix update.',
          child: Column(children: [
            WealthSlider(
              label: 'Current age',
              valueText: '$_age years',
              value: _age.toDouble(),
              min: 18,
              max: 75,
              divisions: 57,
              onChanged: (value) => setState(() => _age = value.round()),
            ),
            const SizedBox(height: 20),
            WealthMoneyInput(
              label: 'Monthly income',
              controller: _income,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 18),
            WealthMoneyInput(
              label: 'Essential monthly expenses',
              controller: _expenses,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 22),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Risk appetite',
                  style: TextStyle(
                      color: WealthUi.ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ),
            const SizedBox(height: 12),
            Row(children: [
              _RiskChoice(
                  name: 'Low',
                  selected: _riskLevel == 0,
                  onTap: () => setState(() => _riskLevel = 0)),
              const SizedBox(width: 8),
              _RiskChoice(
                  name: 'Moderate',
                  selected: _riskLevel == 1,
                  onTap: () => setState(() => _riskLevel = 1)),
              const SizedBox(width: 8),
              _RiskChoice(
                  name: 'High',
                  selected: _riskLevel == 2,
                  onTap: () => setState(() => _riskLevel = 2)),
            ]),
          ]),
        ),
        const SizedBox(height: 17),
        Row(children: [
          Expanded(
            child: WealthStat(
              label: '6-month emergency reserve',
              value: WealthCalculatorLogic.rupees(reserve, compact: true),
              icon: Icons.health_and_safety_outlined,
              tint: const Color(0xFFE5F6F2),
              accent: WealthUi.teal,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: WealthStat(
              label: 'Broad life-stage focus',
              value: focus,
              icon: Icons.track_changes_rounded,
              tint: const Color(0xFFEAF0FF),
            ),
          ),
        ]),
        const SizedBox(height: 20),
        const WealthNote(
          text: 'Allocation uses 120 − age, adjusted −10/0/+10 percentage points for low/moderate/high risk (capped at 20–90% equity). Emergency savings assume six months of essential expenses. Income is contextual only and does not change this rule. This is a teaching heuristic, not a suitability assessment or investment recommendation.',
        ),
      ]),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.text});
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 7),
        Text(text,
            style: const TextStyle(color: Colors.white, fontSize: 12)),
      ]);
}

class _RiskChoice extends StatelessWidget {
  const _RiskChoice({required this.name, required this.selected, required this.onTap});
  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Material(
          color: selected ? WealthUi.blue : WealthUi.background,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
              child: Text(name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: selected ? Colors.white : WealthUi.muted,
                      fontWeight: FontWeight.w800,
                      fontSize: 12)),
            ),
          ),
        ),
      );
}
