import 'package:flutter/material.dart';
import 'package:webinar/app/pages/main_page/home_page/financial_planning_page/financial_planning_widgets.dart';
import 'package:webinar/app/pages/main_page/home_page/shared/secure_service_webview_page.dart';

/// Restores the Financial Planning plan card before hosted discovery.
/// The plan's website remains the source of truth for prices and payments.
class FinancialPlanningPage extends StatelessWidget {
  const FinancialPlanningPage({super.key});

  static const _discoveryUrl =
      'https://profitfromit.co.in/financial-discovery';

  void _openDiscovery(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const SecureServiceWebViewPage(
          title: 'Financial Discovery',
          initialUrl: _discoveryUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PlanningPalette.background,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: PlanningPalette.ink,
        title: const Text(
          'Financial Planning',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
              children: [
                const FinancialPlanningIntro(),
                const SizedBox(height: 24),
                FinancialPlanningPlanCard(
                  onBegin: () => _openDiscovery(context),
                ),
                const SizedBox(height: 18),
                const FinancialPlanningDisclosure(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
