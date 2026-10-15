import 'package:flutter/material.dart';
import 'package:webinar/app/models/q1_fy27_dashboard_model.dart';

class ThematicBasketsPage extends StatefulWidget {
  const ThematicBasketsPage({super.key, required this.data});

  final Q1FY27DashboardData data;

  @override
  State<ThematicBasketsPage> createState() => _ThematicBasketsPageState();
}

class _ThematicBasketsPageState extends State<ThematicBasketsPage> {
  static const Color _blue = Color(0xFF0D3CCF);
  static const Color _greenDark = Color(0xFF067647);
  static const Color _red = Color(0xFFF04438);
  static const Color _text = Color(0xFF101828);
  static const Color _muted = Color(0xFF667085);
  static const Color _border = Color(0xFFE4E7EC);

  int _selected = 0;

  Q1Theme get _activeTheme => widget
      .data.themes[_selected.clamp(0, widget.data.themes.length - 1).toInt()];

  @override
  Widget build(BuildContext context) {
    if (widget.data.themes.isEmpty) {
      return const Center(child: Text('No thematic basket data available.'));
    }
    return ListView(
      padding: const EdgeInsets.only(top: 14, bottom: 24),
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
      padding: const EdgeInsets.fromLTRB(13, 14, 13, 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Thematic Baskets',
              style: TextStyle(
                  color: _text, fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          const Text(
              'Select a basket to view its real Q1 FY27 constituents and earnings metrics.',
              style: TextStyle(color: _muted, fontSize: 8.5, height: 1.35)),
          const SizedBox(height: 13),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final int columns = constraints.maxWidth >= 760
                  ? 4
                  : constraints.maxWidth >= 520
                      ? 2
                      : 1;
              if (columns == 1) {
                return Column(
                  children: List<Widget>.generate(widget.data.themes.length,
                      (int index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: _basketCard(index, widget.data.themes[index]),
                    );
                  }),
                );
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.data.themes.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 9,
                  mainAxisSpacing: 9,
                  mainAxisExtent: 166,
                ),
                itemBuilder: (BuildContext context, int index) =>
                    _basketCard(index, widget.data.themes[index]),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _basketCard(int index, Q1Theme item) {
    final bool selected = index == _selected;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _selected = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEFF4FF) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: selected ? _blue : _border, width: selected ? 1.3 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: _border)),
                    child: Text('${item.count} stocks',
                        style: const TextStyle(
                            color: _muted,
                            fontSize: 7,
                            fontWeight: FontWeight.w800)),
                  ),
                  const Spacer(),
                  Icon(
                      selected
                          ? Icons.check_circle_rounded
                          : Icons.arrow_forward_rounded,
                      size: 15,
                      color: selected ? _blue : _muted),
                ],
              ),
              const SizedBox(height: 9),
              Text(item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: _text,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 7),
              Text(Q1Format.marketCap(item.marketCap),
                  style: const TextStyle(
                      color: _text, fontSize: 14, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(child: _metric('SALES GR.', item.salesGrowth)),
                  const SizedBox(width: 6),
                  Expanded(child: _metric('PROFIT GR.', item.profitGrowth)),
                ],
              ),
              const Spacer(),
              Text(
                  'Margin ${Q1Format.plainPct(item.marginFY27)} • ${Q1Format.pp(item.marginChange)}',
                  style: const TextStyle(color: _muted, fontSize: 7)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metric(String label, double? value) {
    final bool positive = (value ?? 0) >= 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label,
            style: const TextStyle(
                color: _muted, fontSize: 6.4, fontWeight: FontWeight.w700)),
        const SizedBox(height: 3),
        Text(Q1Format.pct(value),
            style: TextStyle(
                color: positive ? _greenDark : _red,
                fontSize: 8,
                fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _constituentsSection() {
    final Q1Theme theme = _activeTheme;
    final List<Q1ThemeMember> rows = List<Q1ThemeMember>.from(theme.members)
      ..sort(
          (Q1ThemeMember a, Q1ThemeMember b) => b.weight.compareTo(a.weight));
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: _border)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 14, 13, 11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('${theme.name} — Constituents',
                    style: const TextStyle(
                        color: _text,
                        fontSize: 15,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text('${rows.length} stocks, sorted by basket weight.',
                    style: const TextStyle(color: _muted, fontSize: 8.3)),
              ],
            ),
          ),
          const Divider(height: 1, color: _border),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 38,
              dataRowMinHeight: 48,
              dataRowMaxHeight: 58,
              horizontalMargin: 12,
              columnSpacing: 16,
              headingTextStyle: const TextStyle(
                  color: _blue, fontSize: 7.6, fontWeight: FontWeight.w900),
              dataTextStyle: const TextStyle(
                  color: _text, fontSize: 7.8, fontWeight: FontWeight.w600),
              columns: const <DataColumn>[
                DataColumn(label: Text('COMPANY / SYMBOL')),
                DataColumn(label: Text('SECTOR')),
                DataColumn(label: Text('INDUSTRY')),
                DataColumn(label: Text('WEIGHT')),
                DataColumn(label: Text('MARKET CAP')),
                DataColumn(label: Text('SALES GR.')),
                DataColumn(label: Text('PROFIT GR.')),
                DataColumn(label: Text('MARGIN')),
                DataColumn(label: Text('MARGIN Δ')),
              ],
              rows: rows.map((Q1ThemeMember item) {
                return DataRow(cells: <DataCell>[
                  DataCell(SizedBox(
                      width: 160,
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
                          ]))),
                  DataCell(_softPill(item.sector)),
                  DataCell(SizedBox(
                      width: 145,
                      child: Text(item.industry,
                          maxLines: 2, overflow: TextOverflow.ellipsis))),
                  DataCell(Text('${item.weight.toStringAsFixed(2)}%')),
                  DataCell(Text(Q1Format.marketCap(item.marketCap))),
                  DataCell(_growthPill(item.salesGrowth)),
                  DataCell(_growthPill(item.profitGrowth)),
                  DataCell(Text(Q1Format.plainPct(item.marginFY27))),
                  DataCell(_growthPill(item.marginChange, suffix: ' pp')),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _softPill(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
          color: const Color(0xFFF2F4F7),
          borderRadius: BorderRadius.circular(999)),
      child: Text(value,
          style: const TextStyle(
              color: _muted, fontSize: 7, fontWeight: FontWeight.w700)),
    );
  }

  Widget _growthPill(double? value, {String suffix = '%'}) {
    if (value == null) return const Text('—');
    final bool positive = value >= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
          color: positive ? const Color(0xFFECFDF3) : const Color(0xFFFFF1F3),
          borderRadius: BorderRadius.circular(999)),
      child: Text('${positive ? '+' : ''}${value.toStringAsFixed(2)}$suffix',
          style: TextStyle(
              color: positive ? _greenDark : _red,
              fontSize: 7.2,
              fontWeight: FontWeight.w900)),
    );
  }

  Widget _researchEducationCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: <Color>[Color(0xFF071B47), Color(0xFF15366F)]),
          borderRadius: BorderRadius.circular(17)),
      child: Text(
        '${widget.data.themes.length} thematic baskets loaded from the Q1 FY27 API.\nEducational purposes only. Not investment advice.',
        style: TextStyle(
            color: Colors.white.withValues(alpha: .72),
            fontSize: 8.5,
            height: 1.5),
      ),
    );
  }
}
