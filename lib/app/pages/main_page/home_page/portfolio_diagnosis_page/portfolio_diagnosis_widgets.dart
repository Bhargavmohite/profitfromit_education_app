import 'package:flutter/material.dart';

/// Visual components shared by the two Portfolio Diagnosis plan cards.
class DiagnosisPalette {
  static const background = Color(0xFFF5F7FB);
  static const ink = Color(0xFF122641);
  static const muted = Color(0xFF66778F);
  static const blue = Color(0xFF1976D2);
  static const orange = Color(0xFFFF7846);
  static const blueTint = Color(0xFFE8F2FF);
  static const orangeTint = Color(0xFFFFEFE7);
  static const border = Color(0xFFE5EAF1);
}

class DiagnosisIntroBanner extends StatelessWidget {
  const DiagnosisIntroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF132C53), Color(0xFF26548D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -50,
              top: -70,
              child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0x18FFFFFF),
                    width: 26,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.analytics_outlined,
                          size: 19, color: Color(0xFF93CBFF)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'RESEARCH-LED PORTFOLIO REVIEW',
                          style: TextStyle(
                            color: Color(0xFFD0E3FA),
                            letterSpacing: 1.0,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Know what you own.\nUnderstand what matters.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Explore structured reviews of portfolio risk, quality and concentration.',
                    style: TextStyle(
                      color: Color(0xFFD5E3F6),
                      fontSize: 12.5,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DiagnosisPlanCard extends StatelessWidget {
  const DiagnosisPlanCard({
    super.key,
    required this.badge,
    required this.title,
    required this.description,
    required this.price,
    required this.benefits,
    required this.buttonText,
    required this.accent,
    required this.softAccent,
    required this.icon,
    required this.onPressed,
  });

  final String badge;
  final String title;
  final String description;
  final String price;
  final List<String> benefits;
  final String buttonText;
  final Color accent;
  final Color softAccent;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: DiagnosisPalette.border),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D1D3456),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(height: 5, color: accent),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 21),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 46,
                        width: 46,
                        decoration: BoxDecoration(
                          color: softAccent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(icon, color: accent, size: 25),
                      ),
                      const Spacer(),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: softAccent,
                          ),
                          child: Text(
                            badge,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: accent,
                              fontSize: 9.5,
                              letterSpacing: .3,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 19,
                      color: DiagnosisPalette.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.55,
                      color: DiagnosisPalette.muted,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1, color: DiagnosisPalette.border),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          color: DiagnosisPalette.ink,
                          fontSize: 28,
                          height: 1.0,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 2),
                        child: Text(
                          '+ GST',
                          style: TextStyle(
                            color: DiagnosisPalette.muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...benefits.map(
                    (benefit) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle_rounded,
                              color: accent, size: 17),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              benefit,
                              style: const TextStyle(
                                color: DiagnosisPalette.ink,
                                fontWeight: FontWeight.w500,
                                fontSize: 12.5,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 47,
                    child: FilledButton(
                      onPressed: onPressed,
                      style: FilledButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              buttonText,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 7),
                          const Icon(Icons.arrow_forward_rounded, size: 17),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DiagnosisDisclosure extends StatelessWidget {
  const DiagnosisDisclosure({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0F9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded,
              size: 19, color: DiagnosisPalette.blue),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Profit Finstock Pvt. Ltd. | SEBI Registered Investment Adviser: INA000020651. '
              'Prices shown exclude GST. Services and deliverables are subject to applicable terms and disclosures.',
              style: TextStyle(
                color: DiagnosisPalette.muted,
                fontSize: 11.5,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
