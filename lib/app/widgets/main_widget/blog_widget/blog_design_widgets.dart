import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:webinar/app/models/blog_model.dart';
import 'package:webinar/common/utils/date_formater.dart';

/// Shared, presentation-only widgets for the Blog listing and reader.
/// No API, navigation, or user-session behavior is changed here.
class BlogDesign {
  static const Color primary = Color(0xFF0D3CCF);
  static const Color navy = Color(0xFF172743);
  static const Color secondary = Color(0xFF75839B);
  static const Color canvas = Color(0xFFF5F7FC);
  static const Color border = Color(0xFFE6EBF5);
  static const Color paleBlue = Color(0xFFEDF2FF);

  static String plainText(String? value) {
    if (value == null || value.isEmpty) return '';
    return value
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String date(int? seconds) => seconds == null || seconds <= 0
      ? 'Recently'
      : timeStampToDate(seconds * 1000);

  static String category(BlogModel blog) {
    final label = blog.category?.trim() ?? '';
    return label.isEmpty ? 'INSIGHTS' : label.toUpperCase();
  }

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF24385D).withValues(alpha: 0.055),
          blurRadius: 22,
          offset: const Offset(0, 8),
        ),
      ];
}

class BlogCover extends StatelessWidget {
  final BlogModel blog;
  final bool useHero;

  const BlogCover({super.key, required this.blog, this.useHero = false});

  @override
  Widget build(BuildContext context) {
    final url = blog.image?.trim() ?? '';
    final cover = Container(
      color: BlogDesign.paleBlue,
      alignment: Alignment.center,
      child: url.isEmpty
          ? _placeholder()
          : CachedNetworkImage(
              imageUrl: url,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.contain, // Keep the complete thumbnail visible.
              fadeInDuration: const Duration(milliseconds: 180),
              placeholder: (_, __) => const Center(
                child: SizedBox(
                  width: 23,
                  height: 23,
                  child: CircularProgressIndicator(
                    color: BlogDesign.primary,
                    strokeWidth: 2,
                  ),
                ),
              ),
              errorWidget: (_, __, ___) => _placeholder(),
            ),
    );

    if (!useHero || blog.id == null) return cover;
    return Hero(tag: blog.id!, child: cover);
  }

  Widget _placeholder() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.auto_stories_rounded, size: 31, color: BlogDesign.primary),
        SizedBox(height: 7),
        Text('PROFIT FROM IT',
            style: TextStyle(
                color: BlogDesign.primary,
                fontWeight: FontWeight.w800,
                fontSize: 9,
                letterSpacing: 1.1)),
      ],
    );
  }
}

class BlogInfoRow extends StatelessWidget {
  final BlogModel blog;
  final bool showAuthor;

  const BlogInfoRow({super.key, required this.blog, this.showAuthor = false});

  @override
  Widget build(BuildContext context) {
    final author = blog.author?.fullName?.trim() ?? '';
    return Wrap(
      spacing: 12,
      runSpacing: 7,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _InfoItem(
            Icons.calendar_today_outlined, BlogDesign.date(blog.createdAt)),
        if (showAuthor && author.isNotEmpty)
          _InfoItem(Icons.person_outline_rounded, author),
        _InfoItem(
            Icons.chat_bubble_outline_rounded, '${blog.commentCount ?? 0}'),
        if ((blog.blogCount ?? 0) > 0)
          _InfoItem(Icons.visibility_outlined, '${blog.blogCount}'),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoItem(this.icon, this.label);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: BlogDesign.secondary),
          const SizedBox(width: 4),
          Flexible(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: BlogDesign.secondary,
                  ))),
        ],
      );
}

class BlogFeaturedCard extends StatelessWidget {
  final BlogModel blog;
  final VoidCallback onTap;

  const BlogFeaturedCard({super.key, required this.blog, required this.onTap});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(23),
          border: Border.all(color: BlogDesign.border),
          boxShadow: BlogDesign.cardShadow,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(23),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    AspectRatio(
                        aspectRatio: 16 / 9,
                        child: BlogCover(blog: blog, useHero: true)),
                    PositionedDirectional(
                      top: 13,
                      start: 13,
                      child: _CategoryBadge(label: BlogDesign.category(blog)),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(17, 18, 17, 17),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.bolt_rounded,
                              color: BlogDesign.primary, size: 16),
                          SizedBox(width: 5),
                          Text('LATEST STORY',
                              style: TextStyle(
                                  color: BlogDesign.primary,
                                  letterSpacing: 1.3,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10)),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Text(
                        blog.title ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.35,
                          fontWeight: FontWeight.w800,
                          color: BlogDesign.navy,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (BlogDesign.plainText(blog.description)
                          .isNotEmpty) ...[
                        const SizedBox(height: 9),
                        Text(BlogDesign.plainText(blog.description),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12.5,
                                height: 1.6,
                                color: BlogDesign.secondary)),
                      ],
                      const SizedBox(height: 15),
                      const Divider(color: BlogDesign.border, height: 1),
                      const SizedBox(height: 13),
                      Row(
                        children: [
                          Expanded(
                              child: BlogInfoRow(blog: blog, showAuthor: true)),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_rounded,
                              color: BlogDesign.primary, size: 21),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class BlogCompactCard extends StatelessWidget {
  final BlogModel blog;
  final VoidCallback onTap;
  const BlogCompactCard({super.key, required this.blog, required this.onTap});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: BlogDesign.border),
          borderRadius: BorderRadius.circular(20),
          boxShadow: BlogDesign.cardShadow,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                        width: 110,
                        height: 113,
                        child: BlogCover(blog: blog, useHero: true)),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(BlogDesign.category(blog),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: BlogDesign.primary,
                                letterSpacing: 0.8)),
                        const SizedBox(height: 7),
                        Text(blog.title ?? '',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.3,
                              height: 1.35,
                              color: BlogDesign.navy,
                            )),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined,
                                size: 12, color: BlogDesign.secondary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(BlogDesign.date(blog.createdAt),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: BlogDesign.secondary,
                                      fontSize: 10.5)),
                            ),
                            const SizedBox(width: 5),
                            const Icon(Icons.arrow_outward_rounded,
                                size: 18, color: BlogDesign.primary),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _CategoryBadge extends StatelessWidget {
  final String label;
  const _CategoryBadge({required this.label});

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(maxWidth: 210),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .95),
            borderRadius: BorderRadius.circular(30)),
        child: Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 9.5,
                color: BlogDesign.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: .7)),
      );
}

class BlogLoadingCard extends StatelessWidget {
  final bool large;
  const BlogLoadingCard({super.key, this.large = false});

  @override
  Widget build(BuildContext context) {
    Widget block(double height, {double? width, double radius = 10}) =>
        Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(radius)),
        );

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFE6EBF5),
        highlightColor: const Color(0xFFF7F9FE),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: large
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  AspectRatio(aspectRatio: 16 / 9, child: block(1)),
                  const SizedBox(height: 16),
                  block(16, width: 180),
                  const SizedBox(height: 12),
                  block(11),
                  const SizedBox(height: 10),
                  block(11, width: 220),
                ])
              : Row(children: [
                  block(113, width: 110),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          block(10, width: 80),
                          const SizedBox(height: 14),
                          block(12),
                          const SizedBox(height: 9),
                          block(12),
                          const SizedBox(height: 23),
                          block(10, width: 120),
                        ]),
                  ),
                ]),
        ),
      ),
    );
  }
}
