import 'package:webinar/app/models/content_model.dart';

class DeepLinkContentResult {

  final ContentModel chapter;

  final ContentItem item;

  final int chapterIndex;

  final int itemIndex;

  final String? previousLink;

  const DeepLinkContentResult({
    required this.chapter,
    required this.item,
    required this.chapterIndex,
    required this.itemIndex,
    required this.previousLink,
  });

}