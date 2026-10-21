import 'package:flutter/material.dart';
import 'package:webinar/app/pages/main_page/home_page/investment_baskets_page/investment_basket_data.dart';
import 'package:webinar/app/pages/main_page/home_page/investment_baskets_page/investment_basket_details_page.dart';
import 'package:webinar/app/pages/main_page/home_page/investment_baskets_page/investment_basket_widgets.dart';

/// Static, locally rendered Investment Baskets catalogue.
/// No server integration or authentication required to browse the page.
class InvestmentBasketsPage extends StatefulWidget {
  const InvestmentBasketsPage({super.key});
  static const String pageName = '/investment-baskets';

  @override
  State<InvestmentBasketsPage> createState() => _InvestmentBasketsPageState();
}

enum _FeeFilter { all, feeSix, feeTwelve }

class _InvestmentBasketsPageState extends State<InvestmentBasketsPage> {
  final TextEditingController _search = TextEditingController();
  _FeeFilter _filter = _FeeFilter.all;
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<InvestmentBasket> get _filtered {
    return investmentBaskets.where((basket) {
      final term = _query.trim().toLowerCase();
      final matchesSearch = term.isEmpty ||
          basket.name.toLowerCase().contains(term) ||
          basket.subtitle.toLowerCase().contains(term);
      final matchesFee = switch (_filter) {
        _FeeFilter.all => true,
        _FeeFilter.feeSix => basket.annualFee == 6000,
        _FeeFilter.feeTwelve => basket.annualFee == 12000,
      };
      return matchesSearch && matchesFee;
    }).toList();
  }

  void _openDetails(InvestmentBasket basket) {
    Navigator.of(context).push<void>(MaterialPageRoute<void>(
      builder: (_) => InvestmentBasketDetailsPage(basket: basket),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return BasketPageFrame(
      title: 'Investment Baskets',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _CatalogueHero(),
        const SizedBox(height: 26),
        const Text('Discover our baskets', style: TextStyle(
          fontSize: 22, color: BasketColors.ink, fontWeight: FontWeight.w900,
        )),
        const SizedBox(height: 5),
        const Text('Explore six themed strategies at a glance.', style: TextStyle(
          color: BasketColors.secondary, fontSize: 13, height: 1.45,
        )),
        const SizedBox(height: 18),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: BasketColors.outline),
          ),
          child: TextField(
            controller: _search,
            onChanged: (value) => setState(() => _query = value),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search investment baskets',
              hintStyle: const TextStyle(fontSize: 13, color: BasketColors.secondary),
              prefixIcon: const Icon(Icons.search_rounded, color: BasketColors.blue),
              suffixIcon: _query.isEmpty ? null : IconButton(
                tooltip: 'Clear search',
                onPressed: () { _search.clear(); setState(() => _query = ''); },
                icon: const Icon(Icons.close_rounded, size: 19),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 17),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _FilterChip(label: 'All baskets', selected: _filter == _FeeFilter.all,
              onTap: () => setState(() => _filter = _FeeFilter.all)),
            const SizedBox(width: 8),
            _FilterChip(label: '₹6,000 / year', selected: _filter == _FeeFilter.feeSix,
              onTap: () => setState(() => _filter = _FeeFilter.feeSix)),
            const SizedBox(width: 8),
            _FilterChip(label: '₹12,000 / year', selected: _filter == _FeeFilter.feeTwelve,
              onTap: () => setState(() => _filter = _FeeFilter.feeTwelve)),
          ]),
        ),
        const SizedBox(height: 17),
        Row(children: [
          Text('${filtered.length} basket${filtered.length == 1 ? '' : 's'}',
              style: const TextStyle(fontSize: 12, color: BasketColors.secondary,
                  fontWeight: FontWeight.w700)),
          const Spacer(),
          const Icon(Icons.verified_user_outlined,
              size: 15, color: BasketColors.green),
          const SizedBox(width: 5),
          const Flexible(child: Text('Risk: Aggressive',
              style: TextStyle(fontWeight: FontWeight.w700,
                  color: BasketColors.secondary, fontSize: 11))),
        ]),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          const _EmptyResults()
        else
          LayoutBuilder(builder: (context, constraints) {
            final width = constraints.maxWidth;
            final columns = width >= 930 ? 3 : (width >= 590 ? 2 : 1);
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisExtent: 267,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
              ),
              itemBuilder: (context, index) => _BasketTile(
                basket: filtered[index],
                index: investmentBaskets.indexOf(filtered[index]) + 1,
                onTap: () => _openDetails(filtered[index]),
              ),
            );
          }),
        const SizedBox(height: 22),
        const BasketEducationNote(text:
          'Profit Finstock Private Limited | SEBI Registered Investment Adviser: '
          'INA000020651. This catalogue is for information only, not a personalized '
          'recommendation. All baskets are labelled Aggressive in the supplied '
          'reference. Confirm strategy documents, fees, risks and suitability before investing.'),
      ]),
    );
  }
}

class _CatalogueHero extends StatelessWidget {
  const _CatalogueHero();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25),
      gradient: const LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [BasketColors.navy, BasketColors.navyLight, Color(0xFF28649C)],
      ),
    ),
    child: Stack(children: [
      Positioned(right: -80, top: -75, child: Container(
        width: 235, height: 235,
        decoration: BoxDecoration(shape: BoxShape.circle,
            border: Border.all(color: const Color(0x22FFFFFF), width: 28)),
      )),
      Positioned(right: 18, bottom: -65, child: Container(
        width: 130, height: 130,
        decoration: const BoxDecoration(shape: BoxShape.circle,
            color: Color(0x1749CDB9)),
      )),
      Padding(
        padding: const EdgeInsets.all(23),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const BasketPill(
            icon: Icons.shield_outlined,
            text: 'SEBI RIA • INA000020651',
            background: Color(0x25FFFFFF),
            foreground: Color(0xFFE0EAFF),
          ),
          const SizedBox(height: 21),
          const Text('Invest with\ndiscipline.',
              style: TextStyle(fontWeight: FontWeight.w900,
                  fontSize: 30, height: 1.14, letterSpacing: -.8,
                  color: Colors.white)),
          const SizedBox(height: 11),
          const Text(
            'Explore business-focused investment themes in one organised place.',
            style: TextStyle(color: Color(0xFFD7E5F6),
                fontSize: 12.5, height: 1.55),
          ),
          const SizedBox(height: 19),
          Wrap(spacing: 9, runSpacing: 9, children: [
            const BasketPill(text: '6 themed baskets',
              icon: Icons.grid_view_rounded, background: Color(0x22FFFFFF),
              foreground: Colors.white),
            OutlinedButton.icon(
              onPressed: () => showBasketLoginPending(context),
              icon: const Icon(Icons.login_rounded, size: 17),
              label: const Text('Investor Login'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color(0x7DFFFFFF)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
              ),
            ),
          ]),
        ]),
      ),
    ]),
  );
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? BasketColors.navy : Colors.white,
    shape: StadiumBorder(side: BorderSide(
        color: selected ? BasketColors.navy : BasketColors.outline)),
    child: InkWell(
      customBorder: const StadiumBorder(),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 15),
        child: Text(label, style: TextStyle(fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : BasketColors.secondary)),
      ),
    ),
  );
}

class _BasketTile extends StatelessWidget {
  const _BasketTile({required this.basket, required this.index, required this.onTap});
  final InvestmentBasket basket;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(21),
      side: const BorderSide(color: BasketColors.outline),
    ),
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 48, height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: basket.paleAccent,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(basket.icon, size: 25, color: basket.accent),
            ),
            const Spacer(),
            Text(index.toString().padLeft(2, '0'),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900,
                  color: basket.accent.withValues(alpha: .18))),
          ]),
          const SizedBox(height: 13),
          Text(basket.name, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900,
                color: BasketColors.ink)),
          const SizedBox(height: 3),
          Text(basket.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: BasketColors.secondary)),
          const SizedBox(height: 13),
          Row(children: [
            const BasketPill(
              text: 'Aggressive',
              icon: Icons.show_chart_rounded,
              background: Color(0xFFFFF0E7),
              foreground: Color(0xFFA44A1B),
            ),
            const Spacer(),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              const Text('ANNUAL FEE', style: TextStyle(
                  letterSpacing: .5, fontSize: 9,
                  fontWeight: FontWeight.w700, color: BasketColors.secondary)),
              const SizedBox(height: 2),
              Text(basket.feeText, style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w900,
                  color: BasketColors.ink)),
            ]),
          ]),
          const Spacer(),
          SizedBox(width: double.infinity, height: 43,
            child: FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: basket.accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('Explore Basket', style: TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 12)),
                SizedBox(width: 6), Icon(Icons.arrow_forward_rounded, size: 17),
              ]),
            ),
          ),
        ]),
      ),
    ),
  );
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 38),
    decoration: BoxDecoration(color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      border: Border.all(color: BasketColors.outline)),
    child: const Column(children: [
      Icon(Icons.search_off_rounded, size: 38, color: BasketColors.secondary),
      SizedBox(height: 10),
      Text('No matching baskets', style: TextStyle(
          color: BasketColors.ink, fontSize: 16, fontWeight: FontWeight.w800)),
      SizedBox(height: 6),
      Text('Try another search or change the fee filter.',
        textAlign: TextAlign.center,
        style: TextStyle(color: BasketColors.secondary, fontSize: 12)),
    ]),
  );
}
