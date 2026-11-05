/// Server-managed release-notes models. All display content comes from Laravel.
class WhatsNewRelease {
  const WhatsNewRelease({
    required this.enabled,
    required this.version,
    required this.title,
    required this.subtitle,
    required this.publishedAt,
    required this.cards,
  });

  final bool enabled;
  final String version;
  final String title;
  final String subtitle;
  final String publishedAt;
  final List<WhatsNewCard> cards;

  factory WhatsNewRelease.fromJson(Map<String, dynamic> json) {
    final rawCards = json['cards'];
    return WhatsNewRelease(
      enabled: json['enabled'] == true,
      version: (json['version'] ?? '').toString().trim(),
      title: (json['title'] ?? "What's New").toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      publishedAt: (json['published_at'] ?? '').toString(),
      cards: rawCards is List
          ? rawCards
              .whereType<Map>()
              .map((item) => WhatsNewCard.fromJson(
                    Map<String, dynamic>.from(item),
                  ))
              .toList()
          : const <WhatsNewCard>[],
    );
  }
}

class WhatsNewCard {
  const WhatsNewCard({
    required this.id,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.videoUrl,
    required this.ctaLabel,
    required this.ctaAction,
    required this.tag,
  });

  final String id;
  final String icon;
  final String title;
  final String subtitle;
  final String? videoUrl;
  final String ctaLabel;
  final String ctaAction;
  final String tag;

  bool get hasVideo => videoUrl != null && videoUrl!.trim().isNotEmpty;
  bool get hasAction => ctaAction.trim().isNotEmpty && ctaLabel.trim().isNotEmpty;

  factory WhatsNewCard.fromJson(Map<String, dynamic> json) {
    final value = (json['video_url'] ?? '').toString().trim();
    return WhatsNewCard(
      id: (json['id'] ?? '').toString(),
      icon: (json['icon'] ?? 'star').toString(),
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      videoUrl: value.isEmpty ? null : value,
      ctaLabel: (json['cta_label'] ?? '').toString(),
      ctaAction: (json['cta_action'] ?? '').toString(),
      tag: (json['tag'] ?? 'NEW').toString(),
    );
  }
}
