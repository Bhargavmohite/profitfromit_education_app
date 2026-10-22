import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webinar/app/pages/main_page/home_page/financial_planning_page/financial_planning_page.dart';
import 'package:webinar/app/pages/main_page/home_page/portfolio_diagnosis_page/portfolio_diagnosis_page.dart';
import 'package:webinar/app/pages/main_page/home_page/wealth_calculators_page/wealth_calculators_page.dart';

/// Actions attached to the Institutional Models cards on the Home Page.
enum InstitutionalModel {
  investmentBaskets,
  financialPlanning,
  portfolioDiagnosis,
  wealthCalculators,
}

/// Opens the Maxfolio Dashboard using the installed browser's in-app view.
///
/// Android: Chrome Custom Tabs (or a compatible browser's custom tab).
/// iOS: SFSafariViewController.
///
/// Using a browser-powered view is intentional: the Maxfolio site works in
/// the device browser, whereas Android WebView displayed a blank screen and
/// previously reported SSL / navigation errors. Do not bypass TLS checks.
Future<void> _openInvestmentBaskets(BuildContext context) async {
  // The supplied `cd` query parameter may expire or represent a session.
  // Request a server-managed, stable link before distributing the app.
  final Uri dashboardUri = Uri.parse(
    'https://profitfromit.maxfolio.in/Dashboard?'
    'pc=MA00022PFS2026D&up=&'
    'cd=9qNsjB0-VYS5G64eRYkjlmeMAiqHYIw1AYw2PoG4m1A-1_aMAcvEuWJddneUF_4f&lc=',
  );

  bool launched = false;
  try {
    // Does NOT use Android WebView. Do not change to inAppWebView.
    launched = await launchUrl(
      dashboardUri,
      mode: LaunchMode.inAppBrowserView,
    );
  } catch (error) {
    debugPrint('Maxfolio in-app browser launch failed: $error');
  }

  if (launched) return;

  // Device browser fallback: avoids showing a blank page if Custom Tabs
  // are unavailable on the device.
  try {
    launched = await launchUrl(
      dashboardUri,
      mode: LaunchMode.externalApplication,
    );
  } catch (error) {
    debugPrint('Maxfolio external browser launch failed: $error');
  }

  if (!launched && context.mounted) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(
        content: Text('Unable to open Investment Baskets. Check your browser.'),
      ),
    );
  }
}

Future<void> openInstitutionalModel(
  BuildContext context,
  InstitutionalModel model,
) async {
  switch (model) {
    case InstitutionalModel.investmentBaskets:
      await _openInvestmentBaskets(context);
      return;

    case InstitutionalModel.financialPlanning:
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => const FinancialPlanningPage(),
        ),
      );
      return;

    case InstitutionalModel.portfolioDiagnosis:
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => const PortfolioDiagnosisPage(),
        ),
      );
      return;

    case InstitutionalModel.wealthCalculators:
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => const WealthCalculatorsPage(),
        ),
      );
      return;
  }
}

/// Reusable placeholder dialog for future unfinished features.
Future<void> showFeatureUnderDevelopment(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Coming Soon'),
      content: const Text('This Feature is UnderDevelopment'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
