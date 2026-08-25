import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:webinar/app/pages/main_page/home_page/blog_webview.dart';
import 'package:webinar/app/pages/main_page/home_page/single_course_page/single_course_page.dart';
import 'package:webinar/app/pages/main_page/main_page.dart';
import 'package:webinar/app/providers/user_provider.dart';
import 'package:webinar/app/services/user_service/user_service.dart';
import 'package:webinar/app/widgets/main_widget/home_widget/notification_widget.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/common/shimmer_component.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/common/utils/date_formater.dart';
import 'package:webinar/config/assets.dart';
import 'package:webinar/config/colors.dart';
import 'package:webinar/config/styles.dart';
import 'package:webinar/locator.dart';
import 'package:webinar/main.dart';

class NotificationPage extends StatefulWidget {
  static const String pageName = '/notification';

  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  String TAG = "_NotificationPageState";

  bool isLoading = true;

  int offset = 0;
  final int limit = 10;
  bool isLoadingMore = false;
  bool hasMore = true;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (locator<UserProvider>().notification.isEmpty) {
      Future.wait([getNotificationsData()]).then((value) {
        setState(() {
          isLoading = false;
          showNotification = false;
        });
      });
    }
    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMore && hasMore) {
        loadMoreNotifications();
      }
    }
  }

  Future<void> loadNotifications() async {
    offset = 0;
    final data = await UserService.getAllNotification(offset: offset, limit: limit);
    hasMore = data.length == limit;
  }

  Future<void> loadMoreNotifications() async {
    setState(() => isLoadingMore = true);
    offset += limit;
    final data = await UserService.getAllNotification(offset: offset, limit: limit, append: true);
    if (data.length < limit) {
      hasMore = false;
    }
    setState(() => isLoadingMore = false);
  }

  Future getNotificationsData() async {
    await UserService.getAllNotification();
  }

  @override
  Widget build(BuildContext context) {
    return directionality(
      child: Scaffold(
        appBar: appbar(
            title: appText.notification,
            onTapLeftIcon: () {
              nextRoute(MainPage.pageName, isClearBackRoutes: true);
            }),
        body: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            nextRoute(MainPage.pageName, isClearBackRoutes: true);
          },
          child: setNotificationWidget(),
        ),
      ),
    );
  }

  Widget setNotificationWidget() {
    if (locator<UserProvider>().notification.isEmpty && isLoading) {
      return categoryItemShimmer();
    } else if (locator<UserProvider>().notification.isEmpty) {
      return Center(
        child: emptyState(AppAssets.emptyNotificationSvg, appText.noNotifications, appText.noNotificationsDesc),
      );
    } else {
      return ListView.builder(
        controller: scrollController,
        padding: padding(vertical: 18),
        itemCount: locator<UserProvider>().notification.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < locator<UserProvider>().notification.length) {
            return GestureDetector(
              onTap: () {
                if (locator<UserProvider>().notification[index].status != 'read') {
                  UserService.seenNotification(locator<UserProvider>().notification[index].id!);

                  locator<UserProvider>().notification[index].status = 'read';
                  locator<UserProvider>().setNotification(locator<UserProvider>().notification);
                }

                debugPrint("$TAG notification ==========> ${locator<UserProvider>().notification[index].toJson()}");

                if (locator<UserProvider>().notification[index].blogUrl != null && locator<UserProvider>().notification[index].blogUrl != "") {
                  nextRoute(BlogWebview.pageName, arguments: locator<UserProvider>().notification[index].blogUrl);
                } else if (locator<UserProvider>().notification[index].courseType != null) {
                  nextRoute(SingleCoursePage.pageName, arguments: [
                    locator<UserProvider>().notification[index].courseId,
                    locator<UserProvider>().notification[index].courseType == 'bundle',
                    locator<UserProvider>().notification[index].commentId,
                  ]);
                } else {
                  NotificationWidget.showDetailsSheet(locator<UserProvider>().notification[index]);
                }

                setState(() {});
              },
              child: Container(
                width: getSize().width,
                margin: const EdgeInsets.only(bottom: 16),
                padding: padding(horizontal: 13, vertical: 13),
                decoration: BoxDecoration(color: Colors.white, borderRadius: borderRadius(radius: 16)),
                child: Row(
                  children: [
                    // icon
                    Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(color: green77(), borderRadius: borderRadius(radius: 14)),
                      child: Stack(
                        children: [
                          Center(
                            child: SvgPicture.asset(
                              AppAssets.notificationSvg,
                              width: 23,
                            ),
                          ),
                          if (locator<UserProvider>().notification[index].status == 'unread') ...{
                            Positioned(
                              top: 18,
                              right: 20,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(shape: BoxShape.circle, color: red49),
                              ),
                            ),
                          },
                        ],
                      ),
                    ),

                    space(0, width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            locator<UserProvider>().notification[index].title ?? '',
                            style: style14Bold(),
                          ),
                          space(8),
                          Text(
                            timeStampToDateHourAMPM((locator<UserProvider>().notification[index].createdAt ?? 0) * 1000),
                            style: style12Regular().copyWith(color: greyA5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            // Loading indicator at bottom
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
        },
      );
    }
  }
}
