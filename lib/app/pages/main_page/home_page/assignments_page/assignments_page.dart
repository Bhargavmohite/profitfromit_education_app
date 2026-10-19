import 'package:flutter/material.dart';
import 'package:webinar/app/models/assignment_model.dart';
import 'package:webinar/app/models/instructor_assignment_model.dart';
import 'package:webinar/app/providers/user_provider.dart';
import 'package:webinar/app/services/user_service/assignment_service.dart';
import 'package:webinar/app/widgets/main_widget/assignment_widget/assignment_widget.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/locator.dart';

/// Assignments hub for students and instructors.
/// Keeps existing API endpoints and routes used by assignment cards.
class AssignmentsPage extends StatefulWidget {
  static const String pageName = '/assignments';
  const AssignmentsPage({super.key});

  @override
  State<AssignmentsPage> createState() => _AssignmentsPageState();
}

class _AssignmentsPageState extends State<AssignmentsPage>
    with SingleTickerProviderStateMixin {
  static const Color _brand = Color(0xFF0D3CCF);
  static const Color _navy = Color(0xFF102B72);
  static const Color _ink = Color(0xFF192640);
  static const Color _muted = Color(0xFF74809A);
  static const Color _background = Color(0xFFF5F7FC);
  static const Color _border = Color(0xFFE7ECF5);

  late final TabController _tabs;
  late final bool _isInstructor;
  final TextEditingController _search = TextEditingController();

  List<AssignmentModel> _myAssignments = <AssignmentModel>[];
  InstructorAssignmentModel? _instructorAssignments;
  bool _loadingMine = true;
  bool _loadingInstructor = true;
  bool _instructorFailed = false;
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _isInstructor = locator<UserProvider>().profile?.roleName != 'user';
    _tabs = TabController(length: _isInstructor ? 2 : 1, vsync: this);
    _tabs.addListener(_onTabChanged);
    _search.addListener(_onSearchChanged);
    _refresh();
  }

  void _onTabChanged() {
    if (!_tabs.indexIsChanging && mounted) {
      setState(() => _filter = 'All');
    }
  }

  void _onSearchChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabs.removeListener(_onTabChanged);
    _tabs.dispose();
    _search.removeListener(_onSearchChanged);
    _search.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (mounted) {
      setState(() {
        _loadingMine = true;
        if (_isInstructor) _loadingInstructor = true;
      });
    }
    await Future.wait(<Future<void>>[
      _loadMine(),
      if (_isInstructor) _loadInstructor(),
    ]);
  }

  Future<void> _loadMine() async {
    try {
      final value = await AssignmentService.getAssignments();
      if (!mounted) return;
      setState(() {
        _myAssignments = value;
        _loadingMine = false;
      });
    } catch (error) {
      debugPrint('Assignments: failed to load student list: $error');
      if (!mounted) return;
      setState(() => _loadingMine = false);
    }
  }

  Future<void> _loadInstructor() async {
    try {
      final value = await AssignmentService.getAllAssignmentsInstructor();
      if (!mounted) return;
      setState(() {
        _instructorAssignments = value;
        _instructorFailed = value == null;
        _loadingInstructor = false;
      });
    } catch (error) {
      debugPrint('Assignments: failed to load instructor list: $error');
      if (!mounted) return;
      setState(() {
        _instructorFailed = true;
        _loadingInstructor = false;
      });
    }
  }

  bool get _showInstructor => _isInstructor && _tabs.index == 1;

  List<String> get _filters => _showInstructor
      ? <String>['All', 'Pending reviews', 'Passed', 'Failed']
      : <String>['All', 'To submit', 'In review', 'Passed', 'Not passed'];

  bool _matchesFilter(AssignmentModel item, bool instructor) {
    if (_filter == 'All') return true;
    if (instructor) {
      if (_filter == 'Pending reviews') return (item.pendingCount ?? 0) > 0;
      if (_filter == 'Passed') return (item.passedCount ?? 0) > 0;
      return (item.failedCount ?? 0) > 0;
    }
    final status = (item.userStatus ?? '').toLowerCase().trim();
    if (_filter == 'To submit') return status == 'not_submitted';
    if (_filter == 'Passed') return status == 'passed';
    if (_filter == 'Not passed') return status == 'not_passed';
    return status == 'pending' ||
        status == 'submitted' ||
        status == 'in_review' ||
        status == 'waiting';
  }

  List<AssignmentModel> _visibleAssignments(bool instructor) {
    final items = instructor
        ? (_instructorAssignments?.assignments ?? <AssignmentModel>[])
        : _myAssignments;
    final query = _search.text.trim().toLowerCase();
    return items.where((item) {
      final matchesSearch = query.isEmpty ||
          (item.title ?? '').toLowerCase().contains(query) ||
          (item.webinarTitle ?? '').toLowerCase().contains(query);
      return matchesSearch && _matchesFilter(item, instructor);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return directionality(
      child: Scaffold(
        backgroundColor: _background,
        appBar: AppBar(
          backgroundColor: _brand,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 62,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            tooltip: 'Back',
            onPressed: () => backRoute(),
          ),
          title: Text(
            appText.assignments,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 23),
              tooltip: 'Refresh assignments',
              onPressed: _refresh,
            ),
            const SizedBox(width: 6),
          ],
        ),
        body: Column(
          children: <Widget>[
            _buildHero(),
            if (_isInstructor) _buildTabSwitcher(),
            _buildSearchBar(),
            _buildFilterRow(),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                physics: const BouncingScrollPhysics(),
                children: <Widget>[
                  _buildAssignmentsList(instructor: false),
                  if (_isInstructor) _buildAssignmentsList(instructor: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    final isReviewing = _showInstructor;
    final myTotal = _myAssignments.length;
    final passedMine = _myAssignments
        .where(
          (item) => (item.userStatus ?? '').toLowerCase() == 'passed',
        )
        .length;
    final toSubmit = _myAssignments
        .where(
          (item) => (item.userStatus ?? '').toLowerCase() == 'not_submitted',
        )
        .length;
    final reviewTotal = _instructorAssignments?.courseAssignmentsCount ??
        _instructorAssignments?.assignments?.length ??
        0;
    final total = isReviewing ? reviewTotal : myTotal;
    final secondCount = isReviewing
        ? (_instructorAssignments?.pendingReviewsCount ?? 0)
        : passedMine;
    final thirdCount =
        isReviewing ? (_instructorAssignments?.passedCount ?? 0) : toSubmit;
    final showingLoading = isReviewing ? _loadingInstructor : _loadingMine;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 23),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[_brand, _navy],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      isReviewing ? 'ASSIGNMENT CENTRE' : 'YOUR LEARNING SPACE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      isReviewing
                          ? 'Track every submission'
                          : 'Keep learning, keep growing',
                      style: const TextStyle(
                        fontSize: 19,
                        height: 1.24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isReviewing
                          ? 'Manage assignments and review student progress.'
                          : 'All your assignments, deadlines and grades in one place.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: Colors.white.withValues(alpha: 0.83),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(17),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.18)),
                ),
                child: const Icon(Icons.assignment_outlined,
                    color: Colors.white, size: 29),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              Expanded(
                  child: _heroMetric('Total', showingLoading ? '–' : '$total')),
              const SizedBox(width: 9),
              Expanded(
                  child: _heroMetric(isReviewing ? 'To review' : 'Passed',
                      showingLoading ? '–' : '$secondCount')),
              const SizedBox(width: 9),
              Expanded(
                  child: _heroMetric(isReviewing ? 'Passed' : 'To submit',
                      showingLoading ? '–' : '$thirdCount')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroMetric(String label, String number) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(number,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8), fontSize: 10.5)),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 16, 18, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _border),
      ),
      child: TabBar(
        controller: _tabs,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: _muted,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        indicator: BoxDecoration(
          color: _brand,
          borderRadius: BorderRadius.circular(11),
        ),
        tabs: <Tab>[
          Tab(text: appText.myAssignments, height: 37),
          Tab(text: appText.studentAssignmetns, height: 37),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.fromLTRB(18, _isInstructor ? 13 : 17, 18, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF182B57).withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _search,
        textInputAction: TextInputAction.search,
        style: const TextStyle(fontSize: 13, color: _ink),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search_rounded, color: _brand, size: 21),
          hintText: 'Search assignments or courses',
          hintStyle: const TextStyle(color: _muted, fontSize: 12.5),
          suffixIcon: _search.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  onPressed: _search.clear,
                  icon:
                      const Icon(Icons.close_rounded, color: _muted, size: 19),
                ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = _filters[index];
          final selected = label == _filter;
          return ChoiceChip(
            label: Text(label),
            selected: selected,
            onSelected: (_) => setState(() => _filter = label),
            showCheckmark: false,
            labelStyle: TextStyle(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 11.5,
              color: selected ? _brand : _muted,
            ),
            backgroundColor: Colors.white,
            selectedColor: const Color(0xFFEAF0FF),
            side: BorderSide(color: selected ? _brand : _border),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }

  Widget _buildAssignmentsList({required bool instructor}) {
    final loading = instructor ? _loadingInstructor : _loadingMine;
    final items = _visibleAssignments(instructor);
    return RefreshIndicator(
      color: _brand,
      onRefresh: _refresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
        itemCount: loading ? 4 : items.length + 1,
        itemBuilder: (context, index) {
          if (loading) return _loadingCard(index == 0);
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (instructor) ...<Widget>[
                  _instructorSummary(),
                  const SizedBox(height: 17),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(instructor ? 'Student assignments' : 'My assignments',
                        style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: _ink)),
                    Text('${items.length} found',
                        style: const TextStyle(fontSize: 12, color: _muted)),
                  ],
                ),
                const SizedBox(height: 13),
                if (instructor && _instructorFailed)
                  _emptyState('Could not load assignments',
                      'Please check your connection and try again.')
                else if (items.isEmpty)
                  _emptyState(
                      'No assignments found',
                      _filter != 'All' || _search.text.isNotEmpty
                          ? 'Try a different search or filter.'
                          : 'Assignments will appear here when available.'),
              ],
            );
          }
          return AssignmentWidget.assignmentItem(items[index - 1],
              froUserRole: !instructor);
        },
      ),
    );
  }

  Widget _instructorSummary() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _summaryMetric(
              'Pending',
              '${_instructorAssignments?.pendingReviewsCount ?? 0}',
              Icons.schedule_rounded,
              const Color(0xFFF6A52B),
            ),
          ),
          Container(width: 1, height: 42, color: _border),
          Expanded(
            child: _summaryMetric(
              'Passed',
              '${_instructorAssignments?.passedCount ?? 0}',
              Icons.check_circle_outline_rounded,
              const Color(0xFF139E79),
            ),
          ),
          Container(width: 1, height: 42, color: _border),
          Expanded(
            child: _summaryMetric(
              'Failed',
              '${_instructorAssignments?.failedCount ?? 0}',
              Icons.cancel_outlined,
              const Color(0xFFE26167),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryMetric(
      String label, String amount, IconData icon, Color accent) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, color: accent, size: 17),
            const SizedBox(width: 5),
            Text(amount,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 16, color: _ink)),
          ],
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: _muted, fontSize: 11)),
      ],
    );
  }

  Widget _emptyState(String title, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 38),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF0FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.assignment_late_outlined,
                color: _brand, size: 31),
          ),
          const SizedBox(height: 14),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontWeight: FontWeight.w800, color: _ink, fontSize: 15)),
          const SizedBox(height: 7),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted, fontSize: 12, height: 1.5)),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Refresh'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _brand,
              side: const BorderSide(color: _border),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingCard(bool withHeading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (withHeading) ...<Widget>[
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text('Loading assignments…',
                style: TextStyle(fontSize: 13, color: _muted)),
          ),
        ],
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(15),
          height: 172,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 92,
                width: 110,
                decoration: BoxDecoration(
                  color: _background,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 10),
                    _skeletonLine(1),
                    const SizedBox(height: 12),
                    _skeletonLine(.85),
                    const SizedBox(height: 14),
                    _skeletonLine(.5),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _skeletonLine(double widthFactor) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: 12,
        decoration: BoxDecoration(
          color: _background,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
