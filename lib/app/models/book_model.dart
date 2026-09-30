import 'package:webinar/common/utils/constants.dart';

class BookFaq {
  final String question;
  final String answer;

  const BookFaq({
    required this.question,
    required this.answer,
  });

  factory BookFaq.fromJson(Map<String, dynamic> json) {
    return BookFaq(
      question: _firstString(json, const <String>[
        'question',
        'title',
        'name',
      ]),
      answer: _stripHtml(
        _firstString(json, const <String>[
          'answer',
          'description',
          'content',
        ]),
      ),
    );
  }
}

class BookModel {
  final String id;
  final String slug;
  final String title;
  final String author;
  final String description;
  final String image;
  final List<String> images;
  final double price;
  final double? oldPrice;
  final String category;
  final String productType;
  final bool inStock;
  final int? stock;
  final double rating;
  final int reviewsCount;
  final bool freeShipping;
  final String shippingText;
  final Map<String, String> specifications;
  final List<BookFaq> faqs;
  final String cartItemName;
  final Map<String, dynamic> raw;

  const BookModel({
    required this.id,
    required this.slug,
    required this.title,
    required this.author,
    required this.description,
    required this.image,
    required this.images,
    required this.price,
    required this.oldPrice,
    required this.category,
    required this.productType,
    required this.inStock,
    required this.stock,
    required this.rating,
    required this.reviewsCount,
    required this.freeShipping,
    required this.shippingText,
    required this.specifications,
    required this.faqs,
    required this.cartItemName,
    required this.raw,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> translation = _asMap(json['translation']);
    final Map<String, dynamic> categoryMap = _asMap(json['category']);
    final Map<String, dynamic> sellerMap = _firstMap(<dynamic>[
      json['seller'],
      json['creator'],
      json['user'],
      json['provider'],
    ]);

    final String id = _firstNonEmpty(<String>[
      _firstString(json, const <String>['id', 'product_id', 'item_id']),
    ]);

    final String title = _firstNonEmpty(<String>[
      _firstString(json, const <String>['title', 'name', 'product_title']),
      _firstString(translation, const <String>['title', 'name']),
    ]);

    final Map<String, String> specifications = _readSpecifications(json);

    final String author = _firstNonEmpty(<String>[
      _firstString(json, const <String>['author', 'author_name']),
      specifications['Author'] ?? '',
      specifications['author'] ?? '',
      _firstString(sellerMap, const <String>['full_name', 'fullName', 'name']),
    ]);

    final String description = _stripHtml(
      _firstNonEmpty(<String>[
        _firstString(json, const <String>[
          'description',
          'content',
          'summary',
          'product_description',
        ]),
        _firstString(translation, const <String>[
          'description',
          'content',
          'summary',
        ]),
      ]),
    );

    final List<String> images = _readImages(json);

    final double regularPrice = _firstNumber(json, const <String>[
      'price',
      'amount',
      'regular_price',
      'regularPrice',
    ]);

    final double discountedPrice = _firstNumber(json, const <String>[
      'price_with_discount',
      'priceWithDiscount',
      'discount_price',
      'discountPrice',
      'discounted_price',
      'discountedPrice',
      'final_price',
      'finalPrice',
    ]);

    final double price = discountedPrice > 0 ? discountedPrice : regularPrice;

    final double explicitOldPrice = _firstNumber(json, const <String>[
      'old_price',
      'oldPrice',
      'original_price',
      'originalPrice',
    ]);

    double? oldPrice;
    if (explicitOldPrice > price && price > 0) {
      oldPrice = explicitOldPrice;
    } else if (regularPrice > price && price > 0) {
      oldPrice = regularPrice;
    }

    final int? stock = _firstNullableInt(json, const <String>[
      'stock',
      'inventory',
      'quantity',
      'available_quantity',
      'availableQuantity',
    ]);

    final String availability = _firstString(json, const <String>[
      'availability',
      'stock_status',
      'stockStatus',
      'status',
    ]).toLowerCase();

    final bool unlimitedInventory = _firstBool(json, const <String>[
      'unlimited_inventory',
      'unlimitedInventory',
    ]);

    bool inStock = true;
    if (availability.contains('out of stock') ||
        availability == 'out_of_stock' ||
        availability == 'unavailable') {
      inStock = false;
    } else if (!unlimitedInventory && stock != null) {
      inStock = stock > 0;
    }

    final String category = _firstNonEmpty(<String>[
      _firstString(categoryMap, const <String>['title', 'name']),
      _firstString(json, const <String>['category_title', 'category_name']),
      json['category'] is String ? json['category'].toString() : '',
    ]);

    final String productType = _firstNonEmpty(<String>[
      _firstString(json, const <String>[
        'product_type',
        'productType',
        'type_title',
        'typeTitle',
      ]),
      _firstString(_asMap(json['type']), const <String>['title', 'name']),
      'Physical Book',
    ]);

    final double rating = _firstNumber(json, const <String>[
      'rate',
      'rating',
      'average_rate',
      'averageRate',
      'reviews_average',
      'reviewsAverage',
    ]);

    final int reviewsCount = _firstNullableInt(json, const <String>[
          'reviews_count',
          'reviewsCount',
          'review_count',
          'reviewCount',
        ]) ??
        0;

    final bool freeShipping = _firstBool(json, const <String>[
      'free_shipping',
      'freeShipping',
      'is_free_shipping',
      'isFreeShipping',
    ]);

    final String shippingText = _firstNonEmpty(<String>[
      _firstString(json, const <String>[
        'shipping_text',
        'shippingText',
        'delivery_text',
        'deliveryText',
        'delivery_time',
        'deliveryTime',
      ]),
      _firstString(_asMap(json['delivery']), const <String>[
        'title',
        'text',
        'description',
      ]),
    ]);

    final List<BookFaq> faqs = _readFaqs(json);

    final String cartItemName = _firstNonEmpty(<String>[
      _firstString(json, const <String>[
        'cart_item_name',
        'cartItemName',
        'item_name',
        'itemName',
      ]),
      'product',
    ]);

    return BookModel(
      id: id,
      slug: _firstString(json, const <String>['slug']),
      title: title,
      author: author,
      description: description,
      image: images.isNotEmpty ? images.first : '',
      images: images,
      price: price,
      oldPrice: oldPrice,
      category: category,
      productType: productType,
      inStock: inStock,
      stock: stock,
      rating: rating,
      reviewsCount: reviewsCount,
      freeShipping: freeShipping,
      shippingText: shippingText,
      specifications: specifications,
      faqs: faqs,
      cartItemName: cartItemName,
      raw: Map<String, dynamic>.from(json),
    );
  }

  BookModel merge(BookModel other) {
    return BookModel(
      id: other.id.isNotEmpty ? other.id : id,
      slug: other.slug.isNotEmpty ? other.slug : slug,
      title: other.title.isNotEmpty ? other.title : title,
      author: other.author.isNotEmpty ? other.author : author,
      description:
          other.description.isNotEmpty ? other.description : description,
      image: other.image.isNotEmpty ? other.image : image,
      images: other.images.isNotEmpty ? other.images : images,
      price: other.price > 0 ? other.price : price,
      oldPrice: other.oldPrice ?? oldPrice,
      category: other.category.isNotEmpty ? other.category : category,
      productType:
          other.productType.isNotEmpty ? other.productType : productType,
      inStock: other.inStock,
      stock: other.stock ?? stock,
      rating: other.rating > 0 ? other.rating : rating,
      reviewsCount: other.reviewsCount > 0 ? other.reviewsCount : reviewsCount,
      freeShipping: other.freeShipping || freeShipping,
      shippingText:
          other.shippingText.isNotEmpty ? other.shippingText : shippingText,
      specifications: other.specifications.isNotEmpty
          ? other.specifications
          : specifications,
      faqs: other.faqs.isNotEmpty ? other.faqs : faqs,
      cartItemName:
          other.cartItemName.isNotEmpty ? other.cartItemName : cartItemName,
      raw: other.raw.isNotEmpty ? other.raw : raw,
    );
  }
}

List<String> _readImages(Map<String, dynamic> json) {
  final List<String> result = <String>[];

  void addImage(dynamic value) {
    if (value == null) return;

    if (value is String) {
      final String url = _absoluteUrl(value);
      if (url.isNotEmpty && !result.contains(url)) result.add(url);
      return;
    }

    if (value is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(value);
      final String url = _firstString(map, const <String>[
        'url',
        'path',
        'image',
        'image_url',
        'imageUrl',
        'src',
      ]);
      addImage(url);
      return;
    }

    if (value is List) {
      for (final dynamic item in value) {
        addImage(item);
      }
    }
  }

  addImage(json['images']);
  addImage(json['product_images']);
  addImage(json['productImages']);
  addImage(json['gallery']);
  addImage(json['media']);
  addImage(json['image']);
  addImage(json['thumbnail']);
  addImage(json['cover']);
  addImage(json['cover_image']);
  addImage(json['coverImage']);
  addImage(json['image_url']);
  addImage(json['imageUrl']);

  return result;
}

Map<String, String> _readSpecifications(Map<String, dynamic> json) {
  final Map<String, String> result = <String, String>{};
  final dynamic raw = json['specifications'] ??
      json['product_specifications'] ??
      json['productSpecifications'];

  if (raw is Map) {
    raw.forEach((dynamic key, dynamic value) {
      if (value == null) return;
      final String label = key.toString().trim();
      final String text = value is Map
          ? _firstString(Map<String, dynamic>.from(value), const <String>[
              'value',
              'title',
              'name',
            ])
          : value.toString().trim();
      if (label.isNotEmpty && text.isNotEmpty) result[label] = text;
    });
  }

  if (raw is List) {
    for (final dynamic item in raw) {
      if (item is! Map) continue;
      final Map<String, dynamic> map = Map<String, dynamic>.from(item);
      final String label = _firstString(map, const <String>[
        'title',
        'name',
        'key',
        'label',
      ]);
      String value = _firstString(map, const <String>[
        'value',
        'selected_value',
        'selectedValue',
        'description',
      ]);

      if (value.isEmpty && map['values'] is List) {
        value = (map['values'] as List)
            .map((dynamic e) => e.toString())
            .where((String e) => e.trim().isNotEmpty)
            .join(', ');
      }

      if (label.isNotEmpty && value.isNotEmpty) result[label] = value;
    }
  }

  return result;
}

List<BookFaq> _readFaqs(Map<String, dynamic> json) {
  final dynamic raw = json['faqs'] ?? json['faq'] ?? json['frequent_questions'];
  if (raw is! List) return <BookFaq>[];

  return raw
      .whereType<Map>()
      .map((Map item) => BookFaq.fromJson(Map<String, dynamic>.from(item)))
      .where((BookFaq faq) => faq.question.isNotEmpty || faq.answer.isNotEmpty)
      .toList();
}

String _absoluteUrl(String value) {
  final String text = value.trim();
  if (text.isEmpty || text.toLowerCase() == 'null') return '';
  if (text.startsWith('http://') || text.startsWith('https://')) return text;
  if (text.startsWith('//')) return 'https:$text';
  if (text.startsWith('/')) return '${Constants.dommain}$text';
  return '${Constants.dommain}/$text';
}

String _stripHtml(String value) {
  return value
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll(RegExp(r'\n\s*\n+'), '\n\n')
      .trim();
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

Map<String, dynamic> _firstMap(List<dynamic> values) {
  for (final dynamic value in values) {
    if (value is Map) return Map<String, dynamic>.from(value);
  }
  return <String, dynamic>{};
}

String _firstNonEmpty(List<String> values) {
  for (final String value in values) {
    if (value.trim().isNotEmpty) return value.trim();
  }
  return '';
}

String _firstString(Map<String, dynamic> json, List<String> keys) {
  for (final String key in keys) {
    final dynamic value = json[key];
    if (value == null || value is Map || value is List) continue;
    final String text = value.toString().trim();
    if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
  }
  return '';
}

double _firstNumber(Map<String, dynamic> json, List<String> keys) {
  for (final String key in keys) {
    final dynamic value = json[key];
    if (value is num) return value.toDouble();
    if (value != null) {
      final String cleaned = value
          .toString()
          .replaceAll(',', '')
          .replaceAll(RegExp(r'[^0-9.\-]'), '');
      final double? parsed = double.tryParse(cleaned);
      if (parsed != null) return parsed;
    }
  }
  return 0;
}

int? _firstNullableInt(Map<String, dynamic> json, List<String> keys) {
  for (final String key in keys) {
    final dynamic value = json[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value != null) {
      final int? parsed = int.tryParse(value.toString());
      if (parsed != null) return parsed;
    }
  }
  return null;
}

bool _firstBool(Map<String, dynamic> json, List<String> keys) {
  for (final String key in keys) {
    final dynamic value = json[key];
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value != null) {
      final String text = value.toString().trim().toLowerCase();
      if (text == 'true' || text == 'yes' || text == '1') return true;
      if (text == 'false' || text == 'no' || text == '0') return false;
    }
  }
  return false;
}
