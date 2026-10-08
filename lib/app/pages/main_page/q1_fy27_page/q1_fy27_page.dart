import 'package:flutter/material.dart';
import 'package:webinar/config/colors.dart';
import 'macro_economic_sector/macro_economic_sector_page.dart';
import 'basic_industry/basic_industry_page.dart';
import 'all_companies/all_companies_page.dart';
import 'investor_insights/investor_insights_page.dart';
import 'thematic_baskets/thematic_baskets_page.dart';
import 'market_heatmap/q1_market_heatmap.dart';

class Q1FY27Page extends StatefulWidget {
  const Q1FY27Page({super.key});

  static const String pageName = '/q1-fy27';

  @override
  State<Q1FY27Page> createState() => _Q1FY27PageState();
}

class _Q1FY27PageState extends State<Q1FY27Page> {
  static const Color _navy = Color(0xFF0B1F4D);
  static const Color _navy2 = Color(0xFF15366F);
  static const Color _blue = Color(0xFF0D3CCF);
  static const Color _green = Color(0xFF12B76A);
  static const Color _greenDark = Color(0xFF067647);
  static const Color _red = Color(0xFFF04438);
  static const Color _amber = Color(0xFFF6C344);
  static const Color _purple = Color(0xFF7A5AF8);
  static const Color _text = Color(0xFF101828);
  static const Color _muted = Color(0xFF667085);
  static const Color _border = Color(0xFFE4E7EC);
  static const Color _surface = Color(0xFFF5F7FB);

  int _selectedDashboardTab = 0;

  int? _swipePointer;
  Offset? _swipeStartPosition;
  DateTime? _swipeStartTime;

  static const List<_DashboardTab> _dashboardTabs = <_DashboardTab>[
    _DashboardTab('Market Heatmap', Icons.grid_view_rounded),
    _DashboardTab('Macro-Economic Sector', Icons.bar_chart_rounded),
    _DashboardTab('Basic Industry', Icons.factory_outlined),
    _DashboardTab('All Companies', Icons.business_rounded),
    _DashboardTab('Investor Insights', Icons.insights_rounded),
    _DashboardTab('Thematic Baskets', Icons.layers_rounded),
  ];

  static const List<_PulseCardData> _pulseCards = <_PulseCardData>[
    _PulseCardData(
      title: 'NIFTY 50',
      marketCap: '₹189.27 L Cr',
      salesGrowth: 17.73,
      profitGrowth: 6.08,
      sales: '₹27,08,010 Cr',
      profit: '₹2,57,756 Cr',
      margin: '9.52%',
      marginDelta: '-1.05 pp',
    ),
    _PulseCardData(
      title: 'LARGE CAP',
      marketCap: '₹250.05 L Cr',
      salesGrowth: 16.64,
      profitGrowth: 10.44,
      sales: '₹33,56,610 Cr',
      profit: '₹3,20,201 Cr',
      margin: '9.80%',
      marginDelta: '-0.55 pp',
    ),
    _PulseCardData(
      title: 'MID CAP',
      marketCap: '₹86.66 L Cr',
      salesGrowth: 18.21,
      profitGrowth: -2.19,
      sales: '₹10,88,723 Cr',
      profit: '₹86,243 Cr',
      margin: '7.92%',
      marginDelta: '-1.65 pp',
    ),
    _PulseCardData(
      title: 'SMALL CAP',
      marketCap: '₹46.07 L Cr',
      salesGrowth: 24.16,
      profitGrowth: 38.98,
      sales: '₹5,56,895 Cr',
      profit: '₹47,822 Cr',
      margin: '8.59%',
      marginDelta: '+0.92 pp',
    ),
    _PulseCardData(
      title: 'MICRO CAP',
      marketCap: '₹20.13 L Cr',
      salesGrowth: 18.35,
      profitGrowth: 35.09,
      sales: '₹3,18,250 Cr',
      profit: '₹31,919 Cr',
      margin: '10.03%',
      marginDelta: '+1.24 pp',
    ),
    _PulseCardData(
      title: 'ALL CAP',
      marketCap: '₹414.73 L Cr',
      salesGrowth: 17.72,
      profitGrowth: 11.44,
      sales: '₹56,01,923 Cr',
      profit: '₹5,13,431 Cr',
      margin: '9.17%',
      marginDelta: '-0.52 pp',
    ),
  ];

  static const List<_BreadthData> _breadth = <_BreadthData>[
    _BreadthData('90%', 'Grew sales', '951 of 1,054 companies', _blue),
    _BreadthData('69%', 'Grew profit', '724 of 1,053 companies', _green),
    _BreadthData(
        '57%', 'Expanded margins', '599 of 1,054 companies', Color(0xFFD4A80B)),
    _BreadthData(
        '66%', 'Grew sales & profit', '695 of 1,053 companies', _purple),
  ];

  static const List<_DistributionData> _distribution = <_DistributionData>[
    _DistributionData('< -50%', 116, Color(0xFFB42318)),
    _DistributionData('-50—-20%', 86, Color(0xFFD92D20)),
    _DistributionData('-20—0%', 84, Color(0xFFF97066)),
    _DistributionData('0—20%', 219, Color(0xFF6CE9A6)),
    _DistributionData('20—50%', 229, Color(0xFF12B76A)),
    _DistributionData('50—100%', 119, Color(0xFF079455)),
    _DistributionData('> 100%', 143, Color(0xFF067647)),
  ];

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
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: _handleSwipePointerDown,
          onPointerUp: _handleSwipePointerUp,
          onPointerCancel: _handleSwipePointerCancel,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: KeyedSubtree(
              key: ValueKey<int>(_selectedDashboardTab),
              child: _selectedDashboardTab == 0
                  ? _buildMarketHeatmapPage()
                  : _selectedDashboardTab == 1
                      ? MacroEconomicSectorPage(
                          onNavigateToAllCompanies: () {
                            setState(() {
                              _selectedDashboardTab = 3;
                            });
                          },
                        )
                      : _selectedDashboardTab == 2
                          ? const BasicIndustryPage()
                          : _selectedDashboardTab == 3
                              ? const AllCompaniesPage()
                              : _selectedDashboardTab == 4
                                  ? const InvestorInsightsPage()
                                  : _selectedDashboardTab == 5
                                      ? const ThematicBasketsPage()
                                      : _buildComingSoonTab(
                                          _dashboardTabs[_selectedDashboardTab],
                                        ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  void _handleSwipePointerDown(PointerDownEvent event) {
    // Track only one finger at a time.
    if (_swipePointer != null) {
      return;
    }

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

    final double horizontalVelocity = (delta.dx / elapsedMs) * 1000;

    _resetSwipeTracking();

    // A swipe must be clearly horizontal, not a diagonal/vertical scroll.
    final bool clearlyHorizontal = horizontalDistance > verticalDistance * 1.35;

    // Normal swipes should work even when they are not extremely fast.
    // Requiring either enough distance OR enough velocity also avoids
    // accidental page changes from small horizontal movements.
    final bool intentionalSwipe = horizontalDistance >= 70 ||
        (horizontalDistance >= 42 && horizontalVelocity.abs() >= 420);

    if (!clearlyHorizontal || !intentionalSwipe) {
      return;
    }

    if (delta.dx < 0) {
      // Swipe LEFT -> NEXT page.
      _goToNextDashboardTab();
    } else {
      // Swipe RIGHT -> PREVIOUS page.
      _goToPreviousDashboardTab();
    }
  }

  void _handleSwipePointerCancel(PointerCancelEvent event) {
    if (_swipePointer == event.pointer) {
      _resetSwipeTracking();
    }
  }

  void _resetSwipeTracking() {
    _swipePointer = null;
    _swipeStartPosition = null;
    _swipeStartTime = null;
  }

  void _goToNextDashboardTab() {
    if (_selectedDashboardTab >= _dashboardTabs.length - 1) {
      return;
    }

    setState(() {
      _selectedDashboardTab += 1;
    });
  }

  void _goToPreviousDashboardTab() {
    if (_selectedDashboardTab <= 0) {
      return;
    }

    setState(() {
      _selectedDashboardTab -= 1;
    });
  }

  Widget _buildMarketHeatmapPage() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: <Widget>[
        _heroSection(),
        const SizedBox(height: 14),
        _marketPulseSection(),
        const SizedBox(height: 14),
        _earningsBreadthSection(),
        const SizedBox(height: 14),
        _distributionSection(),
        const SizedBox(height: 14),
        const Q1MarketHeatmap(),
        const SizedBox(height: 14),
        _researchEducationCard(),
      ],
    );
  }

  Widget _growthBar({
    required double value,
    required Color color,
    required String label,
  }) {
    return Row(
      children: <Widget>[
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              children: <Widget>[
                const SizedBox(
                  height: 7,
                  width: double.infinity,
                  child: ColoredBox(color: Color(0xFFEAECF0)),
                ),
                FractionallySizedBox(
                  widthFactor: value < .02 ? .02 : value,
                  child: Container(
                    height: 7,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 45,
          child: Text(
            label,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: color,
              fontSize: 7,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _healthMetric({
    required String label,
    required double value,
    required Color color,
  }) {
    final double width = (value.abs().clamp(0, 75).toDouble()) / 75;

    return Row(
      children: <Widget>[
        SizedBox(
          width: 34,
          child: Text(
            label,
            style: const TextStyle(
              color: _muted,
              fontSize: 7.5,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              children: <Widget>[
                const SizedBox(
                  width: double.infinity,
                  height: 5,
                  child: ColoredBox(color: Color(0xFFE4E7EC)),
                ),
                FractionallySizedBox(
                  widthFactor: width < .02 ? .02 : width,
                  child: Container(
                    height: 5,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 48,
          child: Text(
            '${value >= 0 ? '+' : ''}${value.toStringAsFixed(2)}%',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: value >= 0 ? _greenDark : _red,
              fontSize: 7.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _heroSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[
            Color(0xFF071B47),
            Color(0xFF102F6B),
            Color(0xFF162F60),
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
          Row(
            children: <Widget>[
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: _amber,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              const Text(
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
          RichText(
            text: const TextSpan(
              children: <InlineSpan>[
                TextSpan(
                  text: 'Q1 FY27 Earnings Dashboard: ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    height: 1.08,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: 'Nifty All-Cap\n',
                  style: TextStyle(
                    color: _amber,
                    fontSize: 23,
                    height: 1.08,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                TextSpan(
                  text: 'Results Analysis',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    height: 1.08,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
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
            children: const <Widget>[
              _HeroChip(icon: Icons.business_rounded, text: '1,117 Companies'),
              _HeroChip(icon: Icons.category_rounded, text: '12 Sectors'),
              _HeroChip(icon: Icons.folder_rounded, text: '159 Industries'),
              _HeroChip(icon: Icons.hub_rounded, text: '7 Thematic Baskets'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _marketPulseSection() {
    return _lightSection(
      eyebrow: 'MARKET PULSE',
      title: 'Q1 FY27 in one screen',
      subtitle: 'NIFTY ALLCAP Q1 FY27 workbook • ₹ crore',
      child: GridView.builder(
        itemCount: _pulseCards.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 9,
          mainAxisSpacing: 9,
          // A little extra vertical room is required on smaller Android
          // devices so the Sales/Profit/Margin lines and CTA never overflow.
          mainAxisExtent: 190,
        ),
        itemBuilder: (BuildContext context, int index) {
          return _pulseCard(_pulseCards[index]);
        },
      ),
    );
  }

  Widget _pulseCard(_PulseCardData item) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          setState(() {
            _selectedDashboardTab = 3;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[
                Color(0xFF1C376C),
                Color(0xFF18315F),
              ],
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
                      item.title,
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
                    child: const Text(
                      'Q1 FY27',
                      style: TextStyle(
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
                item.marketCap,
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
                  Expanded(
                    child: _growthMetric('SALES GR.', item.salesGrowth),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: _growthMetric('PROFIT GR.', item.profitGrowth),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Divider(
                height: 1,
                color: Colors.white.withValues(alpha: .13),
              ),
              const SizedBox(height: 7),
              Text(
                'Sales  ${item.sales}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 7.5,
                  height: 1.4,
                ),
              ),
              Text(
                'Profit  ${item.profit}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 7.5,
                  height: 1.4,
                ),
              ),
              Text(
                'Margin  ${item.margin}  •  ${item.marginDelta}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 7.5,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              const Row(
                children: <Widget>[
                  Text(
                    'View companies',
                    style: TextStyle(
                      color: _amber,
                      fontSize: 7.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(width: 3),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 10,
                    color: _amber,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            '${positive ? '+' : ''}${value.toStringAsFixed(2)}%',
            style: TextStyle(
              color: color,
              fontSize: 7.2,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _earningsBreadthSection() {
    return _lightSection(
      eyebrow: 'EARNINGS BREADTH',
      title: 'How broad were Q1 FY27 earnings?',
      subtitle: 'Share of All-Cap companies reporting growth.',
      child: GridView.builder(
        itemCount: _breadth.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 9,
          mainAxisSpacing: 9,
          mainAxisExtent: 94,
        ),
        itemBuilder: (BuildContext context, int index) {
          final _BreadthData item = _breadth[index];
          return Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x08101828),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
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
                          value: double.parse(item.value.replaceAll('%', '')) /
                              100,
                          strokeWidth: 5,
                          backgroundColor: const Color(0xFFEAECF0),
                          valueColor: AlwaysStoppedAnimation<Color>(item.color),
                        ),
                      ),
                      Text(
                        item.value,
                        style: const TextStyle(
                          color: _text,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
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
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.note,
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 7,
                          height: 1.25,
                        ),
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

  Widget _distributionSection() {
    final double maxValue = _distribution
        .map((_DistributionData e) => e.value.toDouble())
        .reduce((double a, double b) => a > b ? a : b);

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
              color: _text,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Companies by YoY profit growth • click a bar to list them',
            style: TextStyle(
              color: _muted,
              fontSize: 8,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 145,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _distribution.map((_DistributionData item) {
                final double h = (item.value / maxValue) * 98;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          '${item.value}',
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 6.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          height: h,
                          decoration: BoxDecoration(
                            color: item.color,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          item.label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 5.8,
                            height: 1.05,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _researchEducationCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[
            Color(0xFF071B47),
            Color(0xFF15366F),
          ],
        ),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Research & Education Dashboard',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'This dashboard visualises the NIFTY All-Cap Q1 FY27 earnings workbook for investor education and research. It is not a stock tip, trading call, personalised investment recommendation or assurance of returns.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: .72),
              fontSize: 8.5,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Source',
            style: TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'NIFTY ALLCAP Q1 FY27 workbook',
            style: TextStyle(
              color: Colors.white.withValues(alpha: .65),
              fontSize: 8,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Coverage',
            style: TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '1,117 companies • 12 sectors • 159 industries',
            style: TextStyle(
              color: Colors.white.withValues(alpha: .65),
              fontSize: 8,
            ),
          ),
          const SizedBox(height: 11),
          Text(
            'Profit Finstock Pvt. Ltd. | SEBI Registered Investment Adviser – INA000020651\nEducational purposes only. Not investment advice.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: .55),
              fontSize: 7.2,
              height: 1.45,
            ),
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
              letterSpacing: .6,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              color: _text,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(
              color: _muted,
              fontSize: 8,
              height: 1.35,
            ),
          ),
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
                  setState(() => _selectedDashboardTab = index);
                },
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: index == 1 ? 156 : 128,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? _blue : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? _blue : _border,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        tab.icon,
                        size: 16,
                        color: selected ? Colors.white : _muted,
                      ),
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

  Widget _buildComingSoonTab(_DashboardTab tab) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4FF),
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: Icon(tab.icon, color: _blue, size: 30),
              ),
              const SizedBox(height: 15),
              Text(
                tab.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _text,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Send the website design for this section and we will build it here without changing the completed Market Heatmap page.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _muted,
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: .12),
        ),
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
              fontWeight: FontWeight.w700,
            ),
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

class _PulseCardData {
  const _PulseCardData({
    required this.title,
    required this.marketCap,
    required this.salesGrowth,
    required this.profitGrowth,
    required this.sales,
    required this.profit,
    required this.margin,
    required this.marginDelta,
  });

  final String title;
  final String marketCap;
  final double salesGrowth;
  final double profitGrowth;
  final String sales;
  final String profit;
  final String margin;
  final String marginDelta;
}

class _BreadthData {
  const _BreadthData(this.value, this.title, this.note, this.color);

  final String value;
  final String title;
  final String note;
  final Color color;
}

class _DistributionData {
  const _DistributionData(this.label, this.value, this.color);

  final String label;
  final int value;
  final Color color;
}
