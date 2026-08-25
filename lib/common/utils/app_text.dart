import 'package:flutter/material.dart';
import 'package:webinar/common/data/app_language.dart';
import 'package:webinar/locator.dart';

import '../../config/l10n/app_localizations.dart';

AppLocalizations get appText {
  return lookupAppLocalizations(Locale(locator<AppLanguage>().currentLanguage));
}
