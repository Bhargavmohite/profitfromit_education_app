import 'package:flutter/material.dart';
import 'package:webinar/app/pages/main_page/home_page/portfolio_diagnosis_page/portfolio_diagnosis_widgets.dart';

/// Portfolio Diagnosis plans – presentation only; no backend or payments yet.
class PortfolioDiagnosisPage extends StatelessWidget {
  const PortfolioDiagnosisPage({super.key});

  Future<void> _showComingSoon(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
        title: const Row(
          children: [
            Icon(Icons.rocket_launch_rounded,
                color: DiagnosisPalette.blue, size: 26),
            SizedBox(width: 12),
            Expanded(
              child: Text('Coming Soon',
                  style: TextStyle(
                    color: DiagnosisPalette.ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  )),
            ),
          ],
        ),
        content: const Text(
          'This feature is under development.',
          style: TextStyle(
            color: DiagnosisPalette.muted,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Got it',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
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
                      price: '₹2,000',
                      benefits: const [
                        'Single Demat Review',
                        '30m Expert Strategy Call',
                        'Portfolio Health Score',
                      ],
                      buttonText: 'Start Review Plan',
                      accent: DiagnosisPalette.blue,
                      softAccent: DiagnosisPalette.blueTint,
                      icon: Icons.manage_search_rounded,
                      onPressed: () => _showComingSoon(context),
                    );
                    final family = DiagnosisPlanCard(
                      key: const ValueKey('family_wealth_audit'),
                      badge: 'BEST VALUE FOR FAMILIES',
                      title: 'Family Wealth Audit',
                      description:
                          'Scientific Portfolio Health Score and Mutual Fund overlap audit for entire household portfolios.',
                      price: '₹6,000',
                      benefits: const [
                        'Up to 4 Accounts',
                        '60m Comprehensive Session',
                        'Mutual Fund Overlap Check',
                      ],
                      buttonText: 'Secure Family Portfolio',
                      accent: DiagnosisPalette.orange,
                      softAccent: DiagnosisPalette.orangeTint,
                      icon: Icons.family_restroom_rounded,
                      onPressed: () => _showComingSoon(context),
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
