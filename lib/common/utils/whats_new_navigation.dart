import 'package:flutter/material.dart';
import 'package:webinar/app/pages/main_page/home_page/assignments_page/assignments_page.dart';
import 'package:webinar/app/pages/main_page/home_page/dashboard_page/dashboard_page.dart';
import 'package:webinar/app/pages/main_page/home_page/setting_page/setting_page.dart';
import 'package:webinar/app/providers/page_provider.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/enums/page_name_enum.dart';
import 'package:webinar/common/utils/institutional_model_actions.dart';
import 'package:webinar/locator.dart';

/// Only supported, explicitly mapped CTA actions can navigate the application.
/// Release content can be changed from Laravel without changing this widget.
class WhatsNewNavigation {
  WhatsNewNavigation._();

  static Future<void> open(BuildContext context, String action) async {
    switch (action.toLowerCase().trim()) {
      case 'home':
        locator<PageProvider>().setPage(PageNames.home);
        return;
      case 'my_courses':
        locator<PageProvider>().setPage(PageNames.myClasses);
        return;
      case 'blogs':
        locator<PageProvider>().setPage(PageNames.blog);
        return;
      case 'wealth_calculators':
        return openInstitutionalModel(context, InstitutionalModel.wealthCalculators);
      case 'portfolio_diagnosis':
        return openInstitutionalModel(context, InstitutionalModel.portfolioDiagnosis);
      case 'financial_planning':
        return openInstitutionalModel(context, InstitutionalModel.financialPlanning);
      case 'investment_baskets':
        return openInstitutionalModel(context, InstitutionalModel.investmentBaskets);
      case 'dashboard':
        nextRoute(DashboardPage.pageName);
        return;
      case 'assignments':
        nextRoute(AssignmentsPage.pageName);
        return;
      case 'settings':
        nextRoute(SettingPage.pageName);
        return;
      default:
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(content: Text('This feature is not available yet.')),
        );
    }
  }
}
