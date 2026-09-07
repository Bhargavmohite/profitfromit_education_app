// ignore_for_file: unused_import

import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:webinar/app/pages/authentication_page/login_page.dart';
import 'package:webinar/app/pages/authentication_page/reset_password_page.dart';
import 'package:webinar/app/pages/introduction_page/intro_page.dart';
import 'package:webinar/app/pages/introduction_page/ip_empty_state_page.dart';
import 'package:webinar/app/pages/introduction_page/maintenance_page.dart';
import 'package:webinar/app/pages/introduction_page/splash_page.dart';
import 'package:webinar/app/pages/main_page/home_page/cart_page/web_checkout_v2_page.dart';
import 'package:webinar/app/pages/main_page/home_page/dashboard_page/reward_point_page.dart';
import 'package:webinar/app/pages/main_page/home_page/meetings_page/meeting_details_page.dart';
import 'package:webinar/app/pages/main_page/home_page/payment_status_page/payment_status_page.dart';
import 'package:webinar/app/pages/main_page/home_page/single_course_page/single_content_page/pdf_viewer_page.dart';
import 'package:webinar/app/pages/main_page/home_page/single_course_page/single_content_page/web_view_page.dart';
import 'package:webinar/app/pages/main_page/products_page/products_page.dart';
import 'package:webinar/app/pages/offline_page/internet_connection_page.dart';
import 'package:webinar/app/pages/offline_page/offline_list_course_page.dart';
import 'package:webinar/app/pages/offline_page/offline_single_content_page.dart';
import 'package:webinar/app/pages/offline_page/offline_single_course_page.dart';
import 'package:webinar/app/providers/drawer_provider.dart';
import 'package:webinar/common/data/app_data.dart';
import 'package:webinar/common/data/app_language.dart';
import 'package:webinar/common/database/model/course_model_db.dart';
import 'package:webinar/common/deeplink/deep_link_handler.dart';
import 'package:webinar/common/deeplink/deep_link_model.dart';
import 'package:webinar/common/deeplink/deep_link_service.dart';
import 'package:webinar/common/deeplink/deep_link_type.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/common/utils/constants.dart';
import 'package:webinar/config/colors.dart';
import 'package:webinar/config/notification.dart';

import 'app/pages/authentication_page/forget_password_page.dart';
import 'app/pages/authentication_page/register_page.dart';
import 'app/pages/authentication_page/verify_code_page.dart';
import 'app/pages/main_page/blog_page/details_blog_page.dart';
import 'app/pages/main_page/categories_page/filter_category_page/filter_category_page.dart';
import 'app/pages/main_page/classes_page/course_overview_page.dart';
import 'app/pages/main_page/home_page/assignments_page/assignment_history_page.dart';
import 'app/pages/main_page/home_page/assignments_page/assignment_overview_page.dart';
import 'app/pages/main_page/home_page/assignments_page/assignments_page.dart';
import 'app/pages/main_page/home_page/assignments_page/submissions_page.dart';
import 'app/pages/main_page/home_page/blog_webview.dart';
import 'app/pages/main_page/home_page/cart_page/bank_accounts_page.dart';
import 'app/pages/main_page/home_page/cart_page/cart_page.dart';
import 'app/pages/main_page/home_page/cart_page/checkout_page.dart';
import 'app/pages/main_page/home_page/certificates_page/certificates_details_page.dart';
import 'app/pages/main_page/home_page/certificates_page/certificates_page.dart';
import 'app/pages/main_page/home_page/certificates_page/certificates_student_page.dart';
import 'app/pages/main_page/home_page/comments_page/comment_details_page.dart';
import 'app/pages/main_page/home_page/comments_page/comments_page.dart';
import 'app/pages/main_page/home_page/dashboard_page/dashboard_page.dart';
import 'app/pages/main_page/home_page/events_page/events_page.dart';
import 'app/pages/main_page/home_page/favorites_page/favorites_page.dart';
import 'app/pages/main_page/home_page/financial_page/financial_page.dart';
import 'app/pages/main_page/home_page/meetings_page/meetings_page.dart';
import 'app/pages/main_page/home_page/notification_page.dart';
import 'app/pages/main_page/home_page/quizzes_page/quiz_info_page.dart';
import 'app/pages/main_page/home_page/quizzes_page/quiz_page.dart';
import 'app/pages/main_page/home_page/quizzes_page/quizzes_page.dart';
import 'app/pages/main_page/home_page/search_page/result_search_page.dart';
import 'app/pages/main_page/home_page/search_page/suggested_search_page.dart';
import 'app/pages/main_page/home_page/setting_page/setting_page.dart';
import 'app/pages/main_page/home_page/single_course_page/forum_page/forum_answer_page.dart';
import 'app/pages/main_page/home_page/single_course_page/forum_page/search_forum_page.dart';
import 'app/pages/main_page/home_page/single_course_page/learning_page.dart';
import 'app/pages/main_page/home_page/single_course_page/single_content_page/single_content_page.dart';
import 'app/pages/main_page/home_page/single_course_page/single_course_page.dart';
import 'app/pages/main_page/home_page/subscription_page/subscription_page.dart';
import 'app/pages/main_page/home_page/support_message_page/conversation_page.dart';
import 'app/pages/main_page/home_page/support_message_page/support_message_page.dart';
import 'app/pages/main_page/main_page.dart';
import 'app/pages/main_page/providers_page/user_profile_page/user_profile_page.dart';
import 'app/providers/app_language_provider.dart';
import 'app/providers/filter_course_provider.dart';
import 'app/providers/page_provider.dart';
import 'app/providers/providers_provider.dart';
import 'app/providers/user_provider.dart';
import 'common/common.dart';
import 'locator.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(CourseModelDBAdapter());
  await locatorSetup();
  await locator<AppLanguage>().getLanguage();

  await initializeDateFormatting();
  tz.initializeTimeZones();

  await Firebase.initializeApp();

  await GoogleSignIn.instance.initialize(
    serverClientId:
        "237411900385-2uqshnf61llh122to3uua07g5tab1uda.apps.googleusercontent.com",
  );

  debugPrint("GOOGLE SIGN-IN INITIALIZED");

  try {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    WidgetsBinding.instance.platformDispatcher.onError =
        (Object error, StackTrace stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (e, st) {
    debugPrint("Crashlytics setup failed (non-fatal) =====> $e");
    debugPrint("$st");
  }

  // await DeepLinkService.instance.initialize();

  runApp(const MyApp());

  Future.microtask(() async {
    await DeepLinkService.instance.initialize();
  });

  await setupFlutterNotifications();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    showFlutterNotification(message);
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.data.containsKey("notification_key") &&
        message.data["notification_key"] != null) {
      showCourseNotification = true;
      AppData.saveCourseNotification(message.data);
      nextRoute(MainPage.pageName, isClearBackRoutes: true);
    } else {
      Future.delayed(const Duration(milliseconds: 150), () {
        Get.to(() => const NotificationPage());
      });
    }
  });

  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    if (initialMessage.data.containsKey("notification_key") &&
        initialMessage.data["notification_key"] != null) {
      showCourseNotification = true;
      AppData.saveCourseNotification(initialMessage.data);
    } else {
      showNotification = true;
    }
  }
}

bool showNotification = false;
bool showCourseNotification = false;
String blogId = "";

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseAnalyticsObserver? analyticsObserver;

  @override
  void initState() {
    super.initState();
    analyticsObserver =
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => locator<AppLanguageProvider>()),
        ChangeNotifierProvider(create: (context) => locator<PageProvider>()),
        ChangeNotifierProvider(
            create: (context) => locator<FilterCourseProvider>()),
        ChangeNotifierProvider(
            create: (context) => locator<ProvidersProvider>()),
        ChangeNotifierProvider(create: (context) => locator<UserProvider>()),
        ChangeNotifierProvider(create: (context) => locator<DrawerProvider>()),
      ],
      child: GetMaterialApp(
        title: appText.webinar,
        navigatorKey: navigatorKey,
        navigatorObservers: <NavigatorObserver>[
          analyticsObserver!,
          Constants.singleCourseRouteObserver,
          Constants.contentRouteObserver
        ],
        scrollBehavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
          },
        ),
        theme: ThemeData(
          useMaterial3: false,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
          scaffoldBackgroundColor: greyFA,
        ),
        debugShowCheckedModeBanner: false,
        // initialRoute: SplashPage.pageName,
        home: const SplashPage(),
        onGenerateRoute: (settings) {
          debugPrint("onGenerateRoute => ${settings.name}");

          if (settings.name?.startsWith('/blog/') == true ||
              settings.name?.startsWith('/course/') == true) {
            return MaterialPageRoute(
              builder: (_) => const SplashPage(),
            );
          }

          return null;
        },
        routes: {
          MainPage.pageName: (context) => const MainPage(),
          SplashPage.pageName: (context) => const SplashPage(),
          IntroPage.pageName: (context) => const IntroPage(),
          LoginPage.pageName: (context) => const LoginPage(),
          RegisterPage.pageName: (context) => const RegisterPage(),
          VerifyCodePage.pageName: (context) => const VerifyCodePage(),
          ForgetPasswordPage.pageName: (context) => const ForgetPasswordPage(),
          ResetPasswordPage.pageName: (context) =>
              const ResetPasswordPage(), // added page for reset password on 12-08-2025
          FilterCategoryPage.pageName: (context) => const FilterCategoryPage(),
          SuggestedSearchPage.pageName: (context) =>
              const SuggestedSearchPage(),
          ResultSearchPage.pageName: (context) => const ResultSearchPage(),
          DetailsBlogPage.pageName: (context) => const DetailsBlogPage(),
          SingleCoursePage.pageName: (context) => const SingleCoursePage(),
          LearningPage.pageName: (context) => const LearningPage(),
          SearchForumPage.pageName: (context) => const SearchForumPage(),
          ForumAnswerPage.pageName: (context) => const ForumAnswerPage(),
          NotificationPage.pageName: (context) => const NotificationPage(),
          CartPage.pageName: (context) => const CartPage(),
          CheckoutPage.pageName: (context) => const CheckoutPage(),
          WebCheckoutV2Page.pageName: (context) =>
              const WebCheckoutV2Page(), // added as per new payment gateway on 07-07-2025
          BlogWebview.pageName: (context) =>
              const BlogWebview(), // added for blog webview page 07-07-2025
          ProductsPage.pageName: (context) =>
              const ProductsPage(), // added for product webview page 19-05-2026
          SingleContentPage.pageName: (context) => const SingleContentPage(),
          WebViewPage.pageName: (context) => const WebViewPage(),
          BankAccountsPage.pageName: (context) => const BankAccountsPage(),
          UserProfilePage.pageName: (context) => const UserProfilePage(),
          AssignmentsPage.pageName: (context) => const AssignmentsPage(),
          AssignmentOverviewPage.pageName: (context) =>
              const AssignmentOverviewPage(),
          SubmissionsPage.pageName: (context) => const SubmissionsPage(),
          AssignmentHistoryPage.pageName: (context) =>
              const AssignmentHistoryPage(),
          FinancialPage.pageName: (context) => const FinancialPage(),
          CourseOverviewPage.pageName: (context) => const CourseOverviewPage(),
          MeetingsPage.pageName: (context) => const MeetingsPage(),
          MeetingDetailsPage.pageName: (context) => const MeetingDetailsPage(),
          EventsPage.pageName: (context) =>
              const EventsPage(), // added for latest events on 19-08-2025
          CommentsPage.pageName: (context) => const CommentsPage(),
          CommentDetailsPage.pageName: (context) => const CommentDetailsPage(),
          SettingPage.pageName: (context) => const SettingPage(),
          QuizzesPage.pageName: (context) => const QuizzesPage(),
          QuizInfoPage.pageName: (context) => const QuizInfoPage(),
          QuizPage.pageName: (context) => const QuizPage(),
          CertificatesPage.pageName: (context) => const CertificatesPage(),
          CertificatesDetailsPage.pageName: (context) =>
              const CertificatesDetailsPage(),
          CertificatesStudentPage.pageName: (context) =>
              const CertificatesStudentPage(),
          SubscriptionPage.pageName: (context) => const SubscriptionPage(),
          FavoritesPage.pageName: (context) => const FavoritesPage(),
          DashboardPage.pageName: (context) => const DashboardPage(),
          SupportMessagePage.pageName: (context) => const SupportMessagePage(),
          ConversationPage.pageName: (context) => const ConversationPage(),
          PdfViewerPage.pageName: (context) => const PdfViewerPage(),
          RewardPointPage.pageName: (context) => const RewardPointPage(),
          MaintenancePage.pageName: (context) => const MaintenancePage(),
          PaymentStatusPage.pageName: (context) => const PaymentStatusPage(),
          IpEmptyStatePage.pageName: (context) => const IpEmptyStatePage(),
          // offline pages...
          InternetConnectionPage.pageName: (context) =>
              const InternetConnectionPage(),
          OfflineListCoursePage.pageName: (context) =>
              const OfflineListCoursePage(),
          OfflineSingleCoursePage.pageName: (context) =>
              const OfflineSingleCoursePage(),
          OfflineSingleContentPage.pageName: (context) =>
              const OfflineSingleContentPage(),
        },
      ),
    );
  }
}
