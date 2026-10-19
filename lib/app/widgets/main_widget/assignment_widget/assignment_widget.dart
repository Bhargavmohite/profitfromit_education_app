import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:webinar/app/models/assignment_model.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/common/utils/date_formater.dart';
import 'package:webinar/config/assets.dart';

import '../../../pages/main_page/home_page/assignments_page/assignment_overview_page.dart';

class AssignmentWidget {
  static const Color _brand = Color(0xFF0D3CCF);
  static const Color _ink = Color(0xFF192640);
  static const Color _muted = Color(0xFF74809A);
  static const Color _border = Color(0xFFE7ECF5);

  /// Reusable assignment tile for both students and instructors.
  static Widget assignmentItem(AssignmentModel assignment,
      {bool froUserRole = true}) {
    final String status = froUserRole
        ? (assignment.userStatus ?? '').toLowerCase()
        : (assignment.status ?? '').toLowerCase();
    final String statusLabel;
    final Color statusColor;
    final Color statusBackground;

    switch (status) {
      case 'passed':
        statusLabel = 'Passed';
        statusColor = const Color(0xFF0B9C76);
        statusBackground = const Color(0xFFE7F8F1);
        break;
      case 'not_passed':
      case 'failed':
        statusLabel = 'Not passed';
        statusColor = const Color(0xFFD85160);
        statusBackground = const Color(0xFFFFEBEE);
        break;
      case 'not_submitted':
        statusLabel = 'To submit';
        statusColor = const Color(0xFFD68D13);
        statusBackground = const Color(0xFFFFF4DA);
        break;
      case 'active':
        statusLabel = 'Active';
        statusColor = _brand;
        statusBackground = const Color(0xFFEAF0FF);
        break;
      default:
        statusLabel = 'In review';
        statusColor = _brand;
        statusBackground = const Color(0xFFEAF0FF);
    }

    String displayDate(int? seconds) {
      if (seconds == null || seconds <= 0) return 'Not available';
      return timeStampToDateHour(seconds * 1000);
    }

    final subtitle = (assignment.webinarTitle ?? '').trim();
    final usedAttempts = assignment.usedAttemptsCount ?? 0;
    final attempts = assignment.attempts;
    final attemptsLabel = attempts == null
        ? '$usedAttempts used'
        : '$usedAttempts/$attempts ${appText.attempts}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => nextRoute(
            AssignmentOverviewPage.pageName,
            arguments: <dynamic>[assignment, froUserRole],
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 0),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _border),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                  color: const Color(0xFF223A6F).withValues(alpha: 0.035),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _thumbnail(assignment.webinarImage ?? ''),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            assignment.title?.trim().isNotEmpty == true
                                ? assignment.title!
                                : 'Untitled assignment',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.5,
                              height: 1.32,
                              fontWeight: FontWeight.w800,
                              color: _ink,
                            ),
                          ),
                          if (subtitle.isNotEmpty) ...<Widget>[
                            const SizedBox(height: 5),
                            Text(
                              subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 11.5, color: _muted, height: 1.3),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: statusBackground,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: statusColor,
                                fontSize: 10.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                Container(height: 1, color: _border),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: _info(
                        icon: froUserRole
                            ? Icons.event_outlined
                            : Icons.groups_2_outlined,
                        label: froUserRole
                            ? appText.deadline
                            : appText.totalSubmissions,
                        value: froUserRole
                            ? displayDate(assignment.deadlineTime)
                            : '${assignment.submissionsCount ?? 0}',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _info(
                        icon: froUserRole
                            ? Icons.workspace_premium_outlined
                            : Icons.analytics_outlined,
                        label: froUserRole
                            ? status == 'passed'
                                ? appText.grade
                                : appText.lastSubmission
                            : appText.averageGrade,
                        value: froUserRole
                            ? status == 'passed'
                                ? '${assignment.grade ?? '–'}/${assignment.totalGrade ?? '–'}'
                                : displayDate(assignment.lastSubmission)
                            : '${assignment.avgGrade ?? '–'}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Icon(
                      froUserRole
                          ? Icons.repeat_rounded
                          : Icons.pending_actions_rounded,
                      color: _muted,
                      size: 16,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        froUserRole
                            ? attemptsLabel
                            : '${assignment.pendingCount ?? 0} ${appText.pending}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: _muted, fontSize: 11.5),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text('View details',
                        style: TextStyle(
                            color: _brand,
                            fontWeight: FontWeight.w700,
                            fontSize: 11.5)),
                    const SizedBox(width: 2),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 11, color: _brand),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _thumbnail(String url) {
    Widget fallback() => Image.asset(
          AppAssets.placePng,
          fit: BoxFit.contain,
          width: 112,
          height: 92,
        );

    return Container(
      width: 112,
      height: 92,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF3FB),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: url.trim().isEmpty
          ? fallback()
          : CachedNetworkImage(
              imageUrl: url,
              width: 112,
              height: 92,
              fit: BoxFit.contain,
              placeholder: (context, imageUrl) => const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: _brand,
                    strokeWidth: 2,
                  ),
                ),
              ),
              errorWidget: (context, imageUrl, error) => fallback(),
            ),
    );
  }

  static Widget _info({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF0FF),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 15, color: _brand),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _muted, fontSize: 10.5)),
              const SizedBox(height: 4),
              Text(value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: _ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 11.5)),
            ],
          ),
        ),
      ],
    );
  }
}
