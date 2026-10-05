import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:webinar/app/models/live_market_model.dart';
import 'package:webinar/app/services/guest_service/live_market_service.dart';
import 'package:webinar/config/colors.dart';
import 'package:webinar/config/styles.dart';

class LiveMarketPage extends StatefulWidget {
  const LiveMarketPage({super.key});

  static const String pageName = '/live-market';

  @override
  State<LiveMarketPage> createState() => _LiveMarketPageState();
}

class _LiveMarketPageState extends State<LiveMarketPage> {
  LiveMarketOverviewModel? _overview;
  bool _loading = true;
  String? _error;

  final List<String> _compareSymbols = <String>['RELIANCE', 'TCS', 'HDFCBANK'];
  int _compareMonths = 6;
  Map<String, dynamic>? _compareData;
  bool _compareLoading = false;

  final TextEditingController _pivotController = TextEditingController();
  String _pivotKey = 'NIFTY';
  Map<String, dynamic>? _customPivotBar;
  bool _pivotLoading = false;

  final TextEditingController _stockController =
      TextEditingController(text: 'RELIANCE');
  Map<String, dynamic>? _stockData;
  bool _stockLoading = false;
  String? _stockError;

  String _actionFilter = 'ALL';
  int _actionsShown = 8;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _pivotController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final LiveMarketOverviewModel overview =
          await LiveMarketService.overview();
      if (!mounted) return;
      setState(() {
        _overview = overview;
        _loading = false;
      });

      await Future.wait<void>(<Future<void>>[
        _runCompare(),
        _loadStock('RELIANCE'),
      ]);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _runCompare() async {
    if (_compareSymbols.length < 2 || _compareLoading) return;
    setState(() => _compareLoading = true);
    try {
      final Map<String, dynamic> data = await LiveMarketService.compare(
        symbols: _compareSymbols,
        months: _compareMonths,
      );
      if (!mounted) return;
      setState(() {
        _compareData = data;
        _compareLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _compareLoading = false);
    }
  }

  Future<void> _loadStock([String? symbol]) async {
    if (_stockLoading) return;
    final String value = (symbol ?? _stockController.text).trim().toUpperCase();
    if (value.isEmpty) return;

    _stockController.text = value;
    setState(() {
      _stockLoading = true;
      _stockError = null;
    });

    try {
      final Map<String, dynamic> data = await LiveMarketService.stock(value);
      if (!mounted) return;
      setState(() {
        _stockData = data;
        _stockLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _stockLoading = false;
        _stockError = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _loadCustomPivot() async {
    final String symbol = _pivotController.text.trim().toUpperCase();
    if (symbol.isEmpty || _pivotLoading) return;
    setState(() => _pivotLoading = true);

    try {
      final Map<String, dynamic> response =
          await LiveMarketService.stock(symbol);
      final Map<String, dynamic> data = _map(response['data']);
      final Map<String, dynamic> history = _map(data['history']);
      final Map<String, dynamic> last = _map(history['last']);
      if (!mounted) return;
      setState(() {
        _pivotKey = symbol;
        _customPivotBar = last.isEmpty ? null : last;
        _pivotLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _pivotLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF101828),
        centerTitle: true,
        title: Text('Live Market', style: style16Bold()),
        actions: <Widget>[
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _loadAll,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _errorState()
              : RefreshIndicator(
                  color: green77(),
                  onRefresh: _loadAll,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 40),
                    children: <Widget>[
                      _marketHeader(),
                      const SizedBox(height: 14),
                      _marketStrip(
                        title: 'Global Markets',
                        subtitle: 'Key international benchmarks',
                        items: _overview!.global.items,
                        pricePrefix: '',
                      ),
                      const SizedBox(height: 14),
                      _marketStrip(
                        title: 'Forex Rates',
                        subtitle: 'Indicative spot rates',
                        items: _overview!.forex.items,
                        pricePrefix: '',
                      ),
                      const SizedBox(height: 14),
                      _marketStrip(
                        title: 'Commodities',
                        subtitle: 'International futures benchmarks',
                        items: _overview!.commodities.items,
                        pricePrefix: r'$',
                      ),
                      const SizedBox(height: 14),
                      _industryRadar(),
                      const SizedBox(height: 14),
                      _compareCard(),
                      const SizedBox(height: 14),
                      _pivotCard(),
                      const SizedBox(height: 14),
                      _stockExplorerCard(),
                      const SizedBox(height: 14),
                      _corporateActionsCard(),
                      const SizedBox(height: 18),
                      Text(
                        'Market data is informational and educational only. It is not investment advice.',
                        textAlign: TextAlign.center,
                        style: style10Regular()
                            .copyWith(color: greyA5, height: 1.4),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.cloud_off_rounded, size: 48, color: greyA5),
            const SizedBox(height: 12),
            Text('Unable to load Live Market', style: style16Bold()),
            const SizedBox(height: 7),
            Text(
              _error ?? 'Please try again.',
              textAlign: TextAlign.center,
              style: style12Regular().copyWith(color: greyA5),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadAll,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _marketHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7ECF5)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: green77().withValues(alpha: .08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.stacked_line_chart_rounded,
                color: green77(), size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Market Intelligence', style: style16Bold()),
                const SizedBox(height: 3),
                Text(
                  'Markets, sectors, comparisons, pivots & stock explorer',
                  style: style12Regular().copyWith(color: greyA5),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF8EF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircleAvatar(radius: 4, backgroundColor: Color(0xFF12A150)),
                SizedBox(width: 5),
                Text(
                  'LIVE',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF087A3C)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required String subtitle,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7ECF5)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
              color: Color(0x080B1F44), blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
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
                    Text(title, style: style16Bold()),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: style10Regular().copyWith(color: greyA5)),
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 13),
          child,
        ],
      ),
    );
  }

  Widget _marketStrip({
    required String title,
    required String subtitle,
    required List<MarketTileModel> items,
    required String pricePrefix,
  }) {
    return _sectionCard(
      title: title,
      subtitle: subtitle,
      child: items.isEmpty
          ? _emptyInline('Data is being prepared.')
          : SizedBox(
              height: 132,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 9),
                itemBuilder: (BuildContext context, int index) {
                  final MarketTileModel item = items[index];
                  final bool positive = (item.changePct ?? 0) >= 0;
                  return Container(
                    width: 154,
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBFCFF),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: const Color(0xFFE6EAF2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: style12Bold(),
                              ),
                            ),
                            if ((item.region ?? '').isNotEmpty)
                              _smallBadge(item.region!),
                          ],
                        ),
                        if ((item.description ?? '').isNotEmpty) ...<Widget>[
                          const SizedBox(height: 2),
                          Text(
                            item.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: style10Regular().copyWith(color: greyA5),
                          ),
                        ],
                        const SizedBox(height: 7),
                        Text(
                          '$pricePrefix${_number(item.price)}',
                          style: style16Bold()
                              .copyWith(color: const Color(0xFF101828)),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${positive ? '+' : ''}${_number(item.changePct)}%',
                          style: style10Regular().copyWith(
                            color: positive
                                ? const Color(0xFF12A150)
                                : const Color(0xFFE5484D),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          height: 28,
                          width: double.infinity,
                          child: CustomPaint(
                            painter: _SparklinePainter(
                              item.spark,
                              positive
                                  ? const Color(0xFF12A150)
                                  : const Color(0xFFE5484D),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _industryRadar() {
    final List<SectorMarketModel> sectors = _overview!.sectors.items;
    return _sectionCard(
      title: 'Industry Radar',
      subtitle: 'NSE sector breadth & relative strength',
      trailing: _smallBadge('${sectors.length} Sectors'),
      child: sectors.isEmpty
          ? _emptyInline('Sector data is being prepared.')
          : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 9,
                crossAxisSpacing: 9,
                // Use an explicit row height instead of childAspectRatio.
                // This gives the icon, 2 text lines and status badge enough
                // vertical room on smaller devices and prevents RenderFlex
                // overflow at the bottom.
                mainAxisExtent: 72,
              ),
              itemCount: sectors.length,
              itemBuilder: (BuildContext context, int index) {
                final SectorMarketModel sector = sectors[index];
                final bool positive = sector.changePct >= 0;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBFCFF),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: const Color(0xFFE6EAF2)),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: green77().withValues(alpha: .07),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(Icons.apartment_rounded,
                            size: 17, color: green77()),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              sector.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: style10Regular()
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${positive ? '+' : ''}${sector.changePct.toStringAsFixed(2)}%',
                              style: style10Regular().copyWith(
                                color: positive
                                    ? const Color(0xFF12A150)
                                    : const Color(0xFFE5484D),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _smallBadge(_sectorStatus(sector.changePct)),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _compareCard() {
    return _sectionCard(
      title: 'Compare Stocks',
      subtitle: 'Multi-asset relative return performance',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: <Widget>[
              ..._compareSymbols.map(
                (String symbol) => InputChip(
                  label: Text(symbol,
                      style: style10Regular()
                          .copyWith(fontWeight: FontWeight.w700)),
                  onDeleted: _compareSymbols.length <= 2
                      ? null
                      : () {
                          setState(() => _compareSymbols.remove(symbol));
                          _runCompare();
                        },
                  backgroundColor: green77().withValues(alpha: .06),
                  side: BorderSide(color: green77().withValues(alpha: .14)),
                  deleteIconColor: green77(),
                ),
              ),
              ActionChip(
                avatar: Icon(Icons.add_rounded, size: 16, color: green77()),
                label: const Text('Add Symbol'),
                onPressed: _showAddCompareSymbolDialog,
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFDDE3EE)),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            children: <Widget>[
              Expanded(
                child: SegmentedButton<int>(
                  segments: const <ButtonSegment<int>>[
                    ButtonSegment<int>(value: 1, label: Text('1M')),
                    ButtonSegment<int>(value: 3, label: Text('3M')),
                    ButtonSegment<int>(value: 6, label: Text('6M')),
                    ButtonSegment<int>(value: 12, label: Text('1Y')),
                  ],
                  selected: <int>{_compareMonths},
                  showSelectedIcon: false,
                  onSelectionChanged: (Set<int> value) {
                    setState(() => _compareMonths = value.first);
                    _runCompare();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_compareLoading)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(14),
                    child: CircularProgressIndicator()))
          else
            _compareResults(),
        ],
      ),
    );
  }

  Widget _compareResults() {
    final List<dynamic> raw = _list(_compareData?['stocks']);
    if (raw.isEmpty) return _emptyInline('Comparison data will appear here.');

    final List<Map<String, dynamic>> stocks = raw.map(_map).toList()
      ..sort((Map<String, dynamic> a, Map<String, dynamic> b) =>
          (_toDouble(b['return_pct']) ?? 0)
              .compareTo(_toDouble(a['return_pct']) ?? 0));

    double maxAbs = 1;
    for (final Map<String, dynamic> stock in stocks) {
      maxAbs = math.max(maxAbs, (_toDouble(stock['return_pct']) ?? 0).abs());
    }

    return Column(
      children: stocks.map((Map<String, dynamic> stock) {
        final double ret = _toDouble(stock['return_pct']) ?? 0;
        final bool positive = ret >= 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 11),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                      child: Text((stock['symbol'] ?? '').toString(),
                          style: style10Regular()
                              .copyWith(fontWeight: FontWeight.w800))),
                  Text(
                    '${positive ? '+' : ''}${ret.toStringAsFixed(1)}%',
                    style: style10Regular().copyWith(
                      color: positive
                          ? const Color(0xFF12A150)
                          : const Color(0xFFE5484D),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  minHeight: 7,
                  value: (ret.abs() / maxAbs).clamp(0, 1),
                  backgroundColor: const Color(0xFFEEF1F6),
                  valueColor: AlwaysStoppedAnimation<Color>(
                      positive ? green77() : const Color(0xFFE5484D)),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Future<void> _showAddCompareSymbolDialog() async {
    if (_compareSymbols.length >= 5) return;
    final TextEditingController controller = TextEditingController();
    final String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Add Stock Symbol'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(hintText: 'e.g. INFY'),
            onSubmitted: (String value) => Navigator.pop(dialogContext, value),
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.pop(dialogContext, controller.text),
                child: const Text('Add')),
          ],
        );
      },
    );
    controller.dispose();

    final String symbol = (result ?? '')
        .trim()
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9&\-]'), '');
    if (symbol.isEmpty || _compareSymbols.contains(symbol)) return;
    setState(() => _compareSymbols.add(symbol));
    _runCompare();
  }

  Widget _pivotCard() {
    final Map<String, dynamic>? bar = _pivotBar();
    final Map<String, double>? pivots =
        bar == null ? null : _classicPivots(bar);

    return _sectionCard(
      title: 'Pivot Points Calculator',
      subtitle: 'Classic floor pivots & key technical levels',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 7,
            children:
                <String>['NIFTY', 'BANKNIFTY', 'SENSEX'].map((String key) {
              final bool selected = _pivotKey == key;
              return ChoiceChip(
                label: Text(_pivotLabel(key)),
                selected: selected,
                onSelected: (_) {
                  setState(() {
                    _pivotKey = key;
                    _customPivotBar = null;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _pivotController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    isDense: true,
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    hintText: 'Enter stock symbol (e.g. RELIANCE)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onSubmitted: (_) => _loadCustomPivot(),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _pivotLoading ? null : _loadCustomPivot,
                  child: _pivotLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.calculate_outlined),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (pivots == null)
            _emptyInline('Pivot data is being prepared.')
          else
            _pivotTable(bar!, pivots),
        ],
      ),
    );
  }

  Map<String, dynamic>? _pivotBar() {
    if (_customPivotBar != null) return _customPivotBar;
    final IndexOhlcModel? item =
        _overview!.indexOhlc.items.cast<IndexOhlcModel?>().firstWhere(
              (IndexOhlcModel? e) => e?.key.toUpperCase() == _pivotKey,
              orElse: () => null,
            );
    if (item == null ||
        item.high == null ||
        item.low == null ||
        item.close == null) {
      return null;
    }
    return <String, dynamic>{
      'date': item.date,
      'high': item.high,
      'low': item.low,
      'close': item.close,
      'price': item.price,
    };
  }

  Map<String, double>? _classicPivots(Map<String, dynamic> bar) {
    final double? h = _toDouble(bar['high']);
    final double? l = _toDouble(bar['low']);
    final double? c = _toDouble(bar['close']);
    if (h == null || l == null || c == null) return null;
    final double range = h - l;
    final double p = (h + l + c) / 3;
    return <String, double>{
      'R3': h + 2 * (p - l),
      'R2': p + range,
      'R1': 2 * p - l,
      'P': p,
      'S1': 2 * p - h,
      'S2': p - range,
      'S3': l - 2 * (h - p),
    };
  }

  Widget _pivotTable(Map<String, dynamic> bar, Map<String, double> p) {
    final List<String> keys = <String>['R3', 'R2', 'R1', 'P', 'S1', 'S2', 'S3'];
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: const Color(0xFFF6F8FC),
              borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: <Widget>[
              _miniMetric('Prev Close', _number(bar['close'])),
              _miniMetric('High', _number(bar['high'])),
              _miniMetric('Low', _number(bar['low'])),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ...keys.map((String key) {
          final bool resistance = key.startsWith('R');
          final bool support = key.startsWith('S');
          final Color bg = resistance
              ? const Color(0xFFFFF1F2)
              : support
                  ? const Color(0xFFF0FBF4)
                  : const Color(0xFFEEF3FF);
          final Color fg = resistance
              ? const Color(0xFFC9323B)
              : support
                  ? const Color(0xFF087A3C)
                  : green77();
          final String label = key == 'P'
              ? 'Central Pivot (P)'
              : '${resistance ? 'Resistance' : 'Support'} $key';
          return Container(
            margin: const EdgeInsets.only(bottom: 5),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            decoration: BoxDecoration(
                color: bg, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: Text(label,
                        style: style10Regular()
                            .copyWith(color: fg, fontWeight: FontWeight.w700))),
                Text(_number(p[key]),
                    style: style10Regular()
                        .copyWith(color: fg, fontWeight: FontWeight.w800)),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _stockExplorerCard() {
    return _sectionCard(
      title: 'Stock Explorer',
      subtitle: 'Quote · chart · RSI · volume · corporate actions',
      trailing: Icon(Icons.auto_graph_rounded, color: green77(), size: 21),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _stockController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    isDense: true,
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    hintText: 'Search symbol, e.g. RELIANCE',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onSubmitted: (_) => _loadStock(),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _stockLoading ? null : _loadStock,
                  child: const Text('Search'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_stockLoading)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(22),
                    child: CircularProgressIndicator()))
          else if (_stockError != null)
            _emptyInline(_stockError!)
          else if (_stockData != null)
            _stockExplorerBody(),
        ],
      ),
    );
  }

  Widget _stockExplorerBody() {
    final Map<String, dynamic> root = _map(_stockData!['data']);
    final Map<String, dynamic> quoteEnvelope = _map(root['quote']);
    final Map<String, dynamic> quote = _map(quoteEnvelope['stock']);
    final Map<String, dynamic> history = _map(root['history']);
    final Map<String, dynamic> range = _map(root['fifty_two_week']);
    final Map<String, dynamic> volume = _map(root['volume_analysis']);
    final Map<String, dynamic> actionsEnvelope = _map(root['actions']);

    final String symbol =
        (_stockData!['symbol'] ?? _stockController.text).toString();
    final double? ltp = _toDouble(quote['lastTradedPrice']);
    final double changePct = _toDouble(quote['perChange']) ?? 0;
    final bool positive = changePct >= 0;
    final List<double> closes =
        _list(history['closes']).map(_toDouble).whereType<double>().toList();
    final List<double?> ma20 = _list(history['ma20']).map(_toDouble).toList();
    final List<double?> ma50 = _sma(closes, 50);
    final List<double?> rsi = _rsi(closes);
    double? lastRsi;
    for (final double? value in rsi.reversed) {
      if (value != null) {
        lastRsi = value;
        break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
              color: const Color(0xFFF6F8FC),
              borderRadius: BorderRadius.circular(13)),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(symbol, style: style14Bold()),
                        const SizedBox(height: 2),
                        _smallBadge(quoteEnvelope['source'] == 'live'
                            ? 'LIVE'
                            : 'LAST CLOSE'),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text('₹${_number(ltp)}', style: style20Bold()),
                      const SizedBox(height: 2),
                      Text(
                        '${positive ? '+' : ''}${changePct.toStringAsFixed(2)}%',
                        style: style10Regular().copyWith(
                          color: positive
                              ? const Color(0xFF12A150)
                              : const Color(0xFFE5484D),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 11),
              Row(
                children: <Widget>[
                  _miniMetric('Open', _money(quote['openPrice'])),
                  _miniMetric('High', _money(quote['highPrice'])),
                  _miniMetric('Low', _money(quote['lowPrice'])),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (closes.length >= 2) ...<Widget>[
          Text('Price Trend (3M)', style: style12Bold()),
          const SizedBox(height: 8),
          Container(
            height: 190,
            padding: const EdgeInsets.fromLTRB(7, 12, 7, 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFBFCFF),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: const Color(0xFFE7ECF5)),
            ),
            child: CustomPaint(
              painter: _MultiLineChartPainter(
                primary: closes,
                secondary: ma20,
                tertiary: ma50,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 8),
          const Wrap(
            spacing: 14,
            runSpacing: 6,
            children: <Widget>[
              _LegendDot(color: Color(0xFF0D3CCF), label: 'Price'),
              _LegendDot(color: Color(0xFF12A150), label: '20 DMA'),
              _LegendDot(color: Color(0xFFF59E0B), label: '50 DMA'),
            ],
          ),
          const SizedBox(height: 14),
        ],
        if (lastRsi != null) _rsiCard(lastRsi),
        const SizedBox(height: 12),
        _rangeCard(range),
        const SizedBox(height: 12),
        _volumeCard(volume),
        const SizedBox(height: 12),
        _stockActions(actionsEnvelope),
      ],
    );
  }

  Widget _rsiCard(double rsi) {
    final String state = rsi >= 70
        ? 'Overbought'
        : rsi <= 30
            ? 'Oversold'
            : 'Neutral';
    final Color stateColor = rsi >= 70
        ? const Color(0xFFE5484D)
        : rsi <= 30
            ? const Color(0xFF12A150)
            : green77();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFCFF),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFE7ECF5)),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                  child: Text('RSI (14) — Momentum', style: style12Bold())),
              Text(rsi.toStringAsFixed(1), style: style12Bold()),
              const SizedBox(width: 6),
              Text(state,
                  style: style10Regular().copyWith(
                      color: stateColor, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          Stack(
            alignment: Alignment.centerLeft,
            children: <Widget>[
              Container(
                height: 7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(colors: <Color>[
                    Color(0xFF12A150),
                    Color(0xFFF4C84B),
                    Color(0xFFE5484D)
                  ]),
                ),
              ),
              FractionallySizedBox(
                widthFactor: (rsi / 100).clamp(0, 1),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 13,
                    height: 13,
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: Center(
                        child: Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                                color: stateColor, shape: BoxShape.circle))),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rangeCard(Map<String, dynamic> range) {
    if (range.isEmpty || range['52w_high'] == null) {
      return _emptyInline('52-week range unavailable.');
    }
    final double pos =
        ((_toDouble(range['position_in_range_pct']) ?? 0) / 100).clamp(0, 1);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFCFF),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFE7ECF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('52-Week Range', style: style12Bold()),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                  child: Text('L: ₹${_number(range['52w_low'])}',
                      style: style10Regular().copyWith(color: greyA5))),
              Text('H: ₹${_number(range['52w_high'])}',
                  style: style10Regular().copyWith(color: greyA5)),
            ],
          ),
          const SizedBox(height: 7),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Stack(
                alignment: Alignment.centerLeft,
                children: <Widget>[
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(colors: <Color>[
                        Color(0xFFE5484D),
                        Color(0xFFF4C84B),
                        Color(0xFF12A150)
                      ]),
                    ),
                  ),
                  Positioned(
                    left: math.max(
                        0,
                        math.min(constraints.maxWidth - 14,
                            constraints.maxWidth * pos - 7)),
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: green77(), width: 3),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 9),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '+${_number(range['from_52w_low_pct'])}% from low',
                  style: style10Regular().copyWith(
                      color: const Color(0xFF12A150),
                      fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${_number(range['from_52w_high_pct'])}% from ATH',
                style: style10Regular().copyWith(
                    color: const Color(0xFFE5484D),
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _volumeCard(Map<String, dynamic> volume) {
    if (volume.isEmpty || volume['avg_volume'] == null) {
      return _emptyInline('Volume analysis unavailable.');
    }
    final double vs = _toDouble(volume['last_vs_avg_pct']) ?? 0;
    final bool positive = vs >= 0;
    final List<dynamic> recent =
        _list(volume['recent_5_days']).take(3).toList();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFCFF),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFE7ECF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                  child:
                      Text('Volume Analysis (30 days)', style: style12Bold())),
              Text(
                '${positive ? '+' : ''}${vs.toStringAsFixed(1)}% vs Avg',
                style: style10Regular().copyWith(
                  color: positive
                      ? const Color(0xFF12A150)
                      : const Color(0xFFE5484D),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
              '30-DMA Avg: ${_compactNumber(volume['avg_volume'])} · Current: ${_compactNumber(volume['last_volume'])}',
              style: style10Regular().copyWith(color: grey5E)),
          if (recent.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            ...recent.map((dynamic e) {
              final Map<String, dynamic> row = _map(e);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: <Widget>[
                    Expanded(
                        child: Text((row['date'] ?? '').toString(),
                            style: style10Regular().copyWith(color: greyA5))),
                    Text(_compactNumber(row['volume']),
                        style: style10Regular()
                            .copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(width: 10),
                    Text('${_number(row['vs_avg_pct'])}%',
                        style: style10Regular().copyWith(
                            color: (_toDouble(row['vs_avg_pct']) ?? 0) >= 0
                                ? const Color(0xFF12A150)
                                : const Color(0xFFE5484D))),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _stockActions(Map<String, dynamic> envelope) {
    final List<dynamic> actions = _list(envelope['actions']);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFCFF),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFE7ECF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Corporate Actions — ${_stockController.text}',
              style: style12Bold()),
          const SizedBox(height: 8),
          if (actions.isEmpty)
            Text('No corporate actions in the last 12 months.',
                style: style10Regular().copyWith(color: greyA5))
          else
            ...actions.take(4).map((dynamic e) {
              final Map<String, dynamic> row = _map(e);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Icon(Icons.circle, size: 7, color: Color(0xFF0D3CCF)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text((row['purpose'] ?? '').toString(),
                              style: style10Regular()
                                  .copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(
                              '${row['actionType'] ?? ''} · ${row['exDate'] ?? ''}',
                              style: style10Regular().copyWith(color: greyA5)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _corporateActionsCard() {
    final List<CorporateActionModel> all = _overview!.actions.items;
    final List<String> mainTypes = <String>['DIVIDEND', 'BONUS', 'SPLIT'];
    final List<CorporateActionModel> filtered =
        all.where((CorporateActionModel item) {
      final String type = item.actionType.toUpperCase();
      if (_actionFilter == 'ALL') return true;
      if (_actionFilter == 'OTHER') return !mainTypes.contains(type);
      return type == _actionFilter;
    }).toList();

    final List<CorporateActionModel> visible =
        filtered.take(_actionsShown).toList();

    return _sectionCard(
      title: 'Market-Wide Corporate Actions',
      subtitle: 'Upcoming and recent NSE corporate events',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <String>['ALL', 'DIVIDEND', 'BONUS', 'SPLIT', 'OTHER']
                  .map((String type) {
                final bool selected = _actionFilter == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 7),
                  child: ChoiceChip(
                    label: Text(type == 'ALL' ? 'All' : _title(type)),
                    selected: selected,
                    onSelected: (_) => setState(() {
                      _actionFilter = type;
                      _actionsShown = 8;
                    }),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 9),
          if (visible.isEmpty)
            _emptyInline('No actions of this type.')
          else
            ...visible
                .map((CorporateActionModel item) => _marketActionRow(item)),
          if (filtered.length > _actionsShown)
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => setState(() => _actionsShown += 8),
                child: Text(
                    'Show More Actions (${filtered.length - _actionsShown} more)'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _marketActionRow(CorporateActionModel item) {
    final String type = item.actionType.toUpperCase();
    final Color accent = type == 'DIVIDEND'
        ? const Color(0xFF12A150)
        : type == 'BONUS' || type == 'SPLIT'
            ? green77()
            : const Color(0xFFF59E0B);
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFCFF),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFFE7ECF5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
              width: 3,
              height: 34,
              decoration: BoxDecoration(
                  color: accent, borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(item.symbol,
                        style: style10Regular()
                            .copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(width: 7),
                    _smallBadge(_title(item.actionType)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(item.purpose,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: style10Regular().copyWith(color: grey5E)),
              ],
            ),
          ),
          const SizedBox(width: 7),
          Text(item.exDate, style: style10Regular().copyWith(color: greyA5)),
        ],
      ),
    );
  }

  Widget _miniMetric(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: style10Regular().copyWith(color: greyA5)),
          const SizedBox(height: 2),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style10Regular().copyWith(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _smallBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
          color: green77().withValues(alpha: .07),
          borderRadius: BorderRadius.circular(6)),
      child: Text(text,
          style: style10Regular().copyWith(
              color: green77(), fontWeight: FontWeight.w700, fontSize: 9)),
    );
  }

  Widget _emptyInline(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Text(message,
          textAlign: TextAlign.center,
          style: style10Regular().copyWith(color: greyA5)),
    );
  }

  String _sectorStatus(double value) {
    if (value >= 1.25) return 'Leader';
    if (value >= .65) return 'Strong';
    if (value >= .15) return 'Moderate';
    if (value > -.15) return 'Neutral';
    if (value > -.75) return 'Soft';
    return 'Weakest';
  }

  String _pivotLabel(String key) {
    if (key == 'NIFTY') return 'NIFTY 50';
    if (key == 'BANKNIFTY') return 'BANK NIFTY';
    return 'SENSEX';
  }

  String _money(dynamic value) => value == null ? '—' : '₹${_number(value)}';

  String _number(dynamic value) {
    final double? n = _toDouble(value);
    if (n == null) return '—';
    if (n.abs() >= 1000) {
      final String fixed = n.toStringAsFixed(2);
      final List<String> parts = fixed.split('.');
      final String whole = parts.first;
      final bool negative = whole.startsWith('-');
      final String digits = negative ? whole.substring(1) : whole;
      final StringBuffer out = StringBuffer();
      if (digits.length > 3) {
        final String tail = digits.substring(digits.length - 3);
        String head = digits.substring(0, digits.length - 3);
        while (head.length > 2) {
          out.write('${head.substring(head.length - 2)},');
          head = head.substring(0, head.length - 2);
        }
        final String reversed = out
            .toString()
            .split(',')
            .where((String e) => e.isNotEmpty)
            .toList()
            .reversed
            .join(',');
        final String prefix = head.isEmpty
            ? reversed
            : reversed.isEmpty
                ? head
                : '$head,$reversed';
        return '${negative ? '-' : ''}$prefix,$tail.${parts.last}';
      }
      return fixed;
    }
    return n.toStringAsFixed(n.abs() < 10 ? 3 : 2);
  }

  String _compactNumber(dynamic value) {
    final double? n = _toDouble(value);
    if (n == null) return '—';
    if (n >= 10000000) return '${(n / 10000000).toStringAsFixed(2)} Cr';
    if (n >= 100000) return '${(n / 100000).toStringAsFixed(2)} L';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toStringAsFixed(0);
  }

  String _title(String value) {
    final String lower = value.toLowerCase();
    if (lower.isEmpty) return value;
    return '${lower[0].toUpperCase()}${lower.substring(1)}';
  }

  List<double?> _sma(List<double> closes, int period) {
    return List<double?>.generate(closes.length, (int i) {
      if (i < period - 1) return null;
      double total = 0;
      for (int x = i - period + 1; x <= i; x++) {
        total += closes[x];
      }
      return total / period;
    });
  }

  List<double?> _rsi(List<double> closes, [int period = 14]) {
    final List<double?> out = List<double?>.filled(closes.length, null);
    if (closes.length <= period) return out;
    double gain = 0;
    double loss = 0;
    for (int i = 1; i <= period; i++) {
      final double diff = closes[i] - closes[i - 1];
      if (diff >= 0) {
        gain += diff;
      } else {
        loss -= diff;
      }
    }
    double avgGain = gain / period;
    double avgLoss = loss / period;
    out[period] = avgLoss == 0 ? 100 : 100 - 100 / (1 + avgGain / avgLoss);
    for (int i = period + 1; i < closes.length; i++) {
      final double diff = closes[i] - closes[i - 1];
      final double g = diff > 0 ? diff : 0;
      final double l = diff < 0 ? -diff : 0;
      avgGain = (avgGain * (period - 1) + g) / period;
      avgLoss = (avgLoss * (period - 1) + l) / period;
      out[i] = avgLoss == 0 ? 100 : 100 - 100 / (1 + avgGain / avgLoss);
    }
    return out;
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
            width: 16,
            height: 3,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF667085))),
      ],
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter(this.values, this.color);

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final double minValue = values.reduce(math.min);
    final double maxValue = values.reduce(math.max);
    final double spread =
        (maxValue - minValue).abs() < .000001 ? 1 : maxValue - minValue;
    final Path path = Path();
    for (int i = 0; i < values.length; i++) {
      final double x = i / (values.length - 1) * size.width;
      final double y = size.height -
          ((values[i] - minValue) / spread * (size.height - 3)) -
          1.5;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..strokeWidth = 1.7
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}

class _MultiLineChartPainter extends CustomPainter {
  _MultiLineChartPainter(
      {required this.primary, required this.secondary, required this.tertiary});

  final List<double> primary;
  final List<double?> secondary;
  final List<double?> tertiary;

  @override
  void paint(Canvas canvas, Size size) {
    if (primary.length < 2) return;
    final double minValue = primary.reduce(math.min);
    final double maxValue = primary.reduce(math.max);
    final double pad = (maxValue - minValue).abs() * .08;
    final double minY = minValue - pad;
    final double maxY = maxValue + pad;
    final double spread = (maxY - minY).abs() < .000001 ? 1 : maxY - minY;

    final Paint grid = Paint()
      ..color = const Color(0xFFEFF2F7)
      ..strokeWidth = 1;
    for (int i = 1; i <= 3; i++) {
      final double y = size.height * i / 4;
      canvas.drawLine(Offset.zero.translate(0, y), Offset(size.width, y), grid);
    }

    void drawSeries(List<double?> values, Color color, double width) {
      final Path path = Path();
      bool started = false;
      for (int i = 0; i < values.length; i++) {
        final double? value = values[i];
        if (value == null) continue;
        final double x = i / math.max(1, values.length - 1) * size.width;
        final double y = size.height - ((value - minY) / spread * size.height);
        if (!started) {
          path.moveTo(x, y);
          started = true;
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(
          path,
          Paint()
            ..color = color
            ..strokeWidth = width
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round);
    }

    drawSeries(primary.map<double?>((double e) => e).toList(),
        const Color(0xFF0D3CCF), 2.2);
    drawSeries(secondary, const Color(0xFF12A150), 1.5);
    drawSeries(tertiary, const Color(0xFFF59E0B), 1.5);
  }

  @override
  bool shouldRepaint(covariant _MultiLineChartPainter oldDelegate) => true;
}

Map<String, dynamic> _map(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

List<dynamic> _list(dynamic value) => value is List ? value : const <dynamic>[];

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString().replaceAll(',', ''));
}
