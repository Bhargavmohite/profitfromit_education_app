// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webinar/app/models/cart_model.dart';
import 'package:webinar/app/models/course_model.dart';
import 'package:webinar/app/pages/main_page/home_page/cart_page/web_checkout_v2_page.dart';
import 'package:webinar/app/providers/user_provider.dart';
import 'package:webinar/app/services/user_service/cart_service.dart';
import 'package:webinar/app/widgets/main_widget/home_widget/cart_widget.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/common/data/app_data.dart';
import 'package:webinar/common/data/app_language.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/common/utils/constants.dart';
import 'package:webinar/common/utils/currency_utils.dart';
import 'package:webinar/config/assets.dart';
import 'package:webinar/config/colors.dart';
import 'package:webinar/config/styles.dart';
import 'package:webinar/locator.dart';

class CartPage extends StatefulWidget {
  static const String pageName = '/cart';

  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool isLoading = false;
  bool isLoadingWebCheckout = false;

  int? discountId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await getData();
    },);
  }

  Future<void> getData() async {
    setState(() {
      isLoading = true;
    });

    CartModel? cartModel = await CartService.getCart();

    setState(() {

      debugPrint("cart model ===========> $cartModel");

      locator<UserProvider>().setCartData(cartModel);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return directionality(
      child: Consumer<UserProvider>(builder: (context, userProvider, _) {
        return Scaffold(
          appBar: appbar(
            title: (userProvider.cartData?.items?.length ?? 0) > 0 ? '${appText.cart} (${userProvider.cartData?.items?.length})' : appText.cart,
          ),
          body: isLoading
              ? loading()
              : Stack(
                  children: [
                    // items
                    (userProvider.cartData?.items?.isEmpty ?? true)
                        ? Container(alignment: Alignment.center, margin: EdgeInsets.only(bottom: getSize().height * .2), child: emptyState(AppAssets.emptyCardSvg, appText.cartIsEmpty, appText.cartIsEmptyDesc))
                        : Positioned.fill(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                children: [
                                  space(5),

                                  ...List.generate(userProvider.cartData?.items?.length ?? 0, (index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: Container(
                                          decoration: BoxDecoration(color: red49, borderRadius: borderRadius()),
                                          margin: padding(),
                                          child: Slidable(
                                            key: ValueKey(index),
                                            startActionPane: ActionPane(
                                              motion: const ScrollMotion(),
                                              extentRatio: .3,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      isLoading = true;
                                                    });

                                                    CartService.deleteCourse(userProvider.cartData!.items![index].id!).then((value) async {
                                                      userProvider.cartData!.items!.removeAt(index);

                                                      await Future.delayed(const Duration(seconds: 1));

                                                      setState(() {
                                                        isLoading = false;
                                                      });

                                                      if (value) {
                                                        getData();
                                                      }
                                                    });
                                                  },
                                                  behavior: HitTestBehavior.opaque,
                                                  child: SizedBox(
                                                    width: 90,
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        SvgPicture.asset(AppAssets.deleteSvg),
                                                        space(4),
                                                        Text(
                                                          appText.remove,
                                                          style: style10Regular().copyWith(color: Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                            child: directionality(
                                              child: courseItemVerticallyCartPage(
                                                  CourseModel(
                                                    id: userProvider.cartData?.items?[index].id,
                                                    image: userProvider.cartData?.items?[index].image,
                                                    price: userProvider.cartData?.items?[index].price,
                                                    discountPercent: (userProvider.cartData?.items?[index].discount) != null ? ((((userProvider.cartData?.items?[index].price ?? 1) - (userProvider.cartData?.items?[index].discount ?? 1)) / 100) * 100).toInt() : 0,
                                                    rate: userProvider.cartData?.items?[index].rate,
                                                    title: userProvider.cartData?.items?[index].title,
                                                    reservedMeeting: userProvider.cartData?.items?[index].type == 'meeting'
                                                        ? '${userProvider.cartData?.items?[index].day ?? ''} ${userProvider.cartData?.items?[index].time?.start ?? ''}-${userProvider.cartData?.items?[index].time?.end ?? ''} ${userProvider.cartData?.items?[index].timezone ?? ''}'
                                                        : null,
                                                    reservedMeetingUserTimeZone: userProvider.cartData?.items?[index].type == 'meeting'
                                                        ? '${userProvider.cartData?.items?[index].day ?? ''} ${userProvider.cartData?.items?[index].timeUser?.start ?? ''}-${userProvider.cartData?.items?[index].timeUser?.end ?? ''} ${locator<UserProvider>().profile?.timezone ?? ''}'
                                                        : null,
                                                  ),
                                                  bottomMargin: 0,
                                                  ignoreTap: true,
                                                  height: userProvider.cartData?.items?[index].type == 'meeting' ? 110 : 83,
                                                  imageHeight: userProvider.cartData?.items?[index].type == 'meeting' ? 110 : 83,
                                                  onDelete: () {
                                                    setState(() {
                                                      isLoading = true;
                                                    });

                                                    CartService.deleteCourse(userProvider.cartData!.items![index].id!).then((value) async {
                                                      userProvider.cartData!.items!.removeAt(index);

                                                      await Future.delayed(const Duration(seconds: 1));

                                                      setState(() {
                                                        isLoading = false;
                                                      });

                                                      if (value) {
                                                        getData();
                                                      }
                                                    });
                                                  },
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),

                                  // space(20),

                                  if (userProvider.cartData?.userGroup != null) ...{
                                    helperBox(AppAssets.discountSvg, '${userProvider.cartData?.userGroup?.discount}% ${appText.userGroupDiscount}', '${userProvider.cartData?.userGroup?.name}'),
                                    space(16),
                                  },

                                  if (userProvider.cartData?.totalCashbackAmount != null) ...{
                                    helperBox(
                                        AppAssets.walletSvg,
                                        appText.getCashback,
                                        '${appText.finalizeYourOrderAndGet} '
                                        // '${CurrencyUtils.calculator(userProvider.cartData?.totalCashbackAmount ?? 0, fractionDigits: 1)} ${appText.cashback}'
                                        '${CurrencyUtils.calculator(userProvider.cartData?.totalCashbackAmount ?? 0)} ${appText.cashback}'),
                                    space(16),
                                  },

                                  space(300),
                                ],
                              ),
                            ),
                          ),

                    // amount
                    Positioned(
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: Container(
                        width: getSize().width,
                        padding: padding(vertical: 21),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(30)), boxShadow: [boxShadow(Colors.black.withValues(alpha: .1), y: -3, blur: 15)]),
                        child: Column(
                          children: [
                            // sub total
                            cartItem(appText.subtotal, CurrencyUtils.calculator(userProvider.cartData?.amounts?.subTotal ?? 0)),

                            // Discount
                            cartItem(appText.discount, CurrencyUtils.calculator(userProvider.cartData?.amounts?.totalDiscount ?? 0)),

                            // Tax
                            cartItem('${appText.tax} (${userProvider.cartData?.amounts?.tax ?? 0}%)', CurrencyUtils.calculator(userProvider.cartData?.amounts?.taxPrice ?? 0)),

                            // Total
                            cartItem(appText.total, CurrencyUtils.calculator(userProvider.cartData?.amounts?.total ?? 0)),

                            space(6),

                            if ((userProvider.cartData?.items?.isNotEmpty ?? false)) ...{
                              Row(
                                children: [
                                  Expanded(
                                      child: button(
                                          onTap: () async {
                                            setState(() {
                                              isLoadingWebCheckout = true;
                                            });

                                            String? link = await CartService.webCheckoutV2();
                                            setState(() {
                                              isLoadingWebCheckout = false;
                                            });
                                            nextRoute(WebCheckoutV2Page.pageName, arguments: link);


                                            // old code commented on 07-07-2025
                                            // String? link = await CartService.webCheckout();
                                            // String token = await AppData.getAccessToken();
                                            //
                                            // setState(() {
                                            //   isLoadingWebCheckout = false;
                                            // });
                                            //
                                            // Map<String, String> headers = {
                                            //   "Authorization": "Bearer $token",
                                            //   "Content-Type": "application/json",
                                            //   'Accept': 'application/json',
                                            //   'x-api-key': Constants.apiKey,
                                            //   'x-locale': locator<AppLanguage>().currentLanguage.toLowerCase(),
                                            // };
                                            //
                                            // await launchUrlString(link ?? '',
                                            //     mode: LaunchMode.externalApplication,
                                            //     webViewConfiguration: WebViewConfiguration(
                                            //       headers: headers,
                                            //     ));
                                          },
                                          width: getSize().width,
                                          height: 52,
                                          text: appText.checkout,
                                          bgColor: green77(),
                                          textColor: Colors.white,
                                          isLoading: isLoadingWebCheckout)),
                                  space(0, width: 20),
                                  Expanded(
                                      child: button(
                                          onTap: () async {
                                            var res = await CartWidget.showCouponSheet();

                                            if (res != null) {
                                              userProvider.cartData?.amounts = res['amount'];
                                              discountId = res['discount_id'];

                                              setState(() {});
                                            }
                                          },
                                          width: getSize().width,
                                          height: 52,
                                          text: appText.addCoupon,
                                          bgColor: Colors.white,
                                          textColor: green77(),
                                          borderColor: green77())),
                                ],
                              ),
                              space(8),
                            },
                          ],
                        ),
                      ),
                    )
                  ],
                ),
        );
      }),
    );
  }

  Widget cartItem(String title, String price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: style16Regular(),
          ),
          Text(
            price,
            style: style16Regular().copyWith(color: greyB2),
          ),
        ],
      ),
    );
  }
}
