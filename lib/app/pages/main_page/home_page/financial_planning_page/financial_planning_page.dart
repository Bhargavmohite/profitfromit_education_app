import 'package:flutter/material.dart';
import 'package:webinar/app/pages/main_page/home_page/financial_planning_page/financial_planning_widgets.dart';

/// UI-only financial planning overview; payment/plan flows are not connected.
class FinancialPlanningPage extends StatelessWidget {
  const FinancialPlanningPage({super.key});

  Future<void> _showComingSoon(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.event_available_rounded,
              color: PlanningPalette.blue,
              size: 27,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Coming Soon',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: PlanningPalette.ink,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'This feature is under development.',
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: PlanningPalette.muted,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Got it',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PlanningPalette.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        foregroundColor: PlanningPalette.ink,
        title: const Text(
          'Financial Planning',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 36),
              children: [
                const FinancialPlanningIntro(),
                const SizedBox(height: 22),
                FinancialPlanningPlanCard(
                  onBegin: () => _showComingSoon(context),
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
