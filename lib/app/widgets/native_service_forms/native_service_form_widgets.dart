import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shared native-only visual system for both services.
/// No network calls, WebViews or payment-side effects are made here.
class NativeFormTheme {
  static const bg = Color(0xFFF5F7FB);
  static const navy = Color(0xFF142B4A);
  static const muted = Color(0xFF66768C);
  static const teal = Color(0xFF078F80);
  static const blue = Color(0xFF2267CE);
  static const border = Color(0xFFE3EAF2);
}

class NativeStepHeader extends StatelessWidget {
  const NativeStepHeader({
    super.key,
    required this.labels,
    required this.step,
    required this.title,
    required this.description,
  });

  final List<String> labels;
  final int step;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child:
                  Text('STEP ${step + 1} OF ${labels.length} • ${labels[step]}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .5,
                        color: NativeFormTheme.teal,
                      )),
            ),
            Text('${((step + 1) * 100 / labels.length).round()}%',
                style: const TextStyle(
                    color: NativeFormTheme.muted,
                    fontWeight: FontWeight.w700,
                    fontSize: 12)),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            minHeight: 7,
            value: (step + 1) / labels.length,
            backgroundColor: NativeFormTheme.border,
            valueColor:
                const AlwaysStoppedAnimation<Color>(NativeFormTheme.teal),
          ),
        ),
        const SizedBox(height: 21),
        Text(title,
            style: const TextStyle(
              color: NativeFormTheme.navy,
              fontSize: 23,
              height: 1.2,
              fontWeight: FontWeight.w900,
            )),
        const SizedBox(height: 7),
        Text(description,
            style: const TextStyle(
                color: NativeFormTheme.muted, fontSize: 13.5, height: 1.5)),
      ],
    );
  }
}

class NativeSectionCard extends StatelessWidget {
  const NativeSectionCard(
      {super.key, required this.child, this.title, this.icon});
  final Widget child;
  final String? title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NativeFormTheme.border),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0914294A), blurRadius: 20, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(children: [
              if (icon != null) ...[
                Icon(icon, size: 19, color: NativeFormTheme.teal),
                const SizedBox(width: 9),
              ],
              Expanded(
                child: Text(title!,
                    style: const TextStyle(
                        color: NativeFormTheme.navy,
                        fontWeight: FontWeight.w800,
                        fontSize: 15)),
              ),
            ]),
            const SizedBox(height: 18),
          ],
          child,
        ],
      ),
    );
  }
}

class NativeField extends StatelessWidget {
  const NativeField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.requiredField = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.isEmail = false,
    this.isPhone = false,
    this.isPositiveNumber = false,
    this.isNonNegativeNumber = false,
    this.integerOnly = false,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool requiredField;
  final TextInputType keyboardType;
  final int maxLines;
  final bool isEmail;
  final bool isPhone;
  final bool isPositiveNumber;
  final bool isNonNegativeNumber;
  final bool integerOnly;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        // Flutter requires the multiline keyboard with the newline action.
        // Keep the caller's keyboard type for ordinary single-line fields.
        keyboardType: maxLines > 1 ? TextInputType.multiline : keyboardType,
        maxLines: maxLines,
        textInputAction:
            maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
        inputFormatters:
            integerOnly ? [FilteringTextInputFormatter.digitsOnly] : null,
        style: const TextStyle(
            color: NativeFormTheme.navy,
            fontSize: 14,
            fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: requiredField ? '$label *' : label,
          hintText: hint,
          alignLabelWithHint: maxLines > 1,
          filled: true,
          fillColor: const Color(0xFFF9FBFF),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: NativeFormTheme.border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: NativeFormTheme.teal, width: 1.6)),
        ),
        validator: (raw) {
          final value = (raw ?? '').trim();
          if (requiredField && value.isEmpty) return 'Please enter $label';
          if (value.isEmpty) return null;
          if (isEmail &&
              !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
            return 'Enter a valid email address';
          }
          if (isPhone && !RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
            return 'Enter a 10-digit Indian mobile number';
          }
          if (isPositiveNumber || isNonNegativeNumber) {
            final numeric = double.tryParse(value.replaceAll(',', ''));
            if (numeric == null || !numeric.isFinite) {
              return 'Enter a valid number';
            }
            if (isPositiveNumber && numeric <= 0) {
              return 'Enter a value above zero';
            }
            if (isNonNegativeNumber && numeric < 0) {
              return 'Value cannot be negative';
            }
          }
          return null;
        },
      ),
    );
  }
}

class NativeSelect extends StatelessWidget {
  const NativeSelect({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    this.requiredField = false,
  });

  final String label;
  final List<String> options;
  final String? value;
  final ValueChanged<String?> onChanged;
  final bool requiredField;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        initialValue: options.contains(value) ? value : null,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: requiredField ? '$label *' : label,
          filled: true,
          fillColor: const Color(0xFFF9FBFF),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: NativeFormTheme.border)),
        ),
        items: options
            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
            .toList(),
        onChanged: onChanged,
        validator: (selected) {
          if (requiredField && selected == null) return 'Please select $label';
          return null;
        },
      ),
    );
  }
}

class NativeReviewRow extends StatelessWidget {
  const NativeReviewRow(this.label, this.value, {super.key});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          flex: 2,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12.5, color: NativeFormTheme.muted)),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: Text(value.trim().isEmpty ? 'Not provided' : value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: NativeFormTheme.navy)),
        ),
      ]),
    );
  }
}

class NativeFlowFooter extends StatelessWidget {
  const NativeFlowFooter({
    super.key,
    required this.onBack,
    required this.onNext,
    required this.nextLabel,
    this.isBusy = false,
  });
  final VoidCallback? onBack;
  final VoidCallback onNext;
  final String nextLabel;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
        child: Row(children: [
          if (onBack != null) ...[
            OutlinedButton.icon(
              onPressed: isBusy ? null : onBack,
              icon: const Icon(Icons.arrow_back_rounded, size: 17),
              label: const Text('Back'),
              style: OutlinedButton.styleFrom(
                foregroundColor: NativeFormTheme.navy,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: FilledButton.icon(
              onPressed: isBusy ? null : onNext,
              style: FilledButton.styleFrom(
                backgroundColor: NativeFormTheme.teal,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: Text(nextLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ]),
      ),
    );
  }
}

class NativeNotice extends StatelessWidget {
  const NativeNotice(
      {super.key, required this.text, this.icon = Icons.info_outline_rounded});
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5F3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: NativeFormTheme.teal, size: 19),
        const SizedBox(width: 10),
        Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: NativeFormTheme.navy, fontSize: 12.5, height: 1.5))),
      ]),
    );
  }
}

/// Safe placeholder for tomorrow's Laravel/Easebuzz integration.
/// Does not submit personal data, create an order or simulate a payment.
class NativePaymentHandoffPage extends StatelessWidget {
  const NativePaymentHandoffPage({
    super.key,
    required this.serviceName,
    required this.planName,
    required this.summary,
    required this.draftData,
  });
  final String serviceName;
  final String planName;
  final Map<String, String> summary;

  /// Backend-ready field map; intentionally kept in memory only.
  final Map<String, dynamic> draftData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NativeFormTheme.bg,
      appBar: AppBar(
        title: const Text('Review & Payment', style: TextStyle(fontSize: 17)),
        backgroundColor: Colors.white,
        foregroundColor: NativeFormTheme.navy,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const SizedBox(height: 14),
              Container(
                width: 74,
                height: 74,
                decoration: const BoxDecoration(
                    color: Color(0xFFE3F4F1), shape: BoxShape.circle),
                child: const Icon(Icons.receipt_long_rounded,
                    color: NativeFormTheme.teal, size: 36),
              ),
              const SizedBox(height: 20),
              const Text('Form completed',
                  style: TextStyle(
                      color: NativeFormTheme.navy,
                      fontSize: 25,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text('Your details have been captured in this app session.',
                  style: TextStyle(color: NativeFormTheme.muted, height: 1.5)),
              const SizedBox(height: 23),
              NativeSectionCard(
                title: 'Application preview',
                icon: Icons.fact_check_outlined,
                child: Column(children: [
                  NativeReviewRow('Service', serviceName),
                  NativeReviewRow('Selected plan', planName),
                  ...summary.entries
                      .map((e) => NativeReviewRow(e.key, e.value)),
                ]),
              ),
              const SizedBox(height: 18),
              const NativeNotice(
                icon: Icons.lock_outline_rounded,
                text:
                    'Easebuzz payment and Laravel submission are not connected yet. '
                    'No payment has been collected, no request has been submitted, '
                    'and your information has not been uploaded or saved.',
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: FilledButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.lock_outline_rounded),
                  label: const Text('Secure Payment • Integration Pending'),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to form'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
