import 'package:flutter/material.dart';
import 'package:webinar/app/pages/main_page/home_page/investment_baskets_page/investment_basket_data.dart';
import 'package:webinar/app/pages/main_page/home_page/investment_baskets_page/investment_basket_widgets.dart';
import 'package:webinar/app/pages/main_page/home_page/investment_baskets_page/investment_basket_webview_page.dart';

/// Educational strategy overview. No holdings/performance invented or fetched.
class InvestmentBasketDetailsPage extends StatelessWidget {
  const InvestmentBasketDetailsPage({super.key, required this.basket});
  final InvestmentBasket basket;

  @override
  Widget build(BuildContext context) {
    return BasketPageFrame(
      title: 'Basket Overview',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(23),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(23),
            gradient: LinearGradient(
              colors: [BasketColors.navy, basket.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0x27FFFFFF),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(basket.icon, color: Colors.white, size: 27),
            ),
            const SizedBox(height: 21),
            const Text('INVESTMENT BASKET',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    color: Color(0xFFD3E2F3),
                    letterSpacing: 1.1)),
            const SizedBox(height: 7),
            Text(basket.name,
                style: const TextStyle(
                    fontSize: 28,
                    height: 1.12,
                    fontWeight: FontWeight.w900,
                    color: Colors.white)),
            const SizedBox(height: 6),
            Text(basket.subtitle,
                style: const TextStyle(fontSize: 14, color: Color(0xFFE2EDFB))),
            const SizedBox(height: 20),
            const BasketPill(
              text: 'Aggressive risk profile',
              icon: Icons.trending_up_rounded,
              foreground: Colors.white,
              background: Color(0x27FFFFFF),
            ),
          ]),
        ),
        const SizedBox(height: 15),
        LayoutBuilder(builder: (context, constraints) {
          final twoAcross = constraints.maxWidth >= 500;
          final fees = BasketInfoCard(
            icon: Icons.currency_rupee_rounded,
            heading: 'Annual fee (reference)',
            value: '${basket.feeText} / year',
            accent: basket.accent,
          );
          const risk = BasketInfoCard(
            icon: Icons.speed_outlined,
            heading: 'Reference risk profile',
            value: 'Aggressive',
            accent: Color(0xFFA84F25),
          );
          if (twoAcross) {
            return Row(children: [
              Expanded(child: fees),
              const SizedBox(width: 12),
              const Expanded(child: risk),
            ]);
          }
          return Column(children: [fees, const SizedBox(height: 11), risk]);
        }),
        const SizedBox(height: 23),
        const Text('Strategy overview',
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 19,
                color: BasketColors.ink)),
        const SizedBox(height: 10),
        Text(basket.themeSummary,
            style: const TextStyle(
                fontSize: 13, height: 1.65, color: BasketColors.secondary)),
        const SizedBox(height: 23),
        const Text('Before you invest',
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 19,
                color: BasketColors.ink)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            color: Colors.white,
            border: Border.all(color: BasketColors.outline),
          ),
          child: const Column(children: [
            _ReviewItem(
                icon: Icons.description_outlined,
                text: 'Read the complete strategy and methodology document.'),
            Divider(height: 23, color: BasketColors.outline),
            _ReviewItem(
                icon: Icons.pie_chart_outline_rounded,
                text:
                    'Review current constituents, allocations and rebalancing rules.'),
            Divider(height: 23, color: BasketColors.outline),
            _ReviewItem(
                icon: Icons.shield_outlined,
                text: 'Assess concentration, volatility and downside risks.'),
            Divider(height: 23, color: BasketColors.outline),
            _ReviewItem(
                icon: Icons.receipt_long_outlined,
                text:
                    'Verify current advisory fees, terms and individual suitability.'),
          ]),
        ),
        const SizedBox(height: 18),
        const BasketEducationNote(
            text:
                'This is a locally stored UI catalogue based on the supplied reference. '
                'It does not contain live securities, performance, or suitability analysis. '
                'Past performance does not assure future returns. '
                'Profit Finstock Pvt. Ltd. | SEBI RIA: INA000020651.'),
        const SizedBox(height: 19),
        SizedBox(
          width: double.infinity,
          height: 51,
          child: FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => InvestmentBasketWebViewPage(basket: basket),
              ),
            ),
            icon: const Icon(Icons.description_outlined, size: 18),
            label: const Text('Get Full Details'),
            style: FilledButton.styleFrom(
              backgroundColor: basket.accent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              textStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ]),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  const _ReviewItem({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: BasketColors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      color: BasketColors.ink, fontSize: 12.5, height: 1.5))),
        ],
      );
}
