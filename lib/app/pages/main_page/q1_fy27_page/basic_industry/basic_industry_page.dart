import 'package:flutter/material.dart';

class BasicIndustryPage extends StatefulWidget {
  const BasicIndustryPage({super.key});

  @override
  State<BasicIndustryPage> createState() => _BasicIndustryPageState();
}

class _BasicIndustryPageState extends State<BasicIndustryPage> {
  static const Color _navy = Color(0xFF0B1F4D);
  static const Color _blue = Color(0xFF0D3CCF);
  static const Color _green = Color(0xFF12B76A);
  static const Color _greenDark = Color(0xFF067647);
  static const Color _red = Color(0xFFF04438);
  static const Color _amber = Color(0xFFF6C344);
  static const Color _text = Color(0xFF101828);
  static const Color _muted = Color(0xFF667085);
  static const Color _border = Color(0xFFE4E7EC);

  String _query = '';

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

  static const List<_IndustryData> _industries = <_IndustryData>[
    _IndustryData(
      industry: 'Private Sector Bank',
      sector: 'Financial Services',
      companies: 20,
      allCapCompanies: 18,
      marketCap: '₹33.66 L Cr',
      sales: '₹3,68,371 Cr',
      profit: '₹57,622 Cr',
      salesGrowth: 6.00,
      profitGrowth: 19.80,
      margin: 15.64,
      marginDelta: 1.10,
    ),
    _IndustryData(
      industry: 'Pharmaceuticals',
      sector: 'Healthcare',
      companies: 173,
      allCapCompanies: 67,
      marketCap: '₹25.75 L Cr',
      sales: '₹1,19,717 Cr',
      profit: '₹16,235 Cr',
      salesGrowth: 15.30,
      profitGrowth: 8.80,
      margin: 13.56,
      marginDelta: 0.42,
    ),
    _IndustryData(
      industry: 'Computers - Software & Consulting',
      sector: 'Information Technology',
      companies: 69,
      allCapCompanies: 25,
      marketCap: '₹22.04 L Cr',
      sales: '₹2,40,181 Cr',
      profit: '₹35,260 Cr',
      salesGrowth: 15.39,
      profitGrowth: 9.60,
      margin: 14.68,
      marginDelta: -0.31,
    ),
    _IndustryData(
      industry: 'Refineries & Marketing',
      sector: 'Energy',
      companies: 13,
      allCapCompanies: 5,
      marketCap: '₹19.66 L Cr',
      sales: '₹9,42,012 Cr',
      profit: '₹12,131 Cr',
      salesGrowth: 26.86,
      profitGrowth: -73.80,
      margin: 1.29,
      marginDelta: -3.82,
    ),
    _IndustryData(
      industry: 'Public Sector Bank',
      sector: 'Financial Services',
      companies: 12,
      allCapCompanies: 11,
      marketCap: '₹17.09 L Cr',
      sales: '₹4,07,443 Cr',
      profit: '₹53,353 Cr',
      salesGrowth: 6.16,
      profitGrowth: 24.40,
      margin: 13.09,
      marginDelta: 1.52,
    ),
    _IndustryData(
      industry: 'Telecom - Cellular & Fixed line services',
      sector: 'Telecommunication',
      companies: 8,
      allCapCompanies: 5,
      marketCap: '₹13.18 L Cr',
      sales: '₹79,623 Cr',
      profit: '₹6,800 Cr',
      salesGrowth: 15.41,
      profitGrowth: 184.0,
      margin: 8.54,
      marginDelta: 5.70,
    ),
    _IndustryData(
      industry: 'Heavy Electrical Equipment',
      sector: 'Industrials',
      companies: 41,
      allCapCompanies: 26,
      marketCap: '₹11.68 L Cr',
      sales: '₹41,898 Cr',
      profit: '₹5,671 Cr',
      salesGrowth: 23.31,
      profitGrowth: 105.0,
      margin: 13.54,
      marginDelta: 4.10,
    ),
    _IndustryData(
      industry: 'Non Banking Financial Company (NBFC)',
      sector: 'Financial Services',
      companies: 222,
      allCapCompanies: 24,
      marketCap: '₹10.89 L Cr',
      sales: '₹1,02,679 Cr',
      profit: '₹23,088 Cr',
      salesGrowth: 20.69,
      profitGrowth: 40.20,
      margin: 22.49,
      marginDelta: 2.32,
    ),
    _IndustryData(
      industry: 'Passenger Cars & Utility Vehicles',
      sector: 'Consumer Discretionary',
      companies: 8,
      allCapCompanies: 5,
      marketCap: '₹10.59 L Cr',
      sales: '₹2,23,367 Cr',
      profit: '₹11,220 Cr',
      salesGrowth: 18.45,
      profitGrowth: -16.50,
      margin: 5.02,
      marginDelta: -1.26,
    ),
    _IndustryData(
      industry: 'Cement & Cement Products',
      sector: 'Commodities',
      companies: 38,
      allCapCompanies: 19,
      marketCap: '₹8.85 L Cr',
      sales: '₹1,20,844 Cr',
      profit: '₹9,134 Cr',
      salesGrowth: 12.72,
      profitGrowth: 27.40,
      margin: 7.56,
      marginDelta: 0.81,
    ),
    _IndustryData(
      industry: 'Power Generation',
      sector: 'Utilities',
      companies: 35,
      allCapCompanies: 13,
      marketCap: '₹8.79 L Cr',
      sales: '₹79,923 Cr',
      profit: '₹11,696 Cr',
      salesGrowth: 10.80,
      profitGrowth: 6.60,
      margin: 14.63,
      marginDelta: 0.19,
    ),
    _IndustryData(
      industry: '2/3 Wheelers',
      sector: 'Consumer Discretionary',
      companies: 9,
      allCapCompanies: 6,
      marketCap: '₹8.71 L Cr',
      sales: '₹59,414 Cr',
      profit: '₹6,741 Cr',
      salesGrowth: 42.87,
      profitGrowth: 30.30,
      margin: 11.35,
      marginDelta: 1.88,
    ),
    _IndustryData(
      industry: 'Iron & Steel',
      sector: 'Commodities',
      companies: 14,
      allCapCompanies: 11,
      marketCap: '₹8.60 L Cr',
      sales: '₹1,71,307 Cr',
      profit: '₹11,873 Cr',
      salesGrowth: 12.15,
      profitGrowth: 56.80,
      margin: 6.93,
      marginDelta: 1.67,
    ),
    _IndustryData(
      industry: 'Auto Components & Equipments',
      sector: 'Consumer Discretionary',
      companies: 116,
      allCapCompanies: 37,
      marketCap: '₹8.05 L Cr',
      sales: '₹1,04,617 Cr',
      profit: '₹7,820 Cr',
      salesGrowth: 14.60,
      profitGrowth: 13.70,
      margin: 7.47,
      marginDelta: 0.38,
    ),
    _IndustryData(
      industry: 'Diversified FMCG',
      sector: 'Fast Moving Consumer Goods',
      companies: 11,
      allCapCompanies: 7,
      marketCap: '₹7.72 L Cr',
      sales: '₹89,540 Cr',
      profit: '₹9,148 Cr',
      salesGrowth: 17.10,
      profitGrowth: -12.60,
      margin: 10.22,
      marginDelta: -1.44,
    ),
  ];

  List<_IndustryData> get _filteredIndustries {
    final String q = _query.trim().toLowerCase();
    if (q.isEmpty) return _industries;
    return _industries
        .where(
          (_IndustryData item) =>
              item.industry.toLowerCase().contains(q) ||
              item.sector.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(
        top: 14,
        bottom: 24,
      ),
      children: <Widget>[
        _largestIndustriesSection(),
        const SizedBox(height: 14),
        _basicIndustryDeepDiveSection(),
        const SizedBox(height: 14),
        _researchEducationCard(),
      ],
    );
  }

  Widget _largestIndustriesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.fromLTRB(13, 14, 13, 13),
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
                      'Largest Industries: Sales vs Profit Growth',
                      style: TextStyle(
                        color: _text,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Top industries by market capitalisation.',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 8.5,
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
                  'Axis capped at 150%',
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
          ..._industries.map(_industryGrowthRow),
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

  Widget _industryGrowthRow(_IndustryData item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 118,
            child: Text(
              item.industry,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: _muted,
                fontSize: 7.6,
                height: 1.12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 17,
              child: _DivergingGrowthBars(
                salesGrowth: item.salesGrowth,
                profitGrowth: item.profitGrowth,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _basicIndustryDeepDiveSection() {
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
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 14, 13, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Basic Industry Deep Dive',
                        style: TextStyle(
                          color: _text,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Industry aggregates from the workbook’s BASIC INDUSTRY sheet.',
                        style: TextStyle(
                          color: _muted,
                          fontSize: 8.3,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '159 of 159 Industries',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 7.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 0, 13, 11),
            child: TextField(
              onChanged: (String value) {
                setState(() => _query = value);
              },
              decoration: InputDecoration(
                hintText: 'Search industry...',
                hintStyle: const TextStyle(
                  color: _muted,
                  fontSize: 10,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 19,
                  color: _muted,
                ),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _border),
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: _border),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 38,
              dataRowMinHeight: 46,
              dataRowMaxHeight: 54,
              horizontalMargin: 12,
              columnSpacing: 16,
              headingTextStyle: const TextStyle(
                color: _blue,
                fontSize: 7.7,
                fontWeight: FontWeight.w900,
              ),
              dataTextStyle: const TextStyle(
                color: _text,
                fontSize: 7.8,
                fontWeight: FontWeight.w600,
              ),
              columns: const <DataColumn>[
                DataColumn(label: Text('INDUSTRY')),
                DataColumn(label: Text('SECTOR')),
                DataColumn(label: Text('COS.')),
                DataColumn(label: Text('IN ALL-CAP')),
                DataColumn(label: Text('MARKET CAP')),
                DataColumn(label: Text('SALES Q1 FY27')),
                DataColumn(label: Text('PROFIT Q1 FY27')),
                DataColumn(label: Text('SALES GROWTH')),
                DataColumn(label: Text('PROFIT GROWTH')),
                DataColumn(label: Text('MARGIN')),
                DataColumn(label: Text('MARGIN Δ')),
              ],
              rows: _filteredIndustries.map((_IndustryData item) {
                return DataRow(
                  cells: <DataCell>[
                    DataCell(
                      SizedBox(
                        width: 150,
                        child: Text(
                          item.industry,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    DataCell(_sectorPill(item.sector)),
                    DataCell(Text('${item.companies}')),
                    DataCell(Text('${item.allCapCompanies}')),
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

  Widget _sectorPill(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: _muted,
          fontSize: 7,
          fontWeight: FontWeight.w700,
        ),
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
          fontSize: 7.3,
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
          fontSize: 7.3,
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
}

class _DivergingGrowthBars extends StatelessWidget {
  const _DivergingGrowthBars({
    required this.salesGrowth,
    required this.profitGrowth,
  });

  final double salesGrowth;
  final double profitGrowth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double total = constraints.maxWidth;
        final double zeroX = total * .36;
        final double negativeSpace = zeroX;
        final double positiveSpace = total - zeroX;

        double barWidth(double value) {
          if (value >= 0) {
            return (value.clamp(0, 150).toDouble() / 150) * positiveSpace;
          }
          return (value.abs().clamp(0, 100).toDouble() / 100) * negativeSpace;
        }

        Positioned bar(double value, Color color, double top) {
          final double width = barWidth(value);
          final bool positive = value >= 0;
          return Positioned(
            left: positive ? zeroX : zeroX - width,
            top: top,
            child: Container(
              width: width < 2 ? 2 : width,
              height: 5,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          );
        }

        return Stack(
          children: <Widget>[
            Positioned(
              left: zeroX,
              top: 0,
              bottom: 0,
              child: Container(
                width: 1,
                color: const Color(0xFFD0D5DD),
              ),
            ),
            bar(
              salesGrowth,
              salesGrowth >= 0
                  ? _BasicIndustryPageState._blue
                  : _BasicIndustryPageState._red,
              2,
            ),
            bar(
              profitGrowth,
              profitGrowth >= 0
                  ? _BasicIndustryPageState._green
                  : _BasicIndustryPageState._red,
              10,
            ),
          ],
        );
      },
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

class _IndustryData {
  const _IndustryData({
    required this.industry,
    required this.sector,
    required this.companies,
    required this.allCapCompanies,
    required this.marketCap,
    required this.sales,
    required this.profit,
    required this.salesGrowth,
    required this.profitGrowth,
    required this.margin,
    required this.marginDelta,
  });

  final String industry;
  final String sector;
  final int companies;
  final int allCapCompanies;
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
          Icon(icon, size: 12, color: _BasicIndustryPageState._amber),
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
