import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webinar/app/pages/authentication_page/login_page.dart';
import 'package:webinar/app/services/authentication_service/authentication_service.dart';
import 'package:webinar/app/widgets/authentication_widget/auth_design.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/data/api_public_data.dart';
import 'package:webinar/common/data/app_data.dart';

class VerifyCodePage extends StatefulWidget {
  static const String pageName = '/verify-code';
  const VerifyCodePage({super.key});

  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage> {
  static const int _digitsCount = 5; // Existing API expects 5 digits.
  final _controllers =
      List.generate(_digitsCount, (_) => TextEditingController());
  final _focusNodes = List.generate(_digitsCount, (_) => FocusNode());
  Map<String, dynamic> _data = {};
  bool _verifying = false;
  bool _resending = false;
  bool _otpVerified = false;
  bool _completing = false;
  final _profileFormKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _referralCode = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is Map) {
      _data = Map<String, dynamic>.from(arguments);
      // Used only when the backend explicitly bypassed the OTP step.
      _otpVerified = _otpVerified || _data['otp_verified'] == true;
    }
  }

  @override
  void dispose() {
    _fullName.dispose();
    _referralCode.dispose();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((e) => e.text.trim()).join();
  bool get _isComplete => _code.length == _digitsCount;
  int? get _userId => int.tryParse('${_data['user_id'] ?? ''}');

  void _message(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _onChanged(int index, String value) {
    // Pasting the entire OTP into any box populates all five boxes.
    if (value.length > 1) {
      final pasted = value.replaceAll(RegExp(r'\D'), '');
      for (var i = 0; i < _digitsCount; i++) {
        final newText = i < pasted.length ? pasted[i] : '';
        _controllers[i].value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );
      }
      if (_isComplete) {
        FocusScope.of(context).unfocus();
      } else {
        _focusNodes[pasted.length.clamp(0, _digitsCount - 1).toInt()]
            .requestFocus();
      }
    } else if (value.isNotEmpty) {
      if (index < _digitsCount - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        FocusScope.of(context).unfocus();
      }
    } else if (index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  Future<void> _verify() async {
    if (_verifying || _otpVerified || !_isComplete) return;
    final userId = _userId;
    if (userId == null) {
      _message('Verification session is missing. Please register again.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _verifying = true);
    try {
      final success = await AuthenticationService.verifyCode(userId, _code);
      if (!mounted) return;
      if (success) {
        // The API's registration flow has a required step 3 to set the
        // student's name and activate the new account. Do not navigate to
        // MainPage (as the old code did) or try to log in prematurely.
        setState(() => _otpVerified = true);
        _message('Email verified. Complete your profile to finish signing up.');
      } else {
        _message('Invalid or expired code. Please try again.');
      }
    } catch (_) {
      _message('Verification failed. Please try again.');
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _resend() async {
    if (_resending || _verifying || _otpVerified) return;
    final email = (_data['email'] ?? '').toString().trim();
    if (email.isEmpty) {
      _message('Email is missing. Please start sign up again.');
      return;
    }
    setState(() => _resending = true);
    try {
      // Always request a new OTP by email; never call mobile registration.
      final Map? response = await AuthenticationService.registerWithEmail(
        'email',
        email,
        (_data['password'] ?? '').toString(),
        (_data['retypePassword'] ?? '').toString(),
        PublicData.userRole,
        null,
      );
      if (!mounted) return;
      if (response != null) {
        if (response['user_id'] != null) {
          _data['user_id'] = response['user_id'];
        }
        for (final controller in _controllers) {
          controller.clear();
        }
        _focusNodes.first.requestFocus();
        _message('A new verification code has been requested by email.');
      } else {
        _message(AuthenticationService.lastRegistrationError ??
            'Unable to resend the email code. Please try again.');
      }
    } catch (_) {
      _message('Unable to resend the email code. Please try again.');
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  /// Completes register/step/3, clears the temporary registration session,
  /// and then returns the student to Login as requested.
  Future<void> _finishRegistration() async {
    if (_completing || !_otpVerified) return;
    if (!(_profileFormKey.currentState?.validate() ?? false)) return;

    final userId = _userId;
    if (userId == null) {
      _message('Registration session is missing. Please sign up again.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _completing = true);
    try {
      final completed = await AuthenticationService.registerStep3(
        userId,
        _fullName.text.trim(),
        _referralCode.text.trim(),
      );
      if (!mounted) return;
      if (!completed) {
        _message('Could not finish registration. Please try again.');
        return;
      }

      // Step 3 stores a login token. The desired flow is explicit Login,
      // so remove that temporary authenticated session before navigating.
      await AppData.saveAccessToken('');
      await AppData.saveName('');
      if (!mounted) return;
      nextRoute(LoginPage.pageName, isClearBackRoutes: true);
    } catch (error) {
      _message('Could not finish registration. Please try again.');
    } finally {
      if (mounted) setState(() => _completing = false);
    }
  }

  Widget _buildProfileCompletion() {
    return Form(
      key: _profileFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              height: 66,
              width: 66,
              decoration: BoxDecoration(
                color: const Color(0xFFE9F7EF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.task_alt_rounded,
                  color: Color(0xFF16834A), size: 34),
            ),
          ),
          const SizedBox(height: 18),
          const Text('Email verified successfully',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AuthDesign.ink,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              )),
          const SizedBox(height: 8),
          const Text(
            'Complete one last step to activate your student account. '
            'You will then be taken to Login.',
            textAlign: TextAlign.center,
            style:
                TextStyle(color: AuthDesign.muted, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 25),
          const Text('Full name',
              style: TextStyle(
                color: AuthDesign.ink,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: 8),
          TextFormField(
            controller: _fullName,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: _profileFieldDecoration(
                'Enter your full name', Icons.person_outline_rounded),
            validator: (value) {
              if ((value ?? '').trim().length < 4) {
                return 'Please enter your full name (at least 4 characters).';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          const Text('Referral code (optional)',
              style: TextStyle(
                color: AuthDesign.ink,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: 8),
          TextFormField(
            controller: _referralCode,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _finishRegistration(),
            decoration: _profileFieldDecoration(
                'Referral code, if you have one',
                Icons.confirmation_number_outlined),
          ),
          const SizedBox(height: 25),
          SizedBox(
            height: 54,
            child: FilledButton(
              onPressed: _completing ? null : _finishRegistration,
              style: FilledButton.styleFrom(
                backgroundColor: AuthDesign.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _completing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.2, color: Colors.white),
                    )
                  : const Text('Complete registration',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _profileFieldDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AuthDesign.muted),
      filled: true,
      fillColor: AuthDesign.field,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDCE6F2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDCE6F2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AuthDesign.blue, width: 1.6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final destination = (_data['email'] ?? '').toString().trim();

    return directionality(
      child: AuthPageFrame(
        eyebrow: _otpVerified ? 'Account setup' : 'Account security',
        title:
            _otpVerified ? 'Finish your registration' : 'Verify your account',
        subtitle: _otpVerified
            ? 'Complete your student profile, then sign in securely.'
            : 'One more step to secure your learning experience.',
        icon: _otpVerified
            ? Icons.assignment_turned_in_outlined
            : Icons.verified_user_outlined,
        child: _otpVerified
            ? _buildProfileCompletion()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 66,
                      height: 66,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF3FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.mark_email_read_outlined,
                          color: AuthDesign.blue, size: 32),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Enter verification code',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AuthDesign.ink,
                          fontSize: 19,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 9),
                  Text('Enter the 5-digit code sent to\n$destination',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AuthDesign.muted, fontSize: 13, height: 1.6)),
                  const SizedBox(height: 25),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = ((constraints.maxWidth - 4 * 9) / 5)
                          .clamp(0.0, 60.0)
                          .toDouble();
                      return Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_digitsCount, (index) {
                            return Padding(
                              padding: EdgeInsets.only(
                                  right: index == _digitsCount - 1 ? 0 : 9),
                              child: SizedBox(
                                width: width,
                                height: 60,
                                child: TextField(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  textInputAction: index == _digitsCount - 1
                                      ? TextInputAction.done
                                      : TextInputAction.next,
                                  autofillHints: index == 0
                                      ? const [AutofillHints.oneTimeCode]
                                      : null,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(
                                        _digitsCount),
                                  ],
                                  onChanged: (value) =>
                                      _onChanged(index, value),
                                  onSubmitted: (_) {
                                    if (_isComplete) _verify();
                                  },
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: AuthDesign.ink),
                                  decoration: InputDecoration(
                                    counterText: '',
                                    filled: true,
                                    fillColor: AuthDesign.field,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 13),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(13),
                                      borderSide: const BorderSide(
                                          color: Color(0xFFDCE6F2)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(13),
                                      borderSide: BorderSide(
                                          color: _controllers[index]
                                                  .text
                                                  .isNotEmpty
                                              ? AuthDesign.blue
                                              : const Color(0xFFDCE6F2)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(13),
                                      borderSide: const BorderSide(
                                          color: AuthDesign.blue, width: 2),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 26),
                  SizedBox(
                    height: 54,
                    child: FilledButton(
                      onPressed: (!_isComplete || _verifying) ? null : _verify,
                      style: FilledButton.styleFrom(
                        backgroundColor: AuthDesign.blue,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFB5C5D9),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _verifying
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.2, color: Colors.white))
                          : const Text('Verify account',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text("Didn't receive the code?",
                            style: TextStyle(
                                color: AuthDesign.muted, fontSize: 12.5)),
                        TextButton(
                          onPressed: _resending ? null : _resend,
                          child: _resending
                              ? const SizedBox(
                                  width: 15,
                                  height: 15,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Resend code',
                                  style: TextStyle(
                                      color: AuthDesign.blue,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shield_outlined,
                          color: AuthDesign.muted, size: 14),
                      SizedBox(width: 5),
                      Flexible(
                          child: Text(
                              'A one-time code helps protect your account',
                              style: TextStyle(
                                  color: AuthDesign.muted, fontSize: 11),
                              textAlign: TextAlign.center)),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
