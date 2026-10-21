import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:provider/provider.dart';
import 'package:webinar/app/models/dashboard_model.dart';
import 'package:webinar/app/pages/main_page/home_page/dashboard_page/reward_point_page.dart';
import 'package:webinar/app/providers/page_provider.dart';
import 'package:webinar/app/providers/user_provider.dart';
import 'package:webinar/app/services/user_service/user_service.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/enums/page_name_enum.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/common/utils/currency_utils.dart';
import 'package:webinar/common/utils/date_formater.dart';
import 'package:webinar/locator.dart';

import '../cart_page/cart_page.dart';
import '../notification_page.dart';

/// User learning / account dashboard. Market dashboards are separate screens.
class DashboardPage extends StatefulWidget {
  static const String pageName = '/dashboard';

  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const Color _blue = Color(0xFF0D3CCF);
  static const Color _navy = Color(0xFF102B72);
  static const Color _ink = Color(0xFF17233F);
  static const Color _muted = Color(0xFF74809A);
  static const Color _background = Color(0xFFF5F7FC);
  static const Color _border = Color(0xFFE7EBF4);

  DashboardModel? data;
  bool isLoading = true;
  bool _loadFailed = false;
  bool _showAllNotices = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    try {
      final DashboardModel? response = await UserService.getDashboardData();
      if (!mounted) return;
      setState(() {
        if (response != null) {
          data = response;
          _loadFailed = false;
        } else if (data == null) {
          _loadFailed = true;
        }
        isLoading = false;
      });
    } catch (error) {
      debugPrint('Dashboard load failed: $error');
      if (!mounted) return;
      setState(() {
        isLoading = false;
        _loadFailed = data == null;
      });
    }
  }

  void _openMyCourses() {
    locator<PageProvider>().setPage(PageNames.myClasses);
    backRoute();
  }

  @override
  Widget build(BuildContext context) {
    return directionality(
      child: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          final bool isInstructor = userProvider.profile?.roleName != 'user';
          final bool hasCartItems =
              userProvider.cartData?.items?.isNotEmpty ?? false;
          final bool hasUnread = userProvider.notification
              .any((notification) => notification.status == 'unread');

          return Scaffold(
            backgroundColor: _background,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              centerTitle: true,
              elevation: 0,
              toolbarHeight: 64,
              backgroundColor: _blue,
              title: Text(
                appText.dashboard,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              leading: const IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    size: 20, color: Colors.white),
                tooltip: 'Back',
                onPressed: backRoute,
              ),
              actions: <Widget>[
                _appBarAction(
                  icon: Icons.shopping_bag_outlined,
                  tooltip: 'Cart',
                  hasDot: hasCartItems,
                  onTap: () => nextRoute(CartPage.pageName),
                ),
                _appBarAction(
                  icon: Icons.notifications_none_rounded,
                  tooltip: 'Notifications',
                  hasDot: hasUnread,
                  onTap: () => nextRoute(NotificationPage.pageName),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: isLoading && data == null
                ? _loadingView()
                : _loadFailed && data == null
                    ? _errorView()
                    : RefreshIndicator(
                        color: _blue,
                        onRefresh: getData,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: EdgeInsets.zero,
                          children: <Widget>[
                            _welcomeHeader(userProvider),
                            const SizedBox(height: 22),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  _sectionHeading(
                                    title: 'Overview',
                                    subtitle: 'Your activity at a glance',
                                  ),
                                  const SizedBox(height: 14),
                                  _statisticsGrid(isInstructor),
                                  const SizedBox(height: 26),
                                  _sectionHeading(
                                    title: 'Achievements & Rewards',
                                    subtitle: 'Track your progress and points',
                                  ),
                                  const SizedBox(height: 14),
                                  _rewardsRow(),
                                  const SizedBox(height: 26),
                                  _sectionHeading(
                                    title: isInstructor
                                        ? appText.monthSales
                                        : appText.learningStatistics,
                                    subtitle: 'Monthly performance overview',
                                  ),
                                  const SizedBox(height: 14),
                                  _chartCard(),
                                  const SizedBox(height: 26),
                                  _noticesSection(),
                                  const SizedBox(height: 38),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
          );
        },
      ),
    );
  }

  Widget _appBarAction({
    required IconData icon,
    required String tooltip,
    required bool hasDot,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 44,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          IconButton(
            tooltip: tooltip,
            onPressed: onTap,
            icon: Icon(icon, color: Colors.white, size: 23),
          ),
          if (hasDot)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFCB52),
                  shape: BoxShape.circle,
                  border: Border.all(color: _blue, width: 1.2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _welcomeHeader(UserProvider userProvider) {
    final String name = (userProvider.profile?.fullName ?? '').trim();
    final int newEvents = data?.unreadNotifications?.count ?? 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 17, 20, 23),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[_blue, _navy],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: Colors.white.withValues(alpha: .15)),
            ),
            child: const Text(
              'MY DASHBOARD',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 13),
          Text(
            name.isEmpty ? appText.hi : '${appText.hi} $name',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Your learning, activity and rewards in one place.',
            style: TextStyle(
              fontSize: 12,
              height: 1.45,
              color: Colors.white.withValues(alpha: .80),
            ),
          ),
          const SizedBox(height: 21),
          // A separate card avoids overlapping elements at small screen widths.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x18062057),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF0FF),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.account_balance_wallet_outlined,
                      color: _blue, size: 25),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        appText.accountBalance,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          CurrencyUtils.calculator(data?.balance),
                          style: const TextStyle(
                            color: _ink,
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (newEvents > 0)
                  Tooltip(
                    message: '$newEvents new notifications',
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => nextRoute(NotificationPage.pageName),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF7F1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$newEvents new',
                          style: const TextStyle(
                            color: Color(0xFF218B57),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeading({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            color: _ink,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: _muted,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _statisticsGrid(bool isInstructor) {
    final List<_DashboardStatistic> stats = <_DashboardStatistic>[
      _DashboardStatistic(
        label:
            isInstructor ? appText.pendingMeetings : appText.purchasedCourses,
        value: isInstructor
            ? '${data?.pendingAppointments ?? 0}'
            : '${data?.webinarsCount ?? 0}',
        icon: Icons.play_circle_outline_rounded,
        accent: const Color(0xFF315CE8),
        onTap: isInstructor ? null : _openMyCourses,
      ),
      _DashboardStatistic(
        label: appText.supportMessages,
        value: '${data?.supportsCount ?? 0}',
        icon: Icons.mark_email_unread_outlined,
        accent: const Color(0xFFED8B3F),
      ),
      _DashboardStatistic(
        label: isInstructor ? appText.monthlySales : appText.meetings,
        value: isInstructor
            ? CurrencyUtils.calculator(
                (data?.monthlySalesCount ?? 0).toDouble(),
              )
            : '${data?.reserveMeetingsCount ?? 0}',
        icon: isInstructor
            ? Icons.trending_up_rounded
            : Icons.calendar_month_outlined,
        accent: const Color(0xFF149E8E),
      ),
      _DashboardStatistic(
        label: appText.comments,
        value: '${data?.commentsCount ?? 0}',
        icon: Icons.forum_outlined,
        accent: const Color(0xFF8F60D6),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const double gap = 12;
        final double width = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: stats
              .map((stat) => SizedBox(
                    width: width,
                    child: _statCard(stat),
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _statCard(_DashboardStatistic stat) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        borderRadius: BorderRadius.circular(19),
        onTap: stat.onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 140),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border.all(color: _border),
            borderRadius: BorderRadius.circular(19),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x090B2454),
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: stat.accent.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(stat.icon, color: stat.accent, size: 21),
                  ),
                  const Spacer(),
                  if (stat.onTap != null)
                    Icon(Icons.arrow_outward_rounded,
                        color: stat.accent, size: 16),
                ],
              ),
              const SizedBox(height: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  stat.value,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                stat.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: _muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rewardsRow() {
    final double percentage =
        (double.tryParse('${data?.badges?.percent ?? 0}') ?? 0)
            .clamp(0.0, 100.0)
            .toDouble();
    final String badge = (data?.badges?.earned ?? '').trim();
    final String nextBadge = (data?.badges?.nextBadge ?? '').trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Container(
            constraints: const BoxConstraints(minHeight: 191),
            padding: const EdgeInsets.all(15),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Row(
                  children: <Widget>[
                    Icon(Icons.workspace_premium_outlined,
                        color: Color(0xFFE3A229), size: 20),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text('My Badge',
                          style: TextStyle(
                              color: _ink,
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Center(
                  child: SizedBox(
                    height: 58,
                    width: 58,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        SizedBox.expand(
                          child: CircularProgressIndicator(
                            value: percentage / 100,
                            strokeWidth: 5,
                            backgroundColor: const Color(0xFFF0F2F8),
                            color: const Color(0xFFF0B240),
                          ),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: _ink,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 11),
                Text(
                  badge.isEmpty ? 'No badge yet' : badge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  nextBadge.isEmpty ? 'Keep learning' : 'Next: $nextBadge',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(color: _muted, fontSize: 11, height: 1.3),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(19),
            child: InkWell(
              borderRadius: BorderRadius.circular(19),
              onTap: () => nextRoute(RewardPointPage.pageName),
              child: Container(
                constraints: const BoxConstraints(minHeight: 191),
                padding: const EdgeInsets.all(15),
                decoration: _cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Row(
                      children: <Widget>[
                        Icon(Icons.card_giftcard_rounded,
                            color: Color(0xFF8B61D8), size: 20),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text('Rewards',
                              style: TextStyle(
                                  color: _ink,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${data?.totalPoints ?? 0}',
                        style: const TextStyle(
                            color: _ink,
                            fontSize: 29,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      appText.rewardPoints,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _muted, fontSize: 11),
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            'View rewards',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _blue,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        SizedBox(width: 3),
                        Icon(Icons.arrow_forward_rounded,
                            color: _blue, size: 15),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      border: Border.all(color: _border),
      boxShadow: const <BoxShadow>[
        BoxShadow(
          color: Color(0x090B2454),
          blurRadius: 15,
          offset: Offset(0, 5),
        ),
      ],
    );
  }

  Widget _chartCard() {
    final List<int> values = data?.monthlyChart?.data ?? <int>[];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(13, 17, 17, 12),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Row(
              children: <Widget>[
                Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: _blue,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                const Expanded(
                  child: Text(
                    'Monthly trend',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Text(
                  'Monthly data',
                  style: TextStyle(color: _muted, fontSize: 11),
                ),
              ],
            ),
          ),
          if (values.isEmpty)
            const SizedBox(
              height: 220,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.insights_outlined,
                        color: Color(0xFFB8C4DC), size: 40),
                    SizedBox(height: 10),
                    Text('Chart data is not available yet',
                        style: TextStyle(color: _muted, fontSize: 12)),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 235,
              child: LineChart(mainData()),
            ),
        ],
      ),
    );
  }

  Widget _noticesSection() {
    final List<UnreadNoticeboards> notices =
        data?.unreadNoticeboards ?? <UnreadNoticeboards>[];
    final List<UnreadNoticeboards> shown =
        _showAllNotices ? notices : notices.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: _sectionHeading(
                title: appText.notices,
                subtitle: 'Announcements and important updates',
              ),
            ),
            if (notices.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF0FF),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  '${notices.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: _blue,
                    fontSize: 11,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        if (notices.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
            width: double.infinity,
            decoration: _cardDecoration(),
            child: const Column(
              children: <Widget>[
                Icon(Icons.notifications_active_outlined,
                    size: 34, color: Color(0xFFB7C2D9)),
                SizedBox(height: 9),
                Text('You are all caught up',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _ink)),
                SizedBox(height: 4),
                Text('New notices will appear here.',
                    style: TextStyle(fontSize: 12, color: _muted)),
              ],
            ),
          )
        else ...<Widget>[
          for (int index = 0; index < shown.length; index++) ...<Widget>[
            _noticeCard(shown[index]),
            if (index != shown.length - 1) const SizedBox(height: 11),
          ],
          if (notices.length > 3) ...<Widget>[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  setState(() => _showAllNotices = !_showAllNotices);
                },
                icon: Icon(
                  _showAllNotices
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: _blue,
                  size: 20,
                ),
                label: Text(
                  _showAllNotices ? 'Show less' : 'Show all notices',
                  style: const TextStyle(
                    color: _blue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _noticeCard(UnreadNoticeboards notice) {
    final String message = parse(notice.message ?? '').body?.text.trim() ?? '';
    final int createdAt = notice.createdAt ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 33,
                height: 33,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF0FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    const Icon(Icons.campaign_outlined, color: _blue, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  notice.title ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Wrap(
            spacing: 13,
            runSpacing: 6,
            children: <Widget>[
              if ((notice.sender ?? '').isNotEmpty)
                _noticeMeta(Icons.person_outline_rounded, notice.sender!),
              if (createdAt > 0)
                _noticeMeta(Icons.calendar_today_outlined,
                    timeStampToDate(createdAt * 1000)),
            ],
          ),
          if (message.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            Container(height: 1, color: _border),
            const SizedBox(height: 11),
            Text(
              message,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _muted,
                fontSize: 12,
                height: 1.55,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _noticeMeta(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 13, color: _muted),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 175),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: _muted, fontSize: 11),
          ),
        ),
      ],
    );
  }

  Widget _loadingView() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      children: <Widget>[
        Container(
          height: 220,
          decoration: BoxDecoration(
            color: const Color(0xFFE1E8FC),
            borderRadius: BorderRadius.circular(23),
          ),
          alignment: Alignment.center,
          child: const CircularProgressIndicator(color: _blue),
        ),
        const SizedBox(height: 24),
        const Text('Loading your dashboard...',
            style: TextStyle(color: _muted, fontSize: 13)),
        const SizedBox(height: 14),
        for (int i = 0; i < 4; i++) ...<Widget>[
          Container(
            height: 78,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _errorView() {
    return RefreshIndicator(
      onRefresh: getData,
      color: _blue,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          SizedBox(height: MediaQuery.of(context).size.height * .22),
          const Icon(Icons.cloud_off_outlined, size: 56, color: _muted),
          const SizedBox(height: 14),
          const Center(
            child: Text(
              'Unable to load your dashboard',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
          ),
          const SizedBox(height: 7),
          const Center(
            child: Text('Please check your connection and try again.',
                style: TextStyle(color: _muted, fontSize: 12)),
          ),
          const SizedBox(height: 16),
          Center(
            child: FilledButton.icon(
              onPressed: () {
                setState(() => isLoading = true);
                getData();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: FilledButton.styleFrom(backgroundColor: _blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    final int monthIndex = value.round();
    final List<String> months = data?.monthlyChart?.months ?? <String>[];
    const List<String> defaultMonths = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final int count = data?.monthlyChart?.data?.length ?? 0;
    // Limit tick labels on smaller screens; actual point values remain intact.
    if (monthIndex != value.toInt() ||
        monthIndex < 0 ||
        monthIndex >= count ||
        (count > 6 && monthIndex.isOdd)) {
      return const SizedBox.shrink();
    }
    final String month = monthIndex < months.length
        ? months[monthIndex]
        : defaultMonths[monthIndex % 12];
    final String label = month.length > 3 ? month.substring(0, 3) : month;
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(label, style: const TextStyle(fontSize: 10, color: _muted)),
    );
  }

  LineChartData mainData() {
    final List<int> values = data?.monthlyChart?.data ?? <int>[];
    final int length = values.length;
    final int peak =
        values.fold<int>(0, (previous, value) => math.max(previous, value));
    final double maxY = math.max(1, peak).toDouble() * 1.20;

    return LineChartData(
      minX: 0,
      maxX: math.max(11, length - 1).toDouble(),
      minY: 0,
      maxY: maxY,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY / 4,
        getDrawingHorizontalLine: (value) => const FlLine(
          color: Color(0xFFE9EDF5),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 27,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => _navy,
          tooltipRoundedRadius: 10,
          getTooltipItems: (spots) => spots
              .map((spot) => LineTooltipItem(
                    spot.y.toStringAsFixed(0),
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ))
              .toList(),
        ),
      ),
      lineBarsData: <LineChartBarData>[
        LineChartBarData(
          spots: List<FlSpot>.generate(length,
              (index) => FlSpot(index.toDouble(), values[index].toDouble())),
          isCurved: length > 2,
          preventCurveOverShooting: true,
          color: _blue,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: length == 1),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                _blue.withValues(alpha: .18),
                _blue.withValues(alpha: .01),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DashboardStatistic {
  const _DashboardStatistic({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final VoidCallback? onTap;
}
