import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:webinar/app/models/q1_fy27_dashboard_model.dart';
import 'package:webinar/app/services/guest_service/q1_fy27_dashboard_service.dart';
import 'package:webinar/config/colors.dart';

import 'all_companies/all_companies_page.dart';
import 'basic_industry/basic_industry_page.dart';
import 'investor_insights/investor_insights_page.dart';
import 'macro_economic_sector/macro_economic_sector_page.dart';
import 'market_heatmap/q1_market_heatmap.dart';
import 'thematic_baskets/thematic_baskets_page.dart';

class Q1FY27Page extends StatefulWidget {
  const Q1FY27Page({super.key});

  static const String pageName = '/q1-fy27';

  @override
  State<Q1FY27Page> createState() => _Q1FY27PageState();
}

class _Q1FY27PageState extends State<Q1FY27Page> {
  static const Color _navy = Color(0xFF0B1F4D);
  static const Color _blue = Color(0xFF0D3CCF);
  static const Color _green = Color(0xFF12B76A);
  static const Color _amber = Color(0xFFF6C344);
  static const Color _purple = Color(0xFF7A5AF8);
  static const Color _text = Color(0xFF101828);
  static const Color _muted = Color(0xFF667085);
  static const Color _border = Color(0xFFE4E7EC);
  static const Color _surface = Color(0xFFF5F7FB);

  int _selectedDashboardTab = 0;
  late Future<Q1FY27DashboardData> _dashboardFuture;

  int? _swipePointer;
  Offset? _swipeStartPosition;
  DateTime? _swipeStartTime;

  String? _allCompaniesSector;
  String? _allCompaniesCap;
  int _allCompaniesNavigationVersion = 0;

  static const List<_DashboardTab> _dashboardTabs = <_DashboardTab>[
    _DashboardTab('Market Heatmap', Icons.grid_view_rounded),
    _DashboardTab('Macro-Economic Sector', Icons.bar_chart_rounded),
    _DashboardTab('Basic Industry', Icons.factory_outlined),
    _DashboardTab('All Companies', Icons.business_rounded),
    _DashboardTab('Investor Insights', Icons.insights_rounded),
    _DashboardTab('Thematic Baskets', Icons.layers_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _dashboardFuture = Q1FY27DashboardService.dashboard();
  }

  void _retry() {
    setState(() {
      _dashboardFuture = Q1FY27DashboardService.dashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: green77(),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Q1FY27',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<Q1FY27DashboardData>(
          future: _dashboardFuture,
          builder: (
            BuildContext context,
            AsyncSnapshot<Q1FY27DashboardData> snapshot,
          ) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const _Q1LoadingState();
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return _Q1ErrorState(
                message: snapshot.error?.toString() ??
                    'Unable to load Q1 FY27 dashboard data.',
                onRetry: _retry,
              );
            }

            final Q1FY27DashboardData data = snapshot.data!;
            return Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: _handleSwipePointerDown,
              onPointerUp: _handleSwipePointerUp,
              onPointerCancel: _handleSwipePointerCancel,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: KeyedSubtree(
                  key: ValueKey<String>(
                    '$_selectedDashboardTab-$_allCompaniesNavigationVersion',
                  ),
                  child: _buildSelectedPage(data),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildSelectedPage(Q1FY27DashboardData data) {
    switch (_selectedDashboardTab) {
      case 0:
        return _buildMarketHeatmapPage(data);
      case 1:
        return MacroEconomicSectorPage(
          data: data,
          onNavigateToAllCompanies: (String sector) {
            _openAllCompanies(sector: sector);
          },
        );
      case 2:
        return BasicIndustryPage(data: data);
      case 3:
        return AllCompaniesPage(
          data: data,
          initialSector: _allCompaniesSector,
          initialCap: _allCompaniesCap,
        );
      case 4:
        return InvestorInsightsPage(data: data);
      case 5:
        return ThematicBasketsPage(data: data);
      default:
        return const SizedBox.shrink();
    }
  }

  void _openAllCompanies({String? sector, String? cap}) {
    setState(() {
      _allCompaniesSector = sector;
      _allCompaniesCap = cap;
      _selectedDashboardTab = 3;
      _allCompaniesNavigationVersion += 1;
    });
  }

  void _handleSwipePointerDown(PointerDownEvent event) {
    if (_swipePointer != null) return;
    _swipePointer = event.pointer;
    _swipeStartPosition = event.position;
    _swipeStartTime = DateTime.now();
  }

  void _handleSwipePointerUp(PointerUpEvent event) {
    if (_swipePointer != event.pointer ||
        _swipeStartPosition == null ||
        _swipeStartTime == null) {
      _resetSwipeTracking();
      return;
    }

    final Offset delta = event.position - _swipeStartPosition!;
    final double horizontalDistance = delta.dx.abs();
    final double verticalDistance = delta.dy.abs();
    final int elapsedMs = DateTime.now()
        .difference(_swipeStartTime!)
        .inMilliseconds
        .clamp(1, 5000);
    final double horizontalVelocity = delta.dx / elapsedMs * 1000;

    _resetSwipeTracking();

    final bool clearlyHorizontal = horizontalDistance > verticalDistance * 1.35;
    final bool intentionalSwipe = horizontalDistance >= 70 ||
        (horizontalDistance >= 42 && horizontalVelocity.abs() >= 420);

    if (!clearlyHorizontal || !intentionalSwipe) return;

    if (delta.dx < 0) {
      _goToNextDashboardTab();
    } else {
      _goToPreviousDashboardTab();
    }
  }

  void _handleSwipePointerCancel(PointerCancelEvent event) {
    if (_swipePointer == event.pointer) _resetSwipeTracking();
  }

  void _resetSwipeTracking() {
    _swipePointer = null;
    _swipeStartPosition = null;
    _swipeStartTime = null;
  }

  void _goToNextDashboardTab() {
    if (_selectedDashboardTab >= _dashboardTabs.length - 1) return;
    setState(() => _selectedDashboardTab += 1);
  }

  void _goToPreviousDashboardTab() {
    if (_selectedDashboardTab <= 0) return;
    setState(() => _selectedDashboardTab -= 1);
  }

  Widget _buildMarketHeatmapPage(Q1FY27DashboardData data) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: <Widget>[
        _heroSection(data),
        const SizedBox(height: 14),
        _marketPulseSection(data),
        const SizedBox(height: 14),
        _earningsBreadthSection(data),
        const SizedBox(height: 14),
        _distributionSection(data),
        const SizedBox(height: 14),
        Q1MarketHeatmap(data: data),
        const SizedBox(height: 14),
        _researchEducationCard(data),
      ],
    );
  }

  Widget _heroSection(Q1FY27DashboardData data) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[
            Color(0xFF071B47),
            Color(0xFF102F6B),
            Color(0xFF162F60)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x1F0B1F4D),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              DecoratedBox(
                decoration:
                    BoxDecoration(color: _amber, shape: BoxShape.circle),
                child: SizedBox(width: 5, height: 5),
              ),
              SizedBox(width: 7),
              Text(
                'ALL-CAP EARNINGS & MACRO INTELLIGENCE',
                style: TextStyle(
                  color: _amber,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Q1 FY27 Earnings Dashboard: Nifty All-Cap Results Analysis',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              height: 1.08,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Sales, profit and margin performance of India’s listed universe — by index, sector, industry, theme and company.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: .78),
              fontSize: 11,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: <Widget>[
              _HeroChip(
                icon: Icons.business_rounded,
                text: '${data.companies.length} Companies',
              ),
              _HeroChip(
                icon: Icons.category_rounded,
                text: '${data.sectors.length} Sectors',
              ),
              _HeroChip(
                icon: Icons.folder_rounded,
                text: '${data.industries.length} Industries',
              ),
              _HeroChip(
                icon: Icons.hub_rounded,
                text: '${data.themes.length} Thematic Baskets',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _marketPulseSection(Q1FY27DashboardData data) {
    const Set<String> visibleKeys = <String>{
      'NIFTY_50',
      'NIFTY_100 (LARGE CAP)',
      'Mid Cap_150',
      'Small Cap_250',
      'MicroCap_250',
      'NIFTY_ALLCAP',
    };
    final List<Q1OverviewRow> rows = data.overview
        .where((Q1OverviewRow row) => visibleKeys.contains(row.key))
        .toList();

    return _lightSection(
      eyebrow: 'MARKET PULSE',
      title: 'Q1 FY27 in one screen',
      subtitle: '${data.meta.source} • ₹ crore',
      child: GridView.builder(
        itemCount: rows.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 9,
          mainAxisSpacing: 9,
          mainAxisExtent: 190,
        ),
        itemBuilder: (BuildContext context, int index) =>
            _pulseCard(rows[index]),
      ),
    );
  }

  Widget _pulseCard(Q1OverviewRow item) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => _openAllCompanies(cap: _capFilterForOverview(item.key)),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[Color(0xFF1C376C), Color(0xFF18315F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFF36558F)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      item.label.toUpperCase(),
                      style: const TextStyle(
                        color: _amber,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .5,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .09),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      item.key == 'NIFTY_ALLCAP' ? 'ALL CAP' : dataLabel(item),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 6.8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                Q1Format.marketCap(item.marketCap),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Text(
                'MARKET CAP',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 7,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 7),
              Row(
                children: <Widget>[
                  Expanded(child: _growthMetric('SALES GR.', item.salesGrowth)),
                  const SizedBox(width: 7),
                  Expanded(
                      child: _growthMetric('PROFIT GR.', item.profitGrowth)),
                ],
              ),
              const SizedBox(height: 6),
              Divider(height: 1, color: Colors.white.withValues(alpha: .13)),
              const SizedBox(height: 7),
              Text(
                'Sales  ${Q1Format.crore(item.salesFY27)}',
                style: const TextStyle(
                    color: Colors.white70, fontSize: 7.5, height: 1.4),
              ),
              Text(
                'Profit  ${Q1Format.crore(item.profitFY27)}',
                style: const TextStyle(
                    color: Colors.white70, fontSize: 7.5, height: 1.4),
              ),
              Text(
                'Margin  ${Q1Format.plainPct(item.marginFY27)}  •  ${Q1Format.pp(item.marginChange)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 7.5, height: 1.4),
              ),
              const Spacer(),
              const Row(
                children: <Widget>[
                  Text(
                    'View companies',
                    style: TextStyle(
                        color: _amber,
                        fontSize: 7.5,
                        fontWeight: FontWeight.w800),
                  ),
                  SizedBox(width: 3),
                  Icon(Icons.arrow_forward_rounded, size: 10, color: _amber),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String dataLabel(Q1OverviewRow row) => 'Q1 FY27';

  String? _capFilterForOverview(String key) {
    switch (key) {
      case 'NIFTY_50':
        return 'Top 50';
      case 'NIFTY_100 (LARGE CAP)':
        return 'Large Cap';
      case 'Mid Cap_150':
        return 'Mid Cap';
      case 'Small Cap_250':
        return 'Small Cap';
      case 'MicroCap_250':
        return 'Micro Cap';
      default:
        return null;
    }
  }

  Widget _growthMetric(String label, double value) {
    final bool positive = value >= 0;
    final Color color =
        positive ? const Color(0xFF6CE9A6) : const Color(0xFFFDA29B);
    final Color bg = positive
        ? const Color(0xFF027A48).withValues(alpha: .32)
        : const Color(0xFFB42318).withValues(alpha: .35);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
              color: Colors.white54,
              fontSize: 6.5,
              fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 3),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          decoration:
              BoxDecoration(color: bg, borderRadius: BorderRadius.circular(5)),
          child: Text(
            Q1Format.pct(value),
            style: TextStyle(
                color: color, fontSize: 7.2, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }

  Widget _earningsBreadthSection(Q1FY27DashboardData data) {
    const List<Color> colors = <Color>[
      _blue,
      _green,
      Color(0xFFD4A80B),
      _purple
    ];
    final List<Q1BreadthStat> stats = data.breadthStats;
    return _lightSection(
      eyebrow: 'EARNINGS BREADTH',
      title: 'How broad were Q1 FY27 earnings?',
      subtitle: 'Share of All-Cap companies reporting growth.',
      child: GridView.builder(
        itemCount: stats.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 9,
          mainAxisSpacing: 9,
          mainAxisExtent: 94,
        ),
        itemBuilder: (BuildContext context, int index) {
          final Q1BreadthStat item = stats[index];
          return Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border),
            ),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(
                          value: item.percent / 100,
                          strokeWidth: 5,
                          backgroundColor: const Color(0xFFEAECF0),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(colors[index]),
                        ),
                      ),
                      Text(
                        '${item.percent.round()}%',
                        style: const TextStyle(
                            color: _text,
                            fontSize: 10,
                            fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item.title,
                        style: const TextStyle(
                            color: _text,
                            fontSize: 9,
                            fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${item.count} of ${item.base} companies',
                        style: const TextStyle(
                            color: _muted, fontSize: 7, height: 1.25),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _distributionSection(Q1FY27DashboardData data) {
    const List<Color> colors = <Color>[
      Color(0xFFB42318),
      Color(0xFFD92D20),
      Color(0xFFF97066),
      Color(0xFF6CE9A6),
      Color(0xFF12B76A),
      Color(0xFF079455),
      Color(0xFF067647),
    ];
    final List<Q1DistributionBucket> rows = data.profitDistribution;
    final int maxValue = rows.fold<int>(
        1, (int max, Q1DistributionBucket row) => math.max(max, row.count));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.fromLTRB(13, 14, 13, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Profit Growth Distribution',
            style: TextStyle(
                color: _text, fontSize: 13, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 3),
          const Text(
            'Companies by YoY profit growth',
            style: TextStyle(color: _muted, fontSize: 8),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 145,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List<Widget>.generate(rows.length, (int index) {
                final Q1DistributionBucket item = rows[index];
                final double h = item.count / maxValue * 98;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text('${item.count}',
                            style:
                                const TextStyle(color: _muted, fontSize: 6.5)),
                        const SizedBox(height: 3),
                        Container(
                          height: h,
                          decoration: BoxDecoration(
                            color: colors[index],
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4)),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          item.label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: const TextStyle(
                              color: _muted, fontSize: 5.8, height: 1.05),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _researchEducationCard(Q1FY27DashboardData data) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: <Color>[Color(0xFF071B47), Color(0xFF15366F)]),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Research & Education Dashboard',
            style: TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 7),
          Text(
            'This dashboard visualises the NIFTY All-Cap Q1 FY27 earnings workbook for investor education and research. It is not a stock tip, trading call, personalised investment recommendation or assurance of returns.',
            style: TextStyle(
                color: Colors.white.withValues(alpha: .72),
                fontSize: 8.5,
                height: 1.5),
          ),
          const SizedBox(height: 12),
          const Text('Source',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(data.meta.source,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: .65), fontSize: 8)),
          const SizedBox(height: 10),
          const Text('Coverage',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(
            '${data.companies.length} companies • ${data.sectors.length} sectors • ${data.industries.length} industries',
            style: TextStyle(
                color: Colors.white.withValues(alpha: .65), fontSize: 8),
          ),
          const SizedBox(height: 11),
          Text(
            'Profit Finstock Pvt. Ltd. | SEBI Registered Investment Adviser – INA000020651\nEducational purposes only. Not investment advice.',
            style: TextStyle(
                color: Colors.white.withValues(alpha: .55),
                fontSize: 7.2,
                height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _lightSection({
    required String eyebrow,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.fromLTRB(13, 14, 13, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            eyebrow,
            style: const TextStyle(
                color: _blue,
                fontSize: 7.5,
                fontWeight: FontWeight.w900,
                letterSpacing: .6),
          ),
          const SizedBox(height: 5),
          Text(title,
              style: const TextStyle(
                  color: _text, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          Text(subtitle,
              style: const TextStyle(color: _muted, fontSize: 8, height: 1.35)),
          const SizedBox(height: 13),
          child,
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return SafeArea(
      top: false,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 7),
        child: SizedBox(
          height: 58,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _dashboardTabs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 5),
            itemBuilder: (BuildContext context, int index) {
              final _DashboardTab tab = _dashboardTabs[index];
              final bool selected = index == _selectedDashboardTab;
              return InkWell(
                onTap: () {
                  if (_selectedDashboardTab == index) return;
                  setState(() {
                    _selectedDashboardTab = index;
                    if (index == 3) {
                      _allCompaniesSector = null;
                      _allCompaniesCap = null;
                      _allCompaniesNavigationVersion += 1;
                    }
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: index == 1 ? 156 : 128,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? _blue : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: selected ? _blue : _border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(tab.icon,
                          size: 16, color: selected ? Colors.white : _muted),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          tab.label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: selected ? Colors.white : _muted,
                            fontSize: 9.5,
                            height: 1.05,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: .12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 12, color: _Q1FY27PageState._amber),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 8,
                fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _DashboardTab {
  const _DashboardTab(this.label, this.icon);
  final String label;
  final IconData icon;
}

class _Q1LoadingState extends StatelessWidget {
  const _Q1LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CircularProgressIndicator(),
          SizedBox(height: 14),
          Text('Loading Q1 FY27 real data...'),
        ],
      ),
    );
  }
}

class _Q1ErrorState extends StatelessWidget {
  const _Q1ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE4E7EC)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.cloud_off_rounded,
                  size: 42, color: Color(0xFFF04438)),
              const SizedBox(height: 12),
              const Text(
                'Unable to load Q1 FY27 data',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 7),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color(0xFF667085), fontSize: 10, height: 1.4),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
