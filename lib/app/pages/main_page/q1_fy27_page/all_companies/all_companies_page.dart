import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:webinar/app/models/q1_fy27_dashboard_model.dart';

class AllCompaniesPage extends StatefulWidget {
  const AllCompaniesPage({
    super.key,
    required this.data,
    this.initialSector,
    this.initialCap,
  });

  final Q1FY27DashboardData data;
  final String? initialSector;
  final String? initialCap;

  @override
  State<AllCompaniesPage> createState() => _AllCompaniesPageState();
}

class _AllCompaniesPageState extends State<AllCompaniesPage> {
  static const Color _blue = Color(0xFF0D3CCF);
  static const Color _greenDark = Color(0xFF067647);
  static const Color _red = Color(0xFFF04438);
  static const Color _text = Color(0xFF101828);
  static const Color _muted = Color(0xFF667085);
  static const Color _border = Color(0xFFE4E7EC);

  String _query = '';
  String _macroSector = 'All macro sectors';
  String _basicIndustry = 'All basic industries';
  String _marketCap = 'All market caps';
  String _sortBy = 'Market Cap: High → Low';
  int _page = 1;
  int _pageSize = 25;

  @override
  void initState() {
    super.initState();
    if (widget.initialSector != null && widget.initialSector!.isNotEmpty) {
      _macroSector = widget.initialSector!;
    }
    if (widget.initialCap != null && widget.initialCap!.isNotEmpty) {
      _marketCap = widget.initialCap!;
    }
  }

  List<Q1Company> get _filteredCompanies {
    final String q = _query.trim().toLowerCase();
    final List<Q1Company> rows = widget.data.companies.where((Q1Company item) {
      final bool searchMatch = q.isEmpty ||
          item.name.toLowerCase().contains(q) ||
          item.symbol.toLowerCase().contains(q) ||
          item.bseCode.toLowerCase().contains(q);
      final bool macroMatch =
          _macroSector == 'All macro sectors' || item.sector == _macroSector;
      final bool industryMatch = _basicIndustry == 'All basic industries' ||
          item.industry == _basicIndustry;
      final bool capMatch = _matchesCap(item);
      return searchMatch && macroMatch && industryMatch && capMatch;
    }).toList();

    switch (_sortBy) {
      case 'Company: A → Z':
        rows.sort((Q1Company a, Q1Company b) => a.name.compareTo(b.name));
        break;
      case 'Profit Growth: High → Low':
        rows.sort((Q1Company a, Q1Company b) =>
            (b.profitGrowth ?? -double.infinity)
                .compareTo(a.profitGrowth ?? -double.infinity));
        break;
      case 'Sales Growth: High → Low':
        rows.sort((Q1Company a, Q1Company b) =>
            (b.salesGrowth ?? -double.infinity)
                .compareTo(a.salesGrowth ?? -double.infinity));
        break;
      case 'Margin Expansion: High → Low':
        rows.sort((Q1Company a, Q1Company b) =>
            (b.marginChange ?? -double.infinity)
                .compareTo(a.marginChange ?? -double.infinity));
        break;
      default:
        rows.sort(
            (Q1Company a, Q1Company b) => b.marketCap.compareTo(a.marketCap));
    }
    return rows;
  }

  bool _matchesCap(Q1Company item) {
    switch (_marketCap) {
      case 'Top 50':
        return item.rank <= 50;
      case 'Large Cap':
        return item.rank <= 100;
      case 'Mid Cap':
        return item.rank >= 101 && item.rank <= 250;
      case 'Small Cap':
        return item.rank >= 251 && item.rank <= 500;
      case 'Micro Cap':
        return item.rank >= 501 && item.rank <= 750;
      case 'Beyond Top 750':
        return item.rank > 750;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 14, bottom: 24),
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
      ...widget.data.sectors,
    ];
    final List<String> industries = <String>[
      'All basic industries',
      ...widget.data.industryNames,
    ];
    if (!macroSectors.contains(_macroSector)) {
      _macroSector = 'All macro sectors';
    }
    if (!industries.contains(_basicIndustry)) {
      _basicIndustry = 'All basic industries';
    }

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
            onChanged: (String value) => setState(() {
              _query = value;
              _page = 1;
            }),
            decoration: InputDecoration(
              hintText: 'Search company name, NSE symbol or BSE code...',
              hintStyle: const TextStyle(fontSize: 9.5, color: _muted),
              prefixIcon: const Icon(Icons.search_rounded, size: 18),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                  onChanged: (String? v) => setState(() {
                    _macroSector = v ?? 'All macro sectors';
                    _page = 1;
                  }),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _dropdown(
                  value: _basicIndustry,
                  values: industries,
                  onChanged: (String? v) => setState(() {
                    _basicIndustry = v ?? 'All basic industries';
                    _page = 1;
                  }),
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
                    'Top 50',
                    'Large Cap',
                    'Mid Cap',
                    'Small Cap',
                    'Micro Cap',
                    'Beyond Top 750',
                  ],
                  onChanged: (String? v) => setState(() {
                    _marketCap = v ?? 'All market caps';
                    _page = 1;
                  }),
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
                    'Margin Expansion: High → Low',
                  ],
                  onChanged: (String? v) => setState(() {
                    _sortBy = v ?? 'Market Cap: High → Low';
                    _page = 1;
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Showing ${_filteredCompanies.length} of ${widget.data.companies.length} companies',
                  style: const TextStyle(color: _muted, fontSize: 7.7),
                ),
              ),
              PopupMenuButton<int>(
                tooltip: 'Rows per page',
                onSelected: (int value) => setState(() {
                  _pageSize = value;
                  _page = 1;
                }),
                itemBuilder: (BuildContext context) => <int>[25, 50, 100]
                    .map((int n) =>
                        PopupMenuItem<int>(value: n, child: Text('$n rows')))
                    .toList(),
                child:
                    _smallAction(Icons.table_rows_rounded, 'Rows $_pageSize'),
              ),
              const SizedBox(width: 6),
              InkWell(
                  onTap: _resetFilters,
                  child: _smallAction(Icons.refresh_rounded, 'Reset')),
            ],
          ),
        ],
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _query = '';
      _macroSector = 'All macro sectors';
      _basicIndustry = 'All basic industries';
      _marketCap = 'All market caps';
      _sortBy = 'Market Cap: High → Low';
      _page = 1;
    });
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
      initialValue: values.contains(value) ? value : values.first,
      isExpanded: true,
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
        border: _inputBorder(),
        enabledBorder: _inputBorder(),
      ),
      style: const TextStyle(
          color: _text, fontSize: 8.5, fontWeight: FontWeight.w600),
      items: values
          .map((String item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item, maxLines: 1, overflow: TextOverflow.ellipsis),
              ))
          .toList(),
    );
  }

  Widget _smallAction(IconData icon, String label) {
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
          Text(label,
              style: const TextStyle(
                  color: _blue, fontSize: 7.5, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _companiesTable() {
    final List<Q1Company> allRows = _filteredCompanies;
    final int totalPages = math.max(1, (allRows.length / _pageSize).ceil());
    if (_page > totalPages) _page = totalPages;
    final int start = (_page - 1) * _pageSize;
    final int end = math.min(start + _pageSize, allRows.length);
    final List<Q1Company> rows =
        start < allRows.length ? allRows.sublist(start, end) : <Q1Company>[];

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
                  color: _blue, fontSize: 7.6, fontWeight: FontWeight.w900),
              dataTextStyle: const TextStyle(
                  color: _text, fontSize: 7.8, fontWeight: FontWeight.w600),
              columns: const <DataColumn>[
                DataColumn(label: Text('#')),
                DataColumn(label: Text('COMPANY / SYMBOL')),
                DataColumn(label: Text('MACRO SECTOR')),
                DataColumn(label: Text('BASIC INDUSTRY')),
                DataColumn(label: Text('PRICE')),
                DataColumn(label: Text('MARKET CAP')),
                DataColumn(label: Text('SALES Q1 FY27')),
                DataColumn(label: Text('PROFIT Q1 FY27')),
                DataColumn(label: Text('SALES GROWTH')),
                DataColumn(label: Text('PROFIT GROWTH')),
                DataColumn(label: Text('MARGIN')),
                DataColumn(label: Text('MARGIN Δ')),
              ],
              rows: rows.map((Q1Company item) {
                return DataRow(
                  onSelectChanged: (_) => _showCompany(context, item),
                  cells: <DataCell>[
                    DataCell(Text('${item.rank}')),
                    DataCell(
                      SizedBox(
                        width: 155,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(item.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900)),
                            const SizedBox(height: 2),
                            Text('${item.symbol} • ${item.bseCode}',
                                style: const TextStyle(
                                    color: _muted, fontSize: 6.8)),
                          ],
                        ),
                      ),
                    ),
                    DataCell(_pill(item.sector)),
                    DataCell(SizedBox(
                        width: 145,
                        child: Text(item.industry,
                            maxLines: 2, overflow: TextOverflow.ellipsis))),
                    DataCell(Text(Q1Format.price(item.price))),
                    DataCell(Text(Q1Format.marketCap(item.marketCap))),
                    DataCell(Text(Q1Format.crore(item.salesFY27))),
                    DataCell(Text(Q1Format.crore(item.profitFY27))),
                    DataCell(_growthPill(item.salesGrowth)),
                    DataCell(_growthPill(item.profitGrowth)),
                    DataCell(Text(Q1Format.plainPct(item.marginFY27))),
                    DataCell(_marginPill(item.marginChange)),
                  ],
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1, color: _border),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    allRows.isEmpty
                        ? 'No companies match the current filters.'
                        : 'Rows ${start + 1}–$end of ${allRows.length}',
                    style: const TextStyle(color: _muted, fontSize: 7.5),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed:
                      _page > 1 ? () => setState(() => _page -= 1) : null,
                  icon: const Icon(Icons.chevron_left_rounded, size: 18),
                ),
                Text('$_page / $totalPages',
                    style: const TextStyle(
                        color: _text,
                        fontSize: 8,
                        fontWeight: FontWeight.w800)),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: _page < totalPages
                      ? () => setState(() => _page += 1)
                      : null,
                  icon: const Icon(Icons.chevron_right_rounded, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
          color: const Color(0xFFF2F4F7),
          borderRadius: BorderRadius.circular(999)),
      child: Text(text,
          style: const TextStyle(
              color: _muted, fontSize: 7, fontWeight: FontWeight.w700)),
    );
  }

  Widget _growthPill(double? value) {
    if (value == null) return const Text('—');
    final bool positive = value >= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: positive ? const Color(0xFFECFDF3) : const Color(0xFFFFF1F3),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        Q1Format.pct(value),
        style: TextStyle(
            color: positive ? _greenDark : _red,
            fontSize: 7.5,
            fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _marginPill(double? value) {
    if (value == null) return const Text('—');
    final bool positive = value >= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: positive ? const Color(0xFFECFDF3) : const Color(0xFFFFF1F3),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        Q1Format.pp(value),
        style: TextStyle(
            color: positive ? _greenDark : _red,
            fontSize: 7.5,
            fontWeight: FontWeight.w900),
      ),
    );
  }

  void _showCompany(BuildContext context, Q1Company company) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .48),
      builder: (BuildContext dialogContext) {
        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 660, maxHeight: 720),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2B93B)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text('Q1 FY27 COMPANY SCORECARD',
                                  style: TextStyle(
                                      color: _blue,
                                      fontSize: 7.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: .8)),
                              const SizedBox(height: 5),
                              Text(company.name,
                                  style: const TextStyle(
                                      color: Color(0xFF0B1F4D),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900)),
                              const SizedBox(height: 4),
                              Text(
                                  'NSE: ${company.symbol} · BSE: ${company.bseCode}',
                                  style: const TextStyle(
                                      color: _muted, fontSize: 8)),
                            ],
                          ),
                        ),
                        IconButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            icon: const Icon(Icons.close_rounded)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: <Widget>[
                        _pill(company.sector),
                        _pill(company.industry),
                        _pill('${company.capSegment} • Rank #${company.rank}'),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _detailRow('Price', Q1Format.price(company.price)),
                    _detailRow(
                        'Market Cap', Q1Format.marketCap(company.marketCap)),
                    _detailRow('All-Cap Weight',
                        '${company.weight.toStringAsFixed(3)}%'),
                    const Divider(height: 20),
                    _metricLine('Sales', company.salesFY26, company.salesFY27,
                        company.salesGrowth, false),
                    _metricLine('Net Profit', company.profitFY26,
                        company.profitFY27, company.profitGrowth, false),
                    _metricLine('Profit Margin', company.marginFY26,
                        company.marginFY27, company.marginChange, true),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: <Widget>[
          Expanded(
              child: Text(label,
                  style: const TextStyle(color: _muted, fontSize: 9))),
          Text(value,
              style: const TextStyle(
                  color: _text, fontSize: 9, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _metricLine(String label, double oldValue, double newValue,
      double? change, bool margin) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          Expanded(
              flex: 4,
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 8, fontWeight: FontWeight.w800))),
          Expanded(
              flex: 3,
              child: Text(
                  margin
                      ? Q1Format.plainPct(oldValue)
                      : Q1Format.crore(oldValue),
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 7.5, color: _muted))),
          Expanded(
              flex: 3,
              child: Text(
                  margin
                      ? Q1Format.plainPct(newValue)
                      : Q1Format.crore(newValue),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 7.5, fontWeight: FontWeight.w800))),
          Expanded(
              flex: 3,
              child: Text(margin ? Q1Format.pp(change) : Q1Format.pct(change),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontSize: 7.5,
                      fontWeight: FontWeight.w900,
                      color: (change ?? 0) >= 0 ? _greenDark : _red))),
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
            colors: <Color>[Color(0xFF071B47), Color(0xFF15366F)]),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Text(
        'Real Q1 FY27 API data • ${widget.data.companies.length} companies\nEducational purposes only. Not investment advice.',
        style: TextStyle(
            color: Colors.white.withValues(alpha: .72),
            fontSize: 8.5,
            height: 1.5),
      ),
    );
  }
}
