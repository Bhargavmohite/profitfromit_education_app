class Q1FY27DashboardData {
  Q1FY27DashboardData({
    required this.meta,
    required this.overview,
    required this.companies,
    required this.industries,
    required this.themes,
  });

  final Q1FY27Meta meta;
  final List<Q1OverviewRow> overview;
  final List<Q1Company> companies;
  final List<Q1Industry> industries;
  final List<Q1Theme> themes;

  factory Q1FY27DashboardData.fromJson(Map<String, dynamic> json) {
    final Q1FY27Meta meta = Q1FY27Meta.fromJson(_map(json['meta']));
    final List<Q1OverviewRow> overview = _list(json['overview'])
        .map((dynamic e) => Q1OverviewRow.fromJson(_map(e)))
        .toList();

    final List<Q1Company> parsedCompanies = _list(json['companies'])
        .map((dynamic e) => Q1Company.fromJson(_map(e)))
        .toList();

    final List<Q1Company> ranked = List<Q1Company>.from(parsedCompanies)
      ..sort((Q1Company a, Q1Company b) => b.marketCap.compareTo(a.marketCap));

    final List<Q1Company> companies = <Q1Company>[];
    for (int i = 0; i < ranked.length; i++) {
      companies.add(
        ranked[i].copyWith(
          rank: i + 1,
          capSegment: capSegmentForRank(i + 1),
        ),
      );
    }

    final Map<String, Q1Company> byCode = <String, Q1Company>{
      for (final Q1Company c in companies) c.bseCode: c,
    };

    final Map<String, Map<String, int>> industrySectorCounts =
        <String, Map<String, int>>{};
    final Map<String, int> industryCompanyCounts = <String, int>{};
    for (final Q1Company company in companies) {
      industryCompanyCounts.update(
        company.industry,
        (int value) => value + 1,
        ifAbsent: () => 1,
      );
      final Map<String, int> counts =
          industrySectorCounts.putIfAbsent(company.industry, () => <String, int>{});
      counts.update(
        company.sector,
        (int value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    final List<Q1Industry> industries = _list(json['industries']).map((dynamic e) {
      final Q1Industry raw = Q1Industry.fromJson(_map(e));
      final Map<String, int> counts = industrySectorCounts[raw.name] ?? <String, int>{};
      String sector = '';
      int best = -1;
      counts.forEach((String key, int value) {
        if (value > best) {
          best = value;
          sector = key;
        }
      });
      return raw.copyWith(
        sector: sector,
        allCapCompanies: industryCompanyCounts[raw.name] ?? 0,
      );
    }).toList();

    final List<Q1Theme> themes = _list(json['themes'])
        .map((dynamic e) => Q1Theme.fromJson(_map(e), byCode: byCode))
        .toList();

    return Q1FY27DashboardData(
      meta: meta,
      overview: overview,
      companies: companies,
      industries: industries,
      themes: themes,
    );
  }

  List<String> get sectors {
    final List<String> result = companies.map((Q1Company c) => c.sector).toSet().toList();
    result.sort();
    return result;
  }

  List<String> get industryNames {
    final List<String> result = companies.map((Q1Company c) => c.industry).toSet().toList();
    result.sort();
    return result;
  }

  List<Q1SectorSummary> get sectorSummaries {
    final List<Q1SectorSummary> result = sectors.map((String sector) {
      return Q1SectorSummary.fromCompanies(
        sector,
        companies.where((Q1Company c) => c.sector == sector).toList(),
      );
    }).toList();
    result.sort((Q1SectorSummary a, Q1SectorSummary b) => b.marketCap.compareTo(a.marketCap));
    return result;
  }

  List<Q1BreadthStat> get breadthStats {
    final List<Q1Company> salesBase = companies.where((Q1Company c) => c.salesGrowth != null).toList();
    final List<Q1Company> profitBase = companies.where((Q1Company c) => c.profitGrowth != null).toList();
    final List<Q1Company> marginBase = companies.where((Q1Company c) => c.marginChange != null).toList();
    final List<Q1Company> bothBase = companies.where((Q1Company c) => c.salesGrowth != null && c.profitGrowth != null).toList();

    return <Q1BreadthStat>[
      Q1BreadthStat(
        title: 'Grew sales',
        count: salesBase.where((Q1Company c) => c.salesGrowth! > 0).length,
        base: salesBase.length,
      ),
      Q1BreadthStat(
        title: 'Grew profit',
        count: profitBase.where((Q1Company c) => c.profitGrowth! > 0).length,
        base: profitBase.length,
      ),
      Q1BreadthStat(
        title: 'Expanded margins',
        count: marginBase.where((Q1Company c) => c.marginChange! > 0).length,
        base: marginBase.length,
      ),
      Q1BreadthStat(
        title: 'Grew sales & profit',
        count: bothBase.where((Q1Company c) => c.salesGrowth! > 0 && c.profitGrowth! > 0).length,
        base: bothBase.length,
      ),
    ];
  }

  List<Q1DistributionBucket> get profitDistribution {
    final List<Q1DistributionBucket> buckets = <Q1DistributionBucket>[
      const Q1DistributionBucket('< -50%', double.negativeInfinity, -50),
      const Q1DistributionBucket('-50—-20%', -50, -20),
      const Q1DistributionBucket('-20—0%', -20, 0),
      const Q1DistributionBucket('0—20%', 0, 20),
      const Q1DistributionBucket('20—50%', 20, 50),
      const Q1DistributionBucket('50—100%', 50, 100),
      const Q1DistributionBucket('> 100%', 100, double.infinity),
    ];
    return buckets.map((Q1DistributionBucket bucket) {
      final int count = companies.where((Q1Company c) {
        final double? v = c.profitGrowth;
        return v != null && v >= bucket.min && v < bucket.max;
      }).length;
      return bucket.copyWith(count: count);
    }).toList();
  }

  Q1Company? companyByCode(String code) {
    for (final Q1Company c in companies) {
      if (c.bseCode == code) return c;
    }
    return null;
  }

  static String capSegmentForRank(int rank) {
    if (rank <= 100) return 'Large Cap';
    if (rank <= 250) return 'Mid Cap';
    if (rank <= 500) return 'Small Cap';
    if (rank <= 750) return 'Micro Cap';
    return 'Beyond Top 750';
  }
}

class Q1FY27Meta {
  const Q1FY27Meta({
    required this.asOf,
    required this.source,
    required this.companyCount,
    required this.sectorCount,
    required this.industryCount,
  });

  final String asOf;
  final String source;
  final int companyCount;
  final int sectorCount;
  final int industryCount;

  factory Q1FY27Meta.fromJson(Map<String, dynamic> json) {
    return Q1FY27Meta(
      asOf: _string(json['asOf'], fallback: 'Q1 FY27'),
      source: _string(json['source'], fallback: 'NIFTY ALLCAP Q1 FY27 workbook'),
      companyCount: _int(json['companyCount']),
      sectorCount: _int(json['sectorCount']),
      industryCount: _int(json['industryCount']),
    );
  }
}

class Q1OverviewRow {
  const Q1OverviewRow({
    required this.key,
    required this.label,
    required this.marketCap,
    required this.weight,
    required this.salesFY27,
    required this.salesFY26,
    required this.profitFY27,
    required this.profitFY26,
    required this.marginFY27,
    required this.marginFY26,
    required this.marginChange,
    required this.salesGrowth,
    required this.profitGrowth,
  });

  final String key;
  final String label;
  final double marketCap;
  final double weight;
  final double salesFY27;
  final double salesFY26;
  final double profitFY27;
  final double profitFY26;
  final double marginFY27;
  final double marginFY26;
  final double marginChange;
  final double salesGrowth;
  final double profitGrowth;

  factory Q1OverviewRow.fromJson(Map<String, dynamic> json) {
    return Q1OverviewRow(
      key: _string(json['key']),
      label: _string(json['label']),
      marketCap: _double(json['mc']),
      weight: _double(json['w']),
      salesFY27: _double(json['s27']),
      salesFY26: _double(json['s26']),
      profitFY27: _double(json['p27']),
      profitFY26: _double(json['p26']),
      marginFY27: _double(json['m27']),
      marginFY26: _double(json['m26']),
      marginChange: _double(json['mcg']),
      salesGrowth: _double(json['sg']),
      profitGrowth: _double(json['pg']),
    );
  }
}

class Q1Company {
  const Q1Company({
    required this.name,
    required this.bseCode,
    required this.symbol,
    required this.sector,
    required this.industry,
    required this.price,
    required this.marketCap,
    required this.weight,
    required this.salesFY27,
    required this.salesFY26,
    required this.profitFY27,
    required this.profitFY26,
    required this.marginFY27,
    required this.marginFY26,
    required this.marginChange,
    required this.salesGrowth,
    required this.profitGrowth,
    this.rank = 0,
    this.capSegment = '',
  });

  final String name;
  final String bseCode;
  final String symbol;
  final String sector;
  final String industry;
  final double price;
  final double marketCap;
  final double weight;
  final double salesFY27;
  final double salesFY26;
  final double profitFY27;
  final double profitFY26;
  final double marginFY27;
  final double marginFY26;
  final double? marginChange;
  final double? salesGrowth;
  final double? profitGrowth;
  final int rank;
  final String capSegment;

  factory Q1Company.fromJson(Map<String, dynamic> json) {
    return Q1Company(
      name: _string(json['n']),
      bseCode: _string(json['c']),
      symbol: _string(json['s']),
      sector: _string(json['sec'], fallback: 'Unclassified'),
      industry: _string(json['ind'], fallback: 'Unclassified'),
      price: _double(json['pr']),
      marketCap: _double(json['mc']),
      weight: _double(json['w']),
      salesFY27: _double(json['s27']),
      salesFY26: _double(json['s26']),
      profitFY27: _double(json['p27']),
      profitFY26: _double(json['p26']),
      marginFY27: _double(json['m27']),
      marginFY26: _double(json['m26']),
      marginChange: _nullableDouble(json['mcg']),
      salesGrowth: _nullableDouble(json['sg']),
      profitGrowth: _nullableDouble(json['pg']),
    );
  }

  Q1Company copyWith({int? rank, String? capSegment}) {
    return Q1Company(
      name: name,
      bseCode: bseCode,
      symbol: symbol,
      sector: sector,
      industry: industry,
      price: price,
      marketCap: marketCap,
      weight: weight,
      salesFY27: salesFY27,
      salesFY26: salesFY26,
      profitFY27: profitFY27,
      profitFY26: profitFY26,
      marginFY27: marginFY27,
      marginFY26: marginFY26,
      marginChange: marginChange,
      salesGrowth: salesGrowth,
      profitGrowth: profitGrowth,
      rank: rank ?? this.rank,
      capSegment: capSegment ?? this.capSegment,
    );
  }
}

class Q1Industry {
  const Q1Industry({
    required this.name,
    required this.companies,
    required this.marketCap,
    required this.salesFY27,
    required this.salesFY26,
    required this.profitFY27,
    required this.profitFY26,
    required this.marginFY27,
    required this.marginFY26,
    required this.marginChange,
    required this.salesGrowth,
    required this.profitGrowth,
    this.sector = '',
    this.allCapCompanies = 0,
  });

  final String name;
  final int companies;
  final double marketCap;
  final double salesFY27;
  final double salesFY26;
  final double profitFY27;
  final double profitFY26;
  final double marginFY27;
  final double marginFY26;
  final double? marginChange;
  final double? salesGrowth;
  final double? profitGrowth;
  final String sector;
  final int allCapCompanies;

  factory Q1Industry.fromJson(Map<String, dynamic> json) {
    return Q1Industry(
      name: _string(json['ind']),
      companies: _int(json['cnt']),
      marketCap: _double(json['mc']),
      salesFY27: _double(json['s27']),
      salesFY26: _double(json['s26']),
      profitFY27: _double(json['p27']),
      profitFY26: _double(json['p26']),
      marginFY27: _double(json['m27']),
      marginFY26: _double(json['m26']),
      marginChange: _nullableDouble(json['mcg']),
      salesGrowth: _nullableDouble(json['sg']),
      profitGrowth: _nullableDouble(json['pg']),
    );
  }

  Q1Industry copyWith({String? sector, int? allCapCompanies}) {
    return Q1Industry(
      name: name,
      companies: companies,
      marketCap: marketCap,
      salesFY27: salesFY27,
      salesFY26: salesFY26,
      profitFY27: profitFY27,
      profitFY26: profitFY26,
      marginFY27: marginFY27,
      marginFY26: marginFY26,
      marginChange: marginChange,
      salesGrowth: salesGrowth,
      profitGrowth: profitGrowth,
      sector: sector ?? this.sector,
      allCapCompanies: allCapCompanies ?? this.allCapCompanies,
    );
  }
}

class Q1Theme {
  const Q1Theme({
    required this.name,
    required this.count,
    required this.marketCap,
    required this.salesFY27,
    required this.salesFY26,
    required this.profitFY27,
    required this.profitFY26,
    required this.marginFY27,
    required this.marginFY26,
    required this.marginChange,
    required this.salesGrowth,
    required this.profitGrowth,
    required this.members,
  });

  final String name;
  final int count;
  final double marketCap;
  final double salesFY27;
  final double salesFY26;
  final double profitFY27;
  final double profitFY26;
  final double marginFY27;
  final double marginFY26;
  final double? marginChange;
  final double? salesGrowth;
  final double? profitGrowth;
  final List<Q1ThemeMember> members;

  factory Q1Theme.fromJson(
    Map<String, dynamic> json, {
    required Map<String, Q1Company> byCode,
  }) {
    return Q1Theme(
      name: _string(json['name']),
      count: _int(json['cnt']),
      marketCap: _double(json['mc']),
      salesFY27: _double(json['s27']),
      salesFY26: _double(json['s26']),
      profitFY27: _double(json['p27']),
      profitFY26: _double(json['p26']),
      marginFY27: _double(json['m27']),
      marginFY26: _double(json['m26']),
      marginChange: _nullableDouble(json['mcg']),
      salesGrowth: _nullableDouble(json['sg']),
      profitGrowth: _nullableDouble(json['pg']),
      members: _list(json['members'])
          .map(
            (dynamic e) => Q1ThemeMember.fromJson(
              _map(e),
              company: byCode[_string(_map(e)['c'])],
            ),
          )
          .toList(),
    );
  }
}

class Q1ThemeMember {
  const Q1ThemeMember({
    required this.name,
    required this.bseCode,
    required this.symbol,
    required this.sector,
    required this.industry,
    required this.price,
    required this.marketCap,
    required this.weight,
    required this.salesGrowth,
    required this.profitGrowth,
    required this.marginFY27,
    required this.marginChange,
  });

  final String name;
  final String bseCode;
  final String symbol;
  final String sector;
  final String industry;
  final double price;
  final double marketCap;
  final double weight;
  final double? salesGrowth;
  final double? profitGrowth;
  final double marginFY27;
  final double? marginChange;

  factory Q1ThemeMember.fromJson(
    Map<String, dynamic> json, {
    Q1Company? company,
  }) {
    return Q1ThemeMember(
      name: company?.name ?? _string(json['s'], fallback: _string(json['c'])),
      bseCode: _string(json['c']),
      symbol: _string(json['s']),
      sector: _string(json['sec']),
      industry: _string(json['ind']),
      price: _double(json['pr']),
      marketCap: _double(json['mc']),
      weight: _double(json['w']),
      salesGrowth: _nullableDouble(json['sg']),
      profitGrowth: _nullableDouble(json['pg']),
      marginFY27: _double(json['m27']),
      marginChange: _nullableDouble(json['mcg']),
    );
  }
}

class Q1SectorSummary {
  const Q1SectorSummary({
    required this.sector,
    required this.companies,
    required this.marketCap,
    required this.salesFY27,
    required this.salesFY26,
    required this.profitFY27,
    required this.profitFY26,
    required this.salesGrowth,
    required this.profitGrowth,
    required this.marginFY27,
    required this.marginFY26,
    required this.marginChange,
  });

  final String sector;
  final int companies;
  final double marketCap;
  final double salesFY27;
  final double salesFY26;
  final double profitFY27;
  final double profitFY26;
  final double? salesGrowth;
  final double? profitGrowth;
  final double? marginFY27;
  final double? marginFY26;
  final double? marginChange;

  factory Q1SectorSummary.fromCompanies(String sector, List<Q1Company> rows) {
    double mc = 0;
    double s27 = 0;
    double s26 = 0;
    double p27 = 0;
    double p26 = 0;
    for (final Q1Company c in rows) {
      mc += c.marketCap;
      s27 += c.salesFY27;
      s26 += c.salesFY26;
      p27 += c.profitFY27;
      p26 += c.profitFY26;
    }
    final double? sg = s26 == 0 ? null : (s27 / s26 - 1) * 100;
    final double? pg = p26 <= 0 ? null : (p27 / p26 - 1) * 100;
    final double? m27 = s27 == 0 ? null : p27 / s27 * 100;
    final double? m26 = s26 == 0 ? null : p26 / s26 * 100;
    final double? mcg = m27 == null || m26 == null ? null : m27 - m26;

    return Q1SectorSummary(
      sector: sector,
      companies: rows.length,
      marketCap: mc,
      salesFY27: s27,
      salesFY26: s26,
      profitFY27: p27,
      profitFY26: p26,
      salesGrowth: sg,
      profitGrowth: pg,
      marginFY27: m27,
      marginFY26: m26,
      marginChange: mcg,
    );
  }
}

class Q1BreadthStat {
  const Q1BreadthStat({required this.title, required this.count, required this.base});
  final String title;
  final int count;
  final int base;
  double get percent => base == 0 ? 0 : count / base * 100;
}

class Q1DistributionBucket {
  const Q1DistributionBucket(this.label, this.min, this.max, {this.count = 0});
  final String label;
  final double min;
  final double max;
  final int count;

  Q1DistributionBucket copyWith({int? count}) {
    return Q1DistributionBucket(label, min, max, count: count ?? this.count);
  }
}

class Q1Format {
  const Q1Format._();

  static String marketCap(double value) {
    if (value.abs() >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(2)} L Cr';
    }
    return '${money(value)} Cr';
  }

  static String money(double value, {int decimals = 0}) {
    final bool negative = value < 0;
    final double absValue = value.abs();
    final String raw = decimals == 0
        ? absValue.round().toString()
        : absValue.toStringAsFixed(decimals);
    final List<String> parts = raw.split('.');
    String whole = parts.first;
    if (whole.length > 3) {
      final String last3 = whole.substring(whole.length - 3);
      String head = whole.substring(0, whole.length - 3);
      final List<String> groups = <String>[];
      while (head.length > 2) {
        groups.insert(0, head.substring(head.length - 2));
        head = head.substring(0, head.length - 2);
      }
      if (head.isNotEmpty) groups.insert(0, head);
      whole = '${groups.join(',')},$last3';
    }
    final String fraction = parts.length > 1 ? '.${parts[1]}' : '';
    return '${negative ? '-' : ''}₹$whole$fraction';
  }

  static String crore(double value) => '${money(value)} Cr';

  static String price(double value) => money(value, decimals: 2);

  static String pct(double? value, {int decimals = 2}) {
    if (value == null) return '—';
    return '${value >= 0 ? '+' : ''}${value.toStringAsFixed(decimals)}%';
  }

  static String plainPct(double? value, {int decimals = 2}) {
    if (value == null) return '—';
    return '${value.toStringAsFixed(decimals)}%';
  }

  static String pp(double? value, {int decimals = 2}) {
    if (value == null) return '—';
    return '${value >= 0 ? '+' : ''}${value.toStringAsFixed(decimals)} pp';
  }
}

Map<String, dynamic> _map(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

List<dynamic> _list(dynamic value) => value is List ? value : const <dynamic>[];

String _string(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final String result = value.toString().trim();
  return result.isEmpty ? fallback : result;
}

double _double(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

double? _nullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

int _int(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
