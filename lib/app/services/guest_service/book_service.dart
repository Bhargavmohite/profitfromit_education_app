import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:webinar/app/models/book_model.dart';
import 'package:webinar/common/utils/constants.dart';
import 'package:webinar/common/utils/http_handler.dart';

class BookService {
  // API only. No website HTML and no WebView are used here.
  // Different Rocket LMS versions expose Store products under slightly
  // different public API paths, so we safely try the common variants.
  static const List<String> _listPaths = <String>[
    'products?offset=0&limit=100',
    'store/products?offset=0&limit=100',
    'products',
    'store/products',
  ];

  static Future<List<BookModel>> getBooks() async {
    for (final String path in _listPaths) {
      try {
        final String url = '${Constants.baseUrl}$path';
        final Response response = await httpGet(
          url,
          isRedirectingStatusCode: false,
        ).timeout(const Duration(seconds: 20));

        debugPrint(
          'BOOK API LIST ======> $url | status: ${response.statusCode}',
        );

        if (response.statusCode < 200 || response.statusCode >= 300) {
          continue;
        }

        final dynamic decoded = jsonDecode(response.body);
        final List<Map<String, dynamic>>? products =
            _extractProductList(decoded);

        if (products == null) {
          debugPrint('BOOK API LIST ======> no products array found');
          continue;
        }

        final List<BookModel> books = products
            .map((Map<String, dynamic> item) => BookModel.fromJson(item))
            .where(
              (BookModel book) => book.id.isNotEmpty || book.title.isNotEmpty,
            )
            .toList();

        debugPrint('BOOK API LIST ======> books found: ${books.length}');
        return books;
      } on SocketException catch (e) {
        debugPrint('BOOK API NETWORK ERROR ======> $e');
        return <BookModel>[];
      } on TimeoutException catch (e) {
        debugPrint('BOOK API TIMEOUT ======> $e');
        return <BookModel>[];
      } on FormatException catch (e) {
        debugPrint('BOOK API JSON ERROR ======> $e');
      } catch (e, stackTrace) {
        debugPrint('BOOK API LIST ERROR ======> $e');
        debugPrintStack(stackTrace: stackTrace);
      }
    }

    return <BookModel>[];
  }

  static Future<BookModel> getBookDetails(BookModel book) async {
    final List<String> identifiers = <String>[
      if (book.slug.isNotEmpty) book.slug,
      if (book.id.isNotEmpty && book.id != book.slug) book.id,
    ];

    final List<String> paths = <String>[];
    for (final String identifier in identifiers) {
      final String safe = Uri.encodeComponent(identifier);
      paths.add('products/$safe');
      paths.add('store/products/$safe');
    }

    for (final String path in paths) {
      try {
        final String url = '${Constants.baseUrl}$path';
        final Response response = await httpGet(
          url,
          isRedirectingStatusCode: false,
        ).timeout(const Duration(seconds: 20));

        debugPrint(
          'BOOK API DETAILS ======> $url | status: ${response.statusCode}',
        );

        if (response.statusCode < 200 || response.statusCode >= 300) {
          continue;
        }

        final dynamic decoded = jsonDecode(response.body);
        final Map<String, dynamic>? product = _extractProduct(decoded);
        if (product == null) continue;

        return book.merge(BookModel.fromJson(product));
      } on SocketException catch (e) {
        debugPrint('BOOK DETAILS NETWORK ERROR ======> $e');
        return book;
      } on TimeoutException catch (e) {
        debugPrint('BOOK DETAILS TIMEOUT ======> $e');
        return book;
      } on FormatException catch (e) {
        debugPrint('BOOK DETAILS JSON ERROR ======> $e');
      } catch (e, stackTrace) {
        debugPrint('BOOK DETAILS ERROR ======> $e');
        debugPrintStack(stackTrace: stackTrace);
      }
    }

    // The list API may already contain enough fields for the details screen.
    // If no separate details endpoint is available, we keep those API values.
    return book;
  }

  static List<Map<String, dynamic>>? _extractProductList(dynamic decoded) {
    if (decoded is List) {
      return decoded
          .whereType<Map>()
          .map((Map item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (decoded is! Map) return null;
    final Map<String, dynamic> root = Map<String, dynamic>.from(decoded);

    if (root['success'] == false) return null;

    for (final String key in const <String>['products', 'items']) {
      final List<Map<String, dynamic>>? list = _listFrom(root[key]);
      if (list != null) return list;
    }

    final dynamic data = root['data'];
    final List<Map<String, dynamic>>? fromData = _listFrom(data);
    if (fromData != null) return fromData;

    return null;
  }

  static List<Map<String, dynamic>>? _listFrom(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((Map item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (value is! Map) return null;
    final Map<String, dynamic> map = Map<String, dynamic>.from(value);

    for (final String key in const <String>[
      'products',
      'items',
      'data',
      'list',
    ]) {
      final dynamic nested = map[key];
      if (nested is List) {
        return nested
            .whereType<Map>()
            .map((Map item) => Map<String, dynamic>.from(item))
            .toList();
      }
      if (nested is Map) {
        final List<Map<String, dynamic>>? deeper = _listFrom(nested);
        if (deeper != null) return deeper;
      }
    }

    return null;
  }

  static Map<String, dynamic>? _extractProduct(dynamic decoded) {
    if (decoded is! Map) return null;
    final Map<String, dynamic> root = Map<String, dynamic>.from(decoded);

    if (root['success'] == false) return null;

    dynamic candidate = root['product'] ?? root['data'] ?? root;

    if (candidate is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(candidate);

      if (map['product'] is Map) {
        return Map<String, dynamic>.from(map['product']);
      }

      if (_looksLikeProduct(map)) return map;
    }

    return null;
  }

  static bool _looksLikeProduct(Map<String, dynamic> map) {
    return map.containsKey('id') ||
        map.containsKey('product_id') ||
        map.containsKey('title') ||
        map.containsKey('name');
  }
}
