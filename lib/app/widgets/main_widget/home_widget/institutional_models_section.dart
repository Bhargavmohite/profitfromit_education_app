import 'package:flutter/material.dart';
import 'package:webinar/common/utils/institutional_model_actions.dart';
import 'package:webinar/config/styles.dart';

import 'home_widget.dart';

/// Separate two-card rows that can appear at different places on the Home Page.
/// All navigation continues through the original shared model handler.
class InstitutionalModelsSection extends StatelessWidget {
  const InstitutionalModelsSection.topRow({super.key}) : isTopRow = true;
  const InstitutionalModelsSection.bottomRow({super.key}) : isTopRow = false;

  final bool isTopRow;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeWidget.titleAndMore(
            isTopRow ? 'Institutional Models' : 'Explore More Tools',
            subtitle: isTopRow
                ? 'Powerful tools for informed financial decisions'
                : 'Build a stronger long-term wealth strategy',
            isViewAll: false,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: isTopRow
                      ? _InstitutionalModelCard(
                          title: 'Portfolio Diagnosis',
                          subtitle: 'Health Check',
                          icon: Icons.analytics_outlined,
                          accent: const Color(0xFF087C91),
                          tint: const Color(0xFFE9F8FA),
                          onTap: () => openInstitutionalModel(
                            context,
                            InstitutionalModel.portfolioDiagnosis,
                          ),
                        )
                      : _InstitutionalModelCard(
                          title: 'Investment Baskets',
                          subtitle: '6 Curated Themes',
                          icon: Icons.shopping_basket_outlined,
                          accent: const Color(0xFF5E51D7),
                          tint: const Color(0xFFF1EEFF),
                          onTap: () => openInstitutionalModel(
                            context,
                            InstitutionalModel.investmentBaskets,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: isTopRow
                      ? _InstitutionalModelCard(
                          title: 'Financial Planning',
                          subtitle: 'Goal & Asset Map',
                          icon: Icons.account_balance_outlined,
                          accent: const Color(0xFF0D3CCF),
                          tint: const Color(0xFFEAF0FF),
                          onTap: () => openInstitutionalModel(
                            context,
                            InstitutionalModel.financialPlanning,
                          ),
                        )
                      : _InstitutionalModelCard(
                          title: 'Wealth Calculators',
                          subtitle: '3 Interactive Tools',
                          icon: Icons.calculate_outlined,
                          accent: const Color(0xFFAC6416),
                          tint: const Color(0xFFFFF4E5),
                          onTap: () => openInstitutionalModel(
                            context,
                            InstitutionalModel.wealthCalculators,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InstitutionalModelCard extends StatelessWidget {
  const _InstitutionalModelCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.tint,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(19));

    return Semantics(
      button: true,
      label: title,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF203460).withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(color: Color(0xFFE5EAF3)),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Container(
              constraints: const BoxConstraints(minHeight: 174),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, tint.withValues(alpha: 0.52)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: tint,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Icon(icon, size: 24, color: accent),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_outward_rounded,
                        size: 19,
                        color: accent.withValues(alpha: 0.72),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: style16Bold().copyWith(
                      fontSize: 15,
                      color: const Color(0xFF112044),
                      height: 1.18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: style12Regular().copyWith(
                      color: const Color(0xFF718199),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
