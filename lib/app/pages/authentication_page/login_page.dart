import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:webinar/app/pages/authentication_page/forget_password_page.dart';
import 'package:webinar/app/pages/authentication_page/register_page.dart';
import 'package:webinar/app/pages/main_page/home_page/single_course_page/single_content_page/web_view_page.dart';
import 'package:webinar/app/pages/main_page/main_page.dart';
import 'package:webinar/app/providers/page_provider.dart';
import 'package:webinar/app/services/authentication_service/authentication_service.dart';
import 'package:webinar/app/widgets/authentication_widget/auth_widget.dart';
import 'package:webinar/app/widgets/authentication_widget/register_widget/register_widget.dart';
import 'package:webinar/app/widgets/main_widget/main_widget.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/common/data/api_public_data.dart';
import 'package:webinar/common/enums/page_name_enum.dart';
import 'package:webinar/common/utils/constants.dart';
import 'package:webinar/locator.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../common/utils/app_text.dart';
import '../../../config/assets.dart';
import '../../../config/colors.dart';
import '../../../config/styles.dart';
import '../../widgets/authentication_widget/country_code_widget/code_country.dart';

class LoginPage extends StatefulWidget {
  static const String pageName = '/login';

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController mailController = TextEditingController();
  FocusNode mailNode = FocusNode();

  // TextEditingController phoneController = TextEditingController();
  // FocusNode phoneNode = FocusNode();

  TextEditingController passwordController = TextEditingController();
  FocusNode passwordNode = FocusNode();

  String? otherRegisterMethod;
  bool isEmptyInputs = true;
  bool isPhoneNumber = true;
  bool isSendingData = false;

  CountryCode countryCode = CountryCode(code: "IN", dialCode: "+91", flagUri: "${AppAssets.flags}in.png", name: "India");

  late final GoogleSignIn _googleSignIn;

  @override
  void initState() {
    super.initState();
    _googleSignIn = GoogleSignIn.instance;
    _googleSignIn.initialize(
      serverClientId: "237411900385-2uqshnf61llh122to3uua07g5tab1uda.apps.googleusercontent.com",
    );
    if ((PublicData.apiConfigData?['register_method'] ?? '') == 'email') {
      isPhoneNumber = false;
      otherRegisterMethod = 'email';
    } else {
      isPhoneNumber = true;
      otherRegisterMethod = 'phone';
    }

    mailController.addListener(() {
      if ((mailController.text.trim().isNotEmpty) && passwordController.text.trim().isNotEmpty) {
        if (isEmptyInputs) {
          isEmptyInputs = false;
          setState(() {});
        }
      } else {
        if (!isEmptyInputs) {
          isEmptyInputs = true;
          setState(() {});
        }
      }
    });

    passwordController.addListener(() {
      if ((mailController.text.trim().isNotEmpty) && passwordController.text.trim().isNotEmpty) {
        if (isEmptyInputs) {
          isEmptyInputs = false;
          setState(() {});
        }
      } else {
        if (!isEmptyInputs) {
          isEmptyInputs = true;
          setState(() {});
        }
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (re) {
        MainWidget.showExitDialog();
      },
      child: directionality(
          child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
                child: Image.asset(
              AppAssets.introBgPng,
              width: getSize().width,
              height: getSize().height,
              fit: BoxFit.cover,
            )),
            Positioned.fill(
                child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: padding(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  space(getSize().height * .11),

                  // title
                  Row(
                    children: [
                      Text(
                        appText.welcomeBack,
                        style: style24Bold(),
                      ),
                      space(0, width: 4),
                      SvgPicture.asset(AppAssets.emoji2Svg)
                    ],
                  ),

                  // desc
                  Text(
                    appText.welcomeBackDesc,
                    style: style14Regular().copyWith(color: greyA5),
                  ),

                  space(50),

                  // google and facebook auth
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (PublicData.apiConfigData?['show_google_login_button'] ?? false) ...{
                        socialWidget(AppAssets.googleSvg, () async {
                          try {
                            try {
                              await _googleSignIn.signOut();
                            } catch (_) {}

                            // 1. Authenticate with scope hint
                            final GoogleSignInAccount user = await _googleSignIn.authenticate(
                              scopeHint: ['email', 'https://www.googleapis.com/auth/userinfo.profile'],
                            );
                            // 2. Authorize
                            // final GoogleSignInClientAuthorization? authorization = await user.authorizationClient.authorizeScopes([
                            //   'email',
                            //   'https://www.googleapis.com/auth/userinfo.profile',
                            // ]);
                            //
                            // if (authorization == null) {
                            //   debugPrint("Google authorization cancelled by user.");
                            //   return;
                            // }

                            setState(() => isSendingData = true);

                            try {
                              final bool res = await AuthenticationService.google(
                                user.email,
                                // authorization.accessToken,
                                user.authentication.idToken ?? "",
                                user.displayName ?? '',
                              );
                              debugPrint("api response from server =================> $res");
                              if (res) {
                                try {
                                  await FirebaseMessaging.instance.deleteToken();
                                } catch (e) {
                                  debugPrint("firebase delete token error ===============> $e");
                                }

                                nextRoute(MainPage.pageName, isClearBackRoutes: true);
                              }
                            } catch (e, stackTrace) {
                              debugPrint("API Error: $e");
                              debugPrintStack(stackTrace: stackTrace);
                            } finally {
                              if (mounted) {
                                setState(() => isSendingData = false);
                              }
                            }
                          } on GoogleSignInException catch (e) {
                            debugPrint("Google Sign-In Error");
                            debugPrint("Code: ${e.code}");
                            debugPrint("Description: ${e.description}");
                          } catch (e, stackTrace) {
                            debugPrint("Unexpected Error: $e");
                            debugPrintStack(stackTrace: stackTrace);
                          }
                        }),
                        space(0, width: 20),
                      },
                      if (PublicData.apiConfigData?['show_facebook_login_button'] ?? false) ...{
                        socialWidget(AppAssets.facebookSvg, () async {
                          // try{
                          final LoginResult result = await FacebookAuth.instance.login(permissions: ['email']);

                          if (result.status == LoginStatus.success) {
                            final AccessToken accessToken = result.accessToken!;

                            setState(() {
                              isSendingData = true;
                            });

                            FacebookAuth.instance.getUserData().then((value) async {
                              String email = value['email'];
                              String name = value['name'] ?? '';

                              try {
                                bool res = await AuthenticationService.facebook(email, accessToken.tokenString, name);

                                if (res) {
                                  try {
                                    await FirebaseMessaging.instance.deleteToken();
                                  } catch (e) {
                                    debugPrint("firebase delete token error ===============> $e");
                                  }
                                  nextRoute(MainPage.pageName, isClearBackRoutes: true);
                                }
                              } catch (_) {}

                              setState(() {
                                isSendingData = false;
                              });
                            });
                          } else {}
                          // }catch(e){}
                        }),
                      },
                      if (Platform.isIOS)
                        if (PublicData.apiConfigData?['show_apple_login_button'] ?? false) ...{
                          space(0, width: 20),
                          socialWidget(AppAssets.appleSvg, () async {
                            try {
                              debugPrint("user  clicked  =================> ");
                              UserCredential? credential = await signInWithApple();

                              if (credential != null && credential.user != null) {
                                setState(() {
                                  isSendingData = true;
                                });
                                try {
                                  bool res = await AuthenticationService.apple(credential.user?.email ?? "", credential.user?.uid ?? "", credential.user?.displayName ?? '');
                                  if (res) {
                                    fireAuthInstance.signOut();
                                    logoutFromApple();

                                    try {
                                      await FirebaseMessaging.instance.deleteToken();
                                    } catch (e) {
                                      debugPrint("firebase delete token error ===============> $e");
                                    }
                                    nextRoute(MainPage.pageName, isClearBackRoutes: true);
                                  }
                                } catch (e) {
                                  debugPrint("api error to send data to server ===========> ${e.toString()}");
                                }
                                setState(() {
                                  isSendingData = false;
                                });
                              } else {
                                debugPrint("user not found and login failed");
                              }
                            } catch (error) {
                              debugPrint("error in apple signin ===========> ${error.toString()}");
                            }
                          }),
                        }
                    ],
                  ),

                  space(25),

                  // Other Register Method
                  if (PublicData.apiConfigData?['showOtherRegisterMethod'] == '1') ...{
                    space(15),
                    Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: borderRadius()),
                        width: getSize().width,
                        height: 52,
                        child: Row(
                          children: [
                            // email
                            AuthWidget.accountTypeWidget(appText.email, otherRegisterMethod ?? '', 'email', () {
                              setState(() {
                                otherRegisterMethod = 'email';
                                isPhoneNumber = false;
                                mailController.clear();
                              });
                            }),

                            // email
                            AuthWidget.accountTypeWidget(appText.phone, otherRegisterMethod ?? '', 'phone', () {
                              setState(() {
                                otherRegisterMethod = 'phone';
                                isPhoneNumber = true;
                                mailController.clear();
                              });
                            }),
                          ],
                        )),
                    space(15),
                  },

                  // input
                  Column(
                    children: [
                      if (isPhoneNumber) ...{
                        // phone input
                        Row(
                          children: [
                            // country code
                            GestureDetector(
                              onTap: () async {
                                CountryCode? newData = await RegisterWidget.showCountryDialog();

                                if (newData != null) {
                                  countryCode = newData;
                                  setState(() {});
                                }
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(color: Colors.white, borderRadius: borderRadius()),
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

                            Expanded(child: input(mailController, mailNode, appText.phoneNumber))
                          ],
                        )
                      } else ...{
                        input(mailController, mailNode, appText.email, iconPathLeft: AppAssets.mailSvg, leftIconSize: 14),
                      },
                      space(16),
                      input(passwordController, passwordNode, appText.password, iconPathLeft: AppAssets.passwordSvg, leftIconSize: 14, isPassword: true),
                    ],
                  ),

                  space(32),

                  // button
                  Center(
                    child: button(
                        onTap: () async {
                          FocusScope.of(context).unfocus();

                          if (mailController.text.trim().isNotEmpty && passwordController.text.trim().isNotEmpty) {
                            setState(() {
                              isSendingData = true;
                            });

                            bool res = await AuthenticationService.login('${isPhoneNumber ? countryCode.dialCode!.replaceAll('+', '') : ''}${mailController.text.trim()}', passwordController.text.trim());

                            setState(() {
                              isSendingData = false;
                            });

                            if (res) {
                              try {
                                if (defaultTargetPlatform == TargetPlatform.iOS) {
                                  String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
                                  if (apnsToken != null) {
                                    await FirebaseMessaging.instance.deleteToken();
                                  }
                                } else {
                                  await FirebaseMessaging.instance.deleteToken();
                                }
                              } catch (e) {
                                debugPrint("FirebaseMessaging deleteToken error: $e");
                              }

                              locator<PageProvider>().setPage(PageNames.home);
                              nextRoute(MainPage.pageName, isClearBackRoutes: true);
                            }
                          }
                        },
                        width: getSize().width,
                        height: 52,
                        text: appText.login,
                        bgColor: isEmptyInputs ? greyCF : green77(),
                        textColor: Colors.white,
                        borderColor: Colors.transparent,
                        isLoading: isSendingData),
                  ),

                  space(16),

                  // termsPoliciesDesc
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        nextRoute(WebViewPage.pageName, arguments: ['${Constants.dommain}/pages/app-terms', appText.webinar, false, LoadRequestMethod.get]);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        appText.termsPoliciesDesc,
                        style: style14Regular().copyWith(color: greyA5),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  space(80),

                  // haveAnAccount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        appText.dontHaveAnAccount,
                        style: style16Regular(),
                      ),
                      space(0, width: 2),
                      GestureDetector(
                        onTap: () {
                          nextRoute(RegisterPage.pageName, isClearBackRoutes: true);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Text(
                          appText.signup,
                          style: style16Regular(),
                        ),
                      )
                    ],
                  ),

                  space(25),

                  Center(
                    child: GestureDetector(
                      onTap: () {
                        nextRoute(ForgetPasswordPage.pageName);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        appText.forgetPassword,
                        style: style16Regular().copyWith(color: greyB2),
                      ),
                    ),
                  ),

                  space(25),
                ],
              ),
            ))
          ],
        ),
      )),
    );
  }

  socialWidget(String icon, Function onTap) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        width: 98,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius(radius: 16),
        ),
        child: SvgPicture.asset(
          icon,
          width: 30,
        ),
      ),
    );
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  AuthorizationCredentialAppleID? appleCredential;
  OAuthCredential? oauthCredential;
  var fireAuthInstance = FirebaseAuth.instance;

  Future<UserCredential?> signInWithApple() async {
    // final rawNonce = generateNonce();
    // final nonce = sha256ofString(rawNonce);
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        // nonce: nonce,
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
        // rawNonce: rawNonce,
      );

      debugPrint("appleCredential code ==========> ${appleCredential.authorizationCode}");
      debugPrint("appleCredential email ==========> ${appleCredential.email}");
      debugPrint("appleCredential family name ==========> ${appleCredential.familyName}");

      debugPrint("appleCredential given name ==========> ${appleCredential.givenName}");

      // return await FirebaseAuth.instance.signInWithCredential(appleCredential);
      return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
    } catch (e) {
      debugPrint("Error during sign in with apple =======> $e");
      return null;
    }
    // try {
    //   final authProvider = AppleAuthProvider();
    //
    //   return await FirebaseAuth.instance.signInWithProvider(authProvider);
    // } catch(e) {
    //   debugPrint("Error during sign in with apple =======> $e");
    //   return null;
    // }
  }

  Future<void> logoutFromApple() async {
    try {
      appleCredential = null;
      oauthCredential = null;
      print("Apple Sign-In revoked successfully");
    } catch (e) {
      print("Error revoking Apple Sign-In: $e");
    }
  }
}
