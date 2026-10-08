import 'package:flutter/material.dart';

class AllCompaniesPage extends StatefulWidget {
  const AllCompaniesPage({super.key});

  @override
  State<AllCompaniesPage> createState() => _AllCompaniesPageState();
}

class _AllCompaniesPageState extends State<AllCompaniesPage> {
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
  String _macroSector = 'All macro sectors';
  String _basicIndustry = 'All basic industries';
  String _marketCap = 'All market caps';
  String _sortBy = 'Market Cap: High → Low';

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

  static const List<_CompanyData> _companies = <_CompanyData>[
    _CompanyData(
        'RELIANCE INDUSTRIES LTD.',
        'RELIANCE',
        '500325',
        'Energy',
        'Refineries & Marketing',
        1187.50,
        '₹16.07 L Cr',
        '₹3,11,850 Cr',
        '₹26,463 Cr',
        29.24,
        18.10,
        8.49,
        0.72),
    _CompanyData(
        'HDFC BANK LTD.',
        'HDFCBANK',
        '500180',
        'Financial Services',
        'Private Sector Bank',
        709.70,
        '₹10.93 L Cr',
        '₹1,33,110 Cr',
        '₹19,245 Cr',
        12.14,
        9.31,
        14.46,
        0.48),
    _CompanyData(
        'BHARTI AIRTEL LTD.',
        'BHARTIARTL',
        '532454',
        'Telecommunication',
        'Telecom - Cellular & Fixed line services',
        1758.15,
        '₹10.54 L Cr',
        '₹58,539 Cr',
        '₹10,012 Cr',
        18.66,
        31.22,
        17.10,
        2.14),
    _CompanyData(
        'ICICI BANK LTD.',
        'ICICIBANK',
        '532174',
        'Financial Services',
        'Private Sector Bank',
        1322.50,
        '₹9.43 L Cr',
        '₹79,689 Cr',
        '₹15,440 Cr',
        14.90,
        13.88,
        19.38,
        1.11),
    _CompanyData(
        'STATE BANK OF INDIA',
        'SBIN',
        '500112',
        'Financial Services',
        'Public Sector Bank',
        960.70,
        '₹8.87 L Cr',
        '₹1,80,062 Cr',
        '₹24,579 Cr',
        9.10,
        13.65,
        13.65,
        0.84),
    _CompanyData(
        'TATA CONSULTANCY SERVICES LTD.',
        'TCS',
        '532540',
        'Information Technology',
        'Computers - Software & Consulting',
        2050.00,
        '₹7.42 L Cr',
        '₹72,275 Cr',
        '₹13,420 Cr',
        6.43,
        4.69,
        18.57,
        -0.31),
    _CompanyData(
        'LARSEN & TOUBRO LTD.',
        'LT',
        '500510',
        'Industrials',
        'Civil Construction',
        3755.10,
        '₹5.16 L Cr',
        '₹67,942 Cr',
        '₹4,983 Cr',
        17.70,
        15.19,
        7.33,
        0.62),
    _CompanyData(
        'HINDUSTAN UNILEVER LTD.',
        'HINDUNILVR',
        '500696',
        'Fast Moving Consumer Goods',
        'Diversified FMCG',
        1881.75,
        '₹4.42 L Cr',
        '₹17,529 Cr',
        '₹2,680 Cr',
        10.41,
        -3.18,
        15.29,
        -1.04),
    _CompanyData(
        'SUN PHARMACEUTICAL INDUSTRIES',
        'SUNPHARMA',
        '524715',
        'Healthcare',
        'Pharmaceuticals',
        1820.00,
        '₹4.36 L Cr',
        '₹15,300 Cr',
        '₹2,911 Cr',
        17.02,
        26.40,
        19.03,
        1.67),
    _CompanyData(
        'KOTAK MAHINDRA BANK LTD.',
        'KOTAKBANK',
        '500247',
        'Financial Services',
        'Private Sector Bank',
        417.60,
        '₹4.13 L Cr',
        '₹30,069 Cr',
        '₹5,480 Cr',
        12.30,
        22.54,
        18.22,
        1.35),
    _CompanyData(
        'INFOSYS LTD.',
        'INFY',
        '500209',
        'Information Technology',
        'Computers - Software & Consulting',
        995.00,
        '₹4.12 L Cr',
        '₹48,211 Cr',
        '₹7,775 Cr',
        10.08,
        12.29,
        16.13,
        0.44),
    _CompanyData(
        'ITC LTD.',
        'ITC',
        '500875',
        'Fast Moving Consumer Goods',
        'Diversified FMCG',
        268.90,
        '₹3.36 L Cr',
        '₹18,840 Cr',
        '₹4,710 Cr',
        8.43,
        -17.57,
        25.00,
        -2.31),
  ];

  List<_CompanyData> get _filteredCompanies {
    final String q = _query.trim().toLowerCase();
    List<_CompanyData> result = _companies.where((_CompanyData item) {
      final bool searchMatch = q.isEmpty ||
          item.company.toLowerCase().contains(q) ||
          item.symbol.toLowerCase().contains(q) ||
          item.bseCode.toLowerCase().contains(q);

      final bool macroMatch = _macroSector == 'All macro sectors' ||
          item.macroSector == _macroSector;

      final bool industryMatch = _basicIndustry == 'All basic industries' ||
          item.basicIndustry == _basicIndustry;

      return searchMatch && macroMatch && industryMatch;
    }).toList();

    if (_sortBy == 'Market Cap: High → Low') {
      // Data is already stored in descending market-cap order.
      return result;
    }
    if (_sortBy == 'Company: A → Z') {
      result.sort((a, b) => a.company.compareTo(b.company));
    } else if (_sortBy == 'Profit Growth: High → Low') {
      result.sort((a, b) => b.profitGrowth.compareTo(a.profitGrowth));
    } else if (_sortBy == 'Sales Growth: High → Low') {
      result.sort((a, b) => b.salesGrowth.compareTo(a.salesGrowth));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(
        top: 14,
        bottom: 24,
      ),
      children: <Widget>[
        _filtersCard(),
        const SizedBox(height: 14),
        _companiesTable(),
        const SizedBox(height: 14),
        _researchEducationCard(),
      ],
    );
  }

  Widget _filtersCard() {
    final List<String> macroSectors = <String>[
      'All macro sectors',
      ..._companies.map((e) => e.macroSector).toSet(),
    ];
    final List<String> industries = <String>[
      'All basic industries',
      ..._companies.map((e) => e.basicIndustry).toSet(),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: <Widget>[
          TextField(
            onChanged: (String value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Search company name, NSE symbol or BSE code...',
              hintStyle: const TextStyle(fontSize: 9.5, color: _muted),
              prefixIcon: const Icon(Icons.search_rounded, size: 18),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              border: _inputBorder(),
              enabledBorder: _inputBorder(),
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: <Widget>[
              Expanded(
                child: _dropdown(
                  value: _macroSector,
                  values: macroSectors,
                  onChanged: (String? v) {
                    if (v != null) setState(() => _macroSector = v);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _dropdown(
                  value: _basicIndustry,
                  values: industries,
                  onChanged: (String? v) {
                    if (v != null) setState(() => _basicIndustry = v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: <Widget>[
              Expanded(
                child: _dropdown(
                  value: _marketCap,
                  values: const <String>[
                    'All market caps',
                    'Large Cap',
                    'Mid Cap',
                    'Small Cap',
                  ],
                  onChanged: (String? v) {
                    if (v != null) setState(() => _marketCap = v);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _dropdown(
                  value: _sortBy,
                  values: const <String>[
                    'Market Cap: High → Low',
                    'Company: A → Z',
                    'Profit Growth: High → Low',
                    'Sales Growth: High → Low',
                  ],
                  onChanged: (String? v) {
                    if (v != null) setState(() => _sortBy = v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Showing ${_filteredCompanies.length} of 1,117 companies',
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 7.7,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _border),
                ),
                child: const Row(
                  children: <Widget>[
                    Text(
                      'Rows 25',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 7.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 3),
                    Icon(Icons.keyboard_arrow_down_rounded,
                        size: 14, color: _muted),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              _smallActionButton(Icons.download_rounded, 'CSV'),
              const SizedBox(width: 6),
              _smallActionButton(Icons.refresh_rounded, 'Reset'),
            ],
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _inputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: _border),
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> values,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 9,
          vertical: 9,
        ),
        border: _inputBorder(),
        enabledBorder: _inputBorder(),
      ),
      style: const TextStyle(
        color: _text,
        fontSize: 8.5,
        fontWeight: FontWeight.w600,
      ),
      items: values
          .map(
            (String item) => DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _smallActionButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 12, color: _blue),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
              color: _blue,
              fontSize: 7.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _companiesTable() {
    final List<_CompanyData> rows = _filteredCompanies;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 40,
              dataRowMinHeight: 52,
              dataRowMaxHeight: 62,
              horizontalMargin: 12,
              columnSpacing: 16,
              headingTextStyle: const TextStyle(
                color: _blue,
                fontSize: 7.6,
                fontWeight: FontWeight.w900,
              ),
              dataTextStyle: const TextStyle(
                color: _text,
                fontSize: 7.8,
                fontWeight: FontWeight.w600,
              ),
              columns: const <DataColumn>[
                DataColumn(label: Text('#')),
                DataColumn(label: Text('COMPANY / SYMBOL')),
                DataColumn(label: Text('MACRO SECTOR')),
                DataColumn(label: Text('BASIC INDUSTRY')),
                DataColumn(label: Text('PRICE')),
                DataColumn(label: Text('MARKET CAP')),
                DataColumn(label: Text('SALES Q1')),
                DataColumn(label: Text('PROFIT Q1')),
                DataColumn(label: Text('SALES GR.')),
                DataColumn(label: Text('PROFIT GR.')),
                DataColumn(label: Text('MARGIN')),
                DataColumn(label: Text('MARGIN Δ')),
              ],
              rows: List<DataRow>.generate(rows.length, (int index) {
                final _CompanyData item = rows[index];
                return DataRow(
                  cells: <DataCell>[
                    DataCell(Text('${index + 1}')),
                    DataCell(
                      SizedBox(
                        width: 175,
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
                                fontSize: 8.6,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${item.symbol} · ${item.bseCode}',
                              style: const TextStyle(
                                color: Color(0xFF98A2B3),
                                fontSize: 6.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataCell(_pill(item.macroSector)),
                    DataCell(_pill(item.basicIndustry)),
                    DataCell(Text('₹${item.price.toStringAsFixed(2)}')),
                    DataCell(
                      Text(
                        item.marketCap,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    DataCell(Text(item.sales)),
                    DataCell(Text(item.profit)),
                    DataCell(_growthPill(item.salesGrowth)),
                    DataCell(_growthPill(item.profitGrowth)),
                    DataCell(Text('${item.margin.toStringAsFixed(2)}%')),
                    DataCell(_marginPill(item.marginDelta)),
                  ],
                );
              }),
            ),
          ),
          const Divider(height: 1, color: _border),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
            child: Row(
              children: <Widget>[
                const Expanded(
                  child: Text(
                    'Page 1 of 45 · Rows 1–25',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 7.5,
                    ),
                  ),
                ),
                _pageButton('‹', false),
                const SizedBox(width: 4),
                _pageButton('1', true),
                const SizedBox(width: 4),
                _pageButton('2', false),
                const SizedBox(width: 4),
                _pageButton('3', false),
                const SizedBox(width: 4),
                _pageButton('4', false),
                const SizedBox(width: 4),
                _pageButton('5', false),
                const SizedBox(width: 4),
                _pageButton('›', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pageButton(String text, bool selected) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? _navy : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: selected ? _navy : _border),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: selected ? Colors.white : _muted,
          fontSize: 8,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _pill(String text) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 145),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
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

class _CompanyData {
  const _CompanyData(
    this.company,
    this.symbol,
    this.bseCode,
    this.macroSector,
    this.basicIndustry,
    this.price,
    this.marketCap,
    this.sales,
    this.profit,
    this.salesGrowth,
    this.profitGrowth,
    this.margin,
    this.marginDelta,
  );

  final String company;
  final String symbol;
  final String bseCode;
  final String macroSector;
  final String basicIndustry;
  final double price;
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
          Icon(icon, size: 12, color: _AllCompaniesPageState._amber),
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
