import 'package:flutter/material.dart';
import 'package:webinar/app/pages/authentication_page/login_page.dart';
import 'package:webinar/app/services/authentication_service/authentication_service.dart';
import 'package:webinar/app/widgets/authentication_widget/auth_design.dart';
import 'package:webinar/common/common.dart';

class ResetPasswordPage extends StatefulWidget {
  static const String pageName = '/reset-password';

  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController resetPasswordController = TextEditingController();
  final FocusNode passwordNode = FocusNode();
  final FocusNode resetPasswordNode = FocusNode();

  String email = '';
  String resetToken = '';
  bool _routeRead = false;
  bool isSendingData = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool get _hasPassword => passwordController.text.trim().isNotEmpty;
  bool get _hasConfirmation => resetPasswordController.text.trim().isNotEmpty;
  bool get _passwordsMatch =>
      passwordController.text.trim() == resetPasswordController.text.trim();
  bool get _canReset =>
      email.isNotEmpty &&
      resetToken.isNotEmpty &&
      _hasPassword &&
      _hasConfirmation &&
      _passwordsMatch &&
      !isSendingData;

  @override
  void initState() {
    super.initState();
    passwordController.addListener(_refreshForm);
    resetPasswordController.addListener(_refreshForm);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The Forgot Password page passes the verified contact as 'email'.
    // Read route arguments here, where ModalRoute is safe to access.
    if (!_routeRead) {
      final Object? arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments is Map) {
        email = (arguments['email'] ?? '').toString().trim();
        resetToken = (arguments['reset_token'] ?? '').toString().trim();
      }
      _routeRead = true;
    }
  }

  void _refreshForm() {
    if (mounted) setState(() {});
  }

  Future<void> _submitReset() async {
    if (!_canReset) return;
    FocusScope.of(context).unfocus();
    setState(() => isSendingData = true);

    bool success = false;
    try {
      success = await AuthenticationService.resetPassword(
        email,
        passwordController.text.trim(),
        resetToken,
      );
    } catch (error) {
      debugPrint('Password reset request failed: $error');
    } finally {
      if (mounted) setState(() => isSendingData = false);
    }

    if (!mounted) return;
    if (success) {
      nextRoute(LoginPage.pageName, isClearBackRoutes: true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset was not completed. Please try again.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    passwordController.removeListener(_refreshForm);
    resetPasswordController.removeListener(_refreshForm);
    passwordController.dispose();
    resetPasswordController.dispose();
    passwordNode.dispose();
    resetPasswordNode.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String hint,
    required bool isVisible,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF95A4B8), fontSize: 13),
      filled: true,
      fillColor: AuthDesign.field,
      contentPadding: const EdgeInsets.symmetric(vertical: 17, horizontal: 15),
      prefixIcon: const Icon(
        Icons.lock_outline_rounded,
        size: 20,
        color: AuthDesign.muted,
      ),
      suffixIcon: IconButton(
        tooltip: isVisible ? 'Show password' : 'Hide password',
        icon: Icon(
          isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 20,
          color: AuthDesign.muted,
        ),
        onPressed: onToggle,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE1E9F3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AuthDesign.blue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFCC4848)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFCC4848), width: 1.5),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AuthDesign.ink,
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AuthPageFrame(
      eyebrow: 'Account security',
      title: 'Reset your password',
      subtitle:
          'Choose a new password to securely access your learning account.',
      icon: Icons.shield_outlined,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.password_rounded,
                size: 30,
                color: AuthDesign.blue,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Create a new password',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AuthDesign.ink,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Enter your new password below and confirm it to finish resetting your account.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AuthDesign.muted,
              fontSize: 12.5,
              height: 1.5,
            ),
          ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: AuthDesign.field,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFFE1E9F3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_user_outlined,
                        size: 16, color: AuthDesign.blue),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        email,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AuthDesign.navy,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 26),
          _label('New password'),
          TextFormField(
            controller: passwordController,
            focusNode: passwordNode,
            obscureText: _obscurePassword,
            obscuringCharacter: '•',
            enableSuggestions: false,
            autocorrect: false,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            onFieldSubmitted: (_) => resetPasswordNode.requestFocus(),
            decoration: _inputDecoration(
              hint: 'Enter new password',
              isVisible: _obscurePassword,
              onToggle: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 16),
          _label('Confirm password'),
          TextFormField(
            controller: resetPasswordController,
            focusNode: resetPasswordNode,
            obscureText: _obscureConfirmPassword,
            obscuringCharacter: '•',
            enableSuggestions: false,
            autocorrect: false,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            onFieldSubmitted: (_) => _submitReset(),
            decoration: _inputDecoration(
              hint: 'Re-enter new password',
              isVisible: _obscureConfirmPassword,
              onToggle: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
          ),
          const SizedBox(height: 12),
          if (_hasConfirmation)
            Row(
              children: [
                Icon(
                  _passwordsMatch
                      ? Icons.check_circle_outline
                      : Icons.info_outline,
                  color: _passwordsMatch
                      ? const Color(0xFF14805E)
                      : const Color(0xFFC2672B),
                  size: 16,
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    _passwordsMatch
                        ? 'Passwords match'
                        : 'Passwords do not match yet',
                    style: TextStyle(
                      fontSize: 12,
                      color: _passwordsMatch
                          ? const Color(0xFF14805E)
                          : const Color(0xFFC2672B),
                    ),
                  ),
                ),
              ],
            )
          else
            const Text(
              'For your security, use a strong and unique password.',
              style: TextStyle(
                  fontSize: 11.5, height: 1.4, color: AuthDesign.muted),
            ),
          if (email.isEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Verification details are missing. Return to Forgot Password and verify your code again.',
              style: TextStyle(
                  fontSize: 12, height: 1.5, color: Color(0xFFB04B36)),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _canReset ? _submitReset : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AuthDesign.blue,
                disabledBackgroundColor: const Color(0xFFADBDD3),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: isSendingData
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Reset Password',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                    ),
            ),
          ),
          const SizedBox(height: 22),
          Center(
            child: TextButton.icon(
              onPressed: () =>
                  nextRoute(LoginPage.pageName, isClearBackRoutes: true),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Back to Login'),
              style: TextButton.styleFrom(
                foregroundColor: AuthDesign.blue,
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
