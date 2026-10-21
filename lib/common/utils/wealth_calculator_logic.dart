import 'dart:math' as math;

/// All results are illustrative calculations performed entirely on-device.
/// Returns are assumed, not promised, and do not include taxes or charges.
class WealthCalculatorLogic {
  const WealthCalculatorLogic._();

  /// Conventional illustrative '120 minus age' allocation with a risk
  /// adjustment of -10 / 0 / +10 percentage points, capped at 20%–90%.
  static int equityShare(int age, int riskLevel) {
    final adjustment = (riskLevel - 1) * 10;
    return (120 - age + adjustment).clamp(20, 90).toInt();
  }

  /// Assumes 365 days/year of daily discretionary spend and end-of-month
  /// investments, growing at an effective annual return.
  static TimeMachineResult timeMachine({
    required double dailySpend,
    required int years,
    required double annualReturnPercent,
  }) {
    final spend = math.max(0.0, dailySpend);
    final months = math.max(0, years) * 12;
    final monthlyDeposit = spend * 365 / 12;
    final spent = spend * 365 * years;
    final monthlyRate = _monthlyRate(annualReturnPercent);
    final future = monthlyRate == 0
        ? monthlyDeposit * months
        : monthlyDeposit *
            (math.pow(1 + monthlyRate, months).toDouble() - 1) /
            monthlyRate;
    return TimeMachineResult(
      totalSpent: spent,
      futureWealth: future.isFinite ? future : 0,
      wealthGain: (future - spent).isFinite ? future - spent : 0,
    );
  }

  /// End-of-month SIP contributions, monthly compounding derived from an
  /// effective annual rate. Returns null if not achievable within 100 years.
  static int? monthsToTarget({
    required double currentCorpus,
    required double monthlySip,
    required double targetCorpus,
    required double annualReturnPercent,
  }) {
    final start = math.max(0.0, currentCorpus);
    final sip = math.max(0.0, monthlySip);
    if (targetCorpus <= 0 || start >= targetCorpus) return 0;
    if (sip == 0 && (start == 0 || annualReturnPercent <= 0)) return null;
    final rate = _monthlyRate(annualReturnPercent);
    var corpus = start;
    for (var month = 1; month <= 1200; month++) {
      corpus = corpus * (1 + rate) + sip;
      if (corpus >= targetCorpus) return month;
      if (!corpus.isFinite) return null;
    }
    return null;
  }

  static double _monthlyRate(double annualReturnPercent) =>
      math.pow(1 + annualReturnPercent.clamp(0, 30) / 100, 1 / 12).toDouble() - 1;

  /// Indian lakh/crore separators without adding an `intl` dependency.
  static String rupees(num value, {bool compact = false}) {
    if (!value.isFinite) return '₹—';
    final positive = value.abs();
    final sign = value < 0 ? '−' : '';
    if (compact && positive >= 10000000) {
      return '$sign₹${_decimal(positive / 10000000)} Cr';
    }
    if (compact && positive >= 100000) {
      return '$sign₹${_decimal(positive / 100000)} L';
    }
    final digits = positive.round().toString();
    if (digits.length <= 3) return '$sign₹$digits';
    final tail = digits.substring(digits.length - 3);
    var left = digits.substring(0, digits.length - 3);
    final groups = <String>[];
    while (left.length > 2) {
      groups.insert(0, left.substring(left.length - 2));
      left = left.substring(0, left.length - 2);
    }
    if (left.isNotEmpty) groups.insert(0, left);
    return '$sign₹${groups.join(',')},$tail';
  }

  static String _decimal(double value) => value >= 100
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(value >= 10 ? 1 : 2);

  static double parseMoney(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9.]'), '');
    return (double.tryParse(cleaned) ?? 0).clamp(0, 100000000000).toDouble();
  }
}

class TimeMachineResult {
  const TimeMachineResult({
    required this.totalSpent,
    required this.futureWealth,
    required this.wealthGain,
  });

  final double totalSpent;
  final double futureWealth;
  final double wealthGain;
}
