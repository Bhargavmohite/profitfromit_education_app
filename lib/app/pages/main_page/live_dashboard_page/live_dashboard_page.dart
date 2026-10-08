import 'package:flutter/material.dart';
import 'package:webinar/app/pages/main_page/live_market_page/live_market_page.dart';
import 'package:webinar/app/pages/main_page/q1_fy27_page/q1_fy27_page.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/config/colors.dart';

class LiveDashboardPage extends StatelessWidget {
  const LiveDashboardPage({super.key});

  static const String pageName = '/live-dashboard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: green77(),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Live Dashboard',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 28),
          children: <Widget>[
            const Text(
              'Market Intelligence',
              style: TextStyle(
                color: Color(0xFF101828),
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Choose a dashboard to explore live market intelligence or Q1 FY27 earnings analysis.',
              style: TextStyle(
                color: Color(0xFF667085),
                fontSize: 13,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),
            _DashboardCard(
              title: 'Live Market Data',
              subtitle:
                  'Live NSE market data, global markets, sectors, stock explorer, pivots and corporate actions.',
              icon: Icons.show_chart_rounded,
              badge: 'LIVE',
              accent: const Color(0xFF12B76A),
              onTap: () => nextRoute(LiveMarketPage.pageName),
            ),
            const SizedBox(height: 16),
            _DashboardCard(
              title: 'Q1FY27',
              subtitle:
                  'Q1 FY27 earnings intelligence, breadth, heatmap, sector trends, company performance and growth leaders.',
              icon: Icons.analytics_rounded,
              badge: 'EARNINGS',
              accent: const Color(0xFF0D3CCF),
              onTap: () => nextRoute(Q1FY27Page.pageName),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF4FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD7E3FF)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFF0D3CCF),
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Market data is for informational and educational purposes only. It is not investment advice or a buy/sell recommendation.',
                      style: TextStyle(
                        color: Color(0xFF344054),
                        fontSize: 12,
                        height: 1.45,
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

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.badge,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String badge;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE4E7EC)),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x0A101828),
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: accent, size: 29),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Color(0xFF101828),
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: .10),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              color: accent,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: .5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: <Widget>[
                        Text(
                          'Open Dashboard',
                          style: TextStyle(
                            color: accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 17,
                          color: accent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
