import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import 'package:webinar/app/models/register_config_model.dart';
import 'package:webinar/app/pages/authentication_page/login_page.dart';
import 'package:webinar/app/pages/authentication_page/verify_code_page.dart';
import 'package:webinar/app/pages/main_page/home_page/single_course_page/single_content_page/web_view_page.dart';
import 'package:webinar/app/pages/main_page/main_page.dart';
import 'package:webinar/app/providers/page_provider.dart';
import 'package:webinar/app/services/authentication_service/authentication_service.dart';
import 'package:webinar/app/services/guest_service/guest_service.dart';
import 'package:webinar/app/widgets/authentication_widget/auth_design.dart';
import 'package:webinar/app/widgets/authentication_widget/country_code_widget/code_country.dart';
import 'package:webinar/app/widgets/authentication_widget/register_widget/register_widget.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/data/api_public_data.dart';
import 'package:webinar/common/enums/page_name_enum.dart';
import 'package:webinar/common/utils/constants.dart';
import 'package:webinar/locator.dart';
import 'package:webinar/config/assets.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Student-only sign-up. The API calls the student role 'user'.
/// Role selection is internal; the registration form does not expose it.
class RegisterPage extends StatefulWidget {
  static const String pageName = '/register';
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _showPassword = false;
  bool _showConfirmation = false;
  bool _sending = false;
  bool _signingInWithGoogle = false;

  // The backend's student role identifier is 'user', not 'student'.
  // Never expose an instructor/organization selector in this app.
  String get _studentRole => PublicData.userRole;
  late final Future<RegisterConfigModel?> _studentRegisterConfig;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  CountryCode _country = CountryCode(
    code: 'IN',
    dialCode: '+91',
    name: 'India',
  );

  @override
  void initState() {
    super.initState();
    // Use the same role-specific endpoint as the original app, always with
    // the student role. Keep the method returned by that endpoint intact.
    _studentRegisterConfig = GuestService.registerConfig(_studentRole)
        .timeout(const Duration(seconds: 15), onTimeout: () => null);
  }

  @override
  void dispose() {
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  /// Obtain the accepted registration method from the role-specific endpoint.
  /// Do not substitute a generic /config value or rewrite 'mobile' to 'phone':
  /// the backend validates the exact register_method field.
  Future<String?> _resolveRegisterMethod() async {
    final registerConfig = await _studentRegisterConfig;
    final method = registerConfig?.registerMethod?.trim();
    if (method == null || method.isEmpty) return null;
    if (!const {'email', 'phone', 'mobile'}.contains(method.toLowerCase())) {
      debugPrint('Unsupported student registration method from backend.');
      return null;
    }

    // Use the server's exact value in the request. Email is the only
    // email-delivery variant; the source app treats all other configured
    // methods as mobile registration.
    debugPrint('Registration method from role configuration: $method');
    return method;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_sending || !(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _sending = true);
    try {
      final method = await _resolveRegisterMethod();
      if (!mounted) return;
      if (method == null) {
        _message(
            'Student registration is unavailable in the server configuration. '
            'Please try again or contact support.');
        return;
      }

      final email = _email.text.trim();
      final phone = _phone.text.trim();
      final password = _password.text;
      final confirmation = _confirmation.text;

      // Both fields are displayed. The configured primary contact determines
      // where the server sends OTP. The API must support storing the second.
      final Map? result = method.toLowerCase() == 'email'
          ? await AuthenticationService.registerWithEmail(
              method,
              email,
              password,
              confirmation,
              _studentRole,
              null,
              mobile: phone,
              countryCode: _country.dialCode ?? '+91',
            )
          : await AuthenticationService.registerWithPhone(
              method,
              _country.dialCode ?? '+91',
              phone,
              password,
              confirmation,
              _studentRole,
              null,
              email: email,
            );

      if (!mounted) return;
      if (result == null) {
        _message(AuthenticationService.lastRegistrationError ??
            'Registration was not accepted. Please review your details.');
        return;
      }

      final step = result['step']?.toString() ?? '';
      final userId = result['user_id'];
      if (step == 'stored' || step == 'go_step_2') {
        if (userId == null || userId.toString().isEmpty) {
          _message('Account was created but the server did not return a '
              'verification session. Please contact support.');
          return;
        }
        // This route only opens once the registration API confirms the OTP
        // step and returns the ID required to verify the code.
        await nextRoute(VerifyCodePage.pageName, arguments: {
          'user_id': userId,
          'register_method': method,
          'email': email,
          'countryCode': _country.dialCode ?? '+91',
          'phone': phone,
          'password': password,
          'retypePassword': confirmation,
        });
      } else if (step == 'go_step_3') {
        // The backend skipped OTP, but profile completion (register/step/3)
        // is still required before the new student can use Login.
        if (userId == null || userId.toString().trim().isEmpty) {
          _message('The server did not return a registration session. '
              'Please contact support.');
          return;
        }
        await nextRoute(VerifyCodePage.pageName, arguments: {
          'user_id': userId,
          'otp_verified': true,
          'email': email,
        });
      } else {
        _message('Registration returned an unrecognized step: $step. '
            'Please contact support.');
      }
    } catch (error) {
      debugPrint('Registration flow failed: ${error.runtimeType}');
      _message('Unable to finish registration. Check your connection and '
          'try again.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_signingInWithGoogle || _sending) return;
    FocusScope.of(context).unfocus();
    setState(() => _signingInWithGoogle = true);
    try {
      // Use the same Google login and backend callback as LoginPage.
      // Backend account-role assignment remains server-controlled.
      try {
        await _googleSignIn.signOut();
      } catch (_) {
        // No previous Google session is not an error.
      }
      final account = await _googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        _message('Google authentication did not return a valid token.');
        return;
      }
      final signedIn = await AuthenticationService.google(
        account.email,
        idToken,
        account.displayName ?? '',
      );
      if (!mounted) return;
      if (!signedIn) {
        _message('Google sign-in could not be completed. Please try again.');
        return;
      }
      try {
        await FirebaseMessaging.instance.deleteToken();
      } catch (_) {
        // Push-token cleanup must not block a successful login.
      }
      if (!mounted) return;
      locator<PageProvider>().setPage(PageNames.home);
      await nextRoute(MainPage.pageName, isClearBackRoutes: true);
    } on GoogleSignInException catch (_) {
      _message('Google sign-in was cancelled or could not be completed.');
    } catch (error) {
      debugPrint('Google sign-in failed: ${error.runtimeType}');
      _message('Unable to sign in with Google. Please try again.');
    } finally {
      if (mounted) setState(() => _signingInWithGoogle = false);
    }
  }

  Future<void> _selectCountry() async {
    final CountryCode? selected = await RegisterWidget.showCountryDialog();
    if (selected != null && mounted) {
      setState(() => _country = selected);
    }
  }

  void _openTerms() {
    nextRoute(WebViewPage.pageName, arguments: [
      '${Constants.dommain}/pages/app-terms',
      'Terms & Policies',
      false,
      LoadRequestMethod.get,
    ]);
  }

  InputDecoration _decoration(String hint, IconData icon,
      {Widget? suffixIcon, Widget? prefix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF8D9AAD), fontSize: 14),
      prefixIcon: prefix ?? Icon(icon, color: AuthDesign.muted, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AuthDesign.field,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE1E9F3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE1E9F3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AuthDesign.blue, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD94C4C)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD94C4C), width: 1.6),
      ),
    );
  }

  Widget _label(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(label,
            style: const TextStyle(
              color: AuthDesign.ink,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            )),
      );

  Widget _passwordField({required bool confirm}) {
    final visible = confirm ? _showConfirmation : _showPassword;
    return TextFormField(
      controller: confirm ? _confirmation : _password,
      obscureText: !visible,
      obscuringCharacter: '•',
      enableSuggestions: false,
      autocorrect: false,
      textInputAction: confirm ? TextInputAction.done : TextInputAction.next,
      onFieldSubmitted: confirm ? (_) => _submit() : null,
      decoration: _decoration(
        confirm ? 'Re-enter your password' : 'Create a secure password',
        Icons.lock_outline_rounded,
        suffixIcon: IconButton(
          tooltip: visible ? 'Hide password' : 'Show password',
          onPressed: () => setState(() {
            if (confirm) {
              _showConfirmation = !_showConfirmation;
            } else {
              _showPassword = !_showPassword;
            }
          }),
          icon: Icon(
              visible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AuthDesign.muted,
              size: 21),
        ),
      ),
      validator: (value) {
        if ((value ?? '').isEmpty) return 'This field is required';
        if (!confirm && value!.length < 6) {
          return 'Use at least 6 characters';
        }
        if (confirm && value != _password.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return directionality(
      child: AuthPageFrame(
        eyebrow: 'Start your journey',
        title: 'Create your account',
        subtitle:
            'Join Profit From It to learn and invest with greater clarity.',
        icon: Icons.person_add_alt_1_rounded,
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Column(
                children: [
                  Center(
                    child: Text(
                      'Sign up',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: AuthDesign.ink,
                      ),
                    ),
                  ),
                  SizedBox(height: 7),
                  Center(
                    child: Text(
                      'Enter your details to create an account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.8,
                        height: 1.5,
                        color: AuthDesign.muted,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
              _label('Email'),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textCapitalization: TextCapitalization.none,
                autocorrect: false,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                decoration: _decoration(
                    'Enter your email address', Icons.email_outlined),
                validator: (value) {
                  final email = (value ?? '').trim();
                  if (email.isEmpty) return 'Please enter your email';
                  if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 19),
              _label('Phone number'),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(15)
                ],
                autofillHints: const [AutofillHints.telephoneNumberNational],
                decoration: _decoration(
                  'Enter your mobile number',
                  Icons.phone_outlined,
                  prefix: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _selectCountry,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12, right: 9),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.phone_iphone_rounded,
                              color: AuthDesign.muted, size: 18),
                          const SizedBox(width: 5),
                          Text(_country.dialCode ?? '+91',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AuthDesign.ink,
                              )),
                          const Icon(Icons.arrow_drop_down_rounded,
                              color: AuthDesign.muted, size: 20),
                        ]),
                      ),
                    ),
                  ),
                ),
                validator: (value) {
                  final phone = (value ?? '').trim();
                  if (phone.isEmpty) return 'Please enter your phone number';
                  if (_country.dialCode == '+91' && phone.length != 10) {
                    return 'Enter a valid 10-digit mobile number';
                  }
                  if (phone.length < 6 || phone.length > 15) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 19),
              _label('Create password'),
              _passwordField(confirm: false),
              const SizedBox(height: 19),
              _label('Confirm password'),
              _passwordField(confirm: true),
              const SizedBox(height: 26),
              SizedBox(
                height: 54,
                child: FilledButton(
                  onPressed: _sending ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AuthDesign.blue,
                    disabledBackgroundColor: const Color(0xFFB5C5D9),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _sending
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.2, color: Colors.white))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Create an account',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w700)),
                            SizedBox(width: 10),
                            Icon(Icons.arrow_forward_rounded, size: 19),
                          ],
                        ),
                ),
              ),
              const AuthSocialDivider(label: 'OR CONTINUE WITH'),
              SizedBox(
                height: 54,
                child: OutlinedButton(
                  onPressed: (_signingInWithGoogle || _sending)
                      ? null
                      : _signInWithGoogle,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AuthDesign.ink,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFDCE5F1)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _signingInWithGoogle
                      ? const SizedBox(
                          width: 21,
                          height: 21,
                          child: CircularProgressIndicator(strokeWidth: 2.2),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(AppAssets.googleSvg,
                                width: 22, height: 22),
                            const SizedBox(width: 12),
                            const Flexible(
                              child: Text(
                                'Continue with Google',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: GestureDetector(
                  onTap: _openTerms,
                  behavior: HitTestBehavior.opaque,
                  child: const Text.rich(
                    TextSpan(children: [
                      TextSpan(
                          text:
                              'By using our services, you are agreeing to our '),
                      TextSpan(
                          text: 'Terms & Policies.',
                          style: TextStyle(
                            color: AuthDesign.blue,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          )),
                    ]),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AuthDesign.muted, fontSize: 11.7, height: 1.55),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const Divider(color: Color(0xFFE7EDF5)),
              const SizedBox(height: 8),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  children: [
                    const Text('Have an account?',
                        style:
                            TextStyle(fontSize: 13.5, color: AuthDesign.muted)),
                    TextButton(
                      onPressed: () => nextRoute(LoginPage.pageName,
                          isClearBackRoutes: true),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: const Size(0, 34),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Login',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AuthDesign.blue,
                          )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
  