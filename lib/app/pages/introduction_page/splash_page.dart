// ignore_for_file: unused_import

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:webinar/app/models/blog_model.dart';
import 'package:webinar/app/pages/authentication_page/login_page.dart';
import 'package:webinar/app/pages/introduction_page/intro_page.dart';
import 'package:webinar/app/pages/main_page/blog_page/details_blog_page.dart';
import 'package:webinar/app/pages/main_page/home_page/single_course_page/single_course_page.dart';
import 'package:webinar/app/pages/main_page/main_page.dart';
import 'package:webinar/app/pages/offline_page/internet_connection_page.dart';
import 'package:webinar/app/services/guest_service/guest_service.dart';
import 'package:webinar/app/services/user_service/blog_service.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/data/app_data.dart';
import 'package:webinar/common/deeplink/deep_link_service.dart';
import 'package:webinar/common/deeplink/deep_link_type.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/config/assets.dart';
import 'package:webinar/config/colors.dart';
import 'package:webinar/config/styles.dart';

class SplashPage extends StatefulWidget {
  static const String pageName = '/splash';

  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  String tag = "SplashPageState";
  String token = "";
  @override
  void initState() {
    super.initState();

    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 5));

    // FlutterNativeSplash.remove();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      animationController.forward();

      Timer(const Duration(seconds: 3), () async {
        final List<ConnectivityResult> connectivityResult =
            await (Connectivity().checkConnectivity());

        if (connectivityResult.contains(ConnectivityResult.none)) {
          nextRoute(InternetConnectionPage.pageName, isClearBackRoutes: true);
        } else {
          token = await AppData.getAccessToken();

          if (mounted) {
            if (token.isEmpty) {
              bool isFirst = await AppData.getIsFirst();

              if (isFirst) {
                nextRoute(IntroPage.pageName, isClearBackRoutes: true);
              } else {
                await _navigateToHome();
              }
            } else {
              await _navigateToHome();
            }
          }
        }
      });
    });

    GuestService.config();
  }

//new added
  Future<void> _handlePendingDeepLink() async {
    debugPrint("handlePendingDeepLink called");

    final deepLink = DeepLinkService.instance.pendingDeepLink;

    debugPrint("pending ======> $deepLink");

    if (deepLink == null) {
      return;
    }

    switch (deepLink.type) {
      case DeepLinkType.blog:
        final String? blogId = deepLink.blogId;

        if (blogId == null || blogId.isEmpty) {
          return;
        }

        try {
          final BlogModel? blogModel =
              await BlogService.getBlogDataById(blogId);

          if (!mounted) return;

          if (blogModel != null && blogModel.id != null) {
            DeepLinkService.instance.clearPending();

            nextRoute(
              DetailsBlogPage.pageName,
              arguments: blogModel,
            );
          }
        } catch (e) {
          debugPrint("$tag blog deep link error =====> $e");
        }

        break;

      case DeepLinkType.course:
        final int? courseId = int.tryParse(deepLink.courseId ?? '');

        if (courseId == null) {
          return;
        }

        debugPrint("Opening course ======> $courseId");

        DeepLinkService.instance.clearPending();

        if (!mounted) return;

        nextRoute(
          SingleCoursePage.pageName,
          arguments: <dynamic>[
            courseId,
            false,
            null,
            false,
            null,
          ],
        );

        break;

      case DeepLinkType.courseLesson:
        final int? courseId = int.tryParse(deepLink.courseId ?? '');

        final String? lessonId = deepLink.lessonId;

        if (courseId == null || lessonId == null || lessonId.isEmpty) {
          return;
        }

        if (token.isEmpty) {
          nextRoute(
            LoginPage.pageName,
            isClearBackRoutes: true,
          );
          return;
        }

        DeepLinkService.instance.clearPending();

        if (!mounted) return;

        nextRoute(
          SingleCoursePage.pageName,
          arguments: <dynamic>[
            courseId,
            false,
            null,
            false,
            lessonId,
          ],
        );

        break;

      case DeepLinkType.unknown:
        DeepLinkService.instance.clearPending();
        break;
    }
  }

  Future<void> _navigateToHome() async {
    debugPrint(
      "navigateToHome pending ======> "
      "${DeepLinkService.instance.pendingDeepLink}",
    );

    nextRoute(
      MainPage.pageName,
      isClearBackRoutes: true,
    );

    Future.delayed(
      const Duration(milliseconds: 700),
      () {
        _handlePendingDeepLink();
      },
    );
  }

  // Future<void> _handlePendingDeepLink() async {
  //   debugPrint("handlePendingDeepLink called");
  //   debugPrint("pending ======> ${DeepLinkService.instance.pendingDeepLink}");
  //
  //   final deepLink = DeepLinkService.instance.pendingDeepLink;
  //
  //   if (deepLink == null) return;
  //
  //   DeepLinkService.instance.clearPending();
  //
  //   switch (deepLink.type) {
  //     case DeepLinkType.blog:
  //       final String? blogId = deepLink.blogId;
  //       if (blogId == null || blogId.isEmpty) return;
  //       try {
  //         debugPrint("Opening blog ======> $blogId");
  //         final BlogModel? blogModel = await BlogService.getBlogDataById(blogId);
  //         if (!mounted) return;
  //         if (blogModel != null && blogModel.id != null) {
  //           nextRoute(DetailsBlogPage.pageName, arguments: blogModel);
  //         }
  //       } catch (e) {
  //         debugPrint("$tag blog deep link error =====> $e");
  //       }
  //       break;
  //
  //     // case DeepLinkType.course:
  //     //   Get.toNamed(
  //     //     SingleCoursePage.pageName,
  //     //     arguments: deepLink.courseId,
  //     //   );
  //     //   break;
  //
  //     case DeepLinkType.courseLesson:
  //       final int? courseId = int.tryParse(deepLink.courseId ?? '');
  //       final String? lessonId = deepLink.lessonId;
  //       if (courseId == null || lessonId == null || lessonId.isEmpty) return;
  //       if (token.isEmpty) {
  //         debugPrint("$tag courseLesson deep link awaiting login, re-arming");
  //         if (!mounted) return;
  //         nextRoute(LoginPage.pageName, isClearBackRoutes: true);
  //         return;
  //       }
  //
  //       if (!mounted) return;
  //       nextRoute(SingleCoursePage.pageName, arguments: <dynamic>[
  //         courseId,
  //         null,
  //         null,
  //         null,
  //         lessonId,
  //       ]);
  //       break;
  //
  //     case DeepLinkType.unknown:
  //       break;
  //     case DeepLinkType.course:
  //       break;
  //   }
  //   DeepLinkService.instance.clearPending();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: green63,
      body: Container(
        width: getSize().width,
        height: getSize().height,
        decoration: const BoxDecoration(
            image: DecorationImage(
          image: AssetImage(AppAssets.splashPng),
          fit: BoxFit.cover,
        )),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Spacer(),
            Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: AnimatedBuilder(
                      animation: animationController,
                      builder: (content, _) {
                        return Transform.rotate(
                          angle: animationController.value * .5 * 3.14,
                          child: SvgPicture.asset(
                            AppAssets.whiteLogoEmptySvg,
                          ),
                        );
                      }),
                ),
                Center(
                  child: Image.asset(
                    AppAssets.icLauncherRound,
                    width: 190,
                    height: 190,
                  ),
                ),
              ],
            ),
            space(40),
            Text(
              appText.webinar,
              style: style24Bold().copyWith(color: Colors.white),
            ),
            space(10),
            Text(
              appText.splashDesc,
              style: style16Regular().copyWith(color: Colors.white),
            ),
            const Spacer(),
            Text(
              "Published by",
              style: style24Bold().copyWith(color: Colors.white),
            ),
            space(4),
            Text(
              "Profit Finstock Private Limited",
              style: style16Regular().copyWith(color: Colors.white),
            ),
            space(4),
            Text(
              "SEBI Registered Investment Adviser",
              style: style16Regular().copyWith(color: Colors.white),
            ),
            space(4),
            Text(
              "(INA000020651)",
              style: style16Regular().copyWith(color: Colors.white),
            ),
            const Spacer(),
            const SizedBox(
              width: 35,
              child: LoadingIndicator(
                indicatorType: Indicator.ballBeat,
                colors: [Colors.white],
                strokeWidth: 100,
                backgroundColor: Colors.transparent,
                pathBackgroundColor: Colors.transparent,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
