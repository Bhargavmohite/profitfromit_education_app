import 'package:easebuzz_flutter/easebuzz_flutter.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webinar/app/services/personal_services/personal_service_api.dart';
import 'package:webinar/app/widgets/native_service_forms/native_service_form_widgets.dart';

/// Native service checkout. Academy course cart remains on its existing API.
class ServiceCartPage extends StatefulWidget {
  const ServiceCartPage({super.key});

  @override
  State<ServiceCartPage> createState() => _ServiceCartPageState();
}

class _ServiceCartPageState extends State<ServiceCartPage> {
  ServiceCart? _cart;
  PersonalServiceOrder? _lastOrder;
  bool _loading = true;
  bool _checkingOut = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cart = await PersonalServiceApi.cart();
      final preferences = await SharedPreferences.getInstance();
      final previousOrderId = preferences.getInt('personal_service_last_order_id');
      PersonalServiceOrder? lastOrder;
      if (previousOrderId != null) {
        try { lastOrder = await PersonalServiceApi.orderStatus(previousOrderId); }
        catch (_) { /* Cart still works even if prior order lookup fails. */ }
      }
      if (!mounted) return;
      setState(() {
        _cart = cart;
        _lastOrder = lastOrder;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _remove(int id) async {
    try {
      await PersonalServiceApi.remove(id);
      await _refresh();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$error')));
    }
  }

  Future<void> _checkStatus(int orderId) async {
    try {
      final verified = await PersonalServiceApi.orderStatus(orderId);
      if (!mounted) return;
      setState(() => _lastOrder = verified);
      if (verified.status == 'paid') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment verified by the server. A confirmation email will be sent.')),
        );
        await _refresh();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment not yet confirmed. Please check again later.')),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to verify payment: $error')));
    }
  }

  Future<void> _checkout() async {
    if (_checkingOut || (_cart?.items.isEmpty ?? true)) return;
    setState(() => _checkingOut = true);
    int? orderId;
    try {
      final session = await PersonalServiceApi.checkout();
      orderId = session.orderId;
      if (session.accessKey.isEmpty) {
        throw const PersonalServiceException('Payment access key is missing.');
      }
      final preferences = await SharedPreferences.getInstance();
      await preferences.setInt('personal_service_last_order_id', orderId);
      if (!mounted) return;
      // SDK result is informational only. Always verify with Laravel after SDK.
      try {
        await EasebuzzFlutter().payWithEasebuzz(session.accessKey, session.mode);
      } catch (_) {
        // A cancelled/failed SDK hand-off may still have an async gateway result.
        // Laravel is the only authority on whether funds were received.
      }
      if (mounted) await _checkStatus(orderId);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Checkout unavailable: $error')));
    } finally {
      if (mounted) setState(() => _checkingOut = false);
    }
  }

  Widget _summary(String label, String amount, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Expanded(child: Text(label, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w500))),
          Text('₹$amount', style: TextStyle(fontWeight: bold ? FontWeight.w900 : FontWeight.w600)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final cart = _cart;
    return Scaffold(
      backgroundColor: NativeFormTheme.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: NativeFormTheme.navy,
        title: const Text('Financial Services Cart'),
        actions: [IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _loading ? null : _refresh)],
      ),
      body: _loading && cart == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  if (_error != null) ...[
                    NativeNotice(text: 'Could not load services cart: $_error'),
                    const SizedBox(height: 16),
                  ],
                  if (cart == null || cart.items.isEmpty)
                    const NativeSectionCard(
                      icon: Icons.shopping_bag_outlined,
                      title: 'Your services cart is empty',
                      child: Text('Complete Financial Planning or Portfolio Diagnosis to add a service.'),
                    ),
                  if (cart != null && cart.items.isNotEmpty) ...[
                    const Text('YOUR SELECTED SERVICES',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: NativeFormTheme.teal)),
                    const SizedBox(height: 12),
                    ...cart.items.map((item) => Card(
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const CircleAvatar(
                                backgroundColor: Color(0xFFE5F4F1),
                                child: Icon(Icons.assignment_outlined, color: NativeFormTheme.teal),
                              ),
                              title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                              subtitle: Text('₹${item.amount} • Includes applicable tax'),
                              trailing: IconButton(
                                tooltip: 'Remove service',
                                icon: const Icon(Icons.delete_outline_rounded),
                                onPressed: _checkingOut ? null : () => _remove(item.id),
                              ),
                            ),
                          ),
                        )),
                    const SizedBox(height: 14),
                    NativeSectionCard(
                      title: 'Order summary',
                      icon: Icons.receipt_long_outlined,
                      child: Column(children: [
                        _summary('Subtotal', cart.subtotal),
                        _summary('GST', cart.taxTotal),
                        const Divider(),
                        _summary('Amount payable', cart.grandTotal, bold: true),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _checkingOut ? null : _checkout,
                      icon: _checkingOut
                          ? const SizedBox(height: 16, width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.lock_outline),
                      label: Text(_checkingOut ? 'Connecting to Easebuzz…' : 'Proceed to Secure Checkout'),
                      style: FilledButton.styleFrom(
                        backgroundColor: NativeFormTheme.teal,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Payments are confirmed only after server-side verification. Do not pay twice if a payment is pending.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: NativeFormTheme.muted)),
                  ],
                  if (_lastOrder != null) ...[
                    const SizedBox(height: 20),
                    NativeSectionCard(
                      title: 'Latest payment',
                      icon: Icons.verified_user_outlined,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                        Text('Order #${_lastOrder!.id} — ${_lastOrder!.status.toUpperCase()}',
                            style: const TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: _loading || _checkingOut ? null : () => _checkStatus(_lastOrder!.id),
                          icon: const Icon(Icons.fact_check_outlined),
                          label: const Text('Check Payment Status'),
                        ),
                      ]),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
