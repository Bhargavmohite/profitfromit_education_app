// ignore_for_file: unused_local_variable, unused_import

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:webinar/app/pages/authentication_page/reset_password_page.dart';
import 'package:webinar/app/pages/main_page/main_page.dart';
import 'package:webinar/app/services/authentication_service/authentication_service.dart';
import 'package:webinar/app/widgets/authentication_widget/auth_widget.dart';
import 'package:webinar/app/widgets/authentication_widget/auth_design.dart';
import 'package:webinar/app/widgets/authentication_widget/country_code_widget/code_country.dart';
import 'package:webinar/app/widgets/authentication_widget/register_widget/register_widget.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/data/api_public_data.dart';

import '../../../common/utils/app_text.dart';
import '../../../config/assets.dart';
import '../../../config/colors.dart';
import '../../../config/styles.dart';

class ForgetPasswordPage extends StatefulWidget {
  static const String pageName = '/forget-password';
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  TextEditingController mailController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  FocusNode mailNode = FocusNode();
  FocusNode otpNode = FocusNode();

  bool isEmptyInputs = true;
  bool isSendingData = false;

  String? otherRegisterMethod;
  bool isPhoneNumber = true;
  bool showOTP = false;
  String? _otpRecipient;
  CountryCode countryCode = CountryCode(
      code: "IN",
      dialCode: "+91",
      flagUri: "${AppAssets.flags}in.png",
      name: "India");

  @override
  void initState() {
    super.initState();

    isPhoneNumber = false;
    otherRegisterMethod = 'email';

    mailController.addListener(() {
      if (!mounted) return;
      setState(() {
        isEmptyInputs = mailController.text.trim().isEmpty;
        showOTP = false;
        _otpRecipient = null;
        otpController.clear();
      });
    });
  }

  @override
  void dispose() {
    mailController.dispose();
    otpController.dispose();
    mailNode.dispose();
    otpNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return directionality(
      child: AuthPageFrame(
        eyebrow: 'Account assistance',
        title: appText.forgetPassword,
        subtitle: appText.forgetPasswordDesc,
        icon: Icons.key_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const AuthFormHeading('Recover your account',
                description:
                    'We will send a verification code to your registered contact.'),

            // Other Register Method
            ...[
              space(15),
              Container(
                  decoration: BoxDecoration(
                      color: Colors.white, borderRadius: borderRadius()),
                  width: getSize().width,
                  height: 52,
                  child: Row(
                    children: [
                      // email
                      AuthWidget.accountTypeWidget(
                          appText.email, otherRegisterMethod ?? '', 'email',
                          () {
                        setState(() {
                          showOTP = false;
                          otherRegisterMethod = 'email';
                          isPhoneNumber = false;
                          mailController.clear();
                        });
                      }),

                      // email
                      AuthWidget.accountTypeWidget(
                          appText.phone, otherRegisterMethod ?? '', 'phone',
                          () {
                        setState(() {
                          showOTP = false;
                          otherRegisterMethod = 'phone';
                          isPhoneNumber = true;
                          mailController.clear();
                        });
                      }),
                    ],
                  )),
              space(15),
            ],

            AuthFieldHeading(isPhoneNumber
                ? 'Registered mobile number'
                : 'Registered email address'),
            // input
            // if(!showOTP)
            Column(
              children: [
                if (isPhoneNumber) ...{
                  // phone input
                  Row(
                    children: [
                      // country code
                      GestureDetector(
                        onTap: () async {
                          CountryCode? newData =
                              await RegisterWidget.showCountryDialog();

                          if (newData != null) {
                            setState(() {
                              countryCode = newData;
                              showOTP = false;
                              _otpRecipient = null;
                              otpController.clear();
                            });
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: borderRadius()),
                          alignment: Alignment.center,
                          child: ClipRRect(
                            borderRadius: borderRadius(radius: 50),
                            child: Image.asset(
                              countryCode.flagUri ?? '',
                              width: 21,
                              height: 19,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      space(0, width: 15),

                      Expanded(
                          child: input(
                              mailController, mailNode, appText.phoneNumber,
                              isBorder: true,
                              radius: 13,
                              fillColor: AuthDesign.field))
                    ],
                  )
                } else ...{
                  input(
                    mailController,
                    mailNode,
                    appText.email,
                    iconPathLeft: AppAssets.mailSvg,
                    leftIconSize: 14,
                    isBorder: true,
                    radius: 13,
                    fillColor: AuthDesign.field,
                    onChange: (p0) {
                      setState(() {
                        showOTP = false;
                      });
                    },
                  ),
                },
                space(16),
              ],
            ),

            space(16),
            if (!showOTP)
              Center(
                child: button(
                    onTap: () async {
                      if (!isEmptyInputs) {
                        setState(() {
                          isSendingData = true;
                        });

                        final recipient =
                            '${isPhoneNumber ? countryCode.dialCode!.replaceAll('+', '') : ''}${mailController.text.trim()}';
                        final res = await AuthenticationService.forgetPassword(
                            recipient);
                        if (!mounted) return;
                        setState(() {
                          isSendingData = false;
                          if (res) {
                            _otpRecipient = recipient;
                            otpController.clear();
                            showOTP = true;
                          }
                        });
                      }
                    },
                    width: getSize().width,
                    height: 54,
                    raduis: 14,
                    text: appText.verifyMyAccount,
                    bgColor: isEmptyInputs
                        ? const Color(0xFFADBBD0)
                        : AuthDesign.blue,
                    textColor: Colors.white,
                    borderColor: Colors.transparent,
                    isLoading: isSendingData),
              ),

            if (showOTP)
              Center(
                child: Column(
                  children: [
                    const AuthFieldHeading('Verification code'),
                    input(otpController, otpNode, appText.otp,
                        leftIconSize: 14,
                        isNumber: true,
                        isBorder: true,
                        radius: 13,
                        fillColor: AuthDesign.field),
                    space(16),
                    RichText(
                      text: TextSpan(
                        style:
                            const TextStyle(color: Colors.black, fontSize: 18),
                        children: [
                          TextSpan(
                            text: appText.haventReceiveTheCode,
                            style: style14Regular().copyWith(color: greyB2),
                          ),
                          TextSpan(
                            text: " Re-Send",
                            style: style14Regular().copyWith(color: blueFE),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                final recipient = _otpRecipient;
                                if (recipient == null) return;
                                await AuthenticationService.forgetPassword(
                                    recipient);
                              },
                          ),
                        ],
                      ),
                    ),
                    space(16),
                    button(
                        onTap: () async {
                          if (!isEmptyInputs) {
                            setState(() {
                              isSendingData = true;
                            });

                            final recipient = _otpRecipient;
                            final resetToken = recipient == null
                                ? null
                                : await AuthenticationService
                                    .forgetPasswordVerifyOTP(
                                        recipient, otpController.text.trim());
                            if (!mounted) return;
                            setState(() => isSendingData = false);
                            if (resetToken != null && recipient != null) {
                              nextRoute(ResetPasswordPage.pageName,
                                  isClearBackRoutes: false,
                                  arguments: {
                                    'email': recipient,
                                    'reset_token': resetToken,
                                  });
                            }
                          }
                        },
                        width: getSize().width,
                        height: 54,
                        raduis: 14,
                        text: appText.verifyOTP,
                        bgColor: isEmptyInputs
                            ? const Color(0xFFADBBD0)
                            : AuthDesign.blue,
                        textColor: Colors.white,
                        borderColor: Colors.transparent,
                        isLoading: isSendingData),
                  ],
                ),
              ),

            space(26),
            // haveAnAccount
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  appText.haveAnAccount,
                  style: style16Regular(),
                ),
                space(0, width: 2),
                GestureDetector(
                  onTap: () {
                    backRoute();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    appText.login,
                    style: style16Bold().copyWith(color: AuthDesign.blue),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
