import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:webinar/app/models/login_history_model.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/config/assets.dart';

import '../../../../common/data/app_language.dart';
import '../../../../locator.dart';
import '../../../models/location_model.dart';
import '../../../services/guest_service/location_service.dart';
import '../main_widget.dart';

/// Settings sections share one card system so future sections can be added
/// without duplicating decoration, spacing, or typography.
class SettingWidget {
  static const Color _blue = Color(0xFF0D3CCF);
  static const Color _ink = Color(0xFF17233F);
  static const Color _muted = Color(0xFF75839B);
  static const Color _line = Color(0xFFE8EDF5);
  static const Color _red = Color(0xFFDC3545);

  static Widget _content(List<Widget> sections) {
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 17, 16, 26),
      children: sections,
    );
  }

  static Widget _card({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Widget> children,
    Color accent = _blue,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(17, 17, 17, 19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A1B3F82),
            blurRadius: 18,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .09),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: accent, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        color: _ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11.5, color: _muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          const Divider(color: _line, height: 1),
          const SizedBox(height: 17),
          ...children,
        ],
      ),
    );
  }

  static Widget _note(String message,
      {IconData icon = Icons.info_outline_rounded}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _blue, size: 17),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12, height: 1.5, color: _muted),
            ),
          ),
        ],
      ),
    );
  }

  static Widget generalPage({
    required TextEditingController emailController,
    required FocusNode emailNode,
    required TextEditingController nameController,
    required FocusNode nameNode,
    required TextEditingController phoneController,
    required FocusNode phoneNode,
    required TextEditingController refUrlController,
    required FocusNode refUrlNode,
    required TextEditingController languageController,
    required FocusNode languageNode,
    required bool newsletter,
    required Function onTapChangeState,
    required Function(bool value) onTapChangeNewsletter,
    required void Function() onDeleteClick,
    required bool isDeleteLoading,
  }) {
    final languages = locator<AppLanguage>().appLanguagesData;
    final currentLanguage =
        locator<AppLanguage>().currentLanguage.toLowerCase();
    final idx = languages.indexWhere(
      (language) => language.code?.toLowerCase() == currentLanguage,
    );
    languageController.text = idx >= 0 ? (languages[idx].name ?? '') : '';

    return _content([
      _card(
        icon: Icons.person_outline_rounded,
        title: 'Personal information',
        subtitle: 'Keep your profile details up to date',
        children: [
          input(nameController, nameNode, appText.name,
              isBorder: true, title: appText.name, radius: 14),
          const SizedBox(height: 16),
          input(emailController, emailNode, appText.email,
              isBorder: true, title: appText.email, radius: 14),
          const SizedBox(height: 16),
          input(phoneController, phoneNode, appText.phone,
              isBorder: true, title: appText.phone, radius: 14),
        ],
      ),
      const SizedBox(height: 15),
      _card(
        icon: Icons.tune_rounded,
        title: 'Preferences',
        subtitle: 'Choose how you use the app',
        children: [
          input(
            languageController,
            languageNode,
            appText.language,
            isBorder: true,
            title: appText.language,
            radius: 14,
            isReadOnly: true,
            rightIconPath: AppAssets.arrowDownSvg,
            rightIconSize: 16,
            onTap: () async {
              await MainWidget.showLanguageDialog();
              onTapChangeState();
            },
          ),
          const SizedBox(height: 17),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FD),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.mark_email_unread_outlined,
                    color: _blue, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    appText.joinNewsletter,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Switch.adaptive(
                  value: newsletter,
                  activeColor: _blue,
                  onChanged: onTapChangeNewsletter,
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 15),
      _card(
        icon: Icons.warning_amber_rounded,
        title: 'Account management',
        subtitle: 'Sensitive account actions',
        accent: _red,
        children: [
          const Text(
            'Deleting your account is permanent. Please review this action carefully.',
            style: TextStyle(fontSize: 12, height: 1.5, color: _muted),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: isDeleteLoading ? null : onDeleteClick,
            icon: isDeleteLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_outline_rounded, size: 18),
            label: Text(appText.deleteAccount),
            style: OutlinedButton.styleFrom(
              foregroundColor: _red,
              side: const BorderSide(color: Color(0xFFF3B9BF)),
              minimumSize: const Size(double.infinity, 46),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13)),
            ),
          ),
        ],
      ),
    ]);
  }

  static Widget securityPage(
    TextEditingController currentPasswordController,
    FocusNode currentPasswordNode,
    TextEditingController newPasswordController,
    FocusNode newPasswordNode,
    TextEditingController retypePasswordController,
    FocusNode retypePasswordNode,
    List<LoginHistoryModel> loginHistory,
  ) {
    return _content([
      _card(
        icon: Icons.lock_outline_rounded,
        title: 'Password & security',
        subtitle: 'Protect your account with a strong password',
        children: [
          input(currentPasswordController, currentPasswordNode, '',
              isBorder: true,
              title: appText.currentPassword,
              isPassword: true,
              radius: 14),
          const SizedBox(height: 16),
          input(newPasswordController, newPasswordNode, '',
              isBorder: true,
              title: appText.newPassword,
              isPassword: true,
              radius: 14),
          const SizedBox(height: 16),
          input(retypePasswordController, retypePasswordNode, '',
              isBorder: true,
              title: appText.retypePassword,
              isPassword: true,
              radius: 14),
          const SizedBox(height: 16),
          _note('Changes will be applied when you tap Save Changes below.',
              icon: Icons.verified_user_outlined),
        ],
      ),
      const SizedBox(height: 15),
      _card(
        icon: Icons.history_rounded,
        title: appText.loginHistory,
        subtitle: appText.loginHistoryDesc,
        children: [
          if (loginHistory.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: Text('No login history available',
                    style: TextStyle(color: _muted, fontSize: 12)),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 22,
                horizontalMargin: 8,
                headingRowHeight: 42,
                dataRowMinHeight: 46,
                dataRowMaxHeight: 56,
                headingRowColor:
                    WidgetStateProperty.all(const Color(0xFFF1F5FF)),
                columns: [
                  DataColumn(label: _tableHeading(appText.os)),
                  DataColumn(label: _tableHeading(appText.browser)),
                  DataColumn(label: _tableHeading(appText.device)),
                  DataColumn(label: _tableHeading(appText.ip)),
                ],
                rows: loginHistory.map((login) {
                  return DataRow(cells: [
                    DataCell(_tableValue(login.os ?? '')),
                    DataCell(_tableValue(login.browser ?? '')),
                    DataCell(_tableValue(login.device ?? '')),
                    DataCell(_tableValue(login.ip ?? '')),
                  ]);
                }).toList(),
              ),
            ),
        ],
      ),
    ]);
  }

  static Widget _tableHeading(String label) => Text(label,
      style: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.w700, color: _ink));

  static Widget _tableValue(String value) =>
      Text(value, style: const TextStyle(fontSize: 12, color: _muted));

  static Widget financialPage(
    TextEditingController accountTypeController,
    FocusNode accountTypeNode,
    TextEditingController ibanController,
    FocusNode ibanNode,
    TextEditingController accountIdController,
    FocusNode accountIdNode,
    TextEditingController addressController,
    FocusNode addressNode,
    Function onTapChangeState,
    File? indentityScanImage,
    File? certificateImage,
    bool isApprovedIndentity,
    bool isApprovedCertificate,
    Function(ImageSource source) selectIndentityImage,
    Function() selectCertificateImage,
  ) {
    return _content([
      _card(
        icon: Icons.account_balance_outlined,
        title: 'Financial information',
        subtitle: 'Your saved account and address details',
        children: [
          input(
            accountTypeController,
            accountTypeNode,
            appText.accountType,
            isBorder: true,
            title: appText.accountType,
            radius: 14,
            isReadOnly: true,
            rightIconPath: AppAssets.arrowDownSvg,
            rightIconSize: 16,
          ),
          const SizedBox(height: 16),
          input(ibanController, ibanNode, appText.iban,
              isBorder: true, title: appText.iban, radius: 14),
          const SizedBox(height: 16),
          input(accountIdController, accountIdNode, appText.accountID,
              isBorder: true, title: appText.accountID, radius: 14),
          const SizedBox(height: 16),
          input(addressController, addressNode, appText.address,
              isBorder: true, title: appText.address, radius: 14),
          const SizedBox(height: 16),
          _note('Please verify your information before saving.'),
        ],
      ),
    ]);
  }

  static Widget localizationPage(
    List<LocationModel> countries,
    LocationModel? selectedCountry,
    Function(LocationModel val) onTapCountry,
    List<String> timeZoneData,
    String? timeZoneSelected,
    Function(String val) onTapTimezone,
    int? provinceSelectedId,
    Function(int? val) onTapProvince,
    int? citySelectedId,
    Function(int? val) onTapCity,
    int? districtSelectedId,
    Function(int? val) onTapDistrict,
  ) {
    return _LocationSettingsForm(
      countries: countries,
      selectedCountry: selectedCountry,
      onTapCountry: onTapCountry,
      timeZoneData: timeZoneData,
      timeZoneSelected: timeZoneSelected,
      onTapTimezone: onTapTimezone,
      provinceSelectedId: provinceSelectedId,
      onTapProvince: onTapProvince,
      citySelectedId: citySelectedId,
      onTapCity: onTapCity,
      districtSelectedId: districtSelectedId,
      onTapDistrict: onTapDistrict,
    );
  }
}

/// Caches location lookups while interacting with drop-down menus, avoiding
/// repeated network calls on each expansion or selection.
class _LocationSettingsForm extends StatefulWidget {
  final List<LocationModel> countries;
  final LocationModel? selectedCountry;
  final Function(LocationModel) onTapCountry;
  final List<String> timeZoneData;
  final String? timeZoneSelected;
  final Function(String) onTapTimezone;
  final int? provinceSelectedId;
  final Function(int?) onTapProvince;
  final int? citySelectedId;
  final Function(int?) onTapCity;
  final int? districtSelectedId;
  final Function(int?) onTapDistrict;

  const _LocationSettingsForm({
    required this.countries,
    required this.selectedCountry,
    required this.onTapCountry,
    required this.timeZoneData,
    required this.timeZoneSelected,
    required this.onTapTimezone,
    required this.provinceSelectedId,
    required this.onTapProvince,
    required this.citySelectedId,
    required this.onTapCity,
    required this.districtSelectedId,
    required this.onTapDistrict,
  });

  @override
  State<_LocationSettingsForm> createState() => _LocationSettingsFormState();
}

class _LocationSettingsFormState extends State<_LocationSettingsForm> {
  bool _timezoneOpen = false;
  bool _countryOpen = false;
  bool _provinceOpen = false;
  bool _cityOpen = false;
  bool _districtOpen = false;

  Future<List<LocationModel>>? _provinces;
  Future<List<LocationModel>>? _cities;
  Future<List<LocationModel>>? _districts;

  @override
  void initState() {
    super.initState();
    _refreshFutures();
  }

  void _refreshFutures() {
    final countryId = widget.selectedCountry?.id;
    _provinces =
        countryId == null ? null : LocationService.getProvince(countryId);
    final provinceId = widget.provinceSelectedId;
    _cities = provinceId == null ? null : LocationService.getCity(provinceId);
    final cityId = widget.citySelectedId;
    _districts = cityId == null ? null : LocationService.getDistricts(cityId);
  }

  @override
  void didUpdateWidget(covariant _LocationSettingsForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCountry?.id != widget.selectedCountry?.id ||
        oldWidget.provinceSelectedId != widget.provinceSelectedId ||
        oldWidget.citySelectedId != widget.citySelectedId) {
      _refreshFutures();
    }
  }

  Widget _dropdown({
    required String label,
    required String selected,
    required List<String> items,
    required bool expanded,
    required VoidCallback toggle,
    required Function(String, int) onSelected,
  }) {
    return dropDown(label, selected, items, toggle, onSelected, expanded,
        title: label);
  }

  Widget _locationFuture({
    required Future<List<LocationModel>>? future,
    required String label,
    required int? selectedId,
    required bool isOpen,
    required VoidCallback toggle,
    required Function(int?) onSelect,
  }) {
    return FutureBuilder<List<LocationModel>>(
      future: future,
      builder: (context, snapshot) {
        final items = snapshot.data ?? const <LocationModel>[];
        String current = '';
        for (final item in items) {
          if (item.id == selectedId) {
            current = item.title ?? '';
            break;
          }
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _dropdown(
              label: label,
              selected: current,
              items: items.map((item) => item.title ?? '').toList(),
              expanded: isOpen,
              toggle: toggle,
              onSelected: (_, index) {
                if (index < items.length) onSelect(items[index].id);
                // dropDown itself calls toggle after the selection callback.
              },
            ),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Padding(
                padding: EdgeInsets.only(top: 7),
                child: LinearProgressIndicator(minHeight: 2),
              ),
            if (snapshot.hasError)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text('Could not load locations',
                    style: TextStyle(color: Color(0xFFDC3545), fontSize: 11)),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SettingWidget._content([
      SettingWidget._card(
        icon: Icons.public_rounded,
        title: 'Location & timezone',
        subtitle: 'Set your region and local preferences',
        children: [
          _dropdown(
            label: appText.timeZone,
            selected: widget.timeZoneSelected ?? '',
            items: widget.timeZoneData,
            expanded: _timezoneOpen,
            toggle: () => setState(() {
              _timezoneOpen = !_timezoneOpen;
            }),
            onSelected: (value, _) => widget.onTapTimezone(value),
          ),
          const SizedBox(height: 16),
          _dropdown(
            label: appText.country,
            selected: widget.selectedCountry?.title ?? '',
            items: widget.countries.map((e) => e.title ?? '').toList(),
            expanded: _countryOpen,
            toggle: () => setState(() {
              _countryOpen = !_countryOpen;
            }),
            onSelected: (_, index) {
              if (index >= widget.countries.length) return;
              widget.onTapProvince(null);
              widget.onTapCity(null);
              widget.onTapDistrict(null);
              widget.onTapCountry(widget.countries[index]);
            },
          ),
          const SizedBox(height: 16),
          _locationFuture(
            future: _provinces,
            label: appText.province,
            selectedId: widget.provinceSelectedId,
            isOpen: _provinceOpen,
            toggle: () => setState(() {
              _provinceOpen = !_provinceOpen;
            }),
            onSelect: (id) {
              widget.onTapCity(null);
              widget.onTapDistrict(null);
              widget.onTapProvince(id);
            },
          ),
          const SizedBox(height: 16),
          _locationFuture(
            future: _cities,
            label: appText.city,
            selectedId: widget.citySelectedId,
            isOpen: _cityOpen,
            toggle: () => setState(() {
              _cityOpen = !_cityOpen;
            }),
            onSelect: (id) {
              widget.onTapDistrict(null);
              widget.onTapCity(id);
            },
          ),
          const SizedBox(height: 16),
          _locationFuture(
            future: _districts,
            label: appText.district,
            selectedId: widget.districtSelectedId,
            isOpen: _districtOpen,
            toggle: () => setState(() {
              _districtOpen = !_districtOpen;
            }),
            onSelect: widget.onTapDistrict,
          ),
        ],
      ),
    ]);
  }
}
