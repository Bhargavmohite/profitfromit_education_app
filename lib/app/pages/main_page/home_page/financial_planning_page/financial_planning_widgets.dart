import 'package:flutter/material.dart';

/// Shared visual tokens for the Financial Planning page.
class PlanningPalette {
  static const background = Color(0xFFF5F7FB);
  static const white = Colors.white;
  static const ink = Color(0xFF102641);
  static const muted = Color(0xFF66778F);
  static const blue = Color(0xFF1677E9);
  static const blueSoft = Color(0xFFE9F3FF);
  static const teal = Color(0xFF08A88A);
  static const border = Color(0xFFE4EAF2);
}

class FinancialPlanningIntro extends StatelessWidget {
  const FinancialPlanningIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF112D53), Color(0xFF255691)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned(
              right: -35,
              bottom: -72,
              child: Container(
                height: 170,
                width: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0x22FFFFFF),
                    width: 25,
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_outlined,
                        color: Color(0xFFA8D8FF),
                        size: 18,
                      ),
                      SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'YOUR FINANCIAL ROADMAP',
                          style: TextStyle(
                            color: Color(0xFFCEE6FA),
                            fontSize: 10,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 13),
                  Text(
                    'Give every goal\na clear direction.',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.17,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'A structured approach to your goals, asset allocation and long-term decisions.',
                    style: TextStyle(
                      color: Color(0xFFD6E7F8),
                      fontSize: 12.5,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FinancialPlanningPlanCard extends StatelessWidget {
  const FinancialPlanningPlanCard({super.key, required this.onBegin});

  final VoidCallback onBegin;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PlanningPalette.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: PlanningPalette.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0E1C365A),
            blurRadius: 23,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(height: 4, color: PlanningPalette.blue),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: PlanningPalette.blueSoft,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(
                          Icons.route_rounded,
                          color: PlanningPalette.blue,
                          size: 25,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: PlanningPalette.blueSoft,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'COMPLETE ROADMAP',
                            style: TextStyle(
                              color: PlanningPalette.blue,
                              fontWeight: FontWeight.w800,
                              letterSpacing: .45,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Holistic Financial Planning',
                    style: TextStyle(
                      color: PlanningPalette.ink,
                      fontSize: 22,
                      height: 1.2,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'A customized strategy balancing your income, projecting long-term growth, and mapping out milestones like retirement and education.',
                    style: TextStyle(
                      color: PlanningPalette.muted,
                      fontSize: 13,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 21),
                  const Divider(height: 1, color: PlanningPalette.border),
                  const SizedBox(height: 21),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹999',
                        style: TextStyle(
                          color: PlanningPalette.ink,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                        ),
                      ),
                      SizedBox(width: 8),
                      Padding(
                        padding: EdgeInsets.only(bottom: 2),
                        child: Text(
                          '+ GST',
                          style: TextStyle(
                            color: PlanningPalette.muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const _PlanningBenefit('Full Goal Mapping'),
                  const SizedBox(height: 13),
                  const _PlanningBenefit('Asset Allocation Strategy'),
                  const SizedBox(height: 13),
                  const _PlanningBenefit('Tax Efficiency Review'),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: 49,
                    child: FilledButton(
                      onPressed: onBegin,
                      style: FilledButton.styleFrom(
                        backgroundColor: PlanningPalette.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              'Begin Financial Plan',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanningBenefit extends StatelessWidget {
  const _PlanningBenefit(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.check_circle_rounded,
          color: PlanningPalette.teal,
          size: 18,
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: PlanningPalette.ink,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class FinancialPlanningDisclosure extends StatelessWidget {
  const FinancialPlanningDisclosure({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFECF1F8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: PlanningPalette.blue,
            size: 18,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Profit Finstock Pvt. Ltd. | SEBI Registered Investment Adviser: INA000020651. '
              'Price excludes GST. Service availability and terms apply.',
              style: TextStyle(
                color: PlanningPalette.muted,
                fontSize: 11.5,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
