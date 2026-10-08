import 'package:flutter/material.dart';

class ThematicBasketsPage extends StatefulWidget {
  const ThematicBasketsPage({super.key});

  @override
  State<ThematicBasketsPage> createState() => _ThematicBasketsPageState();
}

class _ThematicBasketsPageState extends State<ThematicBasketsPage> {
  static const Color _navy = Color(0xFF0B1F4D);
  static const Color _blue = Color(0xFF0D3CCF);
  static const Color _green = Color(0xFF12B76A);
  static const Color _greenDark = Color(0xFF067647);
  static const Color _red = Color(0xFFF04438);
  static const Color _amber = Color(0xFFF6C344);
  static const Color _text = Color(0xFF101828);
  static const Color _muted = Color(0xFF667085);
  static const Color _border = Color(0xFFE4E7EC);

  int _selectedBasket = 0;

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

  static const List<_BasketData> _baskets = <_BasketData>[
    _BasketData(
      'IFRF Fund',
      '₹102.43 L Cr',
      17.64,
      7.04,
    ),
    _BasketData(
      'Bharat Samriddhi',
      '₹87.44 L Cr',
      18.25,
      6.44,
    ),
    _BasketData(
      'Bharat Atmanirbhar Shakti',
      '₹56.66 L Cr',
      26.80,
      4.77,
    ),
    _BasketData(
      'Bharat GatiShakti',
      '₹73.92 L Cr',
      24.80,
      3.00,
    ),
    _BasketData(
      'Naya Bharat (New India) Digital & Technology',
      '₹39.73 L Cr',
      25.47,
      -2.07,
    ),
    _BasketData(
      'Bharat Urja (Energy)',
      '₹30.39 L Cr',
      21.31,
      1.31,
    ),
    _BasketData(
      'Bharat Artha (Wealth)',
      '₹22.17 L Cr',
      6.95,
      16.62,
    ),
  ];

  static const List<_ConstituentData> _ifrfConstituents = <_ConstituentData>[
    _ConstituentData(
      company: 'RELIANCE INDUSTRIES LTD.',
      symbol: 'RELIANCE',
      code: '500325',
      sector: 'Energy',
      industry: 'Refineries & Marketing',
      weight: 15.68,
      marketCap: '₹16.07 L Cr',
      salesGrowth: 25.41,
      profitGrowth: -15.00,
      margin: 8.49,
    ),
    _ConstituentData(
      company: 'STATE BANK OF INDIA',
      symbol: 'SBIN',
      code: '500112',
      sector: 'Financial Services',
      industry: 'Public Sector Bank',
      weight: 8.66,
      marketCap: '₹8.87 L Cr',
      salesGrowth: 7.83,
      profitGrowth: 13.65,
      margin: 13.65,
    ),
    _ConstituentData(
      company: 'TATA CONSULTANCY SERVICES LTD.',
      symbol: 'TCS',
      code: '532540',
      sector: 'Information Technology',
      industry: 'Computers - Software & Consulting',
      weight: 7.24,
      marketCap: '₹7.42 L Cr',
      salesGrowth: 13.93,
      profitGrowth: 4.69,
      margin: 18.57,
    ),
    _ConstituentData(
      company: 'HDFC BANK LTD.',
      symbol: 'HDFCBANK',
      code: '500180',
      sector: 'Financial Services',
      industry: 'Private Sector Bank',
      weight: 5.31,
      marketCap: '₹5.44 L Cr',
      salesGrowth: 0.04,
      profitGrowth: 18.37,
      margin: 14.46,
    ),
    _ConstituentData(
      company: 'LARSEN & TOUBRO LTD.',
      symbol: 'LT',
      code: '500510',
      sector: 'Industrials',
      industry: 'Civil Construction',
      weight: 5.04,
      marketCap: '₹5.16 L Cr',
      salesGrowth: 6.69,
      profitGrowth: 15.19,
      margin: 7.33,
    ),
    _ConstituentData(
      company: 'TITAN COMPANY LIMITED',
      symbol: 'TITAN',
      code: '500114',
      sector: 'Consumer Discretionary',
      industry: 'Gems & Jewellery',
      weight: 3.98,
      marketCap: '₹4.07 L Cr',
      salesGrowth: 29.31,
      profitGrowth: 62.88,
      margin: 8.26,
    ),
    _ConstituentData(
      company: 'MARUTI SUZUKI INDIA LTD.',
      symbol: 'MARUTI',
      code: '532500',
      sector: 'Consumer Discretionary',
      industry: 'Passenger Cars & Utility Vehicles',
      weight: 3.67,
      marketCap: '₹3.76 L Cr',
      salesGrowth: 35.92,
      profitGrowth: -9.10,
      margin: 6.57,
    ),
    _ConstituentData(
      company: 'ULTRATECH CEMENT LTD.',
      symbol: 'ULTRACEMCO',
      code: '532538',
      sector: 'Commodities',
      industry: 'Cement & Cement Products',
      weight: 3.13,
      marketCap: '₹3.21 L Cr',
      salesGrowth: 15.85,
      profitGrowth: 17.24,
      margin: 10.56,
    ),
    _ConstituentData(
      company: 'Hindustan Aeronautics Limited',
      symbol: 'HAL',
      code: '541154',
      sector: 'Industrials',
      industry: 'Aerospace & Defence',
      weight: 3.04,
      marketCap: '₹3.11 L Cr',
      salesGrowth: 14.44,
      profitGrowth: 14.88,
      margin: 28.83,
    ),
    _ConstituentData(
      company: 'BAJAJ AUTO LTD.',
      symbol: 'BAJAJ-AUTO',
      code: '532977',
      sector: 'Consumer Discretionary',
      industry: '2/3 Wheelers',
      weight: 2.96,
      marketCap: '₹3.03 L Cr',
      salesGrowth: 65.15,
      profitGrowth: 44.30,
      margin: 14.70,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(
        top: 14,
        bottom: 24,
      ),
      children: <Widget>[
        _basketsSection(),
        const SizedBox(height: 14),
        _constituentsSection(),
        const SizedBox(height: 14),
        _researchEducationCard(),
      ],
    );
  }

  Widget _basketsSection() {
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
          const Text(
            'Thematic Baskets',
            style: TextStyle(
              color: _text,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Theme portfolios from the workbook. Select a basket to see its constituents.',
            style: TextStyle(
              color: _muted,
              fontSize: 8.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 13),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final int columns = constraints.maxWidth >= 700
                  ? 4
                  : constraints.maxWidth >= 460
                      ? 3
                      : 2;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _baskets.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 9,
                  mainAxisSpacing: 9,
                  mainAxisExtent: 142,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return _basketCard(index, _baskets[index]);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _basketCard(int index, _BasketData item) {
    final bool selected = _selectedBasket == index;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => setState(() => _selectedBasket = index),
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? _amber : _border,
              width: selected ? 1.5 : 1,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: selected
                    ? const Color(0x22F6C344)
                    : const Color(0x08101828),
                blurRadius: selected ? 12 : 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      item.name,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 10.5,
                        height: 1.18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: selected ? _amber : const Color(0xFF98A2B3),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                item.marketCap,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _text,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(child: _metricPill(item.salesGrowth)),
                  const SizedBox(width: 5),
                  Expanded(child: _metricPill(item.profitGrowth)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricPill(double value) {
    final bool positive = value >= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      decoration: BoxDecoration(
        color: positive ? const Color(0xFFECFDF3) : const Color(0xFFFFF1F3),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '${positive ? '+' : ''}${value.toStringAsFixed(2)}%',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: positive ? _greenDark : _red,
          fontSize: 7.2,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _constituentsSection() {
    final _BasketData selected = _baskets[_selectedBasket];
    final bool hasReferenceData = _selectedBasket == 0;

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
            padding: const EdgeInsets.fromLTRB(13, 14, 13, 11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${selected.name} — Constituents',
                  style: const TextStyle(
                    color: _text,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  hasReferenceData
                      ? '62 stocks, sorted by basket weight. Tap a company for its Q1 FY27 scorecard.'
                      : 'Constituent details for this basket will use the Q1 FY27 backend dataset when connected.',
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 8.2,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          if (hasReferenceData)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 38,
                dataRowMinHeight: 48,
                dataRowMaxHeight: 58,
                horizontalMargin: 12,
                columnSpacing: 16,
                headingTextStyle: const TextStyle(
                  color: _blue,
                  fontSize: 7.5,
                  fontWeight: FontWeight.w900,
                ),
                dataTextStyle: const TextStyle(
                  color: _text,
                  fontSize: 7.7,
                  fontWeight: FontWeight.w600,
                ),
                columns: const <DataColumn>[
                  DataColumn(label: Text('COMPANY / SYMBOL')),
                  DataColumn(label: Text('SECTOR')),
                  DataColumn(label: Text('INDUSTRY')),
                  DataColumn(label: Text('WEIGHT')),
                  DataColumn(label: Text('MARKET CAP')),
                  DataColumn(label: Text('SALES GR.')),
                  DataColumn(label: Text('PROFIT GR.')),
                  DataColumn(label: Text('MARGIN')),
                ],
                rows: _ifrfConstituents.map((_ConstituentData item) {
                  return DataRow(
                    cells: <DataCell>[
                      DataCell(
                        SizedBox(
                          width: 170,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                item.company,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: _text,
                                  fontSize: 8.4,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${item.symbol} · ${item.code}',
                                style: const TextStyle(
                                  color: Color(0xFF98A2B3),
                                  fontSize: 6.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      DataCell(_softPill(item.sector)),
                      DataCell(
                        SizedBox(
                          width: 145,
                          child: Text(
                            item.industry,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(Text('${item.weight.toStringAsFixed(2)}%')),
                      DataCell(Text(item.marketCap)),
                      DataCell(_growthPill(item.salesGrowth)),
                      DataCell(_growthPill(item.profitGrowth)),
                      DataCell(Text('${item.margin.toStringAsFixed(2)}%')),
                    ],
                  );
                }).toList(),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(13, 4, 13, 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _border),
                ),
                child: Column(
                  children: <Widget>[
                    const Icon(
                      Icons.table_chart_outlined,
                      color: _blue,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${selected.name} selected',
                      style: const TextStyle(
                        color: _text,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'The card selection is working. We will populate its real constituent rows from the Q1 FY27 API.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _muted,
                        fontSize: 8.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _softPill(String value) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 140),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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
          fontSize: 7.2,
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

class _BasketData {
  const _BasketData(
    this.name,
    this.marketCap,
    this.salesGrowth,
    this.profitGrowth,
  );

  final String name;
  final String marketCap;
  final double salesGrowth;
  final double profitGrowth;
}

class _ConstituentData {
  const _ConstituentData({
    required this.company,
    required this.symbol,
    required this.code,
    required this.sector,
    required this.industry,
    required this.weight,
    required this.marketCap,
    required this.salesGrowth,
    required this.profitGrowth,
    required this.margin,
  });

  final String company;
  final String symbol;
  final String code;
  final String sector;
  final String industry;
  final double weight;
  final String marketCap;
  final double salesGrowth;
  final double profitGrowth;
  final double margin;
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
          Icon(icon, size: 12, color: _ThematicBasketsPageState._amber),
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
