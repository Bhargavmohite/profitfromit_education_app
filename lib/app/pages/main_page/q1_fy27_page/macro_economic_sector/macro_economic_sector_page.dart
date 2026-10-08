import 'package:flutter/material.dart';

class MacroEconomicSectorPage extends StatelessWidget {
  const MacroEconomicSectorPage({
    super.key,
    required this.onNavigateToAllCompanies,
  });

  final VoidCallback onNavigateToAllCompanies;

  static const Color _navy = Color(0xFF0B1F4D);
  static const Color _blue = Color(0xFF0D3CCF);
  static const Color _green = Color(0xFF12B76A);
  static const Color _greenDark = Color(0xFF067647);
  static const Color _red = Color(0xFFF04438);
  static const Color _amber = Color(0xFFF6C344);
  static const Color _text = Color(0xFF101828);
  static const Color _muted = Color(0xFF667085);
  static const Color _border = Color(0xFFE4E7EC);

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

  static const List<_MacroSectorData> _macroSectors = <_MacroSectorData>[
    _MacroSectorData(
      sector: 'Financial Services',
      companies: 151,
      marketCap: '₹94.89 L Cr',
      sales: '₹15,34,241 Cr',
      profit: '₹2,03,636 Cr',
      salesGrowth: 9.32,
      profitGrowth: 21.77,
      margin: 13.27,
      marginDelta: 1.36,
    ),
    _MacroSectorData(
      sector: 'Consumer Discretionary',
      companies: 272,
      marketCap: '₹73.45 L Cr',
      sales: '₹7,38,259 Cr',
      profit: '₹47,495 Cr',
      salesGrowth: 22.16,
      profitGrowth: 14.13,
      margin: 6.43,
      marginDelta: -0.45,
    ),
    _MacroSectorData(
      sector: 'Industrials',
      companies: 233,
      marketCap: '₹51.84 L Cr',
      sales: '₹3,85,599 Cr',
      profit: '₹36,111 Cr',
      salesGrowth: 16.58,
      profitGrowth: 31.20,
      margin: 9.36,
      marginDelta: 1.04,
    ),
    _MacroSectorData(
      sector: 'Commodities',
      companies: 123,
      marketCap: '₹41.42 L Cr',
      sales: '₹6,02,329 Cr',
      profit: '₹57,534 Cr',
      salesGrowth: 21.76,
      profitGrowth: 49.56,
      margin: 9.55,
      marginDelta: 1.78,
    ),
    _MacroSectorData(
      sector: 'Healthcare',
      companies: 102,
      marketCap: '₹32.67 L Cr',
      sales: '₹1,51,837 Cr',
      profit: '₹19,167 Cr',
      salesGrowth: 17.02,
      profitGrowth: 9.06,
      margin: 12.62,
      marginDelta: -0.92,
    ),
    _MacroSectorData(
      sector: 'Energy',
      companies: 28,
      marketCap: '₹30.23 L Cr',
      sales: '₹13,14,844 Cr',
      profit: '₹41,769 Cr',
      salesGrowth: 25.49,
      profitGrowth: -45.34,
      margin: 3.18,
      marginDelta: -4.12,
    ),
    _MacroSectorData(
      sector: 'Information Technology',
      companies: 50,
      marketCap: '₹25.47 L Cr',
      sales: '₹2,66,490 Cr',
      profit: '₹38,592 Cr',
      salesGrowth: 17.02,
      profitGrowth: 11.92,
      margin: 14.48,
      marginDelta: -0.66,
    ),
    _MacroSectorData(
      sector: 'Fast Moving Consumer Goods',
      companies: 71,
      marketCap: '₹21.62 L Cr',
      sales: '₹2,10,248 Cr',
      profit: '₹18,564 Cr',
      salesGrowth: 17.43,
      profitGrowth: 2.63,
      margin: 8.83,
      marginDelta: -1.27,
    ),
    _MacroSectorData(
      sector: 'Utilities',
      companies: 28,
      marketCap: '₹16.09 L Cr',
      sales: '₹1,61,879 Cr',
      profit: '₹24,444 Cr',
      salesGrowth: 13.62,
      profitGrowth: 13.64,
      margin: 15.10,
      marginDelta: 0.00,
    ),
    _MacroSectorData(
      sector: 'Telecommunication',
      companies: 14,
      marketCap: '₹15.52 L Cr',
      sales: '₹96,423 Cr',
      profit: '₹7,869 Cr',
      salesGrowth: 16.45,
      profitGrowth: 543.94,
      margin: 8.16,
      marginDelta: 6.69,
    ),
    _MacroSectorData(
      sector: 'Services',
      companies: 41,
      marketCap: '₹10.68 L Cr',
      sales: '₹1,31,537 Cr',
      profit: '₹16,995 Cr',
      salesGrowth: 21.21,
      profitGrowth: 7.84,
      margin: 12.92,
      marginDelta: -1.60,
    ),
    _MacroSectorData(
      sector: 'Diversified',
      companies: 4,
      marketCap: '₹89,116 Cr',
      sales: '₹11,405 Cr',
      profit: '₹1,519 Cr',
      salesGrowth: 16.47,
      profitGrowth: 40.13,
      margin: 13.32,
      marginDelta: 2.25,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _buildMacroEconomicSectorPage();
  }

  Widget _buildMacroEconomicSectorPage() {
    return ListView(
      padding: const EdgeInsets.only(
        top: 14,
        bottom: 24,
      ),
      children: <Widget>[
        _macroGrowthMatrixSection(),
        const SizedBox(height: 14),
        _macroSectorHealthSection(),
        const SizedBox(height: 14),
        _macroScorecardSection(),
        const SizedBox(height: 14),
        _researchEducationCard(),
      ],
    );
  }

  Widget _macroGrowthMatrixSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.fromLTRB(13, 14, 13, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _border),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x08101828),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Sector Growth Matrix',
                      style: TextStyle(
                        color: _text,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Year-on-year Q1 FY27 growth by macro-economic sector.',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 8.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Text(
                  'Axis capped at 75%',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ..._macroSectors.map(_macroGrowthRow),
          const SizedBox(height: 6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _LegendDot(color: _blue, label: 'Sales Growth'),
              SizedBox(width: 14),
              _LegendDot(color: _green, label: 'Profit Growth'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _macroGrowthRow(_MacroSectorData item) {
    final double salesWidth =
        (item.salesGrowth.abs().clamp(0, 75).toDouble()) / 75;
    final double profitWidth =
        (item.profitGrowth.abs().clamp(0, 75).toDouble()) / 75;

    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 112,
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(
                item.sector,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 8,
                  height: 1.15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              children: <Widget>[
                _growthBar(
                  value: salesWidth,
                  color: item.salesGrowth >= 0 ? _blue : _red,
                  label:
                      '${item.salesGrowth >= 0 ? '+' : ''}${item.salesGrowth.toStringAsFixed(2)}%',
                ),
                const SizedBox(height: 4),
                _growthBar(
                  value: profitWidth,
                  color: item.profitGrowth >= 0 ? _green : _red,
                  label:
                      '${item.profitGrowth >= 0 ? '+' : ''}${item.profitGrowth.toStringAsFixed(2)}%',
                ),
              ],
            ),
          ),
        ],
      ),
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

  Widget _macroSectorHealthSection() {
    final List<_MacroSectorData> ranked = List<_MacroSectorData>.from(
      _macroSectors,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.fromLTRB(13, 14, 13, 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Sector Health',
            style: TextStyle(
              color: _text,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Ranked by market capitalisation',
            style: TextStyle(
              color: _muted,
              fontSize: 8.5,
            ),
          ),
          const SizedBox(height: 12),
          ...ranked.take(6).map(_sectorHealthCard),
        ],
      ),
    );
  }

  Widget _sectorHealthCard(_MacroSectorData item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  item.sector,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${item.companies} cos. • ${item.marketCap}',
                style: const TextStyle(
                  color: _muted,
                  fontSize: 7.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _healthMetric(
            label: 'Sales',
            value: item.salesGrowth,
            color: _blue,
          ),
          const SizedBox(height: 5),
          _healthMetric(
            label: 'Profit',
            value: item.profitGrowth,
            color: item.profitGrowth >= 0 ? _green : _red,
          ),
        ],
      ),
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

  Widget _macroScorecardSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.fromLTRB(13, 14, 13, 3),
            child: Text(
              'Macro-Economic Sector Scorecard',
              style: TextStyle(
                color: _text,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(13, 0, 13, 11),
            child: Text(
              'Aggregated from company-level Q1 FY27 data. Tap any sector row to view companies; swipe horizontally for all metrics.',
              style: TextStyle(
                color: _muted,
                fontSize: 8.5,
                height: 1.35,
              ),
            ),
          ),
          const Divider(height: 1, color: _border),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 38,
              dataRowMinHeight: 42,
              dataRowMaxHeight: 48,
              horizontalMargin: 12,
              columnSpacing: 16,
              headingTextStyle: const TextStyle(
                color: _blue,
                fontSize: 8,
                fontWeight: FontWeight.w900,
              ),
              dataTextStyle: const TextStyle(
                color: _text,
                fontSize: 8,
                fontWeight: FontWeight.w600,
              ),
              columns: const <DataColumn>[
                DataColumn(label: Text('SECTOR')),
                DataColumn(label: Text('COS.')),
                DataColumn(label: Text('MARKET CAP')),
                DataColumn(label: Text('SALES Q1 FY27')),
                DataColumn(label: Text('PROFIT Q1 FY27')),
                DataColumn(label: Text('SALES GROWTH')),
                DataColumn(label: Text('PROFIT GROWTH')),
                DataColumn(label: Text('MARGIN')),
                DataColumn(label: Text('MARGIN Δ')),
              ],
              rows: _macroSectors.map((_MacroSectorData item) {
                return DataRow(
                  onSelectChanged: (_) => onNavigateToAllCompanies(),
                  cells: <DataCell>[
                    DataCell(
                      SizedBox(
                        width: 128,
                        child: Text(
                          item.sector,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text('${item.companies}')),
                    DataCell(Text(item.marketCap)),
                    DataCell(Text(item.sales)),
                    DataCell(Text(item.profit)),
                    DataCell(_growthPill(item.salesGrowth)),
                    DataCell(_growthPill(item.profitGrowth)),
                    DataCell(Text('${item.margin.toStringAsFixed(2)}%')),
                    DataCell(_marginPill(item.marginDelta)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _growthPill(double value) {
    final bool positive = value >= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: positive ? const Color(0xFFECFDF3) : const Color(0xFFFFF1F3),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '${positive ? '+' : ''}${value.toStringAsFixed(2)}%',
        style: TextStyle(
          color: positive ? _greenDark : _red,
          fontSize: 7.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _marginPill(double value) {
    final bool positive = value >= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: positive ? const Color(0xFFECFDF3) : const Color(0xFFFFF1F3),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '${positive ? '+' : ''}${value.toStringAsFixed(2)} pp',
        style: TextStyle(
          color: positive ? _greenDark : _red,
          fontSize: 7.5,
          fontWeight: FontWeight.w900,
        ),
      ),
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
    return Container(
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
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF667085),
            fontSize: 7.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _MacroSectorData {
  const _MacroSectorData({
    required this.sector,
    required this.companies,
    required this.marketCap,
    required this.sales,
    required this.profit,
    required this.salesGrowth,
    required this.profitGrowth,
    required this.margin,
    required this.marginDelta,
  });

  final String sector;
  final int companies;
  final String marketCap;
  final String sales;
  final String profit;
  final double salesGrowth;
  final double profitGrowth;
  final double margin;
  final double marginDelta;
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
          Icon(icon, size: 12, color: MacroEconomicSectorPage._amber),
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
