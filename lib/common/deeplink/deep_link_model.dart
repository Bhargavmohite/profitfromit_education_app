import 'package:webinar/common/deeplink/deep_link_type.dart';

class DeepLinkModel {
  final DeepLinkType type;
  final String? blogId;
  final String? courseId;
  final String? lessonId;

  const DeepLinkModel({
    required this.type,
    this.blogId,
    this.courseId,
    this.lessonId,
  });

  Map<String, dynamic> toJson() {
    return {
      "type": type.name,
      "blog_id": blogId,
      "course_id": courseId,
      "lesson_id": lessonId,
    };
  }
}