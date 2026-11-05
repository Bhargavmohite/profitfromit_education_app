import 'dart:convert';
import 'dart:developer';
import 'package:webinar/app/models/register_config_model.dart';
import 'package:webinar/common/data/app_data.dart';
import 'package:webinar/common/enums/error_enum.dart';
import 'package:webinar/common/utils/constants.dart';
import 'package:webinar/common/utils/error_handler.dart';
import 'package:webinar/common/utils/http_handler.dart';
import 'package:http/http.dart';

class AuthenticationService {
  static Future google(String email, String token, String name) async {
    try {
      String url = '${Constants.baseUrl}google/callback';

      Response res = await httpPost(url, {
        'email': email,
        'name': name,
        'id': token,
      });

      log("Google callback status code: ${res.statusCode}");
      log("Google callback response: ${res.body}");

      if (res.statusCode == 200) {
        await AppData.saveAccessToken(jsonDecode(res.body)['data']['token']);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log("Google callback exception: $e");
      log("Google callback stackTrace: $StackTrace");
      return false;
    }
  }

  static Future facebook(String email, String token, String name) async {
    try {
      String url = '${Constants.baseUrl}facebook/callback';

      Response res =
          await httpPost(url, {'id': token, 'name': name, 'email': email});

      var jsonResponse = jsonDecode(res.body);
      if (jsonResponse['success']) {
        await AppData.saveAccessToken(jsonDecode(res.body)['data']['token']);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future login(String username, String password) async {
    try {
      String url = '${Constants.baseUrl}login';

      Response res =
          await httpPost(url, {'username': username, 'password': password});

      log(res.body.toString());

      var jsonResponse = jsonDecode(res.body);
      if (jsonResponse['success']) {
        await AppData.saveAccessToken(jsonResponse['data']['token']);
        await AppData.saveName('');
        return true;
      } else {
        ErrorHandler()
            .showError(ErrorEnum.error, jsonResponse, readMessage: true);
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Human-readable feedback for the most recent registration request.
  /// Sensitive request fields (password and OTP) must not be logged.
  static String? lastRegistrationError;

  static Future<Map?> _submitRegistrationStepOne(
      Map<String, dynamic> body) async {
    lastRegistrationError = null;
    try {
      final response = await httpPost(
        '${Constants.baseUrl}register/step/1',
        body,
      ).timeout(const Duration(seconds: 25));

      final dynamic decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        lastRegistrationError =
            'Registration server returned an invalid response.';
        return null;
      }

      final status = (decoded['status'] ?? decoded['step'] ?? '')
          .toString()
          .trim()
          .toLowerCase();
      final bool accepted = decoded['success'] == true ||
          decoded['success'] == 1 ||
          decoded['success'] == 'true';
      const validSteps = {'stored', 'go_step_2', 'go_step_3'};
      final bool stepAccepted = validSteps.contains(status);
      final bool httpOk =
          response.statusCode >= 200 && response.statusCode < 300;

      // Log only non-sensitive diagnostic metadata. Never log passwords,
      // emails, mobile numbers, OTPs or authentication tokens.
      log('Registration step 1: HTTP ${response.statusCode}; status=$status; '
          'accepted=$accepted; method=${body['register_method']}; '
          'role=${body['role'] ?? '(not supplied)'}');

      if (httpOk && (accepted || stepAccepted)) {
        if (!stepAccepted) {
          lastRegistrationError = 'Registration was accepted, but the server '
              'did not provide the next verification step.';
          return null;
        }
        final data = decoded['data'];
        final dynamic userId =
            data is Map ? (data['user_id'] ?? data['id']) : decoded['user_id'];
        if (userId == null || userId.toString().trim().isEmpty) {
          lastRegistrationError = 'The registration server did not return a '
              'user ID for verification.';
          return null;
        }
        return {'user_id': userId, 'step': status};
      }

      // Surface actionable backend validation messages instead of silently
      // returning null, as the earlier implementation did.
      String? message;
      final data = decoded['data'];
      if (data is Map && data['errors'] is Map) {
        final validation = data['errors'] as Map;
        if (validation.isNotEmpty) {
          final first = validation.values.first;
          if (first is List && first.isNotEmpty) {
            message = first.first.toString();
          } else if (first != null) {
            message = first.toString();
          }
        }
      }
      if (message == null && decoded['errors'] is Map) {
        final validation = decoded['errors'] as Map;
        if (validation.isNotEmpty) {
          final first = validation.values.first;
          message = first is List && first.isNotEmpty
              ? first.first.toString()
              : first.toString();
        }
      }
      message ??= decoded['message']?.toString();
      lastRegistrationError = message != null && message.trim().isNotEmpty
          ? message
          : 'The registration request was rejected '
              '(HTTP ${response.statusCode}). Please try again.';
      if ((lastRegistrationError ?? '')
          .toLowerCase()
          .contains('register method')) {
        // Retain the server error and add only safe configuration context.
        // This distinguishes a rejected API configuration from a UI/OTP bug.
        lastRegistrationError = '${lastRegistrationError!} '
            '(student role: ${body['role'] ?? 'missing'}, '
            'method: ${body['register_method'] ?? 'missing'}). '
            'Please verify the server registration settings.';
      }
      return null;
    } catch (error) {
      log('Registration request failed: ${error.runtimeType}');
      lastRegistrationError = 'Could not reach the registration server. '
          'Please check your internet connection and try again.';
      return null;
    }
  }

  static Future<Map?> registerWithEmail(
      String registerMethod,
      String email,
      String password,
      String repeatPassword,
      String? accountType,
      List<Fields>? fields,
      {String? mobile,
      String? countryCode}) async {
    final body = <String, dynamic>{
      'register_method': registerMethod,
      // Required when the backend uses role-specific registration. Previously
      // accountType was received by this method but NEVER sent to the API.
      if (accountType != null && accountType.isNotEmpty)
        'role': accountType,
      'country_code': null,
      'email': email,
      'password': password,
      'password_confirmation': repeatPassword,
    };
    // The original register/step/1 endpoint is single-contact. Do not attach
    // the second contact here even when the form collects it. A backend
    // endpoint must explicitly support saving the second contact later.
    _addRegistrationFields(body, fields);
    return _submitRegistrationStepOne(body);
  }

  static Future<Map?> registerWithPhone(
      String registerMethod,
      String countryCode,
      String mobile,
      String password,
      String repeatPassword,
      String? accountType,
      List<Fields>? fields,
      {String? email}) async {
    final body = <String, dynamic>{
      'register_method': registerMethod,
      if (accountType != null && accountType.isNotEmpty)
        'role': accountType,
      'country_code': countryCode,
      'mobile': mobile,
      'password': password,
      'password_confirmation': repeatPassword,
    };
    // Do not send a second contact to the legacy step-one endpoint.
    _addRegistrationFields(body, fields);
    return _submitRegistrationStepOne(body);
  }

  static void _addRegistrationFields(
      Map<String, dynamic> body, List<Fields>? fields) {
    if (fields == null) return;
    final bodyFields = <dynamic, dynamic>{};
    for (final field in fields) {
      if (field.type == 'upload') continue;
      bodyFields[field.id] = field.type == 'toggle'
          ? (field.userSelectedData == null ? 0 : 1)
          : field.userSelectedData;
    }
    // Maintain the existing backend field serialization format.
    body['fields'] = bodyFields.toString();
  }

  /// Request password recovery by either registered email or Indian mobile.
  /// Delivery routing is decided securely on the Laravel server.
  static Future<bool> forgetPassword(String contact) async {
    try {
      final res = await httpPost('${Constants.baseUrl}forget-password', {
        'email': contact,
      });
      final dynamic decoded = jsonDecode(res.body);
      if (decoded is! Map) return false;
      final success = decoded['success'] == true ||
          decoded['success'] == 1 || decoded['success'] == 'true';
      if (success) {
        ErrorHandler().showError(ErrorEnum.success, decoded, readMessage: true);
        return true;
      }
      ErrorHandler().showError(ErrorEnum.error, decoded, readMessage: true);
    } catch (e) {
      log('Forgot password request failed: ${e.runtimeType}');
    }
    return false;
  }

  static Future<bool> verifyCode(int userId, String code) async {
    try {
      String url = '${Constants.baseUrl}register/step/2';

      Response res = await httpPost(url, {
        "user_id": userId.toString(),
        "code": code,
      });

      log(res.body.toString());

      var jsonResponse = jsonDecode(res.body);
      if (jsonResponse['success']) {
        return true;
      } else {
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> registerStep3(
      int userId, String name, String referralCode) async {
    try {
      String url = '${Constants.baseUrl}register/step/3';

      Response res = await httpPost(url, {
        "user_id": userId.toString(),
        "full_name": name,
        "referral_code": referralCode
      });

      var jsonResponse = jsonDecode(res.body);
      if (jsonResponse['success']) {
        await AppData.saveAccessToken(jsonResponse['data']['token']);
        await AppData.saveName(name);
        return true;
      } else {
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future apple(String email, String token, String name) async {
    try {
      String url = '${Constants.baseUrl}apple/callback';
      Response res = await httpPost(url, {
        'email': email,
        'name': name,
        'id': token,
      });
      print(res.body);
      if (res.statusCode == 200) {
        await AppData.saveAccessToken(jsonDecode(res.body)['data']['token']);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Verify a contact-bound OTP. On success, returns a one-time reset token.
  /// Do not log or persist the OTP or token.
  static Future<String?> forgetPasswordVerifyOTP(
      String contact, String otp) async {
    try {
      final res = await httpPost('${Constants.baseUrl}otp-verify', {
        'email': contact,
        'otp': otp,
      });
      final dynamic decoded = jsonDecode(res.body);
      if (decoded is! Map) return null;
      final success = decoded['success'] == true ||
          decoded['success'] == 1 || decoded['success'] == 'true';
      if (success) {
        final data = decoded['data'];
        final String token = data is Map
            ? (data['reset_token'] ?? '').toString()
            : '';
        if (token.isNotEmpty) {
          ErrorHandler().showError(ErrorEnum.success, decoded, readMessage: true);
          return token;
        }
        log('OTP verified, but API returned no reset_token');
        return null;
      }
      ErrorHandler().showError(ErrorEnum.error, decoded, readMessage: true);
    } catch (e) {
      log('OTP verification failed: ${e.runtimeType}');
    }
    return null;
  }

  /// Reset a password only after the server has verified the OTP.
  static Future<bool> resetPassword(
      String contact, String password, String resetToken) async {
    try {
      final res = await httpPost('${Constants.baseUrl}password-update', {
        'email': contact,
        'password': password,
        'reset_token': resetToken,
      });
      final dynamic decoded = jsonDecode(res.body);
      if (decoded is! Map) return false;
      final success = decoded['success'] == true ||
          decoded['success'] == 1 || decoded['success'] == 'true';
      if (success) {
        ErrorHandler().showError(ErrorEnum.success, decoded, readMessage: true);
        return true;
      }
      ErrorHandler().showError(ErrorEnum.error, decoded, readMessage: true);
    } catch (e) {
      log('Password reset failed: ${e.runtimeType}');
    }
    return false;
  }

}
