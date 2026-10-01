import 'package:flutter/material.dart';
import 'package:webinar/app/models/book_model.dart';
import 'package:webinar/app/services/guest_service/book_service.dart';
import 'package:webinar/app/services/user_service/cart_service.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/common/utils/currency_utils.dart';
import 'package:webinar/config/colors.dart';

class BookDetailsPage extends StatefulWidget {
  final BookModel book;

  const BookDetailsPage({
    super.key,
    required this.book,
  });

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  late BookModel _book;
  final PageController _pageController = PageController();

  int _selectedImage = 0;
  bool _isLoadingDetails = true;
  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    _book = widget.book;
    _loadDetails();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadDetails() async {
    final BookModel details = await BookService.getBookDetails(_book);
    if (!mounted) return;

    setState(() {
      _book = details;
      _isLoadingDetails = false;
      if (_selectedImage >= _book.images.length) _selectedImage = 0;
    });
  }

  Future<void> _addToCart() async {
    if (_isAddingToCart || !_book.inStock || _book.id.isEmpty) return;

    setState(() => _isAddingToCart = true);

    try {
      // Books are Store products. Use the same cart payload shape as the
      // existing working cart flow: item_name=product and specifications=''.
      await CartService.add(
        _book.id,
        'product',
        '',
      );
    } finally {
      if (mounted) {
        setState(() => _isAddingToCart = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FF),
      appBar: appbar(
        title: 'Book Details',
        isBasket: true,
        onTapLeftIcon: () => backRoute(),
      ),
      body: RefreshIndicator(
        onRefresh: _loadDetails,
        color: green77(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _gallery(),
              if (_isLoadingDetails) ...<Widget>[
                const SizedBox(height: 10),
                const LinearProgressIndicator(minHeight: 2),
              ],
              const SizedBox(height: 14),
              _badges(),
              const SizedBox(height: 12),
              Text(
                _book.title.isNotEmpty ? _book.title : 'Book',
                style: const TextStyle(
                  fontSize: 22,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF101828),
                ),
              ),
              if (_book.author.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  'By ${_book.author}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475467),
                  ),
                ),
              ],
              if (_book.rating > 0) ...<Widget>[
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFA000),
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _book.rating.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    if (_book.reviewsCount > 0)
                      Text(
                        ' (${_book.reviewsCount} reviews)',
                        style: const TextStyle(
                          color: Color(0xFF98A2B3),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 14),
              _purchaseCard(),
              if (_book.description.isNotEmpty) ...<Widget>[
                const SizedBox(height: 14),
                _sectionCard(
                  title: 'About This Book',
                  child: Text(
                    _book.description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.55,
                      color: Color(0xFF475467),
                    ),
                  ),
                ),
              ],
              if (_book.specifications.isNotEmpty ||
                  _book.author.isNotEmpty ||
                  _book.category.isNotEmpty) ...<Widget>[
                const SizedBox(height: 14),
                _sectionCard(
                  title: 'Book Details',
                  child: _bookDetails(),
                ),
              ],
              if (_book.freeShipping ||
                  _book.shippingText.isNotEmpty) ...<Widget>[
                const SizedBox(height: 14),
                _shippingCard(),
              ],
              if (_book.faqs.isNotEmpty) ...<Widget>[
                const SizedBox(height: 14),
                _faqCard(),
              ],
              const SizedBox(height: 14),
              _pincodeDeliveryCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Color(0xFFE4E7EC)),
            ),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'PRICE',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF667085),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _money(_book.price),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF101828),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 180,
                child: FilledButton.icon(
                  onPressed:
                      _book.inStock && !_isAddingToCart ? _addToCart : null,
                  icon: _isAddingToCart
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.add_shopping_cart_rounded, size: 19),
                  label: Text(
                    _book.inStock ? 'Add to Cart' : 'Out of Stock',
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: green77(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gallery() {
    final List<String> images = _book.images.isNotEmpty
        ? _book.images
        : (_book.image.isNotEmpty ? <String>[_book.image] : <String>[]);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0E6F0)),
      ),
      child: Column(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1.1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                color: const Color(0xFFF3F5F8),
                child: images.isEmpty
                    ? const Center(
                        child: Icon(
                          Icons.menu_book_rounded,
                          size: 72,
                          color: Color(0xFF98A2B3),
                        ),
                      )
                    : PageView.builder(
                        controller: _pageController,
                        itemCount: images.length,
                        onPageChanged: (int index) {
                          setState(() => _selectedImage = index);
                        },
                        itemBuilder: (BuildContext context, int index) {
                          return _NetworkImage(url: images[index]);
                        },
                      ),
              ),
            ),
          ),
          if (images.length > 1) ...<Widget>[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(
                images.length > 8 ? 8 : images.length,
                (int index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: index == _selectedImage ? 18 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: index == _selectedImage
                        ? green77()
                        : const Color(0xFFD0D5DD),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 68,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (BuildContext context, int index) {
                  final bool selected = index == _selectedImage;
                  return GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                      );
                    },
                    child: Container(
                      width: 58,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: selected ? green77() : const Color(0xFFD0D5DD),
                          width: selected ? 1.8 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: _NetworkImage(url: images[index]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _badges() {
    final bool limitedStock =
        _book.stock != null && _book.stock! > 0 && _book.stock! <= 5;

    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: <Widget>[
        if (_book.category.isNotEmpty) _Badge(text: _book.category),
        _Badge(
          text: _book.productType.isNotEmpty
              ? _book.productType
              : 'Physical Book',
        ),
        _StockBadge(
          inStock: _book.inStock,
          limitedStock: limitedStock,
        ),
      ],
    );
  }

  Widget _purchaseCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0E6F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Text(
                  _money(_book.price),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF101828),
                  ),
                ),
                if (_book.oldPrice != null)
                  Text(
                    _money(_book.oldPrice!),
                    style: const TextStyle(
                      color: Color(0xFF98A2B3),
                      fontSize: 13,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          FilledButton.icon(
            onPressed: _book.inStock && !_isAddingToCart ? _addToCart : null,
            icon: _isAddingToCart
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.add_shopping_cart_rounded, size: 18),
            label: const Text('Add to Cart'),
            style: FilledButton.styleFrom(
              backgroundColor: green77(),
              minimumSize: const Size(132, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bookDetails() {
    final Map<String, String> rows = <String, String>{};

    if (_book.author.isNotEmpty) rows['Author'] = _book.author;
    if (_book.category.isNotEmpty) rows['Category'] = _book.category;
    if (_book.productType.isNotEmpty) rows['Format'] = _book.productType;

    for (final MapEntry<String, String> entry in _book.specifications.entries) {
      if (entry.key.trim().isNotEmpty && entry.value.trim().isNotEmpty) {
        rows[entry.key] = entry.value;
      }
    }

    return Column(
      children: rows.entries.map((MapEntry<String, String> entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 105,
                child: Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF667085),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  entry.value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF101828),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _shippingCard() {
    return _sectionCard(
      title: 'Delivery & Shipping',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (_book.freeShipping)
            const Row(
              children: <Widget>[
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: Color(0xFF067647),
                  size: 18,
                ),
                SizedBox(width: 7),
                Text(
                  'Free Shipping',
                  style: TextStyle(
                    color: Color(0xFF067647),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          if (_book.freeShipping && _book.shippingText.isNotEmpty)
            const SizedBox(height: 10),
          if (_book.shippingText.isNotEmpty)
            Text(
              _book.shippingText,
              style: const TextStyle(
                fontSize: 13,
                height: 1.45,
                color: Color(0xFF475467),
              ),
            ),
        ],
      ),
    );
  }

  Widget _faqCard() {
    return _sectionCard(
      title: 'Frequently Asked Questions',
      child: Column(
        children: List<Widget>.generate(
          _book.faqs.length,
          (int index) {
            final BookFaq faq = _book.faqs[index];
            return Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 12),
                title: Text(
                  faq.question,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF101828),
                  ),
                ),
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      faq.answer,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.45,
                        color: Color(0xFF667085),
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

  Widget _pincodeDeliveryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F5FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD5E3FF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: Color(0xFF175CD3),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Delivery to Any PIN Code Address',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF101828),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Enter your complete delivery address and PIN code during checkout.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: Color(0xFF475467),
                  ),
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
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0E6F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _NetworkImage extends StatelessWidget {
  final String url;

  const _NetworkImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.contain,
      loadingBuilder: (
        BuildContext context,
        Widget child,
        ImageChunkEvent? progress,
      ) {
        if (progress == null) return child;
        return const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      },
      errorBuilder: (_, __, ___) => const Center(
        child: Icon(
          Icons.menu_book_rounded,
          size: 54,
          color: Color(0xFF98A2B3),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;

  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE7EDFF),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFF233876),
        ),
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  final bool inStock;
  final bool limitedStock;

  const _StockBadge({
    required this.inStock,
    required this.limitedStock,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = !inStock
        ? const Color(0xFFB42318)
        : limitedStock
            ? const Color(0xFFB54708)
            : const Color(0xFF067647);

    final String text = !inStock
        ? 'Out of Stock'
        : limitedStock
            ? 'Limited Stock'
            : 'In Stock';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

String _money(double value) {
  try {
    return CurrencyUtils.calculator(value);
  } catch (_) {
    if (value == value.roundToDouble()) {
      return '₹${value.toStringAsFixed(0)}';
    }
    return '₹${value.toStringAsFixed(2)}';
  }
}
