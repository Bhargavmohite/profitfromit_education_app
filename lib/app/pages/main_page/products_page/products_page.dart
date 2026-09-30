import 'package:flutter/material.dart';
import 'package:webinar/app/models/book_model.dart';
import 'package:webinar/app/pages/main_page/products_page/book_details_page.dart';
import 'package:webinar/app/services/guest_service/book_service.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/common/utils/currency_utils.dart';
import 'package:webinar/config/colors.dart';

class ProductsPage extends StatefulWidget {
  static const String pageName = '/productsPage';

  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final TextEditingController _searchController = TextEditingController();

  List<BookModel> _books = <BookModel>[];
  bool _isLoading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    if (mounted) setState(() => _isLoading = true);

    final List<BookModel> books = await BookService.getBooks();

    if (!mounted) return;
    setState(() {
      _books = books;
      _isLoading = false;
    });
  }

  List<BookModel> get _filteredBooks {
    final String query = _query.trim().toLowerCase();
    if (query.isEmpty) return _books;

    return _books.where((BookModel book) {
      return book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query) ||
          book.category.toLowerCase().contains(query) ||
          book.productType.toLowerCase().contains(query);
    }).toList();
  }

  void _openBook(BookModel book) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BookDetailsPage(book: book),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<BookModel> books = _filteredBooks;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FF),
      appBar: appbar(
        title: 'Books',
        isBasket: true,
        onTapLeftIcon: () => backRoute(),
      ),
      body: RefreshIndicator(
        onRefresh: _loadBooks,
        color: green77(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          children: <Widget>[
            const Text(
              'Books for Smart Investors',
              style: TextStyle(
                fontSize: 24,
                height: 1.2,
                fontWeight: FontWeight.w800,
                color: Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Practical knowledge to help you become a better long-term investor.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF667085),
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _searchController,
              onChanged: (String value) {
                setState(() => _query = value);
              },
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search books by title, author, topic...',
                hintStyle: const TextStyle(color: Color(0xFF98A2B3)),
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.close_rounded),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: green77(), width: 1.4),
                ),
              ),
            ),
            const SizedBox(height: 22),
            if (_isLoading) ...<Widget>[
              const _BookCardSkeleton(),
              const SizedBox(height: 16),
              const _BookCardSkeleton(),
              const SizedBox(height: 16),
              const _BookCardSkeleton(),
            ] else if (books.isEmpty) ...<Widget>[
              _EmptyBooks(
                hasSearch: _query.trim().isNotEmpty,
                onRetry: _loadBooks,
              ),
            ] else ...<Widget>[
              ...List<Widget>.generate(
                books.length,
                (int index) => Padding(
                  padding: EdgeInsets.only(
                    bottom: index == books.length - 1 ? 0 : 16,
                  ),
                  child: _BookCard(
                    book: books[index],
                    onTap: () => _openBook(books[index]),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final BookModel book;
  final VoidCallback onTap;

  const _BookCard({
    required this.book,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool limitedStock =
        book.stock != null && book.stock! > 0 && book.stock! <= 5;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFD8DEEA)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _BookCover(url: book.image),
              const SizedBox(width: 14),
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 184),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE7EDFF),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Text(
                                book.productType.isNotEmpty
                                    ? book.productType
                                    : 'Book',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF233876),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _StockLabel(
                            inStock: book.inStock,
                            limitedStock: limitedStock,
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Text(
                        book.title.isNotEmpty ? book.title : 'Book',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.2,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF101828),
                        ),
                      ),
                      if (book.author.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 5),
                        Text(
                          'By ${book.author}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF667085),
                          ),
                        ),
                      ],
                      if (book.rating > 0) ...<Widget>[
                        const SizedBox(height: 8),
                        Row(
                          children: <Widget>[
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFFFA000),
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              book.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF101828),
                              ),
                            ),
                            if (book.reviewsCount > 0) ...<Widget>[
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '(${book.reviewsCount} reviews)',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF98A2B3),
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                      const SizedBox(height: 13),
                      const Divider(height: 1, color: Color(0xFFE4E7EC)),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Wrap(
                              spacing: 7,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: <Widget>[
                                Text(
                                  _money(book.price),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF064E3B),
                                  ),
                                ),
                                if (book.oldPrice != null)
                                  Text(
                                    _money(book.oldPrice!),
                                    style: const TextStyle(
                                      color: Color(0xFF98A2B3),
                                      fontSize: 11,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: green77(),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            alignment: Alignment.center,
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  'View Details',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(width: 3),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ],
                            ),
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
  }
}

class _BookCover extends StatelessWidget {
  final String url;

  const _BookCover({required this.url});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(13),
      child: Container(
        width: 112,
        height: 184,
        color: const Color(0xFFF1F4F9),
        child: url.isEmpty
            ? const _ImageFallback()
            : Image.network(
                url,
                fit: BoxFit.cover,
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
                errorBuilder: (_, __, ___) => const _ImageFallback(),
              ),
      ),
    );
  }
}

class _StockLabel extends StatelessWidget {
  final bool inStock;
  final bool limitedStock;

  const _StockLabel({
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

    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.menu_book_rounded,
        size: 44,
        color: Color(0xFF98A2B3),
      ),
    );
  }
}

class _BookCardSkeleton extends StatelessWidget {
  const _BookCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 214,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: <Widget>[
          Container(
            width: 112,
            height: 184,
            decoration: BoxDecoration(
              color: const Color(0xFFEAECF0),
              borderRadius: BorderRadius.circular(13),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _bar(88),
                const SizedBox(height: 14),
                _bar(double.infinity),
                const SizedBox(height: 8),
                _bar(130),
                const Spacer(),
                _bar(90),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(double width) {
    return Container(
      width: width,
      height: 14,
      decoration: BoxDecoration(
        color: const Color(0xFFEAECF0),
        borderRadius: BorderRadius.circular(7),
      ),
    );
  }
}

class _EmptyBooks extends StatelessWidget {
  final bool hasSearch;
  final VoidCallback onRetry;

  const _EmptyBooks({
    required this.hasSearch,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 42),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        children: <Widget>[
          Icon(Icons.menu_book_rounded, size: 48, color: green77()),
          const SizedBox(height: 14),
          Text(
            hasSearch ? 'No matching books found' : 'No books available',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasSearch
                ? 'Try another search.'
                : 'Pull down to refresh or try again.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF667085)),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
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
