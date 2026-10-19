import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webinar/app/models/blog_model.dart';
import 'package:webinar/app/models/user_model.dart';
import 'package:webinar/app/services/user_service/blog_service.dart';
import 'package:webinar/app/widgets/main_widget/blog_widget/blog_design_widgets.dart';
import 'package:webinar/app/widgets/main_widget/blog_widget/blog_widget.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/common/data/app_data.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/config/assets.dart';

import '../../../../common/utils/utils.dart';

class DetailsBlogPage extends StatefulWidget {
  static const String pageName = '/details-blog';

  const DetailsBlogPage({super.key});

  @override
  State<DetailsBlogPage> createState() => _DetailsBlogPageState();
}

class _DetailsBlogPageState extends State<DetailsBlogPage> {
  BlogModel? blogModel;
  bool userIsLogin = false;
  bool _routeRead = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_routeRead) return;
    _routeRead = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is BlogModel) {
      blogModel = args;
      _updateViewCount(args);
    }
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final token = await AppData.getAccessToken();
    if (mounted) setState(() => userIsLogin = token.isNotEmpty);
  }

  Future<void> _updateViewCount(BlogModel blog) async {
    if (blog.id != null) {
      await BlogService.updateBlogCount(blog.id.toString());
    }
  }

  void _shareArticle() {
    final blog = blogModel;
    if (blog == null || blog.id == null) return;
    final link = 'https://profitfromit.co.in/blog/${blog.id}';
    final title = blog.title ?? '';
    if (Platform.isIOS) {
      shareBlog(context, title, link);
    } else {
      Share.share('$title\n\n$link');
    }
  }

  int get _estimatedReadMinutes {
    final content = BlogDesign.plainText(blogModel?.content);
    if (content.isEmpty) return 1;
    final count = content.split(RegExp(r'\s+')).length;
    return (count / 190).ceil().clamp(1, 60).toInt();
  }

  @override
  Widget build(BuildContext context) => directionality(
        child: Scaffold(
          backgroundColor: BlogDesign.canvas,
          appBar: appbar(
            title: appText.blogPost,
            rightIcon: AppAssets.shareSvg,
            onTapRightIcon: _shareArticle,
            rightWidth: 22,
          ),
          body: blogModel == null
              ? const Center(child: Text('This article could not be opened.'))
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildArticleHeader(),
                      const SizedBox(height: 18),
                      _buildArticleBody(),
                      const SizedBox(height: 24),
                      _buildComments(),
                      const SizedBox(height: 28),
                      const Center(
                        child: Text(
                          'Profit From It  •  Educational purposes only',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 10.5, color: BlogDesign.secondary),
                        ),
                      ),
                    ],
                  ),
                ),
          bottomNavigationBar: userIsLogin && blogModel?.id != null
              ? _buildCommentAction()
              : null,
        ),
      );

  Widget _buildArticleHeader() {
    final blog = blogModel!;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(23),
        color: Colors.white,
        border: Border.all(color: BlogDesign.border),
        boxShadow: BlogDesign.cardShadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(19, 23, 19, 17),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                  color: BlogDesign.paleBlue,
                  borderRadius: BorderRadius.circular(20)),
              child: Text(BlogDesign.category(blog),
                  style: const TextStyle(
                      color: BlogDesign.primary,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w800,
                      fontSize: 10)),
            ),
            const SizedBox(height: 14),
            Text(blog.title ?? '',
                style: const TextStyle(
                    fontSize: 23,
                    height: 1.3,
                    color: BlogDesign.navy,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 15),
            BlogInfoRow(blog: blog),
          ]),
        ),
        AspectRatio(
            aspectRatio: 16 / 9, child: BlogCover(blog: blog, useHero: true)),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 17, 18, 18),
          child: Row(children: [
            _authorAvatar(blog.author),
            const SizedBox(width: 11),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    blog.author?.fullName?.trim().isNotEmpty == true
                        ? blog.author!.fullName!
                        : 'Profit From It',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: BlogDesign.navy)),
                const SizedBox(height: 4),
                const Text('Article author',
                    style:
                        TextStyle(color: BlogDesign.secondary, fontSize: 11)),
              ],
            )),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: BlogDesign.paleBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.schedule_rounded,
                    size: 14, color: BlogDesign.primary),
                const SizedBox(width: 5),
                Text('~$_estimatedReadMinutes min',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: BlogDesign.primary)),
              ]),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _authorAvatar(UserModel? author) {
    final url = author?.avatar?.trim() ?? '';
    return Container(
      width: 42,
      height: 42,
      decoration: const BoxDecoration(
          color: BlogDesign.paleBlue, shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: url.isEmpty
          ? const Icon(Icons.person_rounded, color: BlogDesign.primary)
          : Image.network(url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.person_rounded, color: BlogDesign.primary)),
    );
  }

  Widget _buildArticleBody() => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: BlogDesign.border),
          boxShadow: BlogDesign.cardShadow,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
                width: 4,
                height: 26,
                decoration: BoxDecoration(
                    color: BlogDesign.primary,
                    borderRadius: BorderRadius.circular(8))),
            const SizedBox(width: 10),
            const Text('The full story',
                style: TextStyle(
                    color: BlogDesign.navy,
                    fontSize: 17,
                    fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 19),
          HtmlWidget(
            blogModel?.content ?? '',
            textStyle: const TextStyle(
                color: BlogDesign.navy, fontSize: 14, height: 1.75),
          ),
          const SizedBox(height: 23),
          const Divider(color: BlogDesign.border),
          const SizedBox(height: 9),
          const Row(children: [
            Icon(Icons.info_outline_rounded,
                color: BlogDesign.secondary, size: 16),
            SizedBox(width: 8),
            Expanded(
                child: Text(
                    'For educational purposes only. Not investment advice.',
                    style: TextStyle(
                        color: BlogDesign.secondary,
                        fontSize: 11,
                        height: 1.45))),
          ]),
        ]),
      );

  Widget _buildComments() {
    final blog = blogModel!;
    final comments = blog.comments ?? [];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
            width: 4,
            height: 34,
            decoration: BoxDecoration(
                color: BlogDesign.primary,
                borderRadius: BorderRadius.circular(8))),
        const SizedBox(width: 10),
        Expanded(
            child: Text(appText.comments,
                style: const TextStyle(
                    color: BlogDesign.navy,
                    fontSize: 18,
                    fontWeight: FontWeight.w800))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: BlogDesign.paleBlue,
              borderRadius: BorderRadius.circular(20)),
          child: Text('${blog.commentCount ?? comments.length}',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: BlogDesign.primary)),
        ),
      ]),
      const SizedBox(height: 14),
      if (comments.isEmpty)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 31),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: BlogDesign.border),
              borderRadius: BorderRadius.circular(20)),
          child: Column(children: [
            Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                    color: BlogDesign.paleBlue, shape: BoxShape.circle),
                child: const Icon(Icons.forum_outlined,
                    color: BlogDesign.primary, size: 25)),
            const SizedBox(height: 11),
            Text(appText.noComments,
                style: const TextStyle(
                    color: BlogDesign.navy,
                    fontWeight: FontWeight.w800,
                    fontSize: 15)),
            const SizedBox(height: 5),
            Text(appText.noCommentsDesc,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: BlogDesign.secondary, fontSize: 12, height: 1.5)),
          ]),
        )
      else
        for (final comment in comments) _commentTile(comment),
    ]);
  }

  Widget _commentTile(Comments comment, {bool isReply = false}) {
    final author = comment.user;
    return Container(
      margin: EdgeInsets.only(bottom: isReply ? 9 : 13),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isReply ? BlogDesign.canvas : Colors.white,
        border: Border.all(color: BlogDesign.border),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _authorAvatar(author),
          const SizedBox(width: 9),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(author?.fullName ?? 'Reader',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: BlogDesign.navy)),
              const SizedBox(height: 3),
              Text(BlogDesign.date(comment.createAt),
                  style: const TextStyle(
                      fontSize: 10.5, color: BlogDesign.secondary)),
            ],
          )),
          if (!isReply && comment.id != null && blogModel?.id != null)
            IconButton(
              tooltip: 'Comment options',
              onPressed: () => BlogWidget.showOptionDialog(
                  blogModel!.id!, comment.id, userIsLogin),
              icon: const Icon(Icons.more_horiz_rounded,
                  color: BlogDesign.secondary),
            ),
        ]),
        const SizedBox(height: 11),
        Text(comment.comment ?? '',
            style: const TextStyle(
                color: BlogDesign.navy, fontSize: 12.5, height: 1.65)),
        if (!isReply && comment.replies?.isNotEmpty == true) ...[
          const SizedBox(height: 13),
          for (final reply in comment.replies!) _replyTile(reply),
        ],
      ]),
    );
  }

  Widget _replyTile(Replies reply) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: BlogDesign.canvas, borderRadius: BorderRadius.circular(13)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.subdirectory_arrow_right_rounded,
                color: BlogDesign.primary, size: 18),
            const SizedBox(width: 6),
            Expanded(
                child: Text(reply.user?.fullName ?? 'Reader',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: BlogDesign.navy))),
            Text(BlogDesign.date(reply.createAt),
                style:
                    const TextStyle(fontSize: 10, color: BlogDesign.secondary)),
          ]),
          const SizedBox(height: 7),
          Text(reply.comment ?? '',
              style: const TextStyle(
                  color: BlogDesign.navy, fontSize: 12, height: 1.55)),
        ]),
      );

  Widget _buildCommentAction() => SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(top: BorderSide(color: BlogDesign.border)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .04),
                blurRadius: 16,
                offset: const Offset(0, -4),
              )
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: BlogDesign.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () =>
                  BlogWidget.showReplayDialog(blogModel!.id!, null),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(appText.leaveAComment,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      );
}
