import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:webinar/app/models/login_history_model.dart';
import 'package:webinar/app/pages/authentication_page/login_page.dart';
import 'package:webinar/app/providers/app_language_provider.dart';
import 'package:webinar/app/providers/user_provider.dart';
import 'package:webinar/app/services/guest_service/guest_service.dart';
import 'package:webinar/app/services/guest_service/location_service.dart';
import 'package:webinar/app/services/user_service/user_service.dart';
import 'package:webinar/app/widgets/main_widget/setting_widget/setting_widget.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/common/data/app_data.dart';
import 'package:webinar/common/database/app_database.dart';
import 'package:webinar/common/enums/error_enum.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/locator.dart';

import '../../../../models/location_model.dart';

class SettingPage extends StatefulWidget {
  static const String pageName = '/profile';

  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage>
    with TickerProviderStateMixin {
  late TabController tabController;

  bool isLocalImage = false;
  File? localImage;

  TextEditingController emailController = TextEditingController();
  FocusNode emailNode = FocusNode();
  TextEditingController nameController = TextEditingController();
  FocusNode nameNode = FocusNode();
  TextEditingController phoneController = TextEditingController();
  FocusNode phoneNode = FocusNode();
  TextEditingController refUrlController = TextEditingController();
  FocusNode refUrlNode = FocusNode();
  TextEditingController languageController = TextEditingController();
  FocusNode languageNode = FocusNode();

  bool newsletter = false;

  TextEditingController currentPasswordController = TextEditingController();
  FocusNode currentPasswordNode = FocusNode();
  TextEditingController newPasswordController = TextEditingController();
  FocusNode newPasswordNode = FocusNode();
  TextEditingController retypePasswordController = TextEditingController();
  FocusNode retypePasswordNode = FocusNode();

  TextEditingController accountTypeController = TextEditingController();
  FocusNode accountTypeNode = FocusNode();
  TextEditingController ibanController = TextEditingController();
  FocusNode ibanNode = FocusNode();
  TextEditingController accountIdController = TextEditingController();
  FocusNode accountIdNode = FocusNode();
  TextEditingController addressController = TextEditingController();
  FocusNode addressNode = FocusNode();

  File? indentityScanImage;
  File? certificateImage;
  bool isApprovedIndentity = false;
  bool isApprovedCertificate = false;

  List<LocationModel> countries = [];
  LocationModel? selectedCountry;

  List<String> timeZoneData = [];
  String? timeZoneSelected;

  int? provinceSelectedId;
  int? citySelectedId;
  int? districtSelectedId;

  bool isLoading = false;

  List<LoginHistoryModel> loginHistory = [];

  // delete button
  bool isDeleteLoading = false;

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 4, vsync: this);

    emailController.text = locator<UserProvider>().profile?.email ?? '';
    nameController.text = locator<UserProvider>().profile?.fullName ?? '';
    phoneController.text = locator<UserProvider>().profile?.mobile ?? '';
    refUrlController.text = locator<UserProvider>().profile?.mobile ?? '';

    newsletter = locator<UserProvider>().profile?.newsletter ?? false;

    addressController.text = locator<UserProvider>().profile?.address ?? '';
    ibanController.text = locator<UserProvider>().profile?.iban ?? '';
    accountIdController.text = locator<UserProvider>().profile?.accountId ?? '';

    timeZoneSelected = locator<UserProvider>().profile?.timezone;
    provinceSelectedId = locator<UserProvider>().profile?.provinceId;
    citySelectedId = locator<UserProvider>().profile?.cityId;
    districtSelectedId = locator<UserProvider>().profile?.districtId;

    LocationService.getCountries().then((value) {
      if (!mounted) return;
      setState(() {
        countries = value;
        final currentId = locator<UserProvider>().profile?.countryId;
        selectedCountry = null;
        for (final country in countries) {
          if (country.id == currentId) {
            selectedCountry = country;
            break;
          }
        }
      });
    }).catchError((Object error) {
      debugPrint('Countries loading failed: $error');
    });

    GuestService.getTimeZone().then((value) {
      if (mounted) {
        setState(() {
          timeZoneData = value;
        });
      }
    }).catchError((Object error) {
      debugPrint('Timezones loading failed: $error');
    });

    UserService.getLoginHistory().then((value) {
      if (mounted) {
        setState(() {
          loginHistory = value;
        });
      }
    }).catchError((Object error) {
      debugPrint('Login history loading failed: $error');
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    for (final controller in [
      emailController,
      nameController,
      phoneController,
      refUrlController,
      languageController,
      currentPasswordController,
      newPasswordController,
      retypePasswordController,
      accountTypeController,
      ibanController,
      accountIdController,
      addressController,
    ]) {
      controller.dispose();
    }
    for (final node in [
      emailNode,
      nameNode,
      phoneNode,
      refUrlNode,
      languageNode,
      currentPasswordNode,
      newPasswordNode,
      retypePasswordNode,
      accountTypeNode,
      ibanNode,
      accountIdNode,
      addressNode,
    ]) {
      node.dispose();
    }
    super.dispose();
  }

  Future<File> compressImage(XFile file) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String address =
        '${appDocDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    XFile? result = await FlutterImageCompress.compressAndGetFile(
      file.path,
      address,
      quality: 55,
      minWidth: 550,
    );
    return File(result!.path);
  }

  // Matches the blue/white design language of the Home and Dashboard pages.
  static const Color _primary = Color(0xFF0D3CCF);
  static const Color _navy = Color(0xFF112D7E);
  static const Color _background = Color(0xFFF5F7FC);
  static const Color _muted = Color(0xFF75839B);

  @override
  Widget build(BuildContext context) {
    return directionality(
      child: Scaffold(
        backgroundColor: _background,
        appBar: AppBar(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: const IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            tooltip: 'Back',
            onPressed: backRoute,
          ),
          title: Text(
            appText.settings,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        body: Column(
          children: [
            _profileHeader(),
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.only(top: 5, bottom: 4),
              child: TabBar(
                controller: tabController,
                isScrollable: true,
                dividerColor: Colors.transparent,
                labelColor: _primary,
                unselectedLabelColor: _muted,
                indicatorColor: _primary,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                labelPadding: const EdgeInsets.symmetric(horizontal: 17),
                tabs: [
                  Tab(text: appText.general),
                  Tab(text: appText.security),
                  Tab(text: appText.financial),
                  Tab(text: appText.localization),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  SettingWidget.generalPage(
                    emailController: emailController,
                    emailNode: emailNode,
                    nameController: nameController,
                    nameNode: nameNode,
                    phoneController: phoneController,
                    phoneNode: phoneNode,
                    refUrlController: refUrlController,
                    refUrlNode: refUrlNode,
                    languageController: languageController,
                    languageNode: languageNode,
                    newsletter: newsletter,
                    onTapChangeState: () {
                      if (mounted) setState(() {});
                    },
                    onTapChangeNewsletter: (value) {
                      setState(() {
                        newsletter = value;
                      });
                    },
                    isDeleteLoading: isDeleteLoading,
                    onDeleteClick: () {
                      showDialog<void>(
                        context: context,
                        builder: (dialogContext) =>
                            deleteAccount(dialogContext),
                      );
                    },
                  ),
                  SettingWidget.securityPage(
                    currentPasswordController,
                    currentPasswordNode,
                    newPasswordController,
                    newPasswordNode,
                    retypePasswordController,
                    retypePasswordNode,
                    loginHistory,
                  ),
                  SettingWidget.financialPage(
                    accountTypeController,
                    accountTypeNode,
                    ibanController,
                    ibanNode,
                    accountIdController,
                    accountIdNode,
                    addressController,
                    addressNode,
                    () {
                      if (mounted) setState(() {});
                    },
                    indentityScanImage,
                    certificateImage,
                    locator<UserProvider>().profile?.identityScan != null,
                    locator<UserProvider>().profile?.certificate != null,
                    (ImageSource source) async {
                      final XFile? image =
                          await ImagePicker().pickImage(source: source);
                      if (image != null) {
                        final file = await compressImage(image);
                        if (mounted) {
                          setState(() {
                            indentityScanImage = file;
                          });
                        }
                      }
                    },
                    () async {
                      final XFile? image = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        final file = await compressImage(image);
                        if (mounted) {
                          setState(() {
                            certificateImage = file;
                          });
                        }
                      }
                    },
                  ),
                  SettingWidget.localizationPage(
                    countries,
                    selectedCountry,
                    (data) => setState(() {
                      selectedCountry = data;
                    }),
                    timeZoneData,
                    timeZoneSelected,
                    (data) => setState(() {
                      timeZoneSelected = data;
                    }),
                    provinceSelectedId,
                    (id) => setState(() {
                      provinceSelectedId = id;
                    }),
                    citySelectedId,
                    (id) => setState(() {
                      citySelectedId = id;
                    }),
                    districtSelectedId,
                    (id) => setState(() {
                      districtSelectedId = id;
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE9EDF6))),
            ),
            child: AbsorbPointer(
              absorbing: isLoading,
              child: button(
                onTap: _saveSettings,
                width: double.infinity,
                height: 52,
                text: appText.save,
                bgColor: _primary,
                textColor: Colors.white,
                isLoading: isLoading,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _profileHeader() {
    final profile = locator<UserProvider>().profile;
    final avatarUrl = profile?.avatar ?? '';
    final fullName = profile?.fullName ?? '';
    final role = profile?.roleName ?? '';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primary, _navy],
        ),
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: .15),
            blurRadius: 19,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withValues(alpha: .8), width: 1.5),
              color: Colors.white.withValues(alpha: .18),
            ),
            child: ClipOval(
              child: localImage != null
                  ? Image.file(localImage!, fit: BoxFit.cover)
                  : avatarUrl.isNotEmpty
                      ? fadeInImage(avatarUrl, 66, 66)
                      : const ColoredBox(
                          color: Color(0xFFDEE8FF),
                          child: Icon(Icons.person_rounded,
                              size: 37, color: _primary),
                        ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  fullName.isEmpty ? appText.settings : fullName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 7),
                if (role.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white.withValues(alpha: .17),
                    ),
                    child: Text(
                      role,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(height: 7),
                const Text(
                  'Manage your account and preferences',
                  maxLines: 2,
                  style: TextStyle(color: Color(0xFFDCE6FF), fontSize: 11.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSettings() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });
    try {
      final bool res = await UserService.updateInfo(
        emailController.text.trim().toEnglishDigit(),
        nameController.text.trim().toEnglishDigit(),
        phoneController.text.trim().toEnglishDigit(),
        timeZoneSelected ?? '',
        newsletter,
        ibanController.text.trim().toEnglishDigit(),
        accountTypeController.text.trim().toEnglishDigit(),
        accountIdController.text.trim().toEnglishDigit(),
        addressController.text.trim().toEnglishDigit(),
        selectedCountry?.id,
        provinceSelectedId,
        citySelectedId,
        districtSelectedId,
      );
      if (!res) return;

      if (currentPasswordController.text.trim().isNotEmpty &&
          newPasswordController.text.trim().isNotEmpty) {
        if (newPasswordController.text.trim() ==
            retypePasswordController.text.trim()) {
          await UserService.updatePassword(
            currentPasswordController.text.trim().toEnglishDigit(),
            newPasswordController.text.trim().toEnglishDigit(),
          );
        } else {
          showSnackBar(ErrorEnum.error, appText.passwordAndRetypePassNotMatch);
          return;
        }
      }
      if (localImage != null ||
          indentityScanImage != null ||
          certificateImage != null) {
        await UserService.updateImage(
            localImage, indentityScanImage, certificateImage);
      }
      if (mounted) backRoute();
    } catch (error) {
      debugPrint('Settings update failed: $error');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget deleteAccount(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Color(0xFFDC3545)),
          SizedBox(width: 9),
          Expanded(
            child: Text('Delete Account',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      content: const Text(
        'Are you sure you want to delete your account? This action cannot be undone.',
        style: TextStyle(fontSize: 13, height: 1.5, color: _muted),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            deleteAccountAPICall();
          },
          child: const Text('Delete',
              style: TextStyle(
                  color: Color(0xFFDC3545), fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  Future<void> deleteAccountAPICall() async {
    if (isDeleteLoading) return;
    setState(() {
      isDeleteLoading = true;
    });
    try {
      final response = await UserService.deleteAccount();
      if (!mounted) return;
      if (response) {
        AppData.saveAccessToken('');
        AppDataBase.clearBox();
        locator<UserProvider>().clearAll();
        locator<AppLanguageProvider>().changeState();
        nextRoute(LoginPage.pageName, isClearBackRoutes: true);
      }
    } catch (error) {
      debugPrint('Account deletion failed: $error');
    } finally {
      if (mounted) {
        setState(() {
          isDeleteLoading = false;
        });
      }
    }
  }
}
