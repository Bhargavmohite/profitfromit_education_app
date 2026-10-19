import 'package:flutter/material.dart';
import 'package:webinar/app/models/chat_model.dart';
import 'package:webinar/app/models/support_model.dart';
import 'package:webinar/app/services/user_service/support_service.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/common/utils/date_formater.dart';
import 'package:webinar/config/styles.dart';

class ConversationPage extends StatefulWidget {
  static const String pageName = '/conversation';

  const ConversationPage({super.key});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  static const Color _brand = Color(0xFF0D3CCF);
  static const Color _background = Color(0xFFF5F7FC);
  static const Color _border = Color(0xFFE7ECF5);
  static const Color _ink = Color(0xFF18243A);
  static const Color _muted = Color(0xFF79869A);

  int? _id;
  SupportModel? _data;
  bool _loading = true;
  bool _sending = false;

  final ScrollController _scroll = ScrollController();
  final TextEditingController _message = TextEditingController();
  final FocusNode _messageFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int) {
        _id = args;
        _loadConversation();
      } else {
        setState(() => _loading = false);
      }
    });
  }

  Future<void> _loadConversation({bool showLoader = true}) async {
    final messageId = _id;
    if (messageId == null) return;
    if (showLoader && mounted) setState(() => _loading = true);

    SupportModel? result;
    try {
      result = await SupportService.getOne(messageId);
    } catch (_) {
      result = null;
    }
    if (!mounted) return;
    setState(() {
      _data = result;
      _loading = false;
    });
    _scrollToLatest();
  }

  void _scrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _sendMessage() async {
    final text = _message.text.trim();
    if (text.isEmpty || _sending || _id == null) return;
    setState(() => _sending = true);

    bool sent = false;
    try {
      sent = await SupportService.sendMessage(text, null, _id!);
    } catch (_) {
      sent = false;
    }
    if (!mounted) return;

    if (sent) {
      _message.clear();
      await _loadConversation(showLoader: false);
    }
    if (mounted) setState(() => _sending = false);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _message.dispose();
    _messageFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return directionality(
      child: Scaffold(
        backgroundColor: _background,
        resizeToAvoidBottomInset: true,
        // Keep only the standard AppBar; no decorative hero/header section.
        appBar: appbar(
          title: (_data?.title ?? '').trim().isNotEmpty
              ? _data!.title!
              : appText.support_messages,
        ),
        body: _loading
            ? const Center(
                child: CircularProgressIndicator(color: _brand),
              )
            : _data == null
                ? _buildUnavailable()
                : Column(
                    children: [
                      if (_data?.webinar != null) _buildCourseContext(),
                      Expanded(child: _buildConversation()),
                      _buildComposer(),
                    ],
                  ),
      ),
    );
  }

  Widget _buildCourseContext() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 37,
            height: 37,
            decoration: BoxDecoration(
              color: const Color(0xFFEDF2FF),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.menu_book_outlined,
              size: 19,
              color: _brand,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appText.thisIsACourseSupportMessage,
                  style: style12Regular().copyWith(color: _muted),
                ),
                const SizedBox(height: 3),
                Text(
                  _data?.webinar?.title ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: style14Bold().copyWith(color: _ink),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversation() {
    final messages = _data?.conversations ?? <ChatModel>[];
    return RefreshIndicator(
      color: _brand,
      onRefresh: () => _loadConversation(showLoader: false),
      child: ListView.builder(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        itemCount: messages.isEmpty ? 1 : messages.length,
        itemBuilder: (context, index) {
          if (messages.isEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Column(
                children: [
                  const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: _brand,
                    size: 42,
                  ),
                  const SizedBox(height: 13),
                  Text(
                    'No messages yet',
                    style: style16Bold().copyWith(color: _ink),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Write a message below to continue the conversation.',
                    textAlign: TextAlign.center,
                    style: style14Regular().copyWith(color: _muted),
                  ),
                ],
              ),
            );
          }
          return _buildMessage(messages[index]);
        },
      ),
    );
  }

  Widget _buildMessage(ChatModel message) {
    // Preserve the existing API convention: sender == null is the user.
    final outgoing = message.sender == null;
    final content = (message.message ?? '').trim();
    final hasFile = (message.filePath ?? '').isNotEmpty;

    return Align(
      alignment: outgoing
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * .82,
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Column(
            crossAxisAlignment:
                outgoing ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (content.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: outgoing ? _brand : Colors.white,
                    border: outgoing ? null : Border.all(color: _border),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(17),
                      topRight: const Radius.circular(17),
                      bottomLeft: Radius.circular(outgoing ? 17 : 4),
                      bottomRight: Radius.circular(outgoing ? 4 : 17),
                    ),
                    boxShadow: outgoing
                        ? null
                        : [
                            BoxShadow(
                              color: const Color(0xFF294568)
                                  .withValues(alpha: .035),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                  ),
                  child: Text(
                    content,
                    style: style14Regular().copyWith(
                      color: outgoing ? Colors.white : _ink,
                      height: 1.5,
                    ),
                  ),
                ),
              if (hasFile) ...[
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => downloadSheet(
                    message.filePath!,
                    message.filePath!.split('/').last,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.attach_file_rounded,
                          color: _brand,
                          size: 17,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            (message.fileTitle ?? '').isNotEmpty
                                ? message.fileTitle!
                                : message.filePath!.split('/').last,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: style12Regular().copyWith(color: _ink),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (message.createdAt != null) ...[
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    timeStampToDateHour(message.createdAt! * 1000),
                    style:
                        style12Regular().copyWith(color: _muted, fontSize: 11),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComposer() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: _border)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF294568).withValues(alpha: .045),
              blurRadius: 15,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 48),
                decoration: BoxDecoration(
                  color: _background,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: _border),
                ),
                child: TextField(
                  controller: _message,
                  focusNode: _messageFocus,
                  minLines: 1,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  style: style14Regular().copyWith(color: _ink),
                  decoration: InputDecoration(
                    hintText: appText.message,
                    hintStyle: style14Regular().copyWith(color: _muted),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 13,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _message,
              builder: (context, value, child) {
                final enabled = value.text.trim().isNotEmpty && !_sending;
                return Material(
                  color: enabled ? _brand : const Color(0xFFD8E0EF),
                  borderRadius: BorderRadius.circular(15),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: enabled ? _sendMessage : null,
                    child: SizedBox(
                      height: 48,
                      width: 49,
                      child: _sending
                          ? const Padding(
                              padding: EdgeInsets.all(14),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 21,
                            ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnavailable() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: _muted, size: 52),
            const SizedBox(height: 13),
            Text(
              'Unable to load conversation',
              style: style16Bold().copyWith(color: _ink),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: _id == null ? null : () => _loadConversation(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
