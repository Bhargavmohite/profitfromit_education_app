import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webinar/app/models/basic_model.dart';
import 'package:webinar/app/models/blog_model.dart';
import 'package:webinar/app/pages/main_page/blog_page/details_blog_page.dart';
import 'package:webinar/app/providers/drawer_provider.dart';
import 'package:webinar/app/services/user_service/blog_service.dart';
import 'package:webinar/app/widgets/main_widget/blog_widget/blog_design_widgets.dart';
import 'package:webinar/app/widgets/main_widget/blog_widget/blog_widget.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/common/utils/object_instance.dart';
import 'package:webinar/config/assets.dart';

class BlogsPage extends StatefulWidget {
  const BlogsPage({super.key});

  @override
  State<BlogsPage> createState() => _BlogsPageState();
}

class _BlogsPageState extends State<BlogsPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<BlogModel> blogData = [];
  List<BasicModel> categories = [];
  BasicModel? selectedCategory;

  bool _initialLoading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  bool _loadFailed = false;
  int _requestVersion = 0;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_checkPagination);
    _searchController.addListener(() {
      if (!mounted) return;
      final newQuery = _searchController.text.trim().toLowerCase();
      if (newQuery != _query) setState(() => _query = newQuery);
    });
    _loadArticles(reset: true);
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final result = await BlogService.categories();
    if (mounted) setState(() => categories = result);
  }

  void _checkPagination() {
    if (!_scrollController.hasClients ||
        _initialLoading ||
        _loadingMore ||
        !_hasMore) {
      return;
    }
    if (_scrollController.position.extentAfter < 350) _loadArticles();
  }

  /// Keeps existing offset/category API behavior. Older requests cannot
  /// overwrite results from a newer category or pull-to-refresh request.
  Future<void> _loadArticles({bool reset = false}) async {
    if (!mounted) return;
    if (!reset && (_initialLoading || _loadingMore || !_hasMore)) return;

    if (reset) {
      _requestVersion++;
      setState(() {
        blogData = [];
        _hasMore = true;
        _initialLoading = true;
        _loadingMore = false;
        _loadFailed = false;
      });
    } else {
      setState(() => _loadingMore = true);
    }

    final version = _requestVersion;
    final offset = blogData.length;
    final categoryId = selectedCategory?.id;
    try {
      final results = await BlogService.getBlog(offset, category: categoryId);
      if (!mounted || version != _requestVersion) return;
      setState(() {
        final ids = blogData.map((e) => e.id).toSet();
        for (final item in results) {
          if (item.id == null || ids.add(item.id)) blogData.add(item);
        }
        // BlogService requests pages of 10 articles.
        _hasMore = results.length >= 10;
        _loadFailed = false;
      });
    } catch (error) {
      debugPrint('Blog page load failed: $error');
      if (mounted && version == _requestVersion) {
        setState(() => _loadFailed = true);
      }
    } finally {
      if (mounted && version == _requestVersion) {
        setState(() {
          _initialLoading = false;
          _loadingMore = false;
        });
      }
    }
  }

  void _selectCategory(BasicModel? category) {
    if (selectedCategory?.id == category?.id) return;
    setState(() => selectedCategory = category);
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
    _loadArticles(reset: true);
  }

  Future<void> _openCategorySheet() async {
    final category =
        await BlogWidget.showCategoriesDialog(selectedCategory, categories);
    if (!mounted) return;
    if (category is BasicModel) _selectCategory(category);
  }

  void _openArticle(BlogModel article) => nextRoute(
        DetailsBlogPage.pageName,
        arguments: article,
      );

  List<BlogModel> get _visibleArticles {
    if (_query.isEmpty) return blogData;
    return blogData.where((blog) {
      final haystack = [
        blog.title ?? '',
        BlogDesign.plainText(blog.description),
        blog.category ?? '',
        blog.author?.fullName ?? '',
      ].join(' ').toLowerCase();
      return haystack.contains(_query);
    }).toList();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_checkPagination);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return directionality(
      child: Consumer<DrawerProvider>(builder: (context, drawerProvider, _) {
        return ClipRRect(
          borderRadius:
              borderRadius(radius: drawerProvider.isOpenDrawer ? 20 : 0),
          child: Scaffold(
            backgroundColor: BlogDesign.canvas,
            appBar: appbar(
              title: appText.blog,
              leftIcon: AppAssets.menuSvg,
              onTapLeftIcon: () => drawerController.showDrawer(),
              rightIcon: AppAssets.filterSvg,
              onTapRightIcon: _openCategorySheet,
              rightWidth: 24,
            ),
            body: RefreshIndicator(
              color: BlogDesign.primary,
              onRefresh: () => _loadArticles(reset: true),
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                slivers: [
                  SliverToBoxAdapter(child: _buildSearch()),
                  SliverToBoxAdapter(child: _buildCategoryStrip()),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    sliver: SliverToBoxAdapter(child: _buildResults()),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSearch() => Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: BlogDesign.border),
            boxShadow: BlogDesign.cardShadow,
          ),
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            style: const TextStyle(fontSize: 14, color: BlogDesign.navy),
            decoration: InputDecoration(
              hintText: 'Search articles',
              hintStyle:
                  const TextStyle(fontSize: 13, color: BlogDesign.secondary),
              prefixIcon:
                  const Icon(Icons.search_rounded, color: BlogDesign.primary),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: _searchController.clear,
                      icon: const Icon(Icons.close_rounded, size: 18)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      );

  Widget _buildCategoryStrip() {
    if (categories.isEmpty && selectedCategory == null) {
      return const SizedBox(height: 2);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 19),
      child: SizedBox(
        height: 38,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          children: [
            _categoryChip('All articles', selectedCategory == null,
                () => _selectCategory(null)),
            for (final item in categories)
              _categoryChip(item.title ?? 'Category',
                  selectedCategory?.id == item.id, () => _selectCategory(item)),
          ],
        ),
      ),
    );
  }

  Widget _categoryChip(String title, bool selected, VoidCallback onTap) =>
      Padding(
        padding: const EdgeInsetsDirectional.only(end: 9),
        child: Material(
          color: selected ? BlogDesign.primary : Colors.white,
          borderRadius: BorderRadius.circular(30),
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                    color: selected ? BlogDesign.primary : BlogDesign.border),
              ),
              child: Text(title,
                  maxLines: 1,
                  style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : BlogDesign.secondary)),
            ),
          ),
        ),
      );

  Widget _buildResults() {
    if (_initialLoading) {
      return const Column(children: [
        BlogLoadingCard(large: true),
        BlogLoadingCard(),
        BlogLoadingCard(),
      ]);
    }

    final visible = _visibleArticles;
    if (visible.isEmpty) return _buildEmptyState();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeading('Featured read', 'Latest from our blog'),
      const SizedBox(height: 12),
      BlogFeaturedCard(
          blog: visible.first, onTap: () => _openArticle(visible.first)),
      if (visible.length > 1) ...[
        const SizedBox(height: 25),
        _sectionHeading('Explore more', '${visible.length - 1} more articles'),
        const SizedBox(height: 13),
        for (final article in visible.skip(1))
          BlogCompactCard(blog: article, onTap: () => _openArticle(article)),
      ],
      if (_loadingMore) ...[
        const BlogLoadingCard(),
        const BlogLoadingCard(),
      ],
      if (!_loadingMore && _hasMore)
        Center(
            child: TextButton.icon(
          onPressed: () => _loadArticles(),
          icon: const Icon(Icons.expand_more_rounded, size: 19),
          label: const Text('Load more articles'),
          style: TextButton.styleFrom(foregroundColor: BlogDesign.primary),
        )),
      if (_loadFailed)
        Center(
            child: TextButton(
                onPressed: () => _loadArticles(),
                child: const Text('Loading failed. Tap to retry.'))),
      const SizedBox(height: 17),
      const Center(
          child: Text('Educational content only • Not investment advice',
              textAlign: TextAlign.center,
              style: TextStyle(color: BlogDesign.secondary, fontSize: 10))),
    ]);
  }

  Widget _sectionHeading(String title, String subtitle) => Row(children: [
        Container(
            width: 4,
            height: 34,
            decoration: BoxDecoration(
                color: BlogDesign.primary,
                borderRadius: BorderRadius.circular(10))),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  color: BlogDesign.navy,
                  fontSize: 17,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(subtitle,
              style:
                  const TextStyle(color: BlogDesign.secondary, fontSize: 11)),
        ])),
      ]);

  Widget _buildEmptyState() => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 44),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: BlogDesign.border),
            borderRadius: BorderRadius.circular(22)),
        child: Column(children: [
          Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                  color: BlogDesign.paleBlue, shape: BoxShape.circle),
              child: const Icon(Icons.article_outlined,
                  size: 30, color: BlogDesign.primary)),
          const SizedBox(height: 16),
          Text(_query.isNotEmpty ? 'No matching articles' : 'No articles yet',
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: BlogDesign.navy,
                  fontSize: 17)),
          const SizedBox(height: 8),
          Text(
              _query.isNotEmpty
                  ? 'Try another keyword or explore a different category.'
                  : 'New insights will appear here when available.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 12.5, height: 1.5, color: BlogDesign.secondary)),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () {
              _searchController.clear();
              if (selectedCategory != null) {
                _selectCategory(null);
              } else {
                _loadArticles(reset: true);
              }
            },
            icon: const Icon(Icons.refresh_rounded, size: 17),
            label: const Text('Show all articles'),
          ),
        ]),
      );
}
