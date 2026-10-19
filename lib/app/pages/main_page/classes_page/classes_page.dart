import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:webinar/app/models/course_model.dart';
import 'package:webinar/app/models/purchase_course_model.dart';
import 'package:webinar/app/pages/authentication_page/login_page.dart';
import 'package:webinar/app/pages/main_page/classes_page/course_overview_page.dart';
import 'package:webinar/app/providers/drawer_provider.dart';
import 'package:webinar/app/providers/user_provider.dart';
import 'package:webinar/app/services/user_service/user_service.dart';
import 'package:webinar/app/widgets/main_widget/classes_widget/classes_widget.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/common/data/app_data.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/common/utils/object_instance.dart';
import 'package:webinar/config/assets.dart';
import 'package:webinar/config/colors.dart';
import 'package:webinar/config/styles.dart';
import 'package:webinar/locator.dart';

import '../../../providers/app_language_provider.dart';

/// Local-only filters: no changes to course APIs or purchase logic.
enum _LearningFilter { all, inProgress, completed, notStarted }

class ClassesPage extends StatefulWidget {
  const ClassesPage({super.key});

  @override
  State<ClassesPage> createState() => _ClassesPageState();
}

class _ClassesPageState extends State<ClassesPage>
    with SingleTickerProviderStateMixin {
  static const _brand = Color(0xFF0D3CCF);
  static const _ink = Color(0xFF122142);
  static const _muted = Color(0xFF7A889E);
  static const _background = Color(0xFFF5F7FC);

  late final TabController tabController;
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = false;
  bool _authReady = false;
  String? _loadError;
  bool hasLogin = false;
  String _query = '';
  _LearningFilter _filter = _LearningFilter.all;

  List<CourseModel> myClasses = [];
  List<PurchaseCourseModel> purchases = [];
  List<CourseModel> organizations = [];
  List<CourseModel> invitations = [];

  bool get _isTeacher =>
      (locator<UserProvider>().profile?.roleName ?? 'user') != 'user';
  bool get _hasOrganization => locator<UserProvider>().profile?.organId != null;

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      length: (_isTeacher ? 3 : 1) + (_hasOrganization ? 1 : 0),
      vsync: this,
    );
    _initializeCourses();
  }

  Future<void> _initializeCourses() async {
    try {
      final token = await AppData.getAccessToken();
      if (!mounted) return;
      setState(() {
        hasLogin = token.isNotEmpty;
        _authReady = true;
      });
      if (hasLogin) await getData();
    } catch (error) {
      debugPrint('My Courses authentication check failed: $error');
      if (!mounted) return;
      setState(() {
        _authReady = true;
        _loadError = 'Unable to check your session. Please try again.';
      });
    }
  }

  Future<void> getData() async {
    if (!hasLogin || !mounted || isLoading) return;
    setState(() {
      isLoading = true;
      _loadError = null;
    });

    try {
      if (_isTeacher) {
        final data = await UserService.getTeacherClassess();
        if (!mounted) return;
        setState(() {
          myClasses = data.$1;
          purchases = data.$2;
          organizations = data.$3;
          invitations = data.$4;
        });
      } else {
        // Do not block the Purchased tab (or its cards) on an unrelated
        // Organization API. Many users do not have organization access.
        final purchasedCourses = await UserService.getPurchaseCourse();
        if (!mounted) return;
        setState(() {
          purchases = purchasedCourses;
          isLoading = false;
        });
        if (_hasOrganization) {
          final organizationCourses = await UserService.getOrganizationCourse();
          if (!mounted) return;
          setState(() => organizations = organizationCourses);
        }
      }
    } catch (error) {
      debugPrint('My Courses load failed: $error');
      if (!mounted) return;
      setState(() {
        _loadError =
            'Could not load your courses. Check your connection and retry.';
      });
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    tabController.dispose();
    super.dispose();
  }

  CourseModel _purchasedCourse(PurchaseCourseModel purchase) =>
      purchase.webinar ?? purchase.bundle ?? CourseModel();

  int get _inProgressCount => purchases.where((entry) {
        if (entry.expired == true) return false;
        final progress = _purchasedCourse(entry).progressPercent ?? 0;
        return progress > 0 && progress < 100;
      }).length;

  int get _completedCount => purchases.where((entry) {
        if (entry.expired == true) return false;
        return (_purchasedCourse(entry).progressPercent ?? 0) >= 100;
      }).length;

  bool _searchMatches(CourseModel course) {
    if (_query.isEmpty) return true;
    return (course.title ?? '').toLowerCase().contains(_query) ||
        (course.category ?? '').toLowerCase().contains(_query);
  }

  bool _filterMatches(PurchaseCourseModel purchase) {
    if (_filter == _LearningFilter.all) return true;
    final progress = _purchasedCourse(purchase).progressPercent ?? 0;
    if (purchase.expired == true) return false;
    switch (_filter) {
      case _LearningFilter.all:
        return true;
      case _LearningFilter.inProgress:
        return progress > 0 && progress < 100;
      case _LearningFilter.completed:
        return progress >= 100;
      case _LearningFilter.notStarted:
        return progress <= 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppLanguageProvider>(
      builder: (context, language, _) => directionality(
        child: Consumer<DrawerProvider>(
          builder: (context, drawer, _) => ClipRRect(
            borderRadius: borderRadius(radius: drawer.isOpenDrawer ? 20 : 0),
            child: Scaffold(
              backgroundColor: _background,
              appBar: appbar(
                title: appText.myCourses,
                leftIcon: AppAssets.menuSvg,
                onTapLeftIcon: () => drawerController.showDrawer(),
              ),
              body: !_authReady
                  ? const Center(child: CircularProgressIndicator(color: _brand))
                  : !hasLogin
                      ? (_loadError != null
                          ? _buildSessionError()
                          : _buildLoginState())
                      : _buildCoursesBody(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: _muted, size: 38),
            const SizedBox(height: 12),
            Text(_loadError ?? 'Unable to load', textAlign: TextAlign.center,
                style: style14Regular().copyWith(color: _ink)),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                setState(() {
                  _authReady = false;
                  _loadError = null;
                });
                _initializeCourses();
              },
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            emptyState(
              AppAssets.loginEmptyStateSvg,
              appText.login,
              appText.loginDesc,
              isBottomPadding: false,
            ),
            const SizedBox(height: 20),
            button(
              onTap: () => nextRoute(
                LoginPage.pageName,
                isClearBackRoutes: true,
              ),
              width: MediaQuery.sizeOf(context).width * .72,
              height: 52,
              text: appText.login,
              bgColor: green77(),
              textColor: Colors.white,
              raduis: 16,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> get _tabs => [
        Tab(text: appText.purchased, height: 36),
        if (_isTeacher) Tab(text: appText.myClassess, height: 36),
        if (_hasOrganization) Tab(text: appText.organization, height: 36),
        if (_isTeacher) Tab(text: appText.invited, height: 36),
      ];

  Widget _buildCoursesBody() {
    return NestedScrollView(
      physics: const BouncingScrollPhysics(),
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverToBoxAdapter(child: _buildLearningHero()),
        SliverToBoxAdapter(child: _buildSearchBox()),
        if (tabController.length > 1)
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            toolbarHeight: 70,
            backgroundColor: _background,
            elevation: 0,
            scrolledUnderElevation: 0,
            titleSpacing: 0,
            title: Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 18),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFE9EEF9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                controller: tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelPadding: const EdgeInsets.symmetric(horizontal: 15),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _brand.withValues(alpha: .09),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                labelColor: _brand,
                unselectedLabelColor: _muted,
                labelStyle: style12Bold(),
                unselectedLabelStyle: style12Regular(),
                tabs: _tabs,
              ),
            ),
          ),
      ],
      body: TabBarView(
        controller: tabController,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildPurchasedCourses(),
          if (_isTeacher)
            _buildList<CourseModel>(
              title: appText.myClassess,
              sourceEmpty: myClasses.isEmpty,
              courses: myClasses.where(_searchMatches).toList(),
              itemBuilder: (course) => ClassessWidget.classesItem(
                course,
                onTap: () => _openOverview(course),
              ),
            ),
          if (_hasOrganization)
            _buildList<CourseModel>(
              title: appText.organization,
              sourceEmpty: organizations.isEmpty,
              courses: organizations.where(_searchMatches).toList(),
              itemBuilder: (course) => ClassessWidget.classesItem(
                course,
                onTap: () => _openOverview(course),
              ),
            ),
          if (_isTeacher)
            _buildList<CourseModel>(
              title: appText.invited,
              sourceEmpty: invitations.isEmpty,
              courses: invitations.where(_searchMatches).toList(),
              itemBuilder: (course) => ClassessWidget.classesItem(course),
            ),
        ],
      ),
    );
  }

  void _openOverview(CourseModel course) {
    nextRoute(
      CourseOverviewPage.pageName,
      arguments: [course.id, course.type == 'bundle', course.isPrivate == 1],
    );
  }

  Widget _buildLearningHero() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 19, 20, 19),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFF174FE2), Color(0xFF102B86)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: _brand.withValues(alpha: .16),
              blurRadius: 24,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .17),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    color: Colors.white,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'YOUR LEARNING SPACE',
                    style: style12Bold().copyWith(
                      color: Colors.white.withValues(alpha: .84),
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                Material(
                  color: Colors.white.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: isLoading ? null : getData,
                    borderRadius: BorderRadius.circular(10),
                    child: const SizedBox(
                      height: 34,
                      width: 34,
                      child: Icon(Icons.refresh_rounded,
                          color: Colors.white, size: 19),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Keep learning. Keep growing.',
              style: style20Bold().copyWith(
                color: Colors.white,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Pick up right where you left off.',
              style: style12Regular().copyWith(
                color: Colors.white.withValues(alpha: .77),
              ),
            ),
            const SizedBox(height: 18),
            Container(height: 1, color: Colors.white.withValues(alpha: .17)),
            const SizedBox(height: 15),
            Row(
              children: [
                _stat('${purchases.length}', 'Enrolled', Icons.book_outlined),
                const SizedBox(width: 8),
                _stat('$_inProgressCount', 'In progress', Icons.timelapse_rounded),
                const SizedBox(width: 8),
                _stat('$_completedCount', 'Completed', Icons.verified_outlined),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String value, String label, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white.withValues(alpha: .8)),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: style16Bold().copyWith(color: Colors.white)),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: style10Regular().copyWith(
                    color: Colors.white.withValues(alpha: .76),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 2, 18, 10),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFE6ECF4)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF203460).withValues(alpha: .04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (text) => setState(() => _query = text.trim().toLowerCase()),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search your courses',
            hintStyle: style14Regular().copyWith(color: _muted),
            prefixIcon: const Icon(Icons.search_rounded, color: _brand, size: 22),
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    tooltip: 'Clear search',
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildPurchasedCourses() {
    final filtered = purchases.where((p) =>
        _searchMatches(_purchasedCourse(p)) && _filterMatches(p)).toList();
    return _buildList<PurchaseCourseModel>(
      title: 'My learning library',
      sourceEmpty: purchases.isEmpty,
      courses: filtered,
      showFilters: true,
      itemBuilder: (purchase) => ClassessWidget.classesItem(
        _purchasedCourse(purchase),
        expired: purchase.expired ?? false,
        expiredDate: purchase.expiredAt ?? 0,
      ),
    );
  }

  Widget _buildList<T>({
    required String title,
    required List<T> courses,
    required Widget Function(T) itemBuilder,
    required bool sourceEmpty,
    bool showFilters = false,
  }) {
    return RefreshIndicator(
      color: _brand,
      onRefresh: getData,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 120),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: 1 + (isLoading ? 3 : courses.isEmpty ? 1 : courses.length),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(2, 5, 2, 11),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(title,
                            style: style16Bold().copyWith(color: _ink)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9EEFF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${isLoading ? '...' : courses.length} courses',
                          style: style12Bold().copyWith(color: _brand),
                        ),
                      ),
                    ],
                  ),
                ),
                if (showFilters) _buildFilters(),
              ],
            );
          }
          if (isLoading) return _buildCourseCardSkeleton();
          if (_loadError != null && courses.isEmpty) {
            return _buildLoadError();
          }
          if (courses.isEmpty) {
            return _buildEmptyResults(isFiltered: _query.isNotEmpty ||
                (showFilters && _filter != _LearningFilter.all) || !sourceEmpty);
          }
          return itemBuilder(courses[index - 1]);
        },
      ),
    );
  }

  // Loader uses the same dimensions as the finished card, so the user
  // sees three visible animated skeletons rather than a blank list.
  Widget _buildCourseCardSkeleton() {
    Widget block({double? width, required double height, double radius = 9}) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: const Color(0xFFE6ECF4)),
      ),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFE7ECF5),
        highlightColor: const Color(0xFFF8FAFD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 14),
            block(height: 17),
            const SizedBox(height: 8),
            block(height: 14, width: 175),
            const SizedBox(height: 14),
            block(height: 12, width: 125),
            const SizedBox(height: 20),
            block(height: 7),
            const SizedBox(height: 15),
            block(height: 17, width: 140),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadError() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 28, 18, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6ECF4)),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_outlined, color: _muted, size: 36),
          const SizedBox(height: 12),
          Text(_loadError!,
              textAlign: TextAlign.center,
              style: style14Regular().copyWith(color: _ink)),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: getData,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retry loading'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _filterChip('All courses', _LearningFilter.all),
            _filterChip('In progress', _LearningFilter.inProgress),
            _filterChip('Completed', _LearningFilter.completed),
            _filterChip('Not started', _LearningFilter.notStarted),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String text, _LearningFilter value) {
    final selected = _filter == value;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: Material(
        color: selected ? _brand : Colors.white,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          onTap: () => setState(() => _filter = value),
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              border: Border.all(
                color: selected ? _brand : const Color(0xFFE5EAF3),
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              text,
              style: style12Bold().copyWith(
                color: selected ? Colors.white : _muted,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyResults({required bool isFiltered}) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.fromLTRB(22, 30, 22, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE6ECF4)),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: const Color(0xFFECF1FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isFiltered ? Icons.search_off_rounded : Icons.menu_book_rounded,
              color: _brand,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isFiltered ? 'No matching courses' : appText.noCourses,
            textAlign: TextAlign.center,
            style: style16Bold().copyWith(color: _ink),
          ),
          const SizedBox(height: 7),
          Text(
            isFiltered
                ? 'Try a different search or choose another filter.'
                : appText.noCourseClassesDesc,
            textAlign: TextAlign.center,
            style: style12Regular().copyWith(color: _muted, height: 1.5),
          ),
          if (isFiltered) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _query = '';
                  _filter = _LearningFilter.all;
                });
              },
              icon: const Icon(Icons.refresh_rounded, size: 17),
              label: const Text('Clear filters'),
            ),
          ],
        ],
      ),
    );
  }
}
