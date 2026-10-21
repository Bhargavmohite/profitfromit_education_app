import 'package:flutter/material.dart';
import 'package:webinar/app/models/support_model.dart';
import 'package:webinar/app/providers/user_provider.dart';
import 'package:webinar/app/services/user_service/support_service.dart';
import 'package:webinar/app/widgets/main_widget/support_widget/support_widget.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/common/utils/date_formater.dart';
import 'package:webinar/config/styles.dart';
import 'package:webinar/locator.dart';

import 'conversation_page.dart';

/// A compact support inbox. There is intentionally no decorative page header:
/// the existing AppBar is followed directly by tabs, search and tickets.
class SupportMessagePage extends StatefulWidget {
  static const String pageName = '/support-message';

  const SupportMessagePage({super.key});

  @override
  State<SupportMessagePage> createState() => _SupportMessagePageState();
}

class _SupportMessagePageState extends State<SupportMessagePage>
    with SingleTickerProviderStateMixin {
  static const Color _background = Color(0xFFF5F7FC);
  static const Color _brand = Color(0xFF0D3CCF);
  static const Color _ink = Color(0xFF18243A);
  static const Color _muted = Color(0xFF79869A);
  static const Color _border = Color(0xFFE7ECF5);

  late final TabController _tabs;
  final TextEditingController _search = TextEditingController();

  List<SupportModel> _tickets = [];
  List<SupportModel> _classSupport = [];
  List<SupportModel> _myClassSupport = [];

  bool _loadingTickets = true;
  bool _loadingClasses = true;
  bool _loadingMyClass = true;
  late final bool _isInstructor;
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _isInstructor = locator<UserProvider>().profile?.roleName != 'user';
    _tabs = TabController(length: _isInstructor ? 3 : 2, vsync: this);
    _tabs.addListener(_onTabChanged);
    _search.addListener(_onSearchChanged);
    _loadAll();
  }

  void _onTabChanged() {
    if (mounted) setState(() {});
  }

  void _onSearchChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadAll({bool showLoaders = true}) async {
    if (showLoaders && mounted) {
      setState(() {
        _loadingTickets = true;
        _loadingClasses = true;
        _loadingMyClass = true;
      });
    }
    await Future.wait<void>([
      _loadTickets(),
      _loadClasses(),
      if (_isInstructor) _loadMyClass(),
    ]);
  }

  Future<void> _loadTickets() async {
    try {
      final result = await SupportService.getTickets();
      if (!mounted) return;
      setState(() => _tickets = result);
    } catch (_) {
      // Keep the last loaded tickets if a refresh fails.
    } finally {
      if (mounted) setState(() => _loadingTickets = false);
    }
  }

  Future<void> _loadClasses() async {
    try {
      final result = await SupportService.getClassSupport();
      if (!mounted) return;
      setState(() => _classSupport = result);
    } catch (_) {
      // Keep the last loaded course requests if a refresh fails.
    } finally {
      if (mounted) setState(() => _loadingClasses = false);
    }
  }

  Future<void> _loadMyClass() async {
    try {
      final result = await SupportService.getMyClassSupport();
      if (!mounted) return;
      setState(() => _myClassSupport = result);
    } catch (_) {
      // Keep the last loaded instructor requests if a refresh fails.
    } finally {
      if (mounted) setState(() => _loadingMyClass = false);
    }
  }

  List<SupportModel> _sourceFor(int tab) {
    switch (tab) {
      case 0:
        return _tickets;
      case 1:
        return _classSupport;
      default:
        return _myClassSupport;
    }
  }

  bool _loadingFor(int tab) {
    switch (tab) {
      case 0:
        return _loadingTickets;
      case 1:
        return _loadingClasses;
      default:
        return _loadingMyClass;
    }
  }

  String _normalizedStatus(String? value) {
    final status = (value ?? '').trim().toLowerCase();
    if (status == 'close' || status == 'closed') return 'closed';
    if (status == 'replied') return 'replied';
    return 'waiting';
  }

  List<SupportModel> _filteredFor(int tab) {
    final query = _search.text.trim().toLowerCase();
    return _sourceFor(tab).where((support) {
      if (_statusFilter != 'all' &&
          _normalizedStatus(support.status) != _statusFilter) {
        return false;
      }
      if (query.isEmpty) return true;
      return (support.title ?? '').toLowerCase().contains(query) ||
          (support.webinar?.title ?? '').toLowerCase().contains(query) ||
          (support.id?.toString() ?? '').contains(query);
    }).toList();
  }

  Future<void> _createRequest() async {
    if (_tabs.index == 2) return;
    final bool? created = _tabs.index == 0
        ? await SupportWidget.newSupportMessageSheet()
        : await SupportWidget.newSupportMessageForClassesSheet();
    if (!mounted) return;
    if (created == true) await _loadAll(showLoaders: false);
  }

  @override
  void dispose() {
    _tabs.removeListener(_onTabChanged);
    _tabs.dispose();
    _search.removeListener(_onSearchChanged);
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return directionality(
      child: Scaffold(
        backgroundColor: _background,
        appBar: appbar(title: appText.support_messages),
        body: Column(
          children: [
            _buildTabs(),
            const SizedBox(height: 15),
            _buildSearch(),
            const SizedBox(height: 13),
            _buildFilters(),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: List.generate(
                  _tabs.length,
                  (index) => _buildInbox(index),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: _tabs.index == 2
            ? null
            : FloatingActionButton.extended(
                onPressed: _createRequest,
                backgroundColor: _brand,
                foregroundColor: Colors.white,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
                icon: const Icon(Icons.add_comment_outlined, size: 21),
                label: Text(
                  appText.newSupportMessage,
                  style: style14Bold().copyWith(color: Colors.white),
                ),
              ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _border),
      ),
      child: TabBar(
        controller: _tabs,
        isScrollable: true,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: _brand,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: _muted,
        labelStyle: style12Bold(),
        unselectedLabelStyle: style12Regular(),
        labelPadding: const EdgeInsets.symmetric(horizontal: 13),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        tabs: [
          Tab(text: appText.tickets, height: 40),
          Tab(text: appText.classesSupport, height: 40),
          if (_isInstructor) Tab(text: appText.myClassesSupport, height: 40),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _border),
      ),
      child: TextField(
        controller: _search,
        textInputAction: TextInputAction.search,
        style: style14Regular(),
        decoration: InputDecoration(
          hintText: 'Search support messages',
          hintStyle: style14Regular().copyWith(color: _muted),
          prefixIcon: const Icon(Icons.search_rounded, color: _muted, size: 22),
          suffixIcon: _search.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  icon:
                      const Icon(Icons.close_rounded, color: _muted, size: 19),
                  onPressed: _search.clear,
                ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildFilters() {
    const options = <String, String>{
      'all': 'All',
      'waiting': 'Waiting',
      'replied': 'Replied',
      'closed': 'Closed',
    };
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: options.entries.map((entry) {
          final selected = _statusFilter == entry.key;
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: Material(
              color: selected ? const Color(0xFFE7EEFF) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => setState(() => _statusFilter = entry.key),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? const Color(0xFFB8C9FF) : _border,
                    ),
                  ),
                  child: Text(
                    entry.value,
                    style: style12Bold().copyWith(
                      color: selected ? _brand : _muted,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInbox(int tabIndex) {
    final filtered = _filteredFor(tabIndex);
    if (_loadingFor(tabIndex)) return _loadingView();
    return RefreshIndicator(
      color: _brand,
      onRefresh: () => _loadAll(showLoaders: false),
      child: filtered.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.sizeOf(context).height * .12),
                _emptyView(),
              ],
            )
          : ListView.builder(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 5, 16, 96),
              itemCount: filtered.length,
              itemBuilder: (context, index) => _ticketCard(filtered[index]),
            ),
    );
  }

  Widget _ticketCard(SupportModel support) {
    final status = _normalizedStatus(support.status);
    final date = support.createdAt == null
        ? ''
        : timeStampToDateHour(support.createdAt! * 1000);
    final title = (support.title ?? '').trim().isEmpty
        ? 'Support request'
        : support.title!.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A3F80).withValues(alpha: .035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: support.id == null
              ? null
              : () async {
                  await nextRoute(
                    ConversationPage.pageName,
                    arguments: support.id,
                  );
                  if (mounted) await _loadAll(showLoaders: false);
                },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF2FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.mark_unread_chat_alt_outlined,
                    color: _brand,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: style14Bold().copyWith(
                          color: _ink,
                          height: 1.3,
                        ),
                      ),
                      if ((support.webinar?.title ?? '').isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Text(
                          support.webinar!.title!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: style12Regular().copyWith(color: _muted),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 7,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _statusBadge(status),
                          if (date.isNotEmpty)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.schedule_outlined,
                                  size: 13,
                                  color: _muted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  date,
                                  style: style12Regular()
                                      .copyWith(color: _muted, fontSize: 11),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Icon(Icons.chevron_right_rounded, color: _muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final Color color;
    final Color background;
    final String text;
    if (status == 'closed') {
      color = const Color(0xFF64748B);
      background = const Color(0xFFF1F4F8);
      text = 'Closed';
    } else if (status == 'replied') {
      color = const Color(0xFF15803D);
      background = const Color(0xFFE8F7EE);
      text = 'Replied';
    } else {
      color = const Color(0xFFB7650B);
      background = const Color(0xFFFFF4DF);
      text = 'Waiting';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: style12Bold().copyWith(color: color, fontSize: 11),
      ),
    );
  }

  Widget _emptyView() {
    final isFiltered = _search.text.trim().isNotEmpty || _statusFilter != 'all';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              color: Color(0xFFEDF2FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.forum_outlined,
              size: 34,
              color: _brand,
            ),
          ),
          const SizedBox(height: 17),
          Text(
            isFiltered ? 'No matching messages' : appText.noTickets,
            textAlign: TextAlign.center,
            style: style16Bold().copyWith(color: _ink),
          ),
          const SizedBox(height: 8),
          Text(
            isFiltered
                ? 'Try another search or clear the status filter.'
                : appText.noTicketsDesc,
            textAlign: TextAlign.center,
            style: style14Regular().copyWith(color: _muted, height: 1.5),
          ),
          if (isFiltered) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                _search.clear();
                setState(() => _statusFilter = 'all');
              },
              child: const Text('Clear filters'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _loadingView() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 5, 16, 10),
      itemCount: 4,
      itemBuilder: (context, index) => Container(
        height: 112,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                color: _background,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 11, width: 170, color: _background),
                  const SizedBox(height: 13),
                  Container(height: 9, width: 100, color: _background),
                  const SizedBox(height: 10),
                  Container(height: 9, width: 135, color: _background),
                ],
              ),
            ),
            const SizedBox(
              width: 17,
              height: 17,
              child: CircularProgressIndicator(
                strokeWidth: 1.8,
                color: _brand,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
