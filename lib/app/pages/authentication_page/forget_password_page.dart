// ignore_for_file: unused_local_variable, unused_import

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:webinar/app/pages/authentication_page/reset_password_page.dart';
import 'package:webinar/app/pages/main_page/main_page.dart';
import 'package:webinar/app/services/authentication_service/authentication_service.dart';
import 'package:webinar/app/widgets/authentication_widget/auth_widget.dart';
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
  bool isPhoneNumber=true;
  bool showOTP = false;
  CountryCode countryCode = CountryCode(
      code: "IN",
      dialCode: "+91",
      flagUri: "${AppAssets.flags}in.png",
      name: "India");

  @override
  void initState() {
    super.initState();

    if((PublicData.apiConfigData?['register_method'] ?? '') == 'email'){
      isPhoneNumber = false;
      otherRegisterMethod = 'email';
    }else{
      isPhoneNumber = true;
      otherRegisterMethod = 'phone';
    }

    
    mailController.addListener(() {
      if(mailController.text.trim().isNotEmpty){
        if(isEmptyInputs){
          setState(() {
            isEmptyInputs = false;
          });
        }
      }else{
        setState(() {
          showOTP = false;
        });
        if(!isEmptyInputs){
          setState(() {
            isEmptyInputs = true;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return directionality(
      child: Scaffold(
        body: Stack(
          children: [

            Positioned.fill(
              child: Image.asset(
                AppAssets.introBgPng,
                width: getSize().width,
                height: getSize().height,
                fit: BoxFit.cover,
              )
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
                          appText.forgetPassword,
                          style: style24Bold(),
                        ),

                        space(0,width: 4),

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

                    // Other Register Method
                    if(PublicData.apiConfigData?['showOtherRegisterMethod'] == '1')...{
                      space(15),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: borderRadius()
                        ),

                        width: getSize().width,
                        height:  52,

                        child: Row(
                          children: [

                            // email
                            AuthWidget.accountTypeWidget(appText.email, otherRegisterMethod ?? '', 'email', (){
                              setState(() {
                                showOTP = false;
                                otherRegisterMethod = 'email';
                                isPhoneNumber = false;
                                mailController.clear();
                              });
                            }),

                            // email
                            AuthWidget.accountTypeWidget(appText.phone, otherRegisterMethod ?? '', 'phone', (){
                              setState(() {
                                showOTP = false;
                                otherRegisterMethod = 'phone';
                                isPhoneNumber = true;
                                mailController.clear();
                              });
                            }),

                          ],
                        )
                      ),

                      space(15),

                    },

                    // input
                    // if(!showOTP)
                    Column(
                      children: [

                        if(isPhoneNumber)...{
                          // phone input
                          Row(
                            children: [

                              // country code
                              GestureDetector(
                                onTap: () async {
                                  CountryCode? newData = await RegisterWidget.showCountryDialog();

                                  if(newData != null){
                                    countryCode = newData;
                                    setState(() {});
                                  }
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: borderRadius()
                                  ),
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

                              space(0,width: 15),

                              Expanded(child: input(mailController, mailNode, appText.phoneNumber))
                            ],
                          )
                        }else ...{
                          input(mailController, mailNode, appText.email, iconPathLeft: AppAssets.mailSvg,leftIconSize: 14, onChange: (p0) {
                            setState(() {
                              showOTP = false;
                            });
                          },),
                        },

                        space(16),

                      ],
                    ),

                    space(16),
                    if(!showOTP)
                    Center(
                      child: button(
                        onTap: () async {

                          if(!isEmptyInputs){
                            setState(() {
                              isSendingData = true;
                            });

                            bool res = await AuthenticationService.forgetPassword(
                              '${isPhoneNumber ? countryCode.dialCode!.replaceAll('+', '') : ''}${mailController.text.trim()}',
                            );

                            if(res){
                              setState(() {
                                showOTP = true;
                              });
                            }

                            setState(() {
                              isSendingData = false;
                            });
                          }
                        },
                        width: getSize().width,
                        height: 52,
                        text: appText.verifyMyAccount,
                        bgColor: isEmptyInputs ? greyCF : green77(),
                        textColor: Colors.white,
                        borderColor: Colors.transparent,
                        isLoading: isSendingData
                      ),
                    ),

                    if(showOTP)
                    Center(
                      child: Column(
                        children: [

                          input(otpController, otpNode, appText.otp, leftIconSize: 14, isNumber: true),
                          space(16),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(color: Colors.black, fontSize: 18),
                              children: [
                                TextSpan(text: appText.haventReceiveTheCode,
                                  style: style14Regular().copyWith(color: greyB2),
                                ),

                                TextSpan(
                                  text: " Re-Send",
                                  style: style14Regular().copyWith(color: blueFE),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      bool res = await AuthenticationService.forgetPassword(
                                        '${isPhoneNumber ? countryCode.dialCode!.replaceAll('+', '') : ''}${mailController.text.trim()}',
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),

                          space(16),
                          button(
                              onTap: () async {

                                if(!isEmptyInputs){
                                  setState(() {
                                    isSendingData = true;
                                  });

                                  bool res = await AuthenticationService.forgetPasswordVerifyOTP(otpController.text.trim());

                                  if(res){
                                    setState(() {
                                      showOTP = false;
                                    });
                                    nextRoute(ResetPasswordPage.pageName, isClearBackRoutes: false, arguments: {
                                      'email': '${isPhoneNumber ? countryCode.dialCode!.replaceAll('+', '') : ''}${mailController.text.trim()}',

                                    });
                                  }

                                  setState(() {
                                    isSendingData = false;
                                  });
                                }
                              },
                              width: getSize().width,
                              height: 52,
                              text: appText.verifyOTP,
                              bgColor: isEmptyInputs ? greyCF : green77(),
                              textColor: Colors.white,
                              borderColor: Colors.transparent,
                              isLoading: isSendingData
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 3,),

                    // haveAnAccount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          appText.haveAnAccount,
                          style: style16Regular(),
                        ),

                        space(0,width: 2),

                        GestureDetector(
                          onTap: (){
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
              )
            )

          ],
        ),
      )
    );

  }
}