import 'package:flutter/material.dart';
import 'package:webinar/app/pages/main_page/home_page/service_cart_page/service_cart_page.dart';
import 'package:webinar/app/services/personal_services/personal_service_api.dart';

/// A safe link from the existing Academy cart to the new services cart.
/// We deliberately do not merge service payments with course-cart checkout:
/// the current course backend cannot price or fulfil financial services.
class ServiceCartEntryBanner extends StatefulWidget {
  const ServiceCartEntryBanner({super.key});

  @override
  State<ServiceCartEntryBanner> createState() => _ServiceCartEntryBannerState();
}

class _ServiceCartEntryBannerState extends State<ServiceCartEntryBanner> {
  int? _count;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await PersonalServiceApi.cart();
      if (mounted) setState(() => _count = data.items.length);
    } catch (_) {
      // Don't interrupt the existing course-cart flow if the new backend
      // is unavailable or the signed-in user is not ready yet.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE9F6F2),
      child: InkWell(
        onTap: () async {
          await Navigator.of(context).push<void>(
            MaterialPageRoute<void>(builder: (_) => const ServiceCartPage()),
          );
          _load();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            const Icon(Icons.account_balance_wallet_outlined,
                color: Color(0xFF078F80), size: 22),
            const SizedBox(width: 10),
            Expanded(child: Text(
              _count == null || _count == 0
                  ? 'Financial Services Cart'
                  : 'Financial Services Cart ($_count)',
              style: const TextStyle(fontWeight: FontWeight.w800,
                  color: Color(0xFF143B36), fontSize: 13),
            )),
            const Text('View', style: TextStyle(color: Color(0xFF078F80),
                fontWeight: FontWeight.w700, fontSize: 13)),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF078F80)),
          ]),
        ),
      ),
    );
  }
}
