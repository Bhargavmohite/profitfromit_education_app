import 'package:flutter/material.dart';

/// UI-only catalogue values transcribed from the supplied reference design.
/// Confirm live fees, documentation and eligibility before publishing to clients.
@immutable
class InvestmentBasket {
  const InvestmentBasket({
    required this.id,
    required this.detailsUrl,
    required this.name,
    required this.shortName,
    required this.subtitle,
    required this.themeSummary,
    required this.annualFee,
    required this.icon,
    required this.accent,
    required this.paleAccent,
  });

  final String id;

  /// Dedicated Maxfolio page for this basket.
  final String detailsUrl;
  final String name;
  final String shortName;
  final String subtitle;
  final String themeSummary;
  final int annualFee;
  final IconData icon;
  final Color accent;
  final Color paleAccent;

  String get feeText => annualFee == 12000 ? '₹12,000' : '₹6,000';
  String get riskProfile => 'Aggressive';
}

const List<InvestmentBasket> investmentBaskets = [
  InvestmentBasket(
    id: 'samriddhi',
    detailsUrl:
        'https://profitfromit.maxfolio.in/details?pc=MA00022PFS2026D&bc=MTA1&up=&cd=&lc=',
    name: 'Bharat Samriddhi',
    shortName: 'Samriddhi',
    subtitle: 'Prosperity',
    themeSummary:
        'Explore the Bharat Samriddhi strategy and its investment framework.',
    annualFee: 12000,
    icon: Icons.auto_graph_rounded,
    accent: Color(0xFF6257DC),
    paleAccent: Color(0xFFF0EDFF),
  ),
  InvestmentBasket(
    id: 'atmanirbhar',
    detailsUrl:
        'https://profitfromit.maxfolio.in/details?pc=MA00022PFS2026D&bc=MTA3&up=&cd=&lc=',
    name: 'Bharat Atmanirbhar Shakti',
    shortName: 'Atmanirbhar Shakti',
    subtitle: 'Made in India',
    themeSummary:
        'Explore the Bharat AtmaNirbhar strategy and its investment framework.',
    annualFee: 12000,
    icon: Icons.precision_manufacturing_outlined,
    accent: Color(0xFF088DA7),
    paleAccent: Color(0xFFE4F6FA),
  ),
  InvestmentBasket(
    id: 'gatishakti',
    detailsUrl:
        'https://profitfromit.maxfolio.in/details?pc=MA00022PFS2026D&bc=MTA2&up=&cd=&lc=',
    name: 'Bharat Gati Shakti',
    shortName: 'GatiShakti',
    subtitle: 'Momentum',
    themeSummary:
        'Explore the Bharat GatiShakti strategy and its investment framework.',
    annualFee: 12000,
    icon: Icons.trending_up_rounded,
    accent: Color(0xFF098668),
    paleAccent: Color(0xFFE1F5EE),
  ),
  InvestmentBasket(
    id: 'navya',
    detailsUrl:
        'https://profitfromit.maxfolio.in/details?pc=MA00022PFS2026D&bc=MTA0&up=&cd=&lc=',
    name: 'Navya Bharat',
    shortName: 'Navya Bharat',
    subtitle: 'New India',
    themeSummary:
        'Explore the Navya Bharat strategy and its investment framework.',
    annualFee: 6000,
    icon: Icons.public_rounded,
    accent: Color(0xFFCD7517),
    paleAccent: Color(0xFFFFF1DD),
  ),
  InvestmentBasket(
    id: 'urja',
    detailsUrl:
        'https://profitfromit.maxfolio.in/details?pc=MA00022PFS2026D&bc=MTAz&up=&cd=&lc=',
    name: 'Bharat Urja',
    shortName: 'Urja',
    subtitle: 'Thematic basket',
    themeSummary:
        'Explore the Bharat Urja strategy and its investment framework.',
    annualFee: 6000,
    icon: Icons.bolt_rounded,
    accent: Color(0xFFC83483),
    paleAccent: Color(0xFFFCE8F2),
  ),
  InvestmentBasket(
    id: 'artha',
    detailsUrl:
        'https://profitfromit.maxfolio.in/details?pc=MA00022PFS2026D&bc=MTAx&up=&cd=&lc=',
    name: 'Bharat Artha',
    shortName: 'Artha',
    subtitle: 'Thematic basket',
    themeSummary:
        'Explore the Bharat Artha strategy and its investment framework.',
    annualFee: 6000,
    icon: Icons.account_balance_outlined,
    accent: Color(0xFF405575),
    paleAccent: Color(0xFFEAF0F7),
  ),
];
