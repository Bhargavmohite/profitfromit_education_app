import 'package:flutter/material.dart';
import 'package:webinar/app/pages/main_page/home_page/shared/secure_service_webview_page.dart';

/// Existing website routes; selecting a plan never uses the native draft form.
enum PortfolioDiagnosisPlan { individual, family }

extension PortfolioDiagnosisPlanDisplay on PortfolioDiagnosisPlan {
  String get label => this == PortfolioDiagnosisPlan.individual
      ? 'Individual Audit'
      : 'Family Wealth Audit';

  /// The family link preselects the family plan. The default endpoint allows
  /// an individual to choose the Individual Audit on the existing website.
  Uri get onboardingUrl => Uri.https(
        'profitfromit.co.in',
        '/order-user-details',
        this == PortfolioDiagnosisPlan.family ? {'plan': 'family'} : null,
      );
}

class PortfolioDiagnosisCheckoutPage extends StatelessWidget {
  const PortfolioDiagnosisCheckoutPage({
    super.key,
    required this.plan,
  });

  final PortfolioDiagnosisPlan plan;

  @override
  Widget build(BuildContext context) {
    return SecureServiceWebViewPage(
      title: 'Portfolio Diagnosis',
      subtitle: plan.label,
      initialUrl: plan.onboardingUrl.toString(),
    );
  }
}
