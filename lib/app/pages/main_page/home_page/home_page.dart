// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:webinar/app/pages/main_page/categories_page/filter_category_page/filter_category_page.dart';
import 'package:webinar/app/providers/drawer_provider.dart';
import 'package:webinar/app/services/guest_service/course_service.dart';
import 'package:webinar/app/services/user_service/user_service.dart';
import 'package:webinar/app/widgets/main_widget/home_widget/home_widget.dart';
import 'package:webinar/app/widgets/main_widget/home_widget/institutional_models_section.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/data/app_data.dart';
import 'package:webinar/common/shimmer_component.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/config/assets.dart';
import 'package:webinar/config/styles.dart';

import '../../../../common/components.dart';
import '../../../../locator.dart';
import '../../../models/course_model.dart';
import '../../../providers/app_language_provider.dart';
import '../../../providers/filter_course_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  String token = '';
  String name = '';

  TextEditingController searchController = TextEditingController();
  FocusNode searchNode = FocusNode();

  late AnimationController appBarController;
  late Animation<double> appBarAnimation;

  ScrollController scrollController = ScrollController();

  bool isLoadingNewsetListData = false;
  List<CourseModel> newsetListData = [];

  bool isLoadingBestRatedListData = false;
  List<CourseModel> bestRatedListData = [];

  bool isLoadingBestSellingListData = false;
  List<CourseModel> bestSellingListData = [];

  bool isLoadingDiscountListData = false;
  List<CourseModel> discountListData = [];

  bool isLoadingFreeListData = false;
  List<CourseModel> freeListData = [];

  // Latest Bundles disabled on Home Page.
  // bool isLoadingBundleData = false;
  // List<CourseModel> bundleData = [];

  @override
  void initState() {
    super.initState();

    getToken();

    appBarController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    appBarAnimation = Tween<double>(
      begin: 150 + MediaQuery.of(navigatorKey.currentContext!).viewPadding.top,
      end: 80 + MediaQuery.of(navigatorKey.currentContext!).viewPadding.top,
    ).animate(appBarController);

    scrollController.addListener(() {
      if (scrollController.position.pixels > 100) {
        if (!appBarController.isAnimating) {
          if (appBarController.status == AnimationStatus.dismissed) {
            appBarController.forward();
          }
        }
      } else if (scrollController.position.pixels < 50) {
        if (!appBarController.isAnimating) {
          if (appBarController.status == AnimationStatus.completed) {
            appBarController.reverse();
          }
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (ModalRoute.of(context)!.settings.arguments != null) {
        if (AppData.canShowFinalizeSheet) {
          AppData.canShowFinalizeSheet = false;
          // finalize signup
          HomeWidget.showFinalizeRegister(
                  (ModalRoute.of(context)!.settings.arguments as int))
              .then((value) {
            if (value) {
              getToken();
            }
          });
        }
      }
    });
    getData();
  }

  void getData() {
    isLoadingNewsetListData = true;
    // Latest Bundles disabled on Home Page.
    // isLoadingBundleData = true;
    isLoadingBestRatedListData = true;
    isLoadingBestSellingListData = true;
    isLoadingDiscountListData = true;
    isLoadingFreeListData = true;

    // Latest Bundles disabled on Home Page.
    // CourseService.getAll(offset: 0, bundle: true).then((value) {
    //   if (!mounted) return;
    //   setState(() {
    //     isLoadingBundleData = false;
    //     bundleData = value;
    //   });
    // });

    CourseService.getAll(offset: 0, sort: 'newest').then((value) {
      if (!mounted) return;
      setState(() {
        isLoadingNewsetListData = false;
        newsetListData = value;
      });
    });

    CourseService.getAll(offset: 0, sort: 'best_rates').then((value) {
      if (!mounted) return;
      setState(() {
        isLoadingBestRatedListData = false;
        bestRatedListData = value;
      });
    });

    CourseService.getAll(offset: 0, sort: 'bestsellers').then((value) {
      if (!mounted) return;
      setState(() {
        isLoadingBestSellingListData = false;
        bestSellingListData = value;
      });
    });

    CourseService.getAll(offset: 0, discount: true).then((value) {
      if (!mounted) return;
      setState(() {
        isLoadingDiscountListData = false;
        discountListData = value;
      });
    });

    CourseService.getAll(offset: 0, free: true).then((value) {
      if (!mounted) return;
      setState(() {
        isLoadingFreeListData = false;
        freeListData = value;
      });
    });
  }

  getToken() async {
    AppData.getAccessToken().then((value) {
      if (!mounted) return;
      setState(() {
        token = value;
      });

      if (token.isNotEmpty) {
        // get profile and save name
        UserService.getProfile().then((value) async {
          if (value != null) {
            await AppData.saveName(value.fullName ?? '');
            getUserName();
            // if(value.fullName == null || value.fullName == "") {
            //   // finalize signup
            //   HomeWidget.showFinalizeRegister(value.id as int).then((value) {
            //     if(value) {
            //       getToken();
            //     }
            //   });
            // } else {
            //   await AppData.saveName(value.fullName ?? '');
            //   getUserName();
            // }
          }
        });
      }
    });
    getUserName();
  }

  getUserName() {
    AppData.getName().then((value) {
      if (!mounted) return;
      setState(() {
        name = value;
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    searchNode.dispose();
    scrollController.dispose();
    appBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppLanguageProvider>(
        builder: (context, languageProvider, _) {
      return directionality(child:
          Consumer<DrawerProvider>(builder: (context, drawerProvider, _) {
        return ClipRRect(
          borderRadius:
              borderRadius(radius: drawerProvider.isOpenDrawer ? 20 : 0),
          child: Scaffold(
            backgroundColor: const Color(0xFFF5F7FC),
            body: Column(
              children: [
                // app bar
                HomeWidget.homeAppBar(appBarController, appBarAnimation, token,
                    searchController, searchNode, name),

                // body
                Expanded(
                    child: CustomScrollView(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          // 1. Newest Classes
                          newestClass(),
                          // 2. Free Courses! (by spending points) banner
                          bySpendingPoints(),
                          // 3. Best Rated
                          bestRated(),
                          // 4. Institutional Models: Portfolio Diagnosis and Financial Planning
                          const InstitutionalModelsSection.topRow(),
                          // 5. Best Selling
                          bestSelling(),
                          // 6. Institutional Models: Investment Baskets and Wealth Calculations
                          const InstitutionalModelsSection.bottomRow(),
                          // 7. Discounted Classes
                          discountedClasses(),
                          // 8. Free Classes
                          freeClasses(),
                          const SizedBox(height: 125),
                        ],
                      ),
                    )
                  ],
                ))
              ],
            ),
          ),
        );
      }));
    });
  }

  /// Reusable carousel retains the original courseItem's pricing,
  /// details and navigation while giving Home-only items a card surface.
  Widget _courseSection({
    required String title,
    required String subtitle,
    required bool isLoading,
    required List<CourseModel> courses,
    required VoidCallback onViewAll,
    bool isFree = false,
  }) {
    if (!isLoading && courses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeWidget.titleAndMore(
            title,
            subtitle: subtitle,
            onTapViewAll: onViewAll,
          ),
          SizedBox(
            height: 232,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: isLoading ? 3 : courses.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsetsDirectional.only(end: 12),
                  child: Container(
                    width: 178,
                    height: 220,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE7EBF4)),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF173259).withValues(alpha: 0.055),
                          blurRadius: 16,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: isLoading
                        ? courseItemShimmer(endCardPadding: 0)
                        : courseItem(
                            courses[index],
                            endCardPadding: 0,
                            token: token,
                            isFree: isFree,
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget newestClass() => _courseSection(
        title: appText.newestClasses,
        subtitle: 'Fresh learning, updated regularly',
        isLoading: isLoadingNewsetListData,
        courses: newsetListData,
        onViewAll: () {
          locator<FilterCourseProvider>().clearFilter();
          locator<FilterCourseProvider>().sort = 'newest';
          nextRoute(FilterCategoryPage.pageName);
        },
      );

  Widget bySpendingPoints() {
    void openRewards() {
      locator<FilterCourseProvider>().clearFilter();
      locator<FilterCourseProvider>().rewardCourse = true;
      nextRoute(FilterCategoryPage.pageName);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 5, 16, 17),
      child: Container(
        height: 176,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF112A72), Color(0xFF244ED1), Color(0xFF517CF4)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF244ED1).withValues(alpha: 0.16),
              blurRadius: 20,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -35,
              top: -75,
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.10),
                    width: 30,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 12,
              bottom: -55,
              child: Container(
                width: 134,
                height: 134,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'LEARNING REWARDS',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: style10Regular().copyWith(
                              fontSize: 10,
                              letterSpacing: 0.7,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          appText.freeCourses,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: style20Bold().copyWith(
                            color: Colors.white,
                            fontSize: 21,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appText.bySpendingPoints,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: style12Regular().copyWith(
                            color: Colors.white.withValues(alpha: 0.82),
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(11),
                          child: InkWell(
                            onTap: openRewards,
                            borderRadius: BorderRadius.circular(11),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 9,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    appText.view,
                                    style: style12Bold().copyWith(
                                      color: const Color(0xFF0D3CCF),
                                    ),
                                  ),
                                  const SizedBox(width: 7),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 15,
                                    color: Color(0xFF0D3CCF),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 86,
                    height: 110,
                    child: SvgPicture.asset(
                      AppAssets.pointsMedalSvg,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bestRated() => _courseSection(
        title: appText.bestRated,
        subtitle: 'Highly rated by our learners',
        isLoading: isLoadingBestRatedListData,
        courses: bestRatedListData,
        onViewAll: () {
          locator<FilterCourseProvider>().clearFilter();
          locator<FilterCourseProvider>().sort = 'best_rates';
          nextRoute(FilterCategoryPage.pageName);
        },
      );

  Widget bestSelling() => _courseSection(
        title: appText.bestSelling,
        subtitle: 'Most popular learning programmes',
        isLoading: isLoadingBestSellingListData,
        courses: bestSellingListData,
        onViewAll: () {
          locator<FilterCourseProvider>().clearFilter();
          locator<FilterCourseProvider>().sort = 'bestsellers';
          nextRoute(FilterCategoryPage.pageName);
        },
      );

  Widget discountedClasses() => _courseSection(
        title: appText.discountedClasses,
        subtitle: 'Discover courses with special pricing',
        isLoading: isLoadingDiscountListData,
        courses: discountListData,
        onViewAll: () {
          locator<FilterCourseProvider>().clearFilter();
          locator<FilterCourseProvider>().discount = true;
          nextRoute(FilterCategoryPage.pageName);
        },
      );

  Widget freeClasses() => _courseSection(
        title: appText.freeClasses,
        subtitle: 'Start exploring at no cost',
        isLoading: isLoadingFreeListData,
        courses: freeListData,
        isFree: true,
        onViewAll: () {
          locator<FilterCourseProvider>().clearFilter();
          locator<FilterCourseProvider>().free = true;
          nextRoute(FilterCategoryPage.pageName);
        },
      );
}
