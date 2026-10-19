import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:webinar/app/pages/main_page/home_page/notification_page.dart';
import 'package:webinar/app/pages/main_page/home_page/search_page/suggested_search_page.dart';
import 'package:webinar/app/providers/user_provider.dart';
import 'package:webinar/app/services/authentication_service/authentication_service.dart';
import 'package:webinar/common/components.dart';

import '../../../../common/common.dart';
import '../../../../common/utils/app_text.dart';
import '../../../../common/utils/object_instance.dart';
import '../../../../config/assets.dart';
import '../../../../config/colors.dart';
import '../../../../config/styles.dart';
import '../../../pages/main_page/home_page/cart_page/cart_page.dart';
import '../main_widget.dart';

class HomeWidget {
  /// Premium branded header that collapses with the existing scroll animation.
  /// The controls and search are placed in a Stack to avoid Flex overflows.
  static Widget homeAppBar(
    AnimationController appBarController,
    Animation appBarAnimation,
    String token,
    TextEditingController searchController,
    FocusNode searchNode,
    String name,
  ) {
    return AnimatedBuilder(
      animation: appBarAnimation,
      builder: (context, _) {
        return Consumer<UserProvider>(
          builder: (context, userProvider, _) {
            final topInset = MediaQuery.of(context).viewPadding.top;
            final double currentHeight = appBarAnimation.value.toDouble();
            final double expandedHeight = 150 + topInset;
            final progress =
                ((expandedHeight - currentHeight) / 70).clamp(0.0, 1.0);
            final double searchOpacity =
                (1.0 - progress * 3.0).clamp(0.0, 1.0).toDouble();
            const white = Colors.white;

            return Container(
              width: double.infinity,
              height: currentHeight,
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF082B86),
                    Color(0xFF0D3CCF),
                    Color(0xFF3C68F0)
                  ],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
              ),
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Positioned(
                    right: -68,
                    top: -74,
                    child: Container(
                      width: 210,
                      height: 210,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: white.withValues(alpha: 0.10),
                          width: 25,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -52,
                    bottom: -100,
                    child: Container(
                      width: 165,
                      height: 165,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    end: 0,
                    bottom: -22,
                    child: Opacity(
                      opacity: 0.25,
                      child: SvgPicture.asset(
                        AppAssets.appbarLineSvg,
                        width: MediaQuery.of(context).size.width,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    top: topInset + 14,
                    child: Row(
                      children: [
                        Semantics(
                          label: 'Open menu',
                          button: true,
                          child: Material(
                            color: white.withValues(alpha: 0.13),
                            borderRadius: BorderRadius.circular(13),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(13),
                              onTap: () => drawerController.showDrawer(),
                              child: SizedBox(
                                width: 40,
                                height: 40,
                                child: Center(
                                  child: SvgPicture.asset(
                                    AppAssets.menuSvg,
                                    colorFilter: const ColorFilter.mode(
                                      white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                token.isEmpty
                                    ? appText.webinar
                                    : '${appText.hi} $name',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: style18HeaderBold(),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                appText.letsStartLearning,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: style12Regular().copyWith(
                                  color: white.withValues(alpha: 0.78),
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        MainWidget.menuButton(
                          AppAssets.basketSvg,
                          userProvider.cartData?.items?.isNotEmpty ?? false,
                          white,
                          white.withValues(alpha: 0.13),
                          () => nextRoute(CartPage.pageName),
                        ),
                        const SizedBox(width: 8),
                        MainWidget.menuButton(
                          AppAssets.notificationSvg,
                          userProvider.notification
                              .where((item) => item.status == 'unread')
                              .isNotEmpty,
                          white,
                          white.withValues(alpha: 0.13),
                          () => nextRoute(NotificationPage.pageName),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 15,
                    child: IgnorePointer(
                      ignoring: progress > 0.12,
                      child: Opacity(
                        opacity: searchOpacity,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF061A52)
                                    .withValues(alpha: 0.14),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: input(
                            searchController,
                            searchNode,
                            appText.searchInputDesc,
                            height: 50,
                            radius: 15,
                            iconPathLeft: AppAssets.searchSvg,
                            isReadOnly: true,
                            onTap: () => nextRoute(
                              SuggestedSearchPage.pageName,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static TextStyle style18HeaderBold() => style20Bold().copyWith(
        fontSize: 18,
        color: Colors.white,
        height: 1.1,
      );

  /// Shared heading for the course carousels and the financial-model rows.
  static Widget titleAndMore(
    String title, {
    String? subtitle,
    bool isViewAll = true,
    Function? onTapViewAll,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF0D3CCF),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: style20Bold().copyWith(
                    fontSize: 19,
                    color: const Color(0xFF122142),
                    height: 1.13,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: style12Regular().copyWith(
                      color: const Color(0xFF79869E),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isViewAll) ...[
            const SizedBox(width: 8),
            Material(
              color: const Color(0xFFE8EEFF),
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: onTapViewAll == null ? null : () => onTapViewAll(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 9,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        appText.viewAll,
                        style: style12Bold().copyWith(
                          color: const Color(0xFF0D3CCF),
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: Color(0xFF0D3CCF),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Future showFinalizeRegister(int userId) async {
    TextEditingController nameController = TextEditingController();
    FocusNode nameNode = FocusNode();

    TextEditingController referralController = TextEditingController();
    FocusNode referralNode = FocusNode();

    bool isLoading = false;

    return await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: navigatorKey.currentContext!,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  directionality(
                    child: Container(
                      margin: EdgeInsets.only(
                          bottom: MediaQuery.of(navigatorKey.currentContext!)
                              .viewInsets
                              .bottom),
                      width: getSize().width,
                      padding: padding(vertical: 21),
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(30))),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appText.finalizeYourAccount,
                            style: style16Bold(),
                          ),
                          space(16),
                          input(nameController, nameNode, appText.yourName,
                              iconPathLeft: AppAssets.profileSvg,
                              leftIconSize: 14,
                              isBorder: true),
                          space(16),
                          input(
                              referralController, referralNode, appText.refCode,
                              iconPathLeft: AppAssets.ticketSvg,
                              leftIconSize: 14,
                              isBorder: true),
                          space(24),
                          Center(
                            child: button(
                                onTap: () async {
                                  if (nameController.text.length > 3) {
                                    setState(() {
                                      isLoading = true;
                                    });

                                    bool res = await AuthenticationService
                                        .registerStep3(
                                            userId,
                                            nameController.text.trim(),
                                            referralController.text.trim());

                                    if (res) {
                                      backRoute(arguments: res);
                                    }

                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                },
                                width: getSize().width,
                                height: 52,
                                text: appText.continue_,
                                bgColor: green77(),
                                textColor: Colors.white,
                                isLoading: isLoading),
                          ),
                          space(24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
