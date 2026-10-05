class LiveMarketOverviewModel {
  const LiveMarketOverviewModel({
    required this.global,
    required this.forex,
    required this.commodities,
    required this.sectors,
    required this.indexOhlc,
    required this.actions,
  });

  final MarketSnapshot global;
  final MarketSnapshot forex;
  final MarketSnapshot commodities;
  final SectorSnapshot sectors;
  final IndexOhlcSnapshot indexOhlc;
  final CorporateActionSnapshot actions;

  factory LiveMarketOverviewModel.fromJson(Map<String, dynamic> json) {
    return LiveMarketOverviewModel(
      global: MarketSnapshot.fromJson(_map(json['global'])),
      forex: MarketSnapshot.fromJson(_map(json['forex'])),
      commodities: MarketSnapshot.fromJson(_map(json['commodities'])),
      sectors: SectorSnapshot.fromJson(_map(json['sectors'])),
      indexOhlc: IndexOhlcSnapshot.fromJson(_map(json['index_ohlc'])),
      actions: CorporateActionSnapshot.fromJson(_map(json['actions'])),
    );
  }
}

class MarketSnapshot {
  const MarketSnapshot({
    required this.items,
    this.updatedAt,
    this.pending = false,
  });

  final List<MarketTileModel> items;
  final String? updatedAt;
  final bool pending;

  factory MarketSnapshot.fromJson(Map<String, dynamic> json) {
    return MarketSnapshot(
      items: _list(json['items'])
          .map((dynamic e) => MarketTileModel.fromJson(_map(e)))
          .toList(),
      updatedAt: json['updated_at']?.toString(),
      pending: json['pending'] == true,
    );
  }
}

class MarketTileModel {
  const MarketTileModel({
    required this.name,
    this.region,
    this.description,
    this.price,
    this.change,
    this.changePct,
    this.spark = const <double>[],
  });

  final String name;
  final String? region;
  final String? description;
  final double? price;
  final double? change;
  final double? changePct;
  final List<double> spark;

  factory MarketTileModel.fromJson(Map<String, dynamic> json) {
    return MarketTileModel(
      name: (json['name'] ?? json['symbol'] ?? '').toString(),
      region: json['region']?.toString(),
      description: (json['desc'] ?? json['description'])?.toString(),
      price: _double(json['price']),
      change: _double(json['change']),
      changePct: _double(json['changePct'] ?? json['change_pct']),
      spark: _list(json['spark']).map(_double).whereType<double>().toList(),
    );
  }
}

class SectorSnapshot {
  const SectorSnapshot({required this.items, this.pending = false});

  final List<SectorMarketModel> items;
  final bool pending;

  factory SectorSnapshot.fromJson(Map<String, dynamic> json) {
    return SectorSnapshot(
      items: _list(json['items'])
          .map((dynamic e) => SectorMarketModel.fromJson(_map(e)))
          .toList(),
      pending: json['pending'] == true,
    );
  }
}

class SectorMarketModel {
  const SectorMarketModel({required this.name, required this.changePct});

  final String name;
  final double changePct;

  factory SectorMarketModel.fromJson(Map<String, dynamic> json) {
    return SectorMarketModel(
      name: (json['name'] ?? '').toString(),
      changePct: _double(json['changePct'] ?? json['change_pct']) ?? 0,
    );
  }
}

class IndexOhlcSnapshot {
  const IndexOhlcSnapshot({required this.items, this.pending = false});

  final List<IndexOhlcModel> items;
  final bool pending;

  factory IndexOhlcSnapshot.fromJson(Map<String, dynamic> json) {
    return IndexOhlcSnapshot(
      items: _list(json['items'])
          .map((dynamic e) => IndexOhlcModel.fromJson(_map(e)))
          .toList(),
      pending: json['pending'] == true,
    );
  }
}

class IndexOhlcModel {
  const IndexOhlcModel({
    required this.key,
    required this.name,
    this.date,
    this.open,
    this.high,
    this.low,
    this.close,
    this.price,
  });

  final String key;
  final String name;
  final String? date;
  final double? open;
  final double? high;
  final double? low;
  final double? close;
  final double? price;

  factory IndexOhlcModel.fromJson(Map<String, dynamic> json) {
    return IndexOhlcModel(
      key: (json['key'] ?? '').toString(),
      name: (json['name'] ?? json['key'] ?? '').toString(),
      date: json['date']?.toString(),
      open: _double(json['open']),
      high: _double(json['high']),
      low: _double(json['low']),
      close: _double(json['close']),
      price: _double(json['price']),
    );
  }
}

class CorporateActionSnapshot {
  const CorporateActionSnapshot({required this.items, this.pending = false});

  final List<CorporateActionModel> items;
  final bool pending;

  factory CorporateActionSnapshot.fromJson(Map<String, dynamic> json) {
    return CorporateActionSnapshot(
      items: _list(json['items'])
          .map((dynamic e) => CorporateActionModel.fromJson(_map(e)))
          .toList(),
      pending: json['pending'] == true,
    );
  }
}

class CorporateActionModel {
  const CorporateActionModel({
    required this.symbol,
    required this.actionType,
    required this.purpose,
    required this.exDate,
  });

  final String symbol;
  final String actionType;
  final String purpose;
  final String exDate;

  factory CorporateActionModel.fromJson(Map<String, dynamic> json) {
    return CorporateActionModel(
      symbol: (json['symbol'] ?? '').toString(),
      actionType: (json['actionType'] ?? json['action_type'] ?? '').toString(),
      purpose: (json['purpose'] ?? json['details'] ?? '').toString(),
      exDate: (json['exDate'] ?? json['ex_date'] ?? '').toString(),
    );
  }
}

Map<String, dynamic> _map(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

List<dynamic> _list(dynamic value) {
  return value is List ? value : const <dynamic>[];
}

double? _double(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString().replaceAll(',', ''));
}
