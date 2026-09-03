import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:provider/provider.dart';
import 'package:webinar/app/models/blog_model.dart';
import 'package:webinar/app/pages/main_page/home_page/notification_page.dart';
import 'package:webinar/app/pages/main_page/home_page/single_course_page/single_course_page.dart';
import 'package:webinar/app/providers/drawer_provider.dart';
import 'package:webinar/app/providers/page_provider.dart';
import 'package:webinar/app/services/guest_service/course_service.dart';
import 'package:webinar/app/services/user_service/blog_service.dart';
import 'package:webinar/app/services/user_service/cart_service.dart';
import 'package:webinar/app/services/user_service/rewards_service.dart';
import 'package:webinar/app/services/user_service/user_service.dart';
import 'package:webinar/app/widgets/main_widget/main_drawer.dart';
import 'package:webinar/app/widgets/main_widget/main_widget.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/data/app_data.dart';
import 'package:webinar/common/data/app_language.dart';
import 'package:webinar/common/database/app_database.dart';
import 'package:webinar/common/deeplink/deep_link_service.dart';
import 'package:webinar/common/deeplink/deep_link_type.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/common/utils/object_instance.dart';
import 'package:webinar/config/colors.dart';
import 'package:webinar/locator.dart';
import 'package:webinar/main.dart';

import '../../../common/enums/page_name_enum.dart';
import '../../../config/assets.dart';
import '../../providers/app_language_provider.dart';
import 'blog_page/details_blog_page.dart';

class MainPage extends StatefulWidget {
  static const String pageName = '/main';

  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static const String tag = "_MainPageState";

  late Future<int> future;

  // Create the drawer controller only once.
  // late final AdvancedDrawerController drawerController;

  double bottomNavHeight = 110;
  bool _isHandlingDeepLink = false;

  @override
  void initState() {
    super.initState();

    // ------------------------------------------------------------
    // Initialize AdvancedDrawerController only once.
    // DO NOT create this controller inside build().
    // ------------------------------------------------------------
    // drawerController = AdvancedDrawerController();

    // Add drawer listener only once.
    _addDrawerListener();

    _listenForDeepLinks();

    future = Future<int>(() {
      return 0;
    });

    locator<DrawerProvider>().isOpenDrawer = false;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      AppDataBase.getCoursesAndSaveInDB();

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        FirebaseMessaging.instance.getAPNSToken().then((String? value) {
          try {
            if (value != null) {
              debugPrint('token : $value');
              UserService.sendFirebaseToken(value);
            }
          } catch (_) {
            debugPrint(
              "Error in sending firebase token =====> ${_.toString()}",
            );
          }
        });
      } else {
        FirebaseMessaging.instance.getToken().then((String? value) {
          try {
            if (value != null) {
              debugPrint('token : $value');
              UserService.sendFirebaseToken(value);
            }
          } catch (_) {
            debugPrint(
              "Error in sending firebase token =====> ${_.toString()}",
            );
          }
        });
      }
    });

    getData();
  }

  Future<void> getData() async {
    CourseService.getReasons();

    // Added to show the advertise image in popup 11-05-2026
    AppData.getAccessToken().then((String value) {
      if (value.isNotEmpty) {
        RewardsService.getRewards();
        CartService.getCart();
        UserService.getAllNotification();
      }
    });

    debugPrint("is notification ===========> $showNotification");
    debugPrint(
      "is show Course Notification ===========> $showCourseNotification",
    );

    if (showNotification) {
      Future.delayed(const Duration(milliseconds: 150), () {
        nextRoute(
          NotificationPage.pageName,
          isClearBackRoutes: false,
        );
      });
    }

    if (showCourseNotification) {
      Map<String, dynamic>? retrievedMap =
          await AppData.getCourseNotification();

      debugPrint(
        "is show Course Notification retrievedMap ===========> "
        "${retrievedMap.toString()}",
      );

      if (retrievedMap != null) {
        Future.delayed(const Duration(milliseconds: 150), () {
          nextRoute(
            SingleCoursePage.pageName,
            arguments: [
              int.parse(retrievedMap["course_id"]),
              retrievedMap["type"] == 'bundle',
              retrievedMap["comment_id"],
            ],
          );
        });
      }
    }
  }

  void _listenForDeepLinks() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleDeepLink();
    });

    DeepLinkService.instance.deepLinkNotifier.addListener(
      _handleDeepLink,
    );
  }

  Future<void> _handleDeepLink() async {
    debugPrint(
      "MainPage DeepLink ======> "
      "${DeepLinkService.instance.deepLinkNotifier.value}",
    );

    if (_isHandlingDeepLink) {
      return;
    }

    final deepLink = DeepLinkService.instance.deepLinkNotifier.value;

    if (deepLink == null) {
      return;
    }

    debugPrint("$tag DeepLink Received => ${deepLink.type}");

    _isHandlingDeepLink = true;

    try {
      switch (deepLink.type) {
        case DeepLinkType.blog:
          final String? blogId = deepLink.blogId;

          if (blogId == null || blogId.isEmpty) {
            return;
          }

          try {
            final BlogModel? blogModel = await BlogService.getBlogDataById(
              blogId,
            );

            if (!mounted) {
              return;
            }

            if (blogModel != null) {
              nextRoute(
                DetailsBlogPage.pageName,
                arguments: blogModel,
              );
            }
          } catch (e) {
            debugPrint(
              "$tag blog deep link error => $e",
            );
          }

          break;

        case DeepLinkType.courseLesson:
          final int? courseId = int.tryParse(deepLink.courseId ?? '');

          final String? lessonId = deepLink.lessonId;

          if (courseId == null || lessonId == null || lessonId.isEmpty) {
            return;
          }

          nextRoute(
            SingleCoursePage.pageName,
            arguments: [
              courseId,
              null,
              null,
              null,
              lessonId,
            ],
          );

          break;

        case DeepLinkType.course:
          final int? courseId = int.tryParse(deepLink.courseId ?? '');

          if (courseId == null) {
            return;
          }

          debugPrint(
            "$tag Opening Course DeepLink ======> $courseId",
          );

          nextRoute(
            SingleCoursePage.pageName,
            arguments: [
              courseId,
              false,
              null,
              false,
              null,
            ],
          );

          break;

        case DeepLinkType.unknown:
          break;
      }

      DeepLinkService.instance.clearPending();
    } finally {
      _isHandlingDeepLink = false;
    }
  }

  // ------------------------------------------------------------
  // Advanced Drawer listener
  //
  // IMPORTANT:
  // This is called only once from initState().
  // ------------------------------------------------------------
  void _addDrawerListener() {
    drawerController.addListener(() {
      if (locator<DrawerProvider>().isOpenDrawer !=
          drawerController.value.visible) {
        Future.delayed(
          const Duration(milliseconds: 300),
        ).then((value) {
          if (mounted) {
            locator<DrawerProvider>().setDrawerState(
              drawerController.value.visible,
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    DeepLinkService.instance.deepLinkNotifier.removeListener(
      _handleDeepLink,
    );

    // Controller is created in initState(),
    // therefore it should be disposed here.
    drawerController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeBottomPadding = MediaQuery.of(context).padding.bottom;

    debugPrint(
      "$tag build safeBottomPadding ============> "
      "$safeBottomPadding",
    );

    debugPrint(
      "$tag build width ============> "
      "${MediaQuery.of(context).size.width}",
    );

    debugPrint(
      "$tag build height ============> "
      "${MediaQuery.of(context).size.height}",
    );

    if (MediaQuery.of(context).size.height > 900) {
      bottomNavHeight = 110 + safeBottomPadding;
    } else {
      bottomNavHeight = 110;
    }

    if (Platform.isIOS) {
      bottomNavHeight = 110;

      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [
          SystemUiOverlay.top,
        ],
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (v) {
        if (locator<PageProvider>().page == PageNames.home) {
          MainWidget.showExitDialog();
        } else {
          locator<PageProvider>().setPage(
            PageNames.home,
          );
        }
      },
      child: Consumer<AppLanguageProvider>(
        builder: (context, languageProvider, _) {
          // ------------------------------------------------------
          // IMPORTANT:
          // DO NOT create AdvancedDrawerController here.
          //
          // Removed:
          //
          // drawerController = AdvancedDrawerController();
          //
          // Also removed:
          //
          // addListener();
          //
          // ------------------------------------------------------

          return directionality(
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: green77(),
              body: Consumer<PageProvider>(
                builder: (context, pageProvider, _) {
                  return AdvancedDrawer(
                    // ------------------------------------------------
                    // IMPORTANT:
                    // Removed:
                    //
                    // key: UniqueKey(),
                    //
                    // UniqueKey() was forcing AdvancedDrawer to be
                    // recreated on every build.
                    // ------------------------------------------------
                    disabledGestures:
                        pageProvider.page == PageNames.latestEvents,
                    backdropColor: Colors.transparent,
                    drawer: const MainDrawer(),
                    openRatio: .6,
                    openScale: .75,
                    animationDuration: const Duration(milliseconds: 150),
                    animateChildDecoration: false,
                    animationCurve: Curves.linear,

                    // Use the single controller created in initState.
                    controller: drawerController,

                    childDecoration: BoxDecoration(
                      borderRadius: Platform.isIOS
                          ? borderRadius()
                          : const BorderRadius.vertical(
                              top: Radius.circular(21),
                            ),
                      color: Colors.transparent,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .12),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),

                    rtlOpening: locator<AppLanguage>().isRtl(),

                    backdrop: Container(
                      width: getSize().width,
                      height: getSize().height,
                      color: green63,

                      // decoration: const BoxDecoration(
                      //   image: DecorationImage(
                      //     image: AssetImage(AppAssets.splashPng),
                      //     fit: BoxFit.cover,
                      //   ),
                      // ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          space(60),
                          Image.asset(
                            AppAssets.worldPng,
                            width: getSize().width * .8,
                            fit: BoxFit.cover,
                          ),
                        ],
                      ),
                    ),

                    child: SafeArea(
                      bottom: !kIsWeb && Platform.isAndroid,
                      top: false,
                      child: Scaffold(
                        backgroundColor: Colors.transparent,
                        resizeToAvoidBottomInset: false,
                        extendBody: true,
                        body: pageProvider.pages[pageProvider.page],
                        bottomNavigationBar: Directionality(
                          textDirection: TextDirection.ltr,
                          child: Consumer<DrawerProvider>(
                            builder: (
                              context,
                              drawerProvider,
                              _,
                            ) {
                              return Stack(
                                children: [
                                  // ------------------------------------------------
                                  // Background
                                  // ------------------------------------------------
                                  Positioned.fill(
                                    bottom: 0,
                                    top: getSize().height - bottomNavHeight,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                        bottom: drawerProvider.isOpenDrawer
                                            ? const Radius.circular(
                                                kIsWeb ? 0 : 20,
                                              )
                                            : Radius.zero,
                                      ),
                                      child: ClipPath(
                                        clipper: BottomNavClipper(),
                                        child: Container(
                                          width: getSize().width,
                                          height: bottomNavHeight,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                green77(),
                                                green77(),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // ------------------------------------------------
                                  // Bottom Navigation Items
                                  // ------------------------------------------------
                                  Positioned.fill(
                                    bottom: 0,
                                    top: getSize().height - bottomNavHeight,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        MainWidget.navItem(
                                          PageNames.categories,
                                          pageProvider.page,
                                          appText.categories,
                                          AppAssets.categorySvg,
                                          () {
                                            pageProvider.setPage(
                                              PageNames.categories,
                                            );
                                          },
                                        ),

                                        // Added latest event menu
                                        // and removed provider
                                        // on 06-05-2026
                                        MainWidget.navItem(
                                          PageNames.latestEvents,
                                          pageProvider.page,
                                          appText.latestEvents,
                                          AppAssets.meetingsSvg,
                                          () {
                                            pageProvider.setPage(
                                              PageNames.latestEvents,
                                            );
                                          },
                                        ),

                                        // MainWidget.navItem(
                                        //   PageNames.providers,
                                        //   pageProvider.page,
                                        //   appText.providers,
                                        //   AppAssets.provideresSvg,
                                        //   () {
                                        //     pageProvider.setPage(
                                        //       PageNames.providers,
                                        //     );
                                        //   },
                                        // ),

                                        MainWidget.homeNavItem(
                                          PageNames.home,
                                          pageProvider.page,
                                          () {
                                            pageProvider.setPage(
                                              PageNames.home,
                                            );
                                          },
                                        ),

                                        MainWidget.navItem(
                                          PageNames.blog,
                                          pageProvider.page,
                                          appText.blog,
                                          AppAssets.blogSvg,
                                          () {
                                            pageProvider.setPage(
                                              PageNames.blog,
                                            );
                                          },
                                        ),

                                        MainWidget.navItem(
                                          PageNames.myClasses,
                                          pageProvider.page,
                                          appText.myClassess,
                                          AppAssets.classesSvg,
                                          () {
                                            pageProvider.setPage(
                                              PageNames.myClasses,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class BottomNavClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double height = size.height;
    double width = size.width;

    Path path = Path();

    path.lineTo(0, 0);
    path.lineTo(0, height);
    path.lineTo(width, height);

    path.lineTo(size.width, 0);
    path.quadraticBezierTo(
      width,
      45,
      width - 45,
      45,
    );

    path.lineTo(45, 45);

    path.quadraticBezierTo(
      0,
      45,
      0,
      0,
    );

    // path.moveTo(0, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(
    covariant CustomClipper<Path> oldClipper,
  ) =>
      true;
}

// import 'dart:async';
// import 'dart:io';
//
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
// // import 'package:flutter_native_splash/flutter_native_splash.dart';
// import 'package:provider/provider.dart';
// import 'package:webinar/app/models/blog_model.dart';
// import 'package:webinar/app/pages/main_page/home_page/notification_page.dart';
// import 'package:webinar/app/pages/main_page/home_page/single_course_page/single_course_page.dart';
// import 'package:webinar/app/providers/drawer_provider.dart';
// import 'package:webinar/app/providers/page_provider.dart';
// import 'package:webinar/app/services/guest_service/course_service.dart';
// import 'package:webinar/app/services/user_service/blog_service.dart';
// import 'package:webinar/app/services/user_service/cart_service.dart';
// import 'package:webinar/app/services/user_service/rewards_service.dart';
// import 'package:webinar/app/services/user_service/user_service.dart';
// import 'package:webinar/app/widgets/main_widget/main_drawer.dart';
// import 'package:webinar/app/widgets/main_widget/main_widget.dart';
// import 'package:webinar/common/common.dart';
// import 'package:webinar/common/data/app_data.dart';
// import 'package:webinar/common/data/app_language.dart';
// import 'package:webinar/common/database/app_database.dart';
// import 'package:webinar/common/deeplink/deep_link_service.dart';
// import 'package:webinar/common/deeplink/deep_link_type.dart';
// import 'package:webinar/common/utils/app_text.dart';
// import 'package:webinar/config/colors.dart';
// import 'package:webinar/locator.dart';
// import 'package:webinar/main.dart';
//
// import '../../../common/enums/page_name_enum.dart';
// import '../../../common/utils/object_instance.dart';
// import '../../../config/assets.dart';
// import '../../providers/app_language_provider.dart';
// import 'blog_page/details_blog_page.dart';
//
// class MainPage extends StatefulWidget {
//   static const String pageName = '/main';
//
//   const MainPage({super.key});
//
//   @override
//   State<MainPage> createState() => _MainPageState();
// }
//
// class _MainPageState extends State<MainPage> {
//   static const String tag = "_MainPageState";
//
//   late Future<int> future;
//   double bottomNavHeight = 110;
//   bool _isHandlingDeepLink = false;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _listenForDeepLinks();
//
//     future = Future<int>(() {
//       return 0;
//     });
//
//     locator<DrawerProvider>().isOpenDrawer = false;
//
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
//       AppDataBase.getCoursesAndSaveInDB();
//       addListener();
//       if (defaultTargetPlatform == TargetPlatform.iOS) {
//         FirebaseMessaging.instance.getAPNSToken().then((String? value) {
//           try {
//             if (value != null) {
//               debugPrint('token : $value');
//               UserService.sendFirebaseToken(value);
//             }
//           } catch (_) {
//             debugPrint("Error in sending firebase token =====> ${_.toString()}");
//           }
//         });
//       } else {
//         FirebaseMessaging.instance.getToken().then((String? value) {
//           try {
//             if (value != null) {
//               debugPrint('token : $value');
//               UserService.sendFirebaseToken(value);
//             }
//           } catch (_) {
//             debugPrint("Error in sending firebase token =====> ${_.toString()}");
//           }
//         });
//       }
//     });
//
//     getData();
//   }
//
//   getData() async {
//     CourseService.getReasons();
//     // added to show the advertise image in popup 11-05-2026
//     AppData.getAccessToken().then((String value) {
//       if (value.isNotEmpty) {
//         RewardsService.getRewards();
//         CartService.getCart();
//         UserService.getAllNotification();
//       }
//     });
//
//     debugPrint("is notification ===========> $showNotification");
//     debugPrint("is show Course Notification ===========> $showCourseNotification");
//     if (showNotification) {
//       Future.delayed(const Duration(milliseconds: 150), () {
//         nextRoute(NotificationPage.pageName, isClearBackRoutes: false);
//       });
//     }
//     if (showCourseNotification) {
//       Map<String, dynamic>? retrievedMap = await AppData.getCourseNotification();
//       debugPrint("is show Course Notification retrievedMap ===========> ${retrievedMap.toString()}");
//       if (retrievedMap != null) {
//         Future.delayed(const Duration(milliseconds: 150), () {
//           nextRoute(SingleCoursePage.pageName, arguments: [
//             int.parse(retrievedMap["course_id"]),
//             retrievedMap["type"] == 'bundle',
//             retrievedMap["comment_id"],
//           ]);
//         });
//       }
//     }
//   }
//
//   void _listenForDeepLinks() {
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _handleDeepLink();
//     });
//
//     DeepLinkService.instance.deepLinkNotifier.addListener(
//       _handleDeepLink,
//     );
//   }
//
//   Future<void> _handleDeepLink() async {
//     debugPrint("MainPage DeepLink ======> ${DeepLinkService.instance.deepLinkNotifier.value}");
//     if (_isHandlingDeepLink) {
//       return;
//     }
//     final deepLink = DeepLinkService.instance.deepLinkNotifier.value;
//     if (deepLink == null) {
//       return;
//     }
//     debugPrint("$tag DeepLink Received => ${deepLink.type}");
//
//     _isHandlingDeepLink = true;
//     try {
//       switch (deepLink.type) {
//         case DeepLinkType.blog:
//           final String? blogId = deepLink.blogId;
//
//           if (blogId == null || blogId.isEmpty) {
//             return;
//           }
//
//           try {
//             final BlogModel? blogModel = await BlogService.getBlogDataById(
//               blogId,
//             );
//
//             if (!mounted) return;
//
//             if (blogModel != null) {
//               nextRoute(
//                 DetailsBlogPage.pageName,
//                 arguments: blogModel,
//               );
//             }
//           } catch (e) {
//             debugPrint(
//               "$tag blog deep link error => $e",
//             );
//           }
//           break;
//         case DeepLinkType.courseLesson:
//           final int? courseId = int.tryParse(deepLink.courseId ?? '');
//
//           final String? lessonId = deepLink.lessonId;
//
//           if (courseId == null || lessonId == null || lessonId.isEmpty) {
//             return;
//           }
//
//           nextRoute(
//             SingleCoursePage.pageName,
//             arguments: [
//               courseId,
//               null,
//               null,
//               null,
//               lessonId,
//             ],
//           );
//           break;
//         case DeepLinkType.course:
//         case DeepLinkType.unknown:
//           break;
//       }
//
//       DeepLinkService.instance.clearPending();
//     } finally {
//       _isHandlingDeepLink = false;
//     }
//   }
//
//   @override
//   void dispose() {
//     DeepLinkService.instance.deepLinkNotifier.removeListener(
//       _handleDeepLink,
//     );
//     drawerController.dispose();
//     super.dispose();
//   }
//
//   addListener() {
//     drawerController.addListener(() {
//       if (locator<DrawerProvider>().isOpenDrawer != drawerController.value.visible) {
//         Future.delayed(const Duration(milliseconds: 300)).then((value) {
//           if (mounted) {
//             locator<DrawerProvider>().setDrawerState(drawerController.value.visible);
//           }
//         });
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // bottomNavHeight = 110;
//     final safeBottomPadding = MediaQuery.of(context).padding.bottom;
//     debugPrint("$tag build safeBottomPadding ============> $safeBottomPadding");
//     debugPrint("$tag build width ============> ${MediaQuery.of(context).size.width}");
//     debugPrint("$tag build height ============> ${MediaQuery.of(context).size.height}");
//     if (MediaQuery.of(context).size.height > 900) {
//       bottomNavHeight = 110 + safeBottomPadding;
//     } else {
//       bottomNavHeight = 110;
//     }
//     if (Platform.isIOS) {
//       bottomNavHeight = 110;
//       SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
//     }
//     return PopScope(
//       canPop: false,
//       onPopInvoked: (v) {
//         if (locator<PageProvider>().page == PageNames.home) {
//           MainWidget.showExitDialog();
//         } else {
//           locator<PageProvider>().setPage(PageNames.home);
//         }
//       },
//       child: Consumer<AppLanguageProvider>(builder: (context, languageProvider, _) {
//         drawerController = AdvancedDrawerController();
//         if (locator<DrawerProvider>().isOpenDrawer) {
//           drawerController.showDrawer();
//         } else {
//           drawerController.hideDrawer();
//         }
//
//         addListener();
//
//         return directionality(
//           child: Scaffold(
//             resizeToAvoidBottomInset: false,
//             backgroundColor: green77(),
//             body: Consumer<PageProvider>(builder: (context, pageProvider, _) {
//               return AdvancedDrawer(
//                 key: UniqueKey(),
//                 disabledGestures: pageProvider.page == PageNames.latestEvents,
//                 backdropColor: Colors.transparent,
//                 drawer: const MainDrawer(),
//                 openRatio: .6,
//                 openScale: .75,
//                 animationDuration: const Duration(milliseconds: 150),
//                 animateChildDecoration: false,
//                 animationCurve: Curves.linear,
//                 controller: drawerController,
//                 childDecoration: BoxDecoration(
//                     // borderRadius: Platform.isIOS ? borderRadius() : const BorderRadius.vertical(top: Radius.circular(21)),
//                     // borderRadius: kIsWeb ? null : borderRadius(radius: isOpen ? 20 : 0),
//                     color: Colors.transparent,
//                     boxShadow: [BoxShadow(color: Colors.black.withOpacity(.12), blurRadius: 30, offset: const Offset(0, 10))]),
//                 rtlOpening: locator<AppLanguage>().isRtl(),
//                 // background
//                 backdrop: Container(
//                   width: getSize().width,
//                   height: getSize().height,
//                   color: green63,
//
//                   // decoration: const BoxDecoration(
//                   //   image: DecorationImage(
//                   //     image: AssetImage(AppAssets.splashPng),
//                   //     fit: BoxFit.cover,
//                   //   )
//                   // ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       space(60),
//                       Image.asset(
//                         AppAssets.worldPng,
//                         width: getSize().width * .8,
//                         fit: BoxFit.cover,
//                       ),
//                     ],
//                   ),
//                 ),
//                 child: SafeArea(
//                   bottom: !kIsWeb && Platform.isAndroid,
//                   top: false,
//                   child: Scaffold(
//                     backgroundColor: Colors.transparent,
//                     resizeToAvoidBottomInset: false,
//                     extendBody: true,
//                     body: pageProvider.pages[pageProvider.page],
//                     bottomNavigationBar: Directionality(
//                       textDirection: TextDirection.ltr,
//                       child: Consumer<DrawerProvider>(builder: (context, drawerProvider, _) {
//                         return Stack(
//                           children: [
//                             // background
//                             Positioned.fill(
//                               bottom: 0,
//                               top: getSize().height - bottomNavHeight,
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.vertical(bottom: drawerProvider.isOpenDrawer ? const Radius.circular(kIsWeb ? 0 : 20) : Radius.zero),
//                                 child: ClipPath(
//                                   clipper: BottomNavClipper(),
//                                   child: Container(
//                                     width: getSize().width,
//                                     height: bottomNavHeight,
//                                     // decoration: BoxDecoration(gradient: LinearGradient(colors: [green77(), green4B], begin: Alignment.topLeft, end: Alignment.bottomRight)),
//                                     decoration: BoxDecoration(gradient: LinearGradient(colors: [green77(), green77()], begin: Alignment.topLeft, end: Alignment.bottomRight)),
//                                   ),
//                                 ),
//                               ),
//                             ),
//
//                             Positioned.fill(
//                               bottom: 0,
//                               top: getSize().height - bottomNavHeight,
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   MainWidget.navItem(PageNames.categories, pageProvider.page, appText.categories, AppAssets.categorySvg, () {
//                                     pageProvider.setPage(PageNames.categories);
//                                   }),
//                                   // added latest event menu and remove provider on 06-05-2026
//                                   MainWidget.navItem(PageNames.latestEvents, pageProvider.page, appText.latestEvents, AppAssets.meetingsSvg, () {
//                                     pageProvider.setPage(PageNames.latestEvents);
//                                   }),
//                                   // MainWidget.navItem(PageNames.providers, pageProvider.page, appText.providers, AppAssets.provideresSvg, () {
//                                   //   pageProvider.setPage(PageNames.providers);
//                                   // }),
//                                   MainWidget.homeNavItem(PageNames.home, pageProvider.page, () {
//                                     pageProvider.setPage(PageNames.home);
//                                   }),
//                                   MainWidget.navItem(PageNames.blog, pageProvider.page, appText.blog, AppAssets.blogSvg, () {
//                                     pageProvider.setPage(PageNames.blog);
//                                   }),
//                                   MainWidget.navItem(PageNames.myClasses, pageProvider.page, appText.myClassess, AppAssets.classesSvg, () {
//                                     pageProvider.setPage(PageNames.myClasses);
//                                   }),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         );
//                       }),
//                     ),
//                   ),
//                 ),
//               );
//             }),
//           ),
//         );
//       }),
//     );
//   }
// }
//
// class BottomNavClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     double height = size.height;
//     double width = size.width;
//
//     Path path = Path();
//
//     path.lineTo(0, 0);
//     path.lineTo(0, height);
//     path.lineTo(width, height);
//
//     path.lineTo(size.width, 0);
//     path.quadraticBezierTo(width, 45, width - 45, 45);
//
//     path.lineTo(45, 45);
//
//     path.quadraticBezierTo(0, 45, 0, 0);
//
//     // path.moveTo(0, 0);
//     path.close();
//     return path;
//   }
//
//   @override
//   bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
// }
