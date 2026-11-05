import 'dart:convert';

import 'package:webinar/common/utils/constants.dart';
import 'package:webinar/common/utils/http_handler.dart';

/// Separate from the existing Academy course cart API. The server owns all
/// prices, GST, payment status and private financial discovery records.
class PersonalServiceApi {
  static const String _base = '${Constants.baseUrl}personal-services/';

  static Map<String, dynamic> _decode(String body, int status) {
    Map<String, dynamic> json;
    try {
      final parsed = jsonDecode(body);
      if (parsed is! Map<String, dynamic>) throw const FormatException();
      json = parsed;
    } catch (_) {
      throw PersonalServiceException('Unexpected server response (HTTP $status).');
    }
    if (status < 200 || status >= 300 || json['success'] != true) {
      final message = json['message'];
      if (message is String && message.isNotEmpty) {
        throw PersonalServiceException(message);
      }
      if (status == 422 && json['errors'] is Map) {
        final errors = json['errors'] as Map;
        for (final value in errors.values) {
          if (value is List && value.isNotEmpty) {
            throw PersonalServiceException('Please check your details: ${value.first}');
          }
        }
      }
      if (status == 401) throw PersonalServiceException('Please sign in first.');
      throw PersonalServiceException('Request failed (HTTP $status).');
    }
    return json;
  }

  static Map<String, dynamic> _data(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map<String, dynamic>) return data;
    throw PersonalServiceException('The server returned incomplete data.');
  }

  static Future<void> saveFinancialPlanningAndAddToCart(
      Map<String, dynamic> draft, String submissionId) async {
    final response = await httpPostWithToken(
      '${_base}financial-planning',
      {'submission_id': submissionId, 'data': draft},
      isRedirectingStatusCode: false,
    );
    _data(_decode(response.body, response.statusCode));
  }

  static Future<ServiceCart> cart() async {
    final response = await httpGet('${_base}cart',
        isSendToken: true, isRedirectingStatusCode: false);
    return ServiceCart.fromJson(_data(_decode(response.body, response.statusCode)));
  }

  static Future<void> remove(int itemId) async {
    final response = await httpDeleteWithToken(
        '${_base}cart/$itemId', {}, isRedirectingStatusCode: false);
    _decode(response.body, response.statusCode);
  }

  static Future<EasebuzzSession> checkout() async {
    final response = await httpPostWithToken('${_base}cart/checkout', {},
        isRedirectingStatusCode: false);
    return EasebuzzSession.fromJson(_data(_decode(response.body, response.statusCode)));
  }

  static Future<PersonalServiceOrder> orderStatus(int orderId) async {
    final response = await httpGet('${_base}orders/$orderId/status',
        isSendToken: true, isRedirectingStatusCode: false);
    return PersonalServiceOrder.fromJson(_data(_decode(response.body, response.statusCode)));
  }
}

class PersonalServiceException implements Exception {
  final String message;
  const PersonalServiceException(this.message);
  @override
  String toString() => message;
}

class ServiceCart {
  final List<ServiceCartItem> items;
  final String subtotal;
  final String taxTotal;
  final String grandTotal;
  const ServiceCart({
    required this.items,
    required this.subtotal,
    required this.taxTotal,
    required this.grandTotal,
  });
  factory ServiceCart.fromJson(Map<String, dynamic> json) => ServiceCart(
        items: (json['items'] is List ? json['items'] as List : [])
            .whereType<Map<String, dynamic>>()
            .map(ServiceCartItem.fromJson)
            .toList(growable: false),
        subtotal: '${json['subtotal'] ?? '0.00'}',
        taxTotal: '${json['tax_total'] ?? '0.00'}',
        grandTotal: '${json['grand_total'] ?? '0.00'}',
      );
}

class ServiceCartItem {
  final int id;
  final String title;
  final String type;
  final String amount;
  const ServiceCartItem({
    required this.id,
    required this.title,
    required this.type,
    required this.amount,
  });
  factory ServiceCartItem.fromJson(Map<String, dynamic> json) => ServiceCartItem(
        id: (json['id'] as num).toInt(),
        title: '${json['title'] ?? 'Financial service'}',
        type: '${json['service_type'] ?? ''}',
        amount: '${json['total_amount'] ?? '0.00'}',
      );
}

class EasebuzzSession {
  final int orderId;
  final String accessKey;
  final String mode;
  final String amount;
  const EasebuzzSession({
    required this.orderId,
    required this.accessKey,
    required this.mode,
    required this.amount,
  });
  factory EasebuzzSession.fromJson(Map<String, dynamic> json) => EasebuzzSession(
        orderId: (json['order_id'] as num).toInt(),
        accessKey: '${json['access_key'] ?? ''}',
        mode: '${json['payment_mode'] ?? 'test'}',
        amount: '${json['amount'] ?? ''}',
      );
}

class PersonalServiceOrder {
  final int id;
  final String status;
  final String amount;
  final String txnid;
  const PersonalServiceOrder({
    required this.id,
    required this.status,
    required this.amount,
    required this.txnid,
  });
  factory PersonalServiceOrder.fromJson(Map<String, dynamic> json) => PersonalServiceOrder(
        id: (json['order_id'] as num).toInt(),
        status: '${json['status'] ?? 'pending'}',
        amount: '${json['amount'] ?? ''}',
        txnid: '${json['txnid'] ?? ''}',
      );
}
