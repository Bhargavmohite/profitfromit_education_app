import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class Q1MarketHeatmap extends StatefulWidget {
  const Q1MarketHeatmap({super.key});

  @override
  State<Q1MarketHeatmap> createState() => _Q1MarketHeatmapState();
}

class _Q1MarketHeatmapState extends State<Q1MarketHeatmap> {
  static const Color _navy = Color(0xFF0B1F4D);
  static const Color _blue = Color(0xFF0D3CCF);
  static const Color _navyHeader = Color(0xFF102A5A);
  static const Color _amber = Color(0xFFF6C344);
  static const Color _neutral = Color(0xFF475467);
  static const Color _green = Color(0xFF067647);
  static const Color _red = Color(0xFFB42318);

  static const List<_HeatCompany> _companies = <_HeatCompany>[
    _HeatCompany('HDFCBANK', 'Financial Services', 18.37, 10),
    _HeatCompany('ICICIBANK', 'Financial Services', 13.88, 9),
    _HeatCompany('SBIN', 'Financial Services', 13.65, 8),
    _HeatCompany('KOTAK', 'Financial Services', 22.54, 6),
    _HeatCompany(
      'TATACAP',
      'Financial Services',
      56.39,
      4.2,
      name: 'Tata Capital Limited',
      bseCode: '544574',
      industry: 'Non Banking Financial Company (NBFC)',
      price: '₹327.50',
      marketCap: '₹1.38 L Cr',
      allCapWeight: '0.333%',
      industryRank: '#2',
      industryCount: '24',
      salesFY26: '₹7,692 Cr',
      salesFY27: '₹8,825 Cr',
      salesGrowth: 14.73,
      netProfitFY26: '₹1,041 Cr',
      netProfitFY27: '₹1,628 Cr',
      marginFY26: '13.53%',
      marginFY27: '18.45%',
      marginDelta: 4.91,
    ),
    _HeatCompany('AXISBANK', 'Financial Services', 22.32, 6),
    _HeatCompany('BAJFIN', 'Financial Services', -18.16, 4),
    _HeatCompany('LICI', 'Financial Services', 23.98, 4),
    _HeatCompany('PFC', 'Financial Services', 0.33, 3),
    _HeatCompany('SHRIRAMFIN', 'Financial Services', 59.89, 3),
    _HeatCompany('UNIONBANK', 'Financial Services', 27.39, 2),
    _HeatCompany('BSE', 'Financial Services', 65.97, 2),
    _HeatCompany('PNB', 'Financial Services', 91.43, 2),
    _HeatCompany('TITAN', 'Consumer Discretionary', 62.88, 7),
    _HeatCompany('BAJAJ-AUTO', 'Consumer Discretionary', 44.30, 5),
    _HeatCompany('MARUTI', 'Consumer Discretionary', -9.03, 7),
    _HeatCompany('M&M', 'Consumer Discretionary', 37.03, 6),
    _HeatCompany('ETERNAL', 'Consumer Discretionary', 26.80, 5),
    _HeatCompany('DMART', 'Consumer Discretionary', 11.25, 4),
    _HeatCompany('EICHERMOT', 'Consumer Discretionary', 21.41, 3),
    _HeatCompany('TVSMOTOR', 'Consumer Discretionary', 64.54, 3),
    _HeatCompany('LT', 'Industrials', 15.19, 10),
    _HeatCompany('HAL', 'Industrials', 14.88, 8),
    _HeatCompany('BEL', 'Industrials', 8.77, 7),
    _HeatCompany('BHEL', 'Industrials', -18.26, 4),
    _HeatCompany('ABB', 'Industrials', 2.84, 4),
    _HeatCompany('CUMMINS', 'Industrials', 6.32, 3),
    _HeatCompany('SIEMENS', 'Industrials', 35.16, 3),
    _HeatCompany('POLYCAB', 'Industrials', 22.31, 3),
    _HeatCompany('ADANIENT', 'Commodities', -249.69, 8),
    _HeatCompany('ULTRACEMCO', 'Commodities', 17.24, 6),
    _HeatCompany('JSWSTEEL', 'Commodities', 112.58, 6),
    _HeatCompany('HINDZINC', 'Commodities', 144.81, 5),
    _HeatCompany('GRASIM', 'Commodities', 38.79, 5),
    _HeatCompany('TATASTEEL', 'Commodities', -14.60, 4),
    _HeatCompany('SUNPHARMA', 'Healthcare', 26.40, 9),
    _HeatCompany('DIVISLAB', 'Healthcare', 65.50, 5),
    _HeatCompany('DRREDDY', 'Healthcare', 3.28, 5),
    _HeatCompany('CIPLA', 'Healthcare', -39.16, 4),
    _HeatCompany('LUPIN', 'Healthcare', 16.05, 4),
    _HeatCompany('APOLLOHOSP', 'Healthcare', 13.32, 3),
    _HeatCompany('TCS', 'Information Technology', 4.69, 10),
    _HeatCompany('HCLTECH', 'Information Technology', 20.34, 7),
    _HeatCompany('INFY', 'Information Technology', 12.29, 8),
    _HeatCompany('TECHM', 'Information Technology', 31.62, 4),
    _HeatCompany('LTIM', 'Information Technology', 17.05, 4),
    _HeatCompany('WIPRO', 'Information Technology', 0.60, 4),
    _HeatCompany('RELIANCE', 'Energy', -15.00, 16),
    _HeatCompany('ONGC', 'Energy', -43.26, 7),
    _HeatCompany('COALINDIA', 'Energy', 0.71, 6),
    _HeatCompany('GAIL', 'Energy', 96.10, 4),
    _HeatCompany('IOC', 'Energy', -18.06, 4),
    _HeatCompany('OIL', 'Energy', 16.71, 3),
    _HeatCompany('NTPC', 'Utilities', 12.00, 7),
    _HeatCompany('POWERGRID', 'Utilities', -0.91, 6),
    _HeatCompany('ADANIPOWER', 'Utilities', 10.74, 3),
    _HeatCompany('TATAPOWER', 'Utilities', 10.31, 3),
    _HeatCompany('BHARTIARTL', 'Telecommunication', 34.90, 13),
    _HeatCompany('IDEA', 'Telecommunication', -43.81, 3),
    _HeatCompany('ITC', 'Fast Moving Consumer Goods', -17.57, 8),
    _HeatCompany('NESTLEIND', 'Fast Moving Consumer Goods', 48.45, 6),
    _HeatCompany('HINDUNILVR', 'Fast Moving Consumer Goods', -3.18, 7),
    _HeatCompany('MARICO', 'Fast Moving Consumer Goods', 27.10, 3),
    _HeatCompany('ADANIPORTS', 'Services', 10.21, 6),
    _HeatCompany('INDIGO', 'Services', -10.04, 5),
    _HeatCompany('GMRAIRPORT', 'Services', 7.35, 3),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _navy,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x1F0B1F4D),
            blurRadius: 18,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Market Heatmap',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: TextStyle(
                color: Colors.white.withValues(alpha: .72),
                fontSize: 8.5,
                height: 1.4,
              ),
              children: const <InlineSpan>[
                TextSpan(text: 'Every company is sized by '),
                TextSpan(
                  text: 'market cap',
                  style: TextStyle(
                    color: _amber,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(text: ', grouped by sector and coloured by '),
                TextSpan(
                  text: 'profit growth',
                  style: TextStyle(
                    color: _amber,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(text: '. Tap any tile for details.'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _controls(context),
          const SizedBox(height: 10),
          _scale(),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double height =
                  (constraints.maxWidth * 1.16).clamp(455.0, 620.0).toDouble();

              return SizedBox(
                width: double.infinity,
                height: height,
                child: _SectorTreemap(
                  companies: _companies,
                  colorForValue: _colorForValue,
                  onCompanyTap: (_HeatCompany company) =>
                      _showCompany(context, company),
                ),
              );
            },
          ),
          const SizedBox(height: 9),
          Text(
            'Profit Growth and Market-Cap sizing are active in this design-reference version. '
            'Sales Growth, Margin Δ and Sales sizing will activate when the Q1 FY27 API is connected.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: .48),
              fontSize: 7,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _controls(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 10,
      children: <Widget>[
        _controlGroup(
          label: 'COLOUR BY',
          children: <Widget>[
            _choice(context, 'Profit Gr.', true),
            _choice(context, 'Sales Gr.', false),
            _choice(context, 'Margin Δ', false),
          ],
        ),
        _controlGroup(
          label: 'SIZE BY',
          children: <Widget>[
            _choice(context, 'M-Cap', true),
            _choice(context, 'Sales', false),
          ],
        ),
      ],
    );
  }

  Widget _controlGroup({
    required String label,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 7,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Wrap(spacing: 6, runSpacing: 6, children: children),
      ],
    );
  }

  Widget _choice(BuildContext context, String label, bool enabled) {
    return GestureDetector(
      onTap: enabled
          ? null
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'This heatmap metric will activate when the Q1 FY27 API is connected.',
                  ),
                  duration: Duration(seconds: 2),
                ),
              );
            },
      child: Opacity(
        opacity: enabled ? 1 : .55,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            color: enabled ? Colors.white : Colors.white.withValues(alpha: .06),
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color:
                  enabled ? Colors.white : Colors.white.withValues(alpha: .15),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                label,
                style: TextStyle(
                  color: enabled ? _navy : Colors.white70,
                  fontSize: 7.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (!enabled) ...<Widget>[
                const SizedBox(width: 4),
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 9,
                  color: Colors.white54,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _scale() {
    return Row(
      children: <Widget>[
        const Text(
          '-50%',
          style: TextStyle(color: Colors.white54, fontSize: 7),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Container(
            height: 7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: const LinearGradient(
                colors: <Color>[
                  Color(0xFFB42318),
                  Color(0xFFD92D20),
                  Color(0xFF475467),
                  Color(0xFF079455),
                  Color(0xFF067647),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 7),
        const Text(
          '+50%',
          style: TextStyle(color: Colors.white54, fontSize: 7),
        ),
      ],
    );
  }

  Color _colorForValue(double value) {
    final double clamped = value.clamp(-50.0, 50.0).toDouble();

    if (clamped.abs() < 1) {
      return _neutral;
    }

    if (clamped > 0) {
      return Color.lerp(
            const Color(0xFF356B56),
            _green,
            clamped / 50,
          ) ??
          _green;
    }

    return Color.lerp(
          const Color(0xFF76505A),
          _red,
          clamped.abs() / 50,
        ) ??
        _red;
  }

  void _showCompany(BuildContext context, _HeatCompany company) {
    final List<_HeatCompany> peers = _companies
        .where(
          (_HeatCompany item) =>
              item.sector == company.sector && item.symbol != company.symbol,
        )
        .toList()
      ..sort(
        (_HeatCompany a, _HeatCompany b) => b.weight.compareTo(a.weight),
      );

    final Color metricColor = _colorForValue(company.profitGrowth);

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .48),
      builder: (BuildContext dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 20,
          ),
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 660,
              maxHeight: 760,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFE2B93B),
                  width: 1.2,
                ),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x2B101828),
                    blurRadius: 28,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 13, 9, 11),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text(
                                'Q1 FY27 COMPANY SCORECARD',
                                style: TextStyle(
                                  color: _blue,
                                  fontSize: 7.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: .8,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                company.displayName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: _navy,
                                  fontSize: 18,
                                  height: 1.1,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'NSE: ${company.symbol}'
                                '${company.bseCode == null ? '' : ' · BSE: ${company.bseCode}'}',
                                style: const TextStyle(
                                  color: Color(0xFF667085),
                                  fontSize: 8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close',
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          icon: const Icon(Icons.close_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFF2F4F7),
                            foregroundColor: _navy,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 1,
                    color: Color(0xFFE4E7EC),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        13,
                        16,
                        18,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: <Widget>[
                              _scoreTag(
                                Icons.layers_rounded,
                                company.sector,
                              ),
                              if (company.industry != null)
                                _scoreTag(
                                  Icons.factory_outlined,
                                  company.industry!,
                                ),
                              _scoreTag(
                                Icons.bar_chart_rounded,
                                'Relative M-Cap ${company.weight.toStringAsFixed(1)}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LayoutBuilder(
                            builder: (
                              BuildContext context,
                              BoxConstraints constraints,
                            ) {
                              final int count =
                                  constraints.maxWidth >= 520 ? 4 : 2;

                              return GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: count,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio:
                                    constraints.maxWidth >= 520 ? 1.85 : 1.9,
                                children: <Widget>[
                                  _summaryCard(
                                    'PRICE',
                                    company.price ?? '—',
                                  ),
                                  _summaryCard(
                                    'MARKET CAP',
                                    company.marketCap ?? '—',
                                  ),
                                  _summaryCard(
                                    'ALL-CAP WEIGHT',
                                    company.allCapWeight ?? '—',
                                  ),
                                  _summaryCard(
                                    'INDUSTRY RANK',
                                    company.industryRank == null
                                        ? '—'
                                        : '${company.industryRank}'
                                            '${company.industryCount == null ? '' : ' of ${company.industryCount}'}',
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 14),
                          _metricTable(company, metricColor),
                          const SizedBox(height: 14),
                          const Text(
                            'Sector peers by relative market-cap size',
                            style: TextStyle(
                              color: Color(0xFF344054),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          LayoutBuilder(
                            builder: (
                              BuildContext context,
                              BoxConstraints constraints,
                            ) {
                              final bool twoColumns =
                                  constraints.maxWidth >= 500;
                              final double itemWidth = twoColumns
                                  ? (constraints.maxWidth - 7) / 2
                                  : constraints.maxWidth;

                              return Wrap(
                                spacing: 7,
                                runSpacing: 7,
                                children: peers.take(6).map(
                                  (_HeatCompany peer) {
                                    return SizedBox(
                                      width: itemWidth,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 9,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: const Color(0xFFE4E7EC),
                                          ),
                                        ),
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                peer.displayName,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Color(0xFF101828),
                                                  fontSize: 7.7,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 7),
                                            _growthBadge(
                                              peer.profitGrowth,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ).toList(),
                              );
                            },
                          ),
                          const SizedBox(height: 14),
                          const Divider(
                            height: 1,
                            color: Color(0xFFE4E7EC),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: <Widget>[
                              _actionChip(
                                Icons.search_rounded,
                                'Screener',
                                context,
                              ),
                              _actionChip(
                                Icons.account_balance_outlined,
                                'NSE',
                                context,
                              ),
                              _actionChip(
                                Icons.account_balance_outlined,
                                'BSE',
                                context,
                              ),
                              _actionChip(
                                Icons.show_chart_rounded,
                                'Chart',
                                context,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _scoreTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 11, color: const Color(0xFF475467)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF475467),
                fontSize: 7.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF667085),
              fontSize: 7,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF101828),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricTable(_HeatCompany company, Color metricColor) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE4E7EC)),
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          Container(
            color: const Color(0xFFF8FAFC),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: const Row(
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: Text(
                    'METRIC',
                    style: TextStyle(
                      color: Color(0xFF667085),
                      fontSize: 7,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Q1 FY26',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Color(0xFF667085),
                      fontSize: 7,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Q1 FY27',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Color(0xFF667085),
                      fontSize: 7,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'YOY',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Color(0xFF667085),
                      fontSize: 7,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _metricRow(
            'Sales',
            company.salesFY26 ?? '—',
            company.salesFY27 ?? '—',
            company.salesGrowth == null
                ? '—'
                : '${company.salesGrowth! >= 0 ? '+' : ''}'
                    '${company.salesGrowth!.toStringAsFixed(2)}%',
            company.salesGrowth == null
                ? const Color(0xFF667085)
                : _colorForValue(company.salesGrowth!),
          ),
          _metricRow(
            'Net Profit',
            company.netProfitFY26 ?? '—',
            company.netProfitFY27 ?? '—',
            '${company.profitGrowth >= 0 ? '+' : ''}'
                '${company.profitGrowth.toStringAsFixed(2)}%',
            metricColor,
          ),
          _metricRow(
            'Profit Margin',
            company.marginFY26 ?? '—',
            company.marginFY27 ?? '—',
            company.marginDelta == null
                ? '—'
                : '${company.marginDelta! >= 0 ? '+' : ''}'
                    '${company.marginDelta!.toStringAsFixed(2)} pp',
            company.marginDelta == null
                ? const Color(0xFF667085)
                : _colorForValue(company.marginDelta!),
          ),
        ],
      ),
    );
  }

  Widget _metricRow(
    String label,
    String oldValue,
    String newValue,
    String change,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFE4E7EC)),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF101828),
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              oldValue,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF475467),
                fontSize: 8,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              newValue,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF101828),
                fontSize: 8,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: change == '—'
                  ? const Text(
                      '—',
                      style: TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 8,
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: .10),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        change,
                        style: TextStyle(
                          color: color,
                          fontSize: 7.2,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _growthBadge(double value) {
    final Color color = _colorForValue(value);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '${value >= 0 ? '+' : ''}${value.toStringAsFixed(2)}%',
        style: TextStyle(
          color: color,
          fontSize: 7.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _actionChip(
    IconData icon,
    String label,
    BuildContext context,
  ) {
    return OutlinedButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$label link will be connected with the live company backend.',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      icon: Icon(icon, size: 14),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: _navy,
        textStyle: const TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.w800,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
    );
  }
}

class _SectorTreemap extends StatelessWidget {
  const _SectorTreemap({
    required this.companies,
    required this.colorForValue,
    required this.onCompanyTap,
  });

  final List<_HeatCompany> companies;
  final Color Function(double) colorForValue;
  final ValueChanged<_HeatCompany> onCompanyTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Rect bounds = Rect.fromLTWH(
          0,
          0,
          math.max(1, constraints.maxWidth),
          math.max(1, constraints.maxHeight),
        );

        final Map<String, List<_HeatCompany>> grouped =
            <String, List<_HeatCompany>>{};

        for (final _HeatCompany company in companies) {
          grouped.putIfAbsent(company.sector, () => <_HeatCompany>[]);
          grouped[company.sector]!.add(company);
        }

        final List<_Weighted<_SectorGroup>> sectors =
            grouped.entries.map((entry) {
          final double weight = entry.value.fold<double>(
            0,
            (double sum, _HeatCompany company) => sum + company.weight,
          );
          return _Weighted<_SectorGroup>(
            _SectorGroup(entry.key, entry.value),
            weight,
          );
        }).toList();

        final List<_TreemapTile<_SectorGroup>> sectorTiles =
            _TreemapLayout.layout<_SectorGroup>(sectors, bounds);

        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: sectorTiles.map((tile) {
              return Positioned.fromRect(
                rect: tile.rect,
                child: Padding(
                  padding: const EdgeInsets.all(1),
                  child: _SectorTile(
                    group: tile.item,
                    colorForValue: colorForValue,
                    onCompanyTap: onCompanyTap,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _SectorTile extends StatelessWidget {
  const _SectorTile({
    required this.group,
    required this.colorForValue,
    required this.onCompanyTap,
  });

  final _SectorGroup group;
  final Color Function(double) colorForValue;
  final ValueChanged<_HeatCompany> onCompanyTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double headerHeight = constraints.maxHeight < 55 ? 12 : 17;

        // BoxDecoration's 1 px border contributes 1 px of internal
        // padding on every side. Account for the 2 vertical/horizontal
        // pixels before laying out the fixed-height Column children.
        const double borderSpace = 2;
        final double innerWidth =
            math.max(1, constraints.maxWidth - borderSpace);
        final double bodyHeight = math.max(
          1,
          constraints.maxHeight - headerHeight - borderSpace,
        );

        final List<_Weighted<_HeatCompany>> weighted = group.companies
            .map(
              (_HeatCompany company) => _Weighted<_HeatCompany>(
                company,
                company.weight,
              ),
            )
            .toList();

        final List<_TreemapTile<_HeatCompany>> tiles =
            _TreemapLayout.layout<_HeatCompany>(
          weighted,
          Rect.fromLTWH(
            0,
            0,
            innerWidth,
            bodyHeight,
          ),
        );

        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF38517F)),
            color: const Color(0xFF071B47),
          ),
          child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                height: headerHeight,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                color: _Q1MarketHeatmapState._navyHeader,
                child: Text(
                  group.name.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: headerHeight < 15 ? 4.8 : 5.8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              SizedBox(
                height: bodyHeight,
                child: Stack(
                  children: tiles.map((tile) {
                    return Positioned.fromRect(
                      rect: tile.rect,
                      child: Padding(
                        padding: const EdgeInsets.all(.7),
                        child: _CompanyTile(
                          company: tile.item,
                          color: colorForValue(tile.item.profitGrowth),
                          onTap: () => onCompanyTap(tile.item),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CompanyTile extends StatefulWidget {
  const _CompanyTile({
    required this.company,
    required this.color,
    required this.onTap,
  });

  final _HeatCompany company;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_CompanyTile> createState() => _CompanyTileState();
}

class _CompanyTileState extends State<_CompanyTile> {
  OverlayEntry? _previewEntry;

  void _showPreview(Offset globalPosition) {
    _hidePreview();

    final OverlayState overlay = Overlay.of(context);
    final Size screen = MediaQuery.sizeOf(context);
    const double cardWidth = 285;
    const double cardHeight = 210;

    double left = globalPosition.dx + 10;
    double top = globalPosition.dy + 10;

    if (left + cardWidth > screen.width - 8) {
      left = math.max(8, globalPosition.dx - cardWidth - 10);
    }
    if (top + cardHeight > screen.height - 8) {
      top = math.max(8, globalPosition.dy - cardHeight - 10);
    }

    _previewEntry = OverlayEntry(
      builder: (BuildContext context) {
        return Positioned(
          left: left,
          top: top,
          width: cardWidth,
          child: IgnorePointer(
            child: Material(
              color: Colors.transparent,
              child: _CompanyPreviewCard(company: widget.company),
            ),
          ),
        );
      },
    );

    overlay.insert(_previewEntry!);
  }

  void _hidePreview() {
    _previewEntry?.remove();
    _previewEntry = null;
  }

  @override
  void dispose() {
    _hidePreview();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double w = constraints.maxWidth;
        final double h = constraints.maxHeight;
        final bool showSymbol = w >= 28 && h >= 19;
        final bool showValue = w >= 50 && h >= 34;
        final double fontSize = math.min(
          10,
          math.max(4.5, math.min(w / 8, h / 5.4)),
        );

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (PointerEnterEvent event) {
            _showPreview(event.position);
          },
          onHover: (PointerHoverEvent event) {
            if (_previewEntry == null) {
              _showPreview(event.position);
            }
          },
          onExit: (_) => _hidePreview(),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onLongPressStart: (LongPressStartDetails details) {
              _showPreview(details.globalPosition);
            },
            onLongPressEnd: (_) => _hidePreview(),
            child: Material(
              color: widget.color,
              child: InkWell(
                onTap: () {
                  _hidePreview();
                  widget.onTap();
                },
                child: Padding(
                  padding: EdgeInsets.all(w > 60 && h > 42 ? 4 : 2),
                  child: showSymbol
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              widget.company.symbol,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: fontSize,
                                height: 1,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            if (showValue) ...<Widget>[
                              const SizedBox(height: 2),
                              Text(
                                '${widget.company.profitGrowth >= 0 ? '+' : ''}'
                                '${widget.company.profitGrowth.toStringAsFixed(2)}%',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: .92),
                                  fontSize: math.max(4.4, fontSize - 1.2),
                                  height: 1,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ],
                        )
                      : const SizedBox.expand(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CompanyPreviewCard extends StatelessWidget {
  const _CompanyPreviewCard({required this.company});

  final _HeatCompany company;

  @override
  Widget build(BuildContext context) {
    final bool positive = company.profitGrowth >= 0;
    final Color growthColor =
        positive ? const Color(0xFF067647) : const Color(0xFFB42318);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .98),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD0D5DD)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            company.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF101828),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '${company.symbol}'
            '${company.bseCode == null ? '' : ' · ${company.bseCode}'}'
            '${company.industry == null ? '' : ' · ${company.industry}'}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF667085),
              fontSize: 8.5,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 9),
          _previewLine('Market cap', company.marketCap ?? '—'),
          _previewLine('Sales Q1 FY27', company.salesFY27 ?? '—'),
          _previewLine(
            'Sales growth',
            company.salesGrowth == null
                ? '—'
                : '${company.salesGrowth! >= 0 ? '+' : ''}'
                    '${company.salesGrowth!.toStringAsFixed(2)}%',
            badge: company.salesGrowth,
          ),
          _previewLine(
            'Profit growth',
            '${company.profitGrowth >= 0 ? '+' : ''}'
                '${company.profitGrowth.toStringAsFixed(2)}%',
            valueColor: growthColor,
            badge: company.profitGrowth,
          ),
          _previewLine(
            'Margin',
            company.marginFY27 ??
                (company.marginDelta == null
                    ? '—'
                    : '${company.marginDelta! >= 0 ? '+' : ''}'
                        '${company.marginDelta!.toStringAsFixed(2)} pp'),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tap for full scorecard · Press & hold to preview on mobile',
            style: TextStyle(
              color: Color(0xFF98A2B3),
              fontSize: 6.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _previewLine(
    String label,
    String value, {
    Color? valueColor,
    double? badge,
  }) {
    final Color color = badge == null
        ? (valueColor ?? const Color(0xFF101828))
        : badge >= 0
            ? const Color(0xFF067647)
            : const Color(0xFFB42318);

    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF667085),
                fontSize: 8.5,
              ),
            ),
          ),
          if (badge == null)
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 8.8,
                fontWeight: FontWeight.w800,
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 7.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TreemapLayout {
  static List<_TreemapTile<T>> layout<T>(
    List<_Weighted<T>> source,
    Rect bounds,
  ) {
    if (source.isEmpty || bounds.width <= 0 || bounds.height <= 0) {
      return <_TreemapTile<T>>[];
    }

    final List<_Weighted<T>> clean =
        source.where((_Weighted<T> item) => item.weight > 0).toList()
          ..sort(
            (_Weighted<T> a, _Weighted<T> b) => b.weight.compareTo(a.weight),
          );

    final double totalWeight = clean.fold<double>(
      0,
      (double sum, _Weighted<T> item) => sum + item.weight,
    );

    if (totalWeight <= 0) {
      return <_TreemapTile<T>>[];
    }

    final double scale = (bounds.width * bounds.height) / totalWeight;

    final List<_AreaItem<T>> remaining = clean
        .map(
          (_Weighted<T> item) => _AreaItem<T>(
            item.item,
            item.weight * scale,
          ),
        )
        .toList();

    final List<_TreemapTile<T>> output = <_TreemapTile<T>>[];
    final List<_AreaItem<T>> row = <_AreaItem<T>>[];
    Rect rect = bounds;

    while (remaining.isNotEmpty && rect.width > 0 && rect.height > 0) {
      final _AreaItem<T> next = remaining.first;
      final double side = math.min(rect.width, rect.height);

      final List<_AreaItem<T>> candidate = <_AreaItem<T>>[
        ...row,
        next,
      ];

      if (row.isEmpty || _worst<T>(candidate, side) <= _worst<T>(row, side)) {
        row.add(next);
        remaining.removeAt(0);
      } else {
        rect = _placeRow<T>(row, rect, output);
        row.clear();
      }
    }

    if (row.isNotEmpty) {
      _placeRow<T>(row, rect, output);
    }

    return output;
  }

  static double _worst<T>(
    List<_AreaItem<T>> row,
    double side,
  ) {
    if (row.isEmpty || side <= 0) {
      return double.infinity;
    }

    final double sum = row.fold<double>(
      0,
      (double value, _AreaItem<T> item) => value + item.area,
    );
    final double maxArea =
        row.map((_AreaItem<T> item) => item.area).reduce(math.max);
    final double minArea =
        row.map((_AreaItem<T> item) => item.area).reduce(math.min);

    if (sum <= 0 || minArea <= 0) {
      return double.infinity;
    }

    final double side2 = side * side;
    final double sum2 = sum * sum;

    return math.max(
      (side2 * maxArea) / sum2,
      sum2 / (side2 * minArea),
    );
  }

  static Rect _placeRow<T>(
    List<_AreaItem<T>> row,
    Rect rect,
    List<_TreemapTile<T>> output,
  ) {
    if (row.isEmpty || rect.width <= 0 || rect.height <= 0) {
      return rect;
    }

    final double rowArea = row.fold<double>(
      0,
      (double sum, _AreaItem<T> item) => sum + item.area,
    );

    if (rect.width >= rect.height) {
      final double columnWidth =
          math.min(rect.width, rowArea / math.max(rect.height, .0001));
      double y = rect.top;

      for (int i = 0; i < row.length; i++) {
        final _AreaItem<T> item = row[i];
        final double height = i == row.length - 1
            ? rect.bottom - y
            : math.min(
                rect.bottom - y,
                item.area / math.max(columnWidth, .0001),
              );

        output.add(
          _TreemapTile<T>(
            item.item,
            Rect.fromLTWH(
              rect.left,
              y,
              math.max(0, columnWidth),
              math.max(0, height),
            ),
          ),
        );
        y += height;
      }

      return Rect.fromLTWH(
        rect.left + columnWidth,
        rect.top,
        math.max(0, rect.width - columnWidth),
        rect.height,
      );
    }

    final double rowHeight =
        math.min(rect.height, rowArea / math.max(rect.width, .0001));
    double x = rect.left;

    for (int i = 0; i < row.length; i++) {
      final _AreaItem<T> item = row[i];
      final double width = i == row.length - 1
          ? rect.right - x
          : math.min(
              rect.right - x,
              item.area / math.max(rowHeight, .0001),
            );

      output.add(
        _TreemapTile<T>(
          item.item,
          Rect.fromLTWH(
            x,
            rect.top,
            math.max(0, width),
            math.max(0, rowHeight),
          ),
        ),
      );
      x += width;
    }

    return Rect.fromLTWH(
      rect.left,
      rect.top + rowHeight,
      rect.width,
      math.max(0, rect.height - rowHeight),
    );
  }
}

class _HeatCompany {
  const _HeatCompany(
    this.symbol,
    this.sector,
    this.profitGrowth,
    this.weight, {
    this.name,
    this.bseCode,
    this.industry,
    this.price,
    this.marketCap,
    this.allCapWeight,
    this.industryRank,
    this.industryCount,
    this.salesFY26,
    this.salesFY27,
    this.salesGrowth,
    this.netProfitFY26,
    this.netProfitFY27,
    this.marginFY26,
    this.marginFY27,
    this.marginDelta,
  });

  final String symbol;
  final String sector;
  final double profitGrowth;
  final double weight;

  final String? name;
  final String? bseCode;
  final String? industry;
  final String? price;
  final String? marketCap;
  final String? allCapWeight;
  final String? industryRank;
  final String? industryCount;
  final String? salesFY26;
  final String? salesFY27;
  final double? salesGrowth;
  final String? netProfitFY26;
  final String? netProfitFY27;
  final String? marginFY26;
  final String? marginFY27;
  final double? marginDelta;

  String get displayName => name ?? symbol;
}

class _SectorGroup {
  const _SectorGroup(this.name, this.companies);

  final String name;
  final List<_HeatCompany> companies;
}

class _Weighted<T> {
  const _Weighted(this.item, this.weight);

  final T item;
  final double weight;
}

class _AreaItem<T> {
  const _AreaItem(this.item, this.area);

  final T item;
  final double area;
}

class _TreemapTile<T> {
  const _TreemapTile(this.item, this.rect);

  final T item;
  final Rect rect;
}
