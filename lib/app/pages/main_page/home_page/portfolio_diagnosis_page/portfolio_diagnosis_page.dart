import 'package:flutter/material.dart';
import 'package:webinar/app/pages/main_page/home_page/portfolio_diagnosis_page/portfolio_diagnosis_widgets.dart';
import 'package:webinar/app/pages/main_page/home_page/portfolio_diagnosis_page/portfolio_diagnosis_checkout_page.dart';

/// Portfolio Diagnosis plans with embedded secure website onboarding.
class PortfolioDiagnosisPage extends StatelessWidget {
  const PortfolioDiagnosisPage({super.key});

  void _openCheckout(BuildContext context, PortfolioDiagnosisPlan plan) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => PortfolioDiagnosisCheckoutPage(plan: plan),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DiagnosisPalette.background,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: DiagnosisPalette.ink,
        title: const Text(
          'Portfolio Diagnosis',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1050),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 36),
              children: [
                const DiagnosisIntroBanner(),
                const SizedBox(height: 27),
                const Text(
                  'Choose your review',
                  style: TextStyle(
                    color: DiagnosisPalette.ink,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Two ways to assess portfolio health, risks and diversification.',
                  style: TextStyle(
                    color: DiagnosisPalette.muted,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 17),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final individual = DiagnosisPlanCard(
                      key: const ValueKey('individual_audit'),
                      badge: 'DIAGNOSTICS',
                      title: 'Individual Audit',
                      description:
                          'Single Demat review covering fundamental quality, industry diversification, and growth analysis.',
                      price: '₹2,000 + GST',
                      benefits: const [
                        'Single Demat Review',
                        '30m Expert Strategy Call',
                        'Portfolio Health Score',
                      ],
                      buttonText: 'Start Review Plan',
                      accent: DiagnosisPalette.blue,
                      softAccent: DiagnosisPalette.blueTint,
                      icon: Icons.manage_search_rounded,
                      onPressed: () => _openCheckout(
                        context, PortfolioDiagnosisPlan.individual),
                    );
                    final family = DiagnosisPlanCard(
                      key: const ValueKey('family_wealth_audit'),
                      badge: 'BEST VALUE FOR FAMILIES',
                      title: 'Family Wealth Audit',
                      description:
                          'Scientific Portfolio Health Score and Mutual Fund overlap audit for entire household portfolios.',
                      price: '₹6,000 + GST',
                      benefits: const [
                        'Up to 4 Accounts',
                        '60m Comprehensive Session',
                        'Mutual Fund Overlap Check',
                      ],
                      buttonText: 'Secure Family Portfolio',
                      accent: DiagnosisPalette.orange,
                      softAccent: DiagnosisPalette.orangeTint,
                      icon: Icons.family_restroom_rounded,
                      onPressed: () =>
                          _openCheckout(context, PortfolioDiagnosisPlan.family),
                    );

                    if (constraints.maxWidth >= 660) {
                      return IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: individual),
                            const SizedBox(width: 18),
                            Expanded(child: family),
                          ],
                        ),
                      );
                    }
                    return Column(
                      children: [
                        individual,
                        const SizedBox(height: 16),
                        family,
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                const _CheckoutInfo(),
                const SizedBox(height: 24),
                const DiagnosisDisclosure(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small advisory disclosure in the native plan-selection screen.
class _CheckoutInfo extends StatelessWidget {
  const _CheckoutInfo();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F2FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded,
              color: DiagnosisPalette.blue, size: 19),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Plan fee, GST and any eligible student discount are confirmed '
              'during secure checkout.',
              style: TextStyle(
                color: DiagnosisPalette.ink,
                fontSize: 11.5,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
