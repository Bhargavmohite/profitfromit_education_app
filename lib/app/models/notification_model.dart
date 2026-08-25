
class NotificationModel {
  int? id;
  String? title;
  String? message;
  String? type;
  String? status;
  int? createdAt;
  int? courseId;
  String? courseType;
  String? commentId;
  String? isPrivate;
  String? courseSEOUrl;
  String? blogUrl;


  NotificationModel(
      {this.id,
      this.title,
      this.message,
      this.type,
      this.status,
      this.createdAt,
      this.courseId,
      this.courseType,
      this.commentId,
      this.isPrivate,
      this.courseSEOUrl,
        this.blogUrl,
      });

  NotificationModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    message = json['message'];
    type = json['type'];
    status = json['status'];
    createdAt = json['created_at'];
    courseId = json["course_id"];
    courseType = json["course_type"];
    commentId = json["comment_id"];
    isPrivate = json["isPrivate"];
    courseSEOUrl = json["course_seourl"];
    blogUrl = json["blog_url"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['message'] = message;
    data['type'] = type;
    data['status'] = status;
    data['created_at'] = createdAt;
    data["course_id"] = courseId;
    data["course_type"] = courseType;
    data["comment_id"] = commentId;
    data["isPrivate"] = isPrivate;
    data["course_seourl"] = courseSEOUrl;
    data["blog_url"] = blogUrl;
    return data;
  }
}