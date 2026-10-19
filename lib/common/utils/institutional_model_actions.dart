import 'package:flutter/material.dart';

/// Identifiers for the four Institutional Models cards.
///
/// Keep routing in [openInstitutionalModel] so each feature can be enabled
/// independently without changing the home-page UI.
enum InstitutionalModel {
  investmentBaskets,
  financialPlanning,
  portfolioDiagnosis,
  wealthCalculators,
}

/// Shared click handler for every Institutional Models card.
///
/// When a feature is ready, replace only its respective case with its
/// Navigator push (or the application's named-route navigation).
Future<void> openInstitutionalModel(
  BuildContext context,
  InstitutionalModel model,
) {
  switch (model) {
    case InstitutionalModel.investmentBaskets:
      // TODO: Open the Investment Baskets page when it is implemented.
      return showFeatureUnderDevelopment(context);
    case InstitutionalModel.financialPlanning:
      // TODO: Open the Financial Planning page when it is implemented.
      return showFeatureUnderDevelopment(context);
    case InstitutionalModel.portfolioDiagnosis:
      // TODO: Open the Portfolio Diagnosis page when it is implemented.
      return showFeatureUnderDevelopment(context);
    case InstitutionalModel.wealthCalculators:
      // TODO: Open the Wealth Calculators page when it is implemented.
      return showFeatureUnderDevelopment(context);
  }
}

/// A reusable placeholder dialog for features that are not available yet.
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
