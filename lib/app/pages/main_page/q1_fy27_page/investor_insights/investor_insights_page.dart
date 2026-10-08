import 'dart:math' as math;

import 'package:flutter/material.dart';

class InvestorInsightsPage extends StatelessWidget {
  const InvestorInsightsPage({super.key});

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

  static const List<_InsightSectionData> _insightSections =
      <_InsightSectionData>[
    _InsightSectionData(
      title: 'Top Sales Growth Champions',
      subtitle: 'Highest Q1 FY27 sales growth',
      icon: Icons.trending_up_rounded,
      tone: _blue,
      items: <_InsightItem>[
        _InsightItem('KOLTE-PATIL DEVELOPERS LTD.',
            'KOLTEPATIL • Consumer Discretionary', '+1,020.73%'),
        _InsightItem('IDEAFORGE TECHNOLOGY LIMITED', 'IDEAFORGE • Industrials',
            '+435.94%'),
        _InsightItem(
            'Tega Industries Limited', 'TEGA • Industrials', '+383.90%'),
        _InsightItem('Jio Financial Services Limited',
            'JIOFIN • Financial Services', '+223.75%'),
        _InsightItem('Anand SmartSpaces Limited',
            'ANANTRAJ • Consumer Discretionary', '+211.76%'),
        _InsightItem('LLOYDS METALS AND ENERGY LTD.', 'LLOYDSME • Commodities',
            '+210.41%'),
        _InsightItem('RateGain Travel Technologies L',
            'RATEGAIN • Information Technology', '+187.55%'),
        _InsightItem(
            'Eternal Limited', 'ETERNAL • Consumer Discretionary', '+182.00%'),
        _InsightItem('FINOTEX CHEMICAL LTD.', 'FCL • Commodities', '+175.18%'),
        _InsightItem('NETWEB TECHNOLOGIES INDIA LIMI',
            'NETWEB • Information Technology', '+172.43%'),
      ],
    ),
    _InsightSectionData(
      title: 'Profit Surges',
      subtitle: 'Highest profit growth',
      icon: Icons.bolt_rounded,
      tone: _green,
      items: <_InsightItem>[
        _InsightItem('APOLLO TYRES LTD', 'APOLLOTYRE • Consumer Discretionary',
            '+2,584.62%'),
        _InsightItem('STERLITE TECHNOLOGIES LTD', 'STLTECH • Telecommunication',
            '+1,870.00%'),
        _InsightItem(
            'NEULAND LABORATORIES LTD.', 'NEULANDLAB • Healthcare', '+957.14%'),
        _InsightItem('GLENMARK PHARMACEUTICALS LTD.', 'GLENMARK • Healthcare',
            '+927.66%'),
        _InsightItem('CreditAccess Grameen Ltd.',
            'CREDITACC • Financial Services', '+721.67%'),
        _InsightItem('Arvind SmartSpaces Limited',
            'ARVSMART • Consumer Discretionary', '+708.33%'),
        _InsightItem('PANAMA PETROCHEM LTD.', 'PANAMAPET • Energy', '+618.60%'),
        _InsightItem('Prince Pipes and Fittings Limited',
            'PRINCEPIPE • Industrials', '+602.08%'),
        _InsightItem('UFLEX LTD.', 'UFLEX • Industrials', '+580.65%'),
        _InsightItem(
            'BOSCH LTD.', 'BOSCHLTD • Consumer Discretionary', '+535.14%'),
      ],
    ),
    _InsightSectionData(
      title: 'Earnings Turnarounds',
      subtitle: 'Loss in Q1 FY26 → profit in Q1 FY27',
      icon: Icons.autorenew_rounded,
      tone: _amber,
      items: <_InsightItem>[
        _InsightItem(
            'JSW CEMENT LIMITED', 'JSWCEMENT • Commodities', 'Turnaround'),
        _InsightItem(
            'MANGALORE REFINERY & PETROCHEM', 'MRPL • Energy', 'Turnaround'),
        _InsightItem('CHENNAI PETROLEUM CORPORATION', 'CHENNPETRO • Energy',
            'Turnaround'),
        _InsightItem(
            'NMDC Steel Limited', 'NSLNISP • Commodities', 'Turnaround'),
        _InsightItem('BHARAT HEAVY ELECTRICALS LTD.', 'BHEL • Industrials',
            'Turnaround'),
        _InsightItem(
            'GMR Airports Limited', 'GMRAIRPORT • Services', 'Turnaround'),
        _InsightItem('ITI LTD.', 'ITI • Telecommunication', 'Turnaround'),
        _InsightItem('Equitas Small Finance Bank Ltd',
            'EQUITASBNK • Financial Services', 'Turnaround'),
        _InsightItem('Spandana Sphoorty Financial Ltd',
            'SPANDANA • Financial Services', 'Turnaround'),
        _InsightItem(
            'KIRIN INDUSTRIES LTD.', 'KIRINDUS • Industrials', 'Turnaround'),
      ],
    ),
    _InsightSectionData(
      title: 'Margin Expansion Stars',
      subtitle: 'Largest YoY margin gains',
      icon: Icons.swap_vert_circle_rounded,
      tone: _green,
      items: <_InsightItem>[
        _InsightItem(
            'KIRIN INDUSTRIES LTD.', 'KIRINDUS • Commodities', '+111.79 pp'),
        _InsightItem(
            'JSW CEMENT LIMITED', 'JSWCEMENT • Commodities', '+95.63 pp'),
        _InsightItem('BOROSIL RENEWABLES LIMITED', 'BORORENEW • Industrials',
            '+80.10 pp'),
        _InsightItem('ITI LTD.', 'ITI • Telecommunication', '+69.81 pp'),
        _InsightItem(
            'CENTUM ELECTRONICS LTD.', 'CENTUM • Industrials', '+48.76 pp'),
        _InsightItem('Prince Pipes and Fittings Limited',
            'PRINCEPIPE • Industrials', '+47.06 pp'),
        _InsightItem('Tejas Networks Limited', 'TEJASNET • Telecommunication',
            '+45.79 pp'),
        _InsightItem('KOLTE-PATIL DEVELOPERS LTD.',
            'KOLTEPATIL • Consumer Discretionary', '+36.73 pp'),
        _InsightItem('SIEMENS LTD.', 'SIEMENS • Industrials', '+35.16 pp'),
        _InsightItem('FUSION FINANCE LIMITED', 'FUSION • Financial Services',
            '+34.35 pp'),
      ],
    ),
    _InsightSectionData(
      title: 'Margin Contraction Watch',
      subtitle: 'Largest YoY margin decline',
      icon: Icons.show_chart_rounded,
      tone: _red,
      items: <_InsightItem>[
        _InsightItem('MOSCHIP TECHNOLOGIES LIMITED',
            'MOSCHIP • Information Technology', '-59.81 pp'),
        _InsightItem('LLOYDS ENTERPRISES LIMITED', 'LLOYDENT • Commodities',
            '-54.32 pp'),
        _InsightItem('GANESH HOUSING LIMITED',
            'GANESHHOUC • Consumer Discretionary', '-46.69 pp'),
        _InsightItem('63 Moons Technologies Limited',
            '63MOONS • Information Technology', '-39.41 pp'),
        _InsightItem('NETWORK18 MEDIA & INVESTMENTS',
            'NETWORK18 • Consumer Discretionary', '-39.20 pp'),
        _InsightItem('AXISCADES TECHNOLOGIES LIMITED',
            'AXISCADES • Industrials', '-30.54 pp'),
        _InsightItem(
            'HUBTOWN LTD.', 'HUBTOWN • Consumer Discretionary', '-26.54 pp'),
        _InsightItem(
            'ELECON ENGINEERING CO.LTD.', 'ELECON • Industrials', '-22.18 pp'),
        _InsightItem('Ola Electric Mobility Limited',
            'OLAELEC • Consumer Discretionary', '-22.16 pp'),
        _InsightItem('RATTANINDIA ENTERPRISES LIMITED',
            'RTNINDIA • Consumer Discretionary', '-20.90 pp'),
      ],
    ),
    _InsightSectionData(
      title: 'Profit Heavyweights',
      subtitle: 'Largest absolute Q1 FY27 net profit',
      icon: Icons.workspace_premium_rounded,
      tone: _blue,
      items: <_InsightItem>[
        _InsightItem('RELIANCE INDUSTRIES LTD.',
            'RELIANCE • Profit growth -18.10%', '₹26,463 Cr'),
        _InsightItem('STATE BANK OF INDIA', 'SBIN • Profit growth +13.65%',
            '₹24,579 Cr'),
        _InsightItem(
            'HDFC BANK LTD.', 'HDFCBANK • Profit growth +9.31%', '₹19,245 Cr'),
        _InsightItem('ICICI BANK LTD.', 'ICICIBANK • Profit growth +13.88%',
            '₹15,440 Cr'),
        _InsightItem('LIFE INSURANCE CORPORATION OF INDIA',
            'LICI • Profit growth +23.98%', '₹15,100 Cr'),
        _InsightItem('TATA CONSULTANCY SERVICES LTD.',
            'TCS • Profit growth +4.69%', '₹13,420 Cr'),
        _InsightItem('BHARTI AIRTEL LTD.', 'BHARTIARTL • Profit growth +34.90%',
            '₹10,012 Cr'),
        _InsightItem('POWER FINANCE CORPORATION LTD.',
            'PFC • Profit growth +0.19%', '₹7,820 Cr'),
        _InsightItem(
            'COAL INDIA LTD.', 'COALINDIA • Profit growth +0.71%', '₹7,140 Cr'),
        _InsightItem(
            'Vedanta Ltd.', 'VEDL • Profit growth +7.65%', '₹6,980 Cr'),
      ],
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
        _insightsGrid(context),
        const SizedBox(height: 14),
        _sectorHealthMatrix(),
        const SizedBox(height: 14),
        _researchEducationCard(),
      ],
    );
  }

  Widget _insightsGrid(BuildContext context) {
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
              children: _insightSections
                  .map(
                    (_InsightSectionData section) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _insightCard(context, section),
                    ),
                  )
                  .toList(),
            );
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _insightSections.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              mainAxisExtent: 430,
            ),
            itemBuilder: (BuildContext context, int index) {
              return _insightCard(context, _insightSections[index]);
            },
          );
        },
      ),
    );
  }

  Widget _insightCard(
    BuildContext context,
    _InsightSectionData section,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 13, 12, 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _border),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x09101828),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
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
                  color: section.tone.withValues(alpha: .09),
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: Icon(
                  section.icon,
                  size: 17,
                  color: section.tone,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      section.title,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      section.subtitle,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 7.5,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...List<Widget>.generate(section.items.length, (int index) {
            return _insightRow(
              context: context,
              index: index,
              section: section,
              item: section.items[index],
            );
          }),
        ],
      ),
    );
  }

  Widget _insightRow({
    required BuildContext context,
    required int index,
    required _InsightSectionData section,
    required _InsightItem item,
  }) {
    final bool negative =
        item.value.startsWith('-') || section.title.contains('Contraction');
    final Color valueColor = negative ? _red : _greenDark;
    final double progress =
        ((section.items.length - index) / section.items.length).clamp(.16, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _showCompanyScorecard(
            context,
            section: section,
            item: item,
          ),
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
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 7,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _text,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: negative
                                  ? const Color(0xFFFFF1F3)
                                  : const Color(0xFFECFDF3),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              item.value,
                              style: TextStyle(
                                color: valueColor,
                                fontSize: 7,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              item.meta,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF98A2B3),
                                fontSize: 6.6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.open_in_new_rounded,
                            size: 9,
                            color: Color(0xFF98A2B3),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 3,
                          value: progress,
                          backgroundColor: const Color(0xFFEAECF0),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            section.tone,
                          ),
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
  }

  void _showCompanyScorecard(
    BuildContext context, {
    required _InsightSectionData section,
    required _InsightItem item,
  }) {
    final _InsightCompanyProfile profile = _profileFor(item);
    final List<_InsightItem> peers = section.items
        .where((_InsightItem candidate) => candidate.name != item.name)
        .take(6)
        .toList();

    final String salesChange = section.title == 'Top Sales Growth Champions'
        ? item.value
        : profile.salesGrowth ?? '—';

    final String profitChange = section.title == 'Profit Surges'
        ? item.value
        : section.title == 'Earnings Turnarounds'
            ? 'Turnaround'
            : section.title == 'Profit Heavyweights'
                ? _profitGrowthFromMeta(item.meta)
                : profile.profitGrowth ?? '—';

    final String marginChange = section.title == 'Margin Expansion Stars' ||
            section.title == 'Margin Contraction Watch'
        ? item.value
        : profile.marginDelta ?? '—';

    final String currentProfit = section.title == 'Profit Heavyweights'
        ? item.value
        : profile.netProfitFY27 ?? '—';

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
                  _scorecardHeader(
                    dialogContext,
                    profile: profile,
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
                                profile.sector,
                              ),
                              if (profile.industry != null)
                                _scoreTag(
                                  Icons.factory_outlined,
                                  profile.industry!,
                                ),
                              _scoreTag(
                                Icons.bar_chart_rounded,
                                profile.marketCapRankText,
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
                                  _scoreSummaryCard(
                                    'PRICE',
                                    profile.price ?? '—',
                                  ),
                                  _scoreSummaryCard(
                                    'MARKET CAP',
                                    profile.marketCap ?? '—',
                                  ),
                                  _scoreSummaryCard(
                                    'ALL-CAP WEIGHT',
                                    profile.allCapWeight ?? '—',
                                  ),
                                  _scoreSummaryCard(
                                    'INDUSTRY RANK',
                                    profile.industryRankText,
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 14),
                          _scoreMetricTable(
                            profile: profile,
                            currentProfit: currentProfit,
                            salesChange: salesChange,
                            profitChange: profitChange,
                            marginChange: marginChange,
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Peer companies from this insight list',
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
                                children: peers.map(
                                  (_InsightItem peer) {
                                    return SizedBox(
                                      width: itemWidth,
                                      child: _peerTile(peer),
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
                              _scoreAction(
                                context,
                                Icons.search_rounded,
                                'Screener',
                              ),
                              _scoreAction(
                                context,
                                Icons.account_balance_outlined,
                                'NSE',
                              ),
                              _scoreAction(
                                context,
                                Icons.account_balance_outlined,
                                'BSE',
                              ),
                              _scoreAction(
                                context,
                                Icons.show_chart_rounded,
                                'Chart',
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

  Widget _scorecardHeader(
    BuildContext context, {
    required _InsightCompanyProfile profile,
  }) {
    return Padding(
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
                  profile.name,
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
                  'NSE: ${profile.symbol}'
                  '${profile.bseCode == null ? '' : ' · BSE: ${profile.bseCode}'}',
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF2F4F7),
              foregroundColor: _navy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _scoreTag(IconData icon, String label) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 245),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: 10,
            color: const Color(0xFF475467),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF475467),
                fontSize: 7,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scoreSummaryCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              color: _muted,
              fontSize: 6.8,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _text,
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _scoreMetricTable({
    required _InsightCompanyProfile profile,
    required String currentProfit,
    required String salesChange,
    required String profitChange,
    required String marginChange,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            color: const Color(0xFFF8FAFC),
            child: const Row(
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: Text(
                    'METRIC',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 6.7,
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
                      color: _muted,
                      fontSize: 6.7,
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
                      color: _muted,
                      fontSize: 6.7,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'YOY CHANGE',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: _muted,
                      fontSize: 6.7,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _scoreMetricRow(
            'Sales',
            profile.salesFY26 ?? '—',
            profile.salesFY27 ?? '—',
            salesChange,
          ),
          _scoreMetricRow(
            'Net Profit',
            profile.netProfitFY26 ?? '—',
            currentProfit,
            profitChange,
          ),
          _scoreMetricRow(
            'Profit Margin',
            profile.marginFY26 ?? '—',
            profile.marginFY27 ?? '—',
            marginChange,
          ),
        ],
      ),
    );
  }

  Widget _scoreMetricRow(
    String label,
    String oldValue,
    String newValue,
    String change,
  ) {
    final bool negative = change.trim().startsWith('-');
    final bool isNeutral = change == '—' || change == 'Turnaround';
    final Color changeColor = isNeutral
        ? _muted
        : negative
            ? _red
            : _greenDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: _border),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                color: _text,
                fontSize: 8,
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
                color: _muted,
                fontSize: 7.5,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              newValue,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: _text,
                fontSize: 7.5,
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
                        color: _muted,
                        fontSize: 7.5,
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isNeutral
                            ? const Color(0xFFFFF7E6)
                            : changeColor.withValues(alpha: .10),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        change,
                        style: TextStyle(
                          color:
                              isNeutral ? const Color(0xFFB54708) : changeColor,
                          fontSize: 7,
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

  Widget _peerTile(_InsightItem peer) {
    final bool negative = peer.value.startsWith('-');
    final Color color = negative ? _red : _greenDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              peer.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _text,
                fontSize: 7.7,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 7),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              peer.value,
              style: TextStyle(
                color: color,
                fontSize: 6.7,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scoreAction(
    BuildContext context,
    IconData icon,
    String label,
  ) {
    return OutlinedButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$label action will be connected with the company backend.',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      icon: Icon(icon, size: 13),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: label == 'Screener' ? Colors.white : _navy,
        backgroundColor: label == 'Screener' ? _blue : Colors.white,
        side: BorderSide(
          color: label == 'Screener' ? _blue : _border,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        textStyle: const TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  _InsightCompanyProfile _profileFor(_InsightItem item) {
    final String symbol = item.meta.split('•').first.trim();
    final String metaRight = item.meta.contains('•')
        ? item.meta.split('•').skip(1).join('•').trim()
        : '';

    if (symbol == 'KOLTEPATIL') {
      return const _InsightCompanyProfile(
        name: 'KOLTE-PATIL DEVELOPERS LTD.',
        symbol: 'KOLTEPATIL',
        bseCode: '532924',
        sector: 'Consumer Discretionary',
        industry: 'Residential, Commercial Projects',
        price: '₹423.50',
        marketCap: '₹3,777 Cr',
        allCapWeight: '0.009%',
        industryRank: '#26',
        industryCount: '35',
        salesFY26: '₹82 Cr',
        salesFY27: '₹919 Cr',
        salesGrowth: '+1,020.73%',
        netProfitFY26: '₹-17 Cr',
        netProfitFY27: '₹147 Cr',
        profitGrowth: '-984.71%',
        marginFY26: '-20.73%',
        marginFY27: '16.00%',
        marginDelta: '+36.73 pp',
      );
    }

    final String sector =
        metaRight.startsWith('Profit growth') ? 'Q1 FY27 All-Cap' : metaRight;

    return _InsightCompanyProfile(
      name: item.name,
      symbol: symbol.isEmpty ? '—' : symbol,
      sector: sector.isEmpty ? 'Q1 FY27 All-Cap' : sector,
    );
  }

  String _profitGrowthFromMeta(String meta) {
    final String marker = 'Profit growth ';
    final int index = meta.indexOf(marker);
    if (index < 0) {
      return '—';
    }
    return meta.substring(index + marker.length).trim();
  }

  Widget _sectorHealthMatrix() {
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Sector Health Matrix',
                      style: TextStyle(
                        color: _text,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Sales growth (x) vs profit growth (y); bubble size = market cap.',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 8,
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
                  'Values >100% pinned',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 6.8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AspectRatio(
            aspectRatio: 1.65,
            child: CustomPaint(
              painter: const _SectorHealthPainter(),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 9,
            runSpacing: 7,
            children: const <Widget>[
              _SectorLegend('Financial Services', Color(0xFF4169C1)),
              _SectorLegend('Consumer Discretionary', Color(0xFFE85D55)),
              _SectorLegend('Industrials', Color(0xFF3FA86C)),
              _SectorLegend('Commodities', Color(0xFFE4933A)),
              _SectorLegend('Healthcare', Color(0xFF8B5CF6)),
              _SectorLegend('Energy', Color(0xFF5E8C3F)),
              _SectorLegend('Information Technology', Color(0xFFE76F51)),
              _SectorLegend('Utilities', Color(0xFF2FA1B3)),
              _SectorLegend('Telecommunication', Color(0xFF9B51E0)),
            ],
          ),
        ],
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

class _SectorHealthPainter extends CustomPainter {
  const _SectorHealthPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint grid = Paint()
      ..color = const Color(0xFFE4E7EC)
      ..strokeWidth = 1;

    final Rect plot = Rect.fromLTWH(
      34,
      8,
      math.max(1, size.width - 46),
      math.max(1, size.height - 32),
    );

    for (int i = 0; i <= 5; i++) {
      final double x = plot.left + plot.width * i / 5;
      canvas.drawLine(
        Offset(x, plot.top),
        Offset(x, plot.bottom),
        grid,
      );
      final double y = plot.top + plot.height * i / 5;
      canvas.drawLine(
        Offset(plot.left, y),
        Offset(plot.right, y),
        grid,
      );
    }

    const List<_SectorPoint> points = <_SectorPoint>[
      _SectorPoint(.12, .34, 20, Color(0xFF4169C1)),
      _SectorPoint(.80, .54, 18, Color(0xFFE85D55)),
      _SectorPoint(.53, .38, 17, Color(0xFF3FA86C)),
      _SectorPoint(.77, .73, 15, Color(0xFFE4933A)),
      _SectorPoint(.53, .91, 13, Color(0xFF8B5CF6)),
      _SectorPoint(.58, .31, 13, Color(0xFF5E8C3F)),
      _SectorPoint(.74, .27, 11, Color(0xFFE76F51)),
      _SectorPoint(.95, .12, 14, Color(0xFF2FA1B3)),
      _SectorPoint(.56, .37, 14, Color(0xFF9B51E0)),
    ];

    for (final _SectorPoint point in points) {
      final Offset center = Offset(
        plot.left + point.x * plot.width,
        plot.bottom - point.y * plot.height,
      );
      final Paint fill = Paint()..color = point.color.withValues(alpha: .82);
      final Paint border = Paint()
        ..color = point.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawCircle(center, point.radius, fill);
      canvas.drawCircle(center, point.radius, border);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SectorPoint {
  const _SectorPoint(
    this.x,
    this.y,
    this.radius,
    this.color,
  );

  final double x;
  final double y;
  final double radius;
  final Color color;
}

class _SectorLegend extends StatelessWidget {
  const _SectorLegend(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 7,
          height: 7,
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
            fontSize: 6.8,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _InsightCompanyProfile {
  const _InsightCompanyProfile({
    required this.name,
    required this.symbol,
    required this.sector,
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
    this.profitGrowth,
    this.marginFY26,
    this.marginFY27,
    this.marginDelta,
  });

  final String name;
  final String symbol;
  final String sector;
  final String? bseCode;
  final String? industry;
  final String? price;
  final String? marketCap;
  final String? allCapWeight;
  final String? industryRank;
  final String? industryCount;
  final String? salesFY26;
  final String? salesFY27;
  final String? salesGrowth;
  final String? netProfitFY26;
  final String? netProfitFY27;
  final String? profitGrowth;
  final String? marginFY26;
  final String? marginFY27;
  final String? marginDelta;

  String get industryRankText {
    if (industryRank == null) return '—';
    if (industryCount == null) return industryRank!;
    return '$industryRank of $industryCount';
  }

  String get marketCapRankText {
    if (industryRank != null) {
      return 'Industry Rank $industryRank'
          '${industryCount == null ? '' : ' of $industryCount'}';
    }
    return 'Q1 FY27 All-Cap';
  }
}

class _InsightSectionData {
  const _InsightSectionData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tone,
    required this.items,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color tone;
  final List<_InsightItem> items;
}

class _InsightItem {
  const _InsightItem(this.name, this.meta, this.value);

  final String name;
  final String meta;
  final String value;
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
          Icon(icon, size: 12, color: InvestorInsightsPage._amber),
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
