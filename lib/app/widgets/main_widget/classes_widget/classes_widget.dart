import 'package:flutter/material.dart';
import 'package:webinar/app/models/course_model.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/utils/date_formater.dart';
import 'package:webinar/config/styles.dart';

import '../../../pages/main_page/home_page/single_course_page/single_course_page.dart';

/// Shared course card used by My Courses and Offline Courses.
/// Existing navigation and optional onTap override are preserved.
class ClassessWidget {
  static const _brand = Color(0xFF0D3CCF);
  static const _text = Color(0xFF122142);
  static const _secondary = Color(0xFF77859B);
  static const _edge = Color(0xFFE6ECF4);

  static Widget classesItem(
    CourseModel courseData, {
    bool showProgress = true,
    Function? onTap,
    bool expired = false,
    int? expiredDate,
  }) {
    final percent = (courseData.progressPercent ?? 0).clamp(0, 100).toInt();
    final hasProgressData = courseData.progressPercent != null;
    final completed = percent >= 100;
    final started = percent > 0 && !completed;
    final Color statusColor = expired
        ? const Color(0xFFCE4151)
        : completed
            ? const Color(0xFF168665)
            : started
                ? _brand
                : const Color(0xFF9B6D16);
    final String statusText = expired
        ? 'Expired'
        : completed
            ? 'Completed'
            : started
                ? 'In progress'
                : hasProgressData
                    ? 'Not started'
                    : 'Ready to learn';
    final String actionText = expired
        ? 'VIEW COURSE'
        : completed
            ? 'REVIEW COURSE'
            : started
                ? 'CONTINUE LEARNING'
                : hasProgressData
                    ? 'START LEARNING'
                    : 'OPEN COURSE';

    void openCourse() {
      if (onTap != null) {
        onTap();
      } else {
        nextRoute(
          SingleCoursePage.pageName,
          arguments: [courseData.id, courseData.type == 'bundle'],
        );
      }
    }

    return Container(
      margin: const EdgeInsetsDirectional.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: _edge),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF203460).withValues(alpha: .055),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(21),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: openCourse,
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Keep the layout usable on narrow devices / large text sizes.
                final small = constraints.maxWidth < 330;
                final imageWidth = small ? 93.0 : 114.0;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: SizedBox(
                            width: imageWidth,
                            height: 105,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: fadeInImage(
                                    courseData.image ?? '',
                                    imageWidth,
                                    105,
                                  ),
                                ),
                                PositionedDirectional(
                                  bottom: 7,
                                  end: 7,
                                  child: Container(
                                    height: 27,
                                    width: 27,
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: .94),
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow_rounded,
                                      color: _brand,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                courseData.title?.trim().isNotEmpty == true
                                    ? courseData.title!
                                    : 'Untitled course',
                                style: style14Bold().copyWith(
                                  color: _text,
                                  fontSize: 14.5,
                                  height: 1.3,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 7,
                                runSpacing: 5,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.schedule_rounded,
                                    size: 14,
                                    color: _secondary,
                                  ),
                                  Text(
                                    '${formatHHMMSS(courseData.duration ?? 0)} hrs',
                                    style: style10Regular().copyWith(
                                      color: _secondary,
                                    ),
                                  ),
                                  if ((courseData.rate ?? '').isNotEmpty) ...[
                                    const Icon(Icons.star_rounded,
                                        size: 14, color: Color(0xFFF3AD3D)),
                                    Text(
                                      courseData.rate ?? '',
                                      style: style10Regular()
                                          .copyWith(color: _secondary),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 9),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  _badge(
                                    courseData.type == 'bundle'
                                        ? 'Bundle'
                                        : 'Course',
                                    const Color(0xFFEDF2FF),
                                    _brand,
                                  ),
                                  if (courseData.isPrivate == 1)
                                    _badge('Private', const Color(0xFFF4F0FF),
                                        const Color(0xFF8153B0)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if ((courseData.category ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 11),
                      Row(
                        children: [
                          const Icon(Icons.folder_open_rounded,
                              size: 15, color: _secondary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              courseData.category!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  style12Regular().copyWith(color: _secondary),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 13),
                    Container(height: 1, color: const Color(0xFFF0F3F8)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            statusText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: style12Bold().copyWith(color: statusColor),
                          ),
                        ),
                        if (showProgress && hasProgressData && !expired)
                          Text(
                            '$percent% completed',
                            style: style12Bold().copyWith(color: _brand),
                          ),
                      ],
                    ),
                    if (showProgress && hasProgressData && !expired) ...[
                      const SizedBox(height: 9),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: percent / 100,
                          backgroundColor: const Color(0xFFECF0F8),
                          color: completed ? const Color(0xFF168665) : _brand,
                          minHeight: 7,
                        ),
                      ),
                    ],
                    if (expired) ...[
                      const SizedBox(height: 9),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 9),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0F1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.event_busy_outlined,
                                color: Color(0xFFCE4151), size: 16),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                (expiredDate ?? 0) > 0
                                    ? 'Access expired on ${timeStampToDate(expiredDate! * 1000)}'
                                    : 'Your course access has expired',
                                style: style12Regular()
                                    .copyWith(color: const Color(0xFFCE4151)),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 13),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            actionText,
                            style: style12Bold().copyWith(
                              color: _brand,
                              letterSpacing: .35,
                            ),
                          ),
                        ),
                        Container(
                          height: 28,
                          width: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDF2FF),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 17,
                            color: _brand,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  static Widget _badge(String text, Color background, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(text, style: style10Regular().copyWith(color: color)),
    );
  }
}
