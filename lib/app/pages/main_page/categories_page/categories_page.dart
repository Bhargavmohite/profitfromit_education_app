import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:webinar/app/pages/main_page/categories_page/filter_category_page/filter_category_page.dart';
import 'package:webinar/app/providers/app_language_provider.dart';
import 'package:webinar/app/providers/drawer_provider.dart';
import 'package:webinar/app/services/guest_service/categories_service.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/data/app_language.dart';
import 'package:webinar/common/shimmer_component.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/config/assets.dart';
import 'package:webinar/config/colors.dart';
import 'package:webinar/config/styles.dart';
import 'package:webinar/locator.dart';

import '../../../../common/components.dart';
import '../../../../common/utils/object_instance.dart';
import '../../../models/category_model.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  bool isLoading = true;
  List<CategoryModel> trendCategories = [];
  List<CategoryModel> categories = [];

  @override
  void initState() {
    super.initState();
    Future.wait([getCategoriesData(), getTrendCategoriessData()]).then((value) {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future getCategoriesData() async {
    final List<CategoryModel> loadedCategories =
        await CategoriesService.categories();

    categories = List<CategoryModel>.from(loadedCategories)
      ..sort((CategoryModel a, CategoryModel b) {
        final int aPriority = _categoryPriority(a.title);
        final int bPriority = _categoryPriority(b.title);

        if (aPriority != bPriority) {
          return aPriority.compareTo(bPriority);
        }

        // Keep any other API categories stable/alphabetical after the
        // three requested primary categories.
        return (a.title ?? '')
            .toLowerCase()
            .compareTo((b.title ?? '').toLowerCase());
      });
  }

  int _categoryPriority(String? title) {
    final String normalized = (title ?? '').trim().toLowerCase();

    if (normalized.contains('stock market') && normalized.contains('update')) {
      return 0;
    }

    if (normalized.contains('basic version')) {
      return 1;
    }

    if (normalized.contains('premium version')) {
      return 2;
    }

    return 100;
  }

  Future getTrendCategoriessData() async {
    trendCategories = await CategoriesService.trendCategories();
  }

  Widget _categoryCard(CategoryModel category, int index) {
    final bool hasSubCategories = category.subCategories?.isNotEmpty ?? false;

    final Color categoryColor = category.color ?? green77();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      width: getSize().width,
      margin: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        index == categories.length - 1 ? 0 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE8ECF2),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D101828),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                if (!hasSubCategories) {
                  nextRoute(
                    FilterCategoryPage.pageName,
                    arguments: category,
                  );
                  return;
                }

                setState(() {
                  category.isOpen = !category.isOpen;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: .10),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      alignment: Alignment.center,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: Image.network(
                          category.icon ?? '',
                          width: 27,
                          height: 27,
                          fit: BoxFit.contain,
                          errorBuilder: (
                            BuildContext context,
                            Object error,
                            StackTrace? stackTrace,
                          ) {
                            return Icon(
                              Icons.school_outlined,
                              size: 25,
                              color: categoryColor,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.title ?? '',
                            style: style14Bold().copyWith(
                              color: const Color(0xFF101828),
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                Icons.play_circle_outline_rounded,
                                size: 15,
                                color: greyA5,
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  (category.webinarsCount ?? 0) == 0
                                      ? appText.noCourse
                                      : '${category.webinarsCount ?? 0} ${appText.courses}',
                                  style: style12Regular().copyWith(
                                    color: greyA5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F8FB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: AnimatedRotation(
                        turns: hasSubCategories && category.isOpen
                            ? 0.25
                            : locator<AppLanguage>().isRtl()
                                ? 0.5
                                : 0,
                        duration: const Duration(milliseconds: 200),
                        child: SvgPicture.asset(
                          AppAssets.arrowRightSvg,
                          width: 16,
                          height: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (hasSubCategories && category.isOpen) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFF0F2F5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 7, 15, 10),
              child: Column(
                children: List.generate(
                  category.subCategories!.length,
                  (subIndex) {
                    final CategoryModel subCategory =
                        category.subCategories![subIndex];

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(11),
                        onTap: () {
                          nextRoute(
                            FilterCategoryPage.pageName,
                            arguments: subCategory,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: categoryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      subCategory.title ?? '',
                                      style: style14Bold().copyWith(
                                        color: const Color(0xFF344054),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      (subCategory.webinarsCount ?? 0) == 0
                                          ? appText.noCourse
                                          : '${subCategory.webinarsCount ?? 0} ${appText.courses}',
                                      style: style12Regular().copyWith(
                                        color: greyA5,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 13,
                                color: Color(0xFF98A2B3),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppLanguageProvider>(
        builder: (context, appLanguageProvider, _) {
      return directionality(child:
          Consumer<DrawerProvider>(builder: (context, drawerProvider, _) {
        return ClipRRect(
          borderRadius:
              borderRadius(radius: drawerProvider.isOpenDrawer ? 20 : 0),
          child: Scaffold(
            backgroundColor: greyFA,
            appBar: appbar(
                title: appText.categories,
                leftIcon: AppAssets.menuSvg,
                onTapLeftIcon: () {
                  drawerController.showDrawer();
                }),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  space(15),
                  Padding(
                    padding: padding(),
                    child: Text(
                      appText.trending,
                      style: style16Regular(),
                    ),
                  ),
                  space(14),
                  // trend categories
                  SizedBox(
                    width: getSize().width,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: padding(),
                      child: Row(
                        children: List.generate(
                            isLoading ? 3 : trendCategories.length, (index) {
                          return isLoading
                              ? horizontalCategoryItemShimmer()
                              : horizontalCategoryItem(
                                  trendCategories[index].color ?? green77(),
                                  trendCategories[index].icon ?? '',
                                  trendCategories[index].title ?? '',
                                  trendCategories[index]
                                          .webinarsCount
                                          ?.toString() ??
                                      '0', () {
                                  nextRoute(FilterCategoryPage.pageName,
                                      arguments: trendCategories[index]);
                                });
                        }),
                      ),
                    ),
                  ),
                  space(30),
                  Padding(
                    padding: padding(),
                    child: Text(
                      appText.browseCategories,
                      style: style16Regular().copyWith(color: grey3A),
                    ),
                  ),
                  space(14),
                  // categories
                  if (isLoading)
                    Container(
                      width: getSize().width,
                      margin: padding(),
                      child: Column(
                        children: List.generate(
                          3,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: categoryItemShimmer(),
                          ),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: List.generate(
                        categories.length,
                        (index) => _categoryCard(
                          categories[index],
                          index,
                        ),
                      ),
                    ),
                  space(120),
                ],
              ),
            ),
          ),
        );
      }));
    });
  }
}

class DashedLineVerticalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 6, dashSpace = 5, startY = 0;
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: .5)
      ..strokeWidth = .4;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
