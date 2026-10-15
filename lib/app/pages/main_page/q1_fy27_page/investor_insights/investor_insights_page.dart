import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:webinar/app/models/q1_fy27_dashboard_model.dart';

class InvestorInsightsPage extends StatelessWidget {
  const InvestorInsightsPage({super.key, required this.data});

  final Q1FY27DashboardData data;

  static const Color _navy = Color(0xFF0B1F4D);
  static const Color _blue = Color(0xFF0D3CCF);
  static const Color _green = Color(0xFF12B76A);
  static const Color _greenDark = Color(0xFF067647);
  static const Color _red = Color(0xFFF04438);
  static const Color _amber = Color(0xFFF6C344);
  static const Color _text = Color(0xFF101828);
  static const Color _muted = Color(0xFF667085);
  static const Color _border = Color(0xFFE4E7EC);

  List<_InsightBoard> get _boards {
    List<Q1Company> topRows(
      Iterable<Q1Company> source,
      double Function(Q1Company c) metric, {
      bool ascending = false,
    }) {
      final List<Q1Company> rows = source.toList();
      rows.sort((Q1Company a, Q1Company b) {
        final int cmp = metric(b).compareTo(metric(a));
        return ascending ? -cmp : cmp;
      });
      return rows.take(10).toList();
    }

    final List<Q1Company> marginEligible = data.companies.where((Q1Company c) {
      return c.marginChange != null &&
          c.salesFY27 >= 100 &&
          c.marginFY27.abs() <= 100 &&
          c.marginFY26.abs() <= 100;
    }).toList();

    return <_InsightBoard>[
      _InsightBoard(
        title: 'Top Sales Growth Champions',
        subtitle: 'Highest Q1 FY27 sales growth (Q1 FY26 sales ≥ ₹50 Cr).',
        icon: Icons.trending_up_rounded,
        tone: _blue,
        rows: topRows(
          data.companies.where(
              (Q1Company c) => c.salesGrowth != null && c.salesFY26 >= 50),
          (Q1Company c) => c.salesGrowth!,
        ),
        value: (Q1Company c) => Q1Format.pct(c.salesGrowth),
        metric: (Q1Company c) => c.salesGrowth ?? 0,
        meta: (Q1Company c) => '${c.symbol} • ${c.sector}',
      ),
      _InsightBoard(
        title: 'Profit Surges',
        subtitle: 'Highest profit growth (Q1 FY26 profit ≥ ₹10 Cr).',
        icon: Icons.bolt_rounded,
        tone: _green,
        rows: topRows(
          data.companies.where((Q1Company c) =>
              c.profitGrowth != null && c.profitFY26 >= 10 && c.profitFY27 > 0),
          (Q1Company c) => c.profitGrowth!,
        ),
        value: (Q1Company c) => Q1Format.pct(c.profitGrowth),
        metric: (Q1Company c) => c.profitGrowth ?? 0,
        meta: (Q1Company c) => '${c.symbol} • ${c.sector}',
      ),
      _InsightBoard(
        title: 'Earnings Turnarounds',
        subtitle: 'Loss in Q1 FY26 → profit in Q1 FY27, ranked by swing.',
        icon: Icons.autorenew_rounded,
        tone: _amber,
        rows: topRows(
          data.companies
              .where((Q1Company c) => c.profitFY26 < 0 && c.profitFY27 > 0),
          (Q1Company c) => c.profitFY27 - c.profitFY26,
        ),
        value: (Q1Company c) =>
            '+${Q1Format.crore(c.profitFY27 - c.profitFY26)}',
        metric: (Q1Company c) => c.profitFY27 - c.profitFY26,
        meta: (Q1Company c) =>
            '${c.symbol} • ${Q1Format.crore(c.profitFY26)} → ${Q1Format.crore(c.profitFY27)}',
      ),
      _InsightBoard(
        title: 'Margin Expansion Stars',
        subtitle:
            'Largest YoY margin gain (sales ≥ ₹100 Cr, margins within ±100%).',
        icon: Icons.swap_vert_circle_rounded,
        tone: _green,
        rows: topRows(marginEligible, (Q1Company c) => c.marginChange!),
        value: (Q1Company c) => Q1Format.pp(c.marginChange),
        metric: (Q1Company c) => c.marginChange ?? 0,
        meta: (Q1Company c) => '${c.symbol} • ${c.sector}',
      ),
      _InsightBoard(
        title: 'Margin Contraction Watch',
        subtitle:
            'Largest YoY margin decline (sales ≥ ₹100 Cr, margins within ±100%).',
        icon: Icons.show_chart_rounded,
        tone: _red,
        rows: topRows(
          marginEligible,
          (Q1Company c) => c.marginChange!,
          ascending: true,
        ),
        value: (Q1Company c) => Q1Format.pp(c.marginChange),
        metric: (Q1Company c) => c.marginChange ?? 0,
        meta: (Q1Company c) => '${c.symbol} • ${c.sector}',
      ),
      _InsightBoard(
        title: 'Profit Heavyweights',
        subtitle: 'Largest absolute Q1 FY27 net profit.',
        icon: Icons.workspace_premium_rounded,
        tone: _blue,
        rows: topRows(data.companies, (Q1Company c) => c.profitFY27),
        value: (Q1Company c) => Q1Format.crore(c.profitFY27),
        metric: (Q1Company c) => c.profitFY27,
        meta: (Q1Company c) =>
            '${c.symbol} • Profit growth ${Q1Format.pct(c.profitGrowth)}',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 14, bottom: 24),
      children: <Widget>[
        _insightsGrid(context),
        const SizedBox(height: 14),
        _sectorHealthMatrix(),
        const SizedBox(height: 14),
        _researchEducationCard(),
      ],
    );
  }

  Widget _insightsGrid(BuildContext context) {
    final List<_InsightBoard> boards = _boards;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final int columns = constraints.maxWidth >= 760
              ? 3
              : constraints.maxWidth >= 520
                  ? 2
                  : 1;
          if (columns == 1) {
            return Column(
              children: boards
                  .map((_InsightBoard board) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _insightCard(context, board),
                      ))
                  .toList(),
            );
          }
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: boards.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              mainAxisExtent: 430,
            ),
            itemBuilder: (BuildContext context, int index) =>
                _insightCard(context, boards[index]),
          );
        },
      ),
    );
  }

  Widget _insightCard(BuildContext context, _InsightBoard board) {
    final double maxMetric = board.rows.fold<double>(
      1,
      (double current, Q1Company c) => math.max(current, board.metric(c).abs()),
    );
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 13, 12, 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _border),
        boxShadow: const <BoxShadow>[
          BoxShadow(
              color: Color(0x09101828), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: board.tone.withValues(alpha: .09),
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: Icon(board.icon, size: 17, color: board.tone),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(board.title,
                        style: const TextStyle(
                            color: _text,
                            fontSize: 13,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(height: 2),
                    Text(board.subtitle,
                        style: const TextStyle(
                            color: _muted, fontSize: 7.5, height: 1.25)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...List<Widget>.generate(board.rows.length, (int index) {
            final Q1Company company = board.rows[index];
            final double metric = board.metric(company);
            final bool negative = metric < 0;
            final double progress = math.max(.05, metric.abs() / maxMetric);
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => _showCompanyScorecard(context, company, board),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(5, 5, 4, 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 20,
                          height: 20,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: const Color(0xFFF2F4F7),
                              borderRadius: BorderRadius.circular(999)),
                          child: Text('${index + 1}',
                              style: const TextStyle(
                                  color: _muted,
                                  fontSize: 7,
                                  fontWeight: FontWeight.w800)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(company.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: _text,
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.w800)),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: negative
                                          ? const Color(0xFFFFF1F3)
                                          : const Color(0xFFECFDF3),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(board.value(company),
                                        style: TextStyle(
                                            color: negative ? _red : _greenDark,
                                            fontSize: 7,
                                            fontWeight: FontWeight.w900)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(board.meta(company),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Color(0xFF98A2B3), fontSize: 6.6)),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  minHeight: 3,
                                  value: progress.clamp(0.0, 1.0),
                                  backgroundColor: const Color(0xFFEAECF0),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      negative ? _red : board.tone),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showCompanyScorecard(
    BuildContext context,
    Q1Company company,
    _InsightBoard board,
  ) {
    final List<Q1Company> peers = data.companies
        .where((Q1Company c) =>
            c.industry == company.industry && c.bseCode != company.bseCode)
        .toList()
      ..sort((Q1Company a, Q1Company b) => b.marketCap.compareTo(a.marketCap));
    final int industryCount = data.companies
        .where((Q1Company c) => c.industry == company.industry)
        .length;
    final List<Q1Company> rankedIndustry = data.companies
        .where((Q1Company c) => c.industry == company.industry)
        .toList()
      ..sort((Q1Company a, Q1Company b) => b.marketCap.compareTo(a.marketCap));
    final int industryRank = rankedIndustry
            .indexWhere((Q1Company c) => c.bseCode == company.bseCode) +
        1;

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .48),
      builder: (BuildContext dialogContext) {
        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 660, maxHeight: 760),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2B93B), width: 1.2),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                      color: Color(0x2B101828),
                      blurRadius: 28,
                      offset: Offset(0, 12)),
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
                              const Text('Q1 FY27 COMPANY SCORECARD',
                                  style: TextStyle(
                                      color: _blue,
                                      fontSize: 7.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: .8)),
                              const SizedBox(height: 5),
                              Text(company.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: _navy,
                                      fontSize: 18,
                                      height: 1.1,
                                      fontWeight: FontWeight.w900)),
                              const SizedBox(height: 5),
                              Text(
                                  'NSE: ${company.symbol} · BSE: ${company.bseCode}',
                                  style: const TextStyle(
                                      color: _muted, fontSize: 8)),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close',
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          icon: const Icon(Icons.close_rounded),
                          style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFFF2F4F7),
                              foregroundColor: _navy),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: _border),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 13, 16, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: <Widget>[
                              _tag(Icons.layers_rounded, company.sector),
                              _tag(Icons.factory_outlined, company.industry),
                              _tag(Icons.bar_chart_rounded,
                                  '${company.capSegment} • #${company.rank} by M-Cap'),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LayoutBuilder(
                            builder: (BuildContext context,
                                BoxConstraints constraints) {
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
                                  _summary(
                                      'PRICE', Q1Format.price(company.price)),
                                  _summary('MARKET CAP',
                                      Q1Format.marketCap(company.marketCap)),
                                  _summary('ALL-CAP WEIGHT',
                                      '${company.weight.toStringAsFixed(3)}%'),
                                  _summary(
                                      'INDUSTRY RANK',
                                      industryRank > 0
                                          ? '#$industryRank of $industryCount'
                                          : '—'),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 14),
                          _metricTable(company),
                          const SizedBox(height: 14),
                          Text('Industry peers by market cap • ${board.title}',
                              style: const TextStyle(
                                  color: Color(0xFF344054),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900)),
                          const SizedBox(height: 8),
                          LayoutBuilder(
                            builder: (BuildContext context,
                                BoxConstraints constraints) {
                              final double width = constraints.maxWidth >= 500
                                  ? (constraints.maxWidth - 7) / 2
                                  : constraints.maxWidth;
                              return Wrap(
                                spacing: 7,
                                runSpacing: 7,
                                children: peers.take(6).map((Q1Company peer) {
                                  return SizedBox(
                                    width: width,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 9, vertical: 8),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(color: _border)),
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                              child: Text(peer.name,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      color: _text,
                                                      fontSize: 7.7,
                                                      fontWeight:
                                                          FontWeight.w800))),
                                          const SizedBox(width: 7),
                                          _miniGrowth(peer.profitGrowth),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
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

  Widget _tag(IconData icon, String label) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 245),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
          color: const Color(0xFFF2F4F7),
          borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 10, color: const Color(0xFF475467)),
          const SizedBox(width: 4),
          Flexible(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Color(0xFF475467),
                      fontSize: 7,
                      fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }

  Widget _summary(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _border)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label,
              style: const TextStyle(
                  color: _muted, fontSize: 6.8, fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: _text, fontSize: 12.5, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _metricTable(Q1Company company) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: _border),
          borderRadius: BorderRadius.circular(10)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: const Color(0xFFF8FAFC),
            child: const Row(
              children: <Widget>[
                Expanded(
                    flex: 4,
                    child: Text('METRIC',
                        style: TextStyle(
                            color: _muted,
                            fontSize: 6.7,
                            fontWeight: FontWeight.w900))),
                Expanded(
                    flex: 3,
                    child: Text('Q1 FY26',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            color: _muted,
                            fontSize: 6.7,
                            fontWeight: FontWeight.w900))),
                Expanded(
                    flex: 3,
                    child: Text('Q1 FY27',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            color: _muted,
                            fontSize: 6.7,
                            fontWeight: FontWeight.w900))),
                Expanded(
                    flex: 3,
                    child: Text('YOY CHANGE',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            color: _muted,
                            fontSize: 6.7,
                            fontWeight: FontWeight.w900))),
              ],
            ),
          ),
          _metricRow(
              'Sales',
              Q1Format.crore(company.salesFY26),
              Q1Format.crore(company.salesFY27),
              Q1Format.pct(company.salesGrowth),
              company.salesGrowth),
          _metricRow(
              'Net Profit',
              Q1Format.crore(company.profitFY26),
              Q1Format.crore(company.profitFY27),
              Q1Format.pct(company.profitGrowth),
              company.profitGrowth),
          _metricRow(
              'Profit Margin',
              Q1Format.plainPct(company.marginFY26),
              Q1Format.plainPct(company.marginFY27),
              Q1Format.pp(company.marginChange),
              company.marginChange),
        ],
      ),
    );
  }

  Widget _metricRow(String label, String oldValue, String newValue,
      String change, double? rawChange) {
    final bool positive = (rawChange ?? 0) >= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration:
          const BoxDecoration(border: Border(top: BorderSide(color: _border))),
      child: Row(
        children: <Widget>[
          Expanded(
              flex: 4,
              child: Text(label,
                  style: const TextStyle(
                      color: _text, fontSize: 8, fontWeight: FontWeight.w800))),
          Expanded(
              flex: 3,
              child: Text(oldValue,
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: _muted, fontSize: 7.5))),
          Expanded(
              flex: 3,
              child: Text(newValue,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      color: _text,
                      fontSize: 7.5,
                      fontWeight: FontWeight.w800))),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                    color: positive
                        ? const Color(0xFFECFDF3)
                        : const Color(0xFFFFF1F3),
                    borderRadius: BorderRadius.circular(999)),
                child: Text(change,
                    style: TextStyle(
                        color: positive ? _greenDark : _red,
                        fontSize: 7,
                        fontWeight: FontWeight.w900)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniGrowth(double? value) {
    if (value == null) return const Text('—');
    final bool positive = value >= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
          color: positive ? const Color(0xFFECFDF3) : const Color(0xFFFFF1F3),
          borderRadius: BorderRadius.circular(999)),
      child: Text(Q1Format.pct(value),
          style: TextStyle(
              color: positive ? _greenDark : _red,
              fontSize: 6.7,
              fontWeight: FontWeight.w900)),
    );
  }

  Widget _sectorHealthMatrix() {
    final List<Q1SectorSummary> rows = data.sectorSummaries;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.fromLTRB(13, 14, 13, 13),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: _border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Sector Health Matrix',
              style: TextStyle(
                  color: _text, fontSize: 15, fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          const Text(
              'Sales growth (x) vs profit growth (y); bubble size = market cap.',
              style: TextStyle(color: _muted, fontSize: 8, height: 1.35)),
          const SizedBox(height: 14),
          AspectRatio(
            aspectRatio: 1.65,
            child: CustomPaint(
                painter: _SectorHealthPainter(rows),
                child: const SizedBox.expand()),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: rows
                .map((Q1SectorSummary row) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(
                          color: const Color(0xFFF2F4F7),
                          borderRadius: BorderRadius.circular(999)),
                      child: Text(row.sector,
                          style: const TextStyle(
                              color: _muted,
                              fontSize: 6.8,
                              fontWeight: FontWeight.w700)),
                    ))
                .toList(),
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
              colors: <Color>[Color(0xFF071B47), Color(0xFF15366F)]),
          borderRadius: BorderRadius.circular(17)),
      child: Text(
        'Investor Insights calculated from ${data.companies.length} real Q1 FY27 company records.\nEducational purposes only. Not investment advice.',
        style: TextStyle(
            color: Colors.white.withValues(alpha: .72),
            fontSize: 8.5,
            height: 1.5),
      ),
    );
  }
}

class _InsightBoard {
  const _InsightBoard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tone,
    required this.rows,
    required this.value,
    required this.metric,
    required this.meta,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final Color tone;
  final List<Q1Company> rows;
  final String Function(Q1Company) value;
  final double Function(Q1Company) metric;
  final String Function(Q1Company) meta;
}

class _SectorHealthPainter extends CustomPainter {
  const _SectorHealthPainter(this.rows);
  final List<Q1SectorSummary> rows;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint grid = Paint()
      ..color = const Color(0xFFE4E7EC)
      ..strokeWidth = 1;
    final Paint axis = Paint()
      ..color = const Color(0xFF98A2B3)
      ..strokeWidth = 1.2;
    for (int i = 0; i <= 4; i++) {
      final double x = size.width * i / 4;
      final double y = size.height * i / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    canvas.drawLine(
        Offset(size.width / 2, 0), Offset(size.width / 2, size.height), axis);
    canvas.drawLine(
        Offset(0, size.height / 2), Offset(size.width, size.height / 2), axis);

    double maxMc = 1;
    for (final Q1SectorSummary row in rows) {
      maxMc = math.max(maxMc, row.marketCap);
    }

    for (int i = 0; i < rows.length; i++) {
      final Q1SectorSummary row = rows[i];
      final double xValue = (row.salesGrowth ?? 0).clamp(-100.0, 100.0);
      final double yValue = (row.profitGrowth ?? 0).clamp(-100.0, 100.0);
      final double x = (xValue + 100) / 200 * size.width;
      final double y = size.height - (yValue + 100) / 200 * size.height;
      final double radius = 5 + math.sqrt(row.marketCap / maxMc) * 13;
      final Color color =
          Colors.primaries[i % Colors.primaries.length].shade600;
      canvas.drawCircle(
          Offset(x, y), radius, Paint()..color = color.withValues(alpha: .62));
    }
  }

  @override
  bool shouldRepaint(covariant _SectorHealthPainter oldDelegate) =>
      oldDelegate.rows != rows;
}
