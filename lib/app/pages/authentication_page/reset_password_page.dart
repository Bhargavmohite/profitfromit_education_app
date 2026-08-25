import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:webinar/app/pages/authentication_page/login_page.dart';
import 'package:webinar/app/services/authentication_service/authentication_service.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/config/assets.dart';
import 'package:webinar/config/colors.dart';
import 'package:webinar/config/styles.dart';

class ResetPasswordPage extends StatefulWidget {
  static const String pageName = '/reset-password';

  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController resetPasswordController = TextEditingController();
  FocusNode passwordNode = FocusNode();
  FocusNode resetPasswordNode = FocusNode();

  bool isEmptyInputs = true;
  bool isSendingData = false;
  String email = "";
  String password = "";
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late Map data;

  @override
  void initState() {
    super.initState();

    passwordController.addListener(() {
      if (passwordController.text.trim().isNotEmpty && resetPasswordController.text.trim().isNotEmpty) {
        if (passwordController.text.trim() == resetPasswordController.text.trim()) {
          password = passwordController.text.trim();
          if (isEmptyInputs) {
            setState(() {
              isEmptyInputs = false;
            });
          }
        } else {
          if (!isEmptyInputs) {
            setState(() {
              isEmptyInputs = true;
            });
          }
        }
      } else {
        if (!isEmptyInputs) {
          setState(() {
            isEmptyInputs = true;
          });
        }
      }
    });

    resetPasswordController.addListener(() {
      if (passwordController.text.trim().isNotEmpty && resetPasswordController.text.trim().isNotEmpty) {
        if (passwordController.text.trim() == resetPasswordController.text.trim()) {
          password = passwordController.text.trim();
          if (isEmptyInputs) {
            setState(() {
              isEmptyInputs = false;
            });
          }
        } else {
          if (!isEmptyInputs) {
            setState(() {
              isEmptyInputs = true;
            });
          }
        }
      } else {
        if (!isEmptyInputs) {
          setState(() {
            isEmptyInputs = true;
          });
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        data = ModalRoute.of(context)!.settings.arguments as Map;
        email = data['email'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AppAssets.introBgPng,
              width: getSize().width,
              height: getSize().height,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: padding(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  space(getSize().height * .11),
                  // title
                  Row(
                    children: [
                      Text(
                        appText.resetPassword,
                        style: style24Bold(),
                      ),
                      space(0, width: 4),
                      SvgPicture.asset(AppAssets.emoji2Svg)
                    ],
                  ),
                  // desc
                  Text(
                    appText.forgetPasswordDesc,
                    style: style14Regular().copyWith(color: greyA5),
                  ),
                  const Spacer(flex: 2),
                  space(25),
                  // input
                  Column(
                    children: [
                      inputResetPassword(
                        passwordController,
                        passwordNode,
                        appText.password,
                        iconPathLeft: AppAssets.passwordSvg,
                        leftIconSize: 14,
                        isPasswordField: true,
                        obscureText: _obscurePassword,
                        onTogglePassword: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      space(16),
                      inputResetPassword(
                        resetPasswordController,
                        resetPasswordNode,
                        appText.retypePassword,
                        iconPathLeft: AppAssets.passwordSvg,
                        leftIconSize: 14,
                        isPasswordField: true,
                        obscureText: _obscureConfirmPassword,
                        onTogglePassword: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ],
                  ),

                  space(16),
                  Center(
                    child: button(
                        onTap: () async {
                          if (!isEmptyInputs) {
                            setState(() {
                              isSendingData = true;
                            });
                            bool res = await AuthenticationService.resetPassword(email, password);
                            setState(() {
                              isSendingData = false;
                            });
                            if (res) {
                              nextRoute(LoginPage.pageName, isClearBackRoutes: true);
                            }
                          }
                        },
                        width: getSize().width,
                        height: 52,
                        text: appText.resetPassword,
                        bgColor: isEmptyInputs ? greyCF : green77(),
                        textColor: Colors.white,
                        borderColor: Colors.transparent,
                        isLoading: isSendingData),
                  ),

                  const Spacer(
                    flex: 3,
                  ),

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
                          style: style16Regular(),
                        ),
                      )
                    ],
                  ),
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
