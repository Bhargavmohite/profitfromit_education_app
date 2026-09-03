// ignore_for_file: body_might_complete_normally_nullable, dead_null_aware_expression, depend_on_referenced_packages, unused_import

import 'dart:io';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:html/parser.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webinar/app/models/content_model.dart';
import 'package:webinar/app/models/note_model.dart';
import 'package:webinar/app/models/single_content_model.dart';
import 'package:webinar/app/pages/main_page/home_page/single_course_page/single_content_page/pdf_viewer_page.dart';
import 'package:webinar/app/pages/main_page/home_page/single_course_page/single_content_page/web_view_page.dart';
import 'package:webinar/app/services/guest_service/course_service.dart';
import 'package:webinar/app/services/user_service/personal_note_service.dart';
import 'package:webinar/app/widgets/main_widget/home_widget/single_course_widget/pod_video_player.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/common/data/api_public_data.dart';
import 'package:webinar/common/data/app_data.dart';
import 'package:webinar/common/data/app_language.dart';
import 'package:webinar/common/enums/error_enum.dart';
import 'package:webinar/common/html_image_loading_widget.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/common/utils/constants.dart';
import 'package:webinar/config/colors.dart';
import 'package:webinar/config/styles.dart';
import 'package:webinar/locator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:webinar/app/widgets/main_widget/home_widget/single_course_widget/vimeo_video_player_widget.dart';

import '../../../../../../common/utils/date_formater.dart';
import '../../../../../../common/utils/utils.dart';
import '../../../../../../config/assets.dart';
import '../../../../../widgets/main_widget/home_widget/single_course_widget/course_video_player.dart';
import '../../../../../widgets/main_widget/home_widget/single_course_widget/single_course_widget.dart';

class SingleContentPage extends StatefulWidget {
  static const String pageName = '/single-content';

  const SingleContentPage({super.key});

  @override
  State<SingleContentPage> createState() => _SingleContentPageState();
}

class _SingleContentPageState extends State<SingleContentPage> {

  String tag = "_SingleContentPageState";

  List<String> videoFormats = ['mp4', 'mkv', 'mov', 'wmv', 'avi', 'webm', 'video'];

  NoteModel? note;

  ContentItem? content;
  SingleContentModel? singleContentData;
  int? courseId;

  bool isLoading = true;
  bool isSpeakLoading = false;
  bool isPlayingText = false;

  FlutterTts flutterTts = FlutterTts();

  String? previousContentLink;
  SingleContentModel? previousContentData;
  bool isDripContent = false;

  YoutubePlayerController? _playerController;

  List<ContentItem> contentList = [];
  late int contentListIndex;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      content = (ModalRoute.of(context)!.settings.arguments as List)[0];
      courseId = (ModalRoute.of(context)!.settings.arguments as List)[1];
      try {
        previousContentLink = (ModalRoute.of(context)!.settings.arguments as List)[2];
      } catch (_) {}
      contentListIndex = (ModalRoute.of(context)!.settings.arguments as List)[3];
      try {
        contentList = (ModalRoute.of(context)!.settings.arguments as List)[4];
      } catch(_) {
        debugPrint("$tag error in getting list of all content data ========> ");
      }
      debugPrint("$tag course id ========> ${courseId.toString()}");
      debugPrint("$tag content ========> ${content?.toJson()}");
      debugPrint("$tag previousContentLink ========> $previousContentLink");

      Future.wait([getData(), getPreviousData(), getNote()]).then((value) {
        if (previousContentData != null) {
          if (singleContentData?.checkPreviousParts == 1 && (!(previousContentData?.authHasRead ?? true) || !(previousContentData?.passed ?? true) || (previousContentData?.assignmentStatus != 'passed'))) {
            isDripContent = true;
          }
        }

        if (singleContentData?.storage == 'youtube') {
          initYouTubePlayer();
        }
        setState(() {
          isLoading = false;
        });
      });
    });
  }

  Future getNote() async {
    note = await PersonalNoteService.getNote(content!.id!);
    setState(() {});
    debugPrint("$tag course id ========> ${courseId.toString()}");
    debugPrint("$tag content ========> ${content?.toJson()}");
  }

  Future getData() async {
    setState(() {
      isLoading = true;
    });
    singleContentData = await CourseService.getSingleContent(content?.link ?? '');
    //debugPrint("content link ==============> ${content?.link}");
    // debugPrint("singleContentData content ==============> ${singleContentData!.content}");

    /*if(singleContentData!.content!.contains("img")) {
      debugPrint("singleContentData content ==============> have image");
    } else {
      debugPrint("singleContentData content ==============> do not have image");
    }*/

    if (content?.type == 'text_lesson') {
      // flutterTts.setInitHandler(() {});
      if (Platform.isIOS) {
        flutterTts.setSharedInstance(true);
      }
    }
  }

  Future getPreviousData() async {
    if (previousContentLink == null) {
      return;
    }

    previousContentData = await CourseService.getSingleContent(previousContentLink!);
  }

  void initYouTubePlayer() {
    String videoId = YoutubePlayer.convertUrlToId(singleContentData!.file.toString()) ?? "";
    _playerController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // print(content?.type);
    // print(content?.storage ?? '');
    // print(content?.downloadable == 1 || ( content?.type == 'file' && ([ 'upload_archive', 'external_link', 'google_drive', 'iframe', 'secure_host', 'upload' ].contains(content?.storage ?? '')) ));
    return directionality(
        child: youTubePlayerWidget(),
    );
  }

  Widget pageButton({bool showViewButton = true}) {
    return AnimatedPositioned(
        duration: const Duration(milliseconds: 500),
        bottom: 0,
        child: Container(
          width: getSize().width,
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [boxShadow(Colors.black.withValues(alpha: .1), blur: 15, y: -3)], borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
          child: content?.type == 'file'
              ? Row(
                  children: [
                    // download
                    if (content?.downloadable == 1) ...{
                      Expanded(
                        child: button(
                            onTap: () {
                              downloadSheet('${Constants.baseUrl}files/${content?.id}/download', singleContentData?.file?.split('/').last ?? '${singleContentData?.title}.${singleContentData?.fileType}');
                            },
                            width: getSize().width,
                            height: 52,
                            text: appText.download,
                            bgColor: green77(),
                            textColor: Colors.white),
                      ),
                      if (showViewButton) ...{
                        space(0, width: 16),
                      }
                    },

                    // view
                    if (showViewButton) ...{
                      Expanded(
                        child: button(
                            onTap: () {
                              // print(singleContentData?.storage);
                              // print(singleContentData?.fileType);
                              // print(singleContentData?.downloadLink);

                              if (singleContentData?.fileType == 'pdf') {
                                nextRoute(PdfViewerPage.pageName, arguments: [
                                  singleContentData?.file,
                                  singleContentData?.title,
                                ]);
                                return;
                              }

                              // String url = '${Constants.baseUrl}panel/files/${singleContentData?.id}';
                              // print('${Constants.baseUrl}panel/files/${singleContentData?.id}');

                              switch (singleContentData?.storage ?? '') {
                                case 'upload':
                                case 'upload_archive':
                                case 'external_link':
                                case 'google_drive':
                                case 'iframe':
                                case 'secure_host':
                                  nextRoute(WebViewPage.pageName, arguments: [singleContentData?.file, singleContentData?.title, true, LoadRequestMethod.get]);
                                  return;

                                case 's3':
                                  {
                                    if (singleContentData?.fileType != 'video') {
                                      nextRoute(WebViewPage.pageName, arguments: [
                                        singleContentData?.file,
                                        singleContentData?.title,
                                        singleContentData?.fileType == 'pdf' ? false : true, // if pdf file. Authorization token not be sent
                                        LoadRequestMethod.get
                                      ]);
                                      return;
                                    }
                                  }

                                default:
                              }

                              showSnackBar(ErrorEnum.alert, appText.noContentForShow);
                            },
                            width: getSize().width,
                            height: 52,
                            text: buttonText(singleContentData?.storage ?? '', singleContentData?.fileType ?? ''),
                            bgColor: green77(),
                            textColor: Colors.white),
                      ),
                    }
                  ],
                )
              : content?.type == 'text_lesson'
                  ? Row(
                      children: [
                        Expanded(
                            child: button(
                                onTap: () {
                                  backRoute();
                                },
                                width: getSize().width,
                                height: 52,
                                text: appText.back,
                                bgColor: green77(),
                                textColor: Colors.white)),
                        space(0, width: 14),
                        GestureDetector(
                          onTap: () async {
                            if (content?.type == 'text_lesson') {
                              if (isPlayingText) {
                                flutterTts.pause();

                                setState(() {
                                  isPlayingText = false;
                                });
                              } else {
                                setState(() {
                                  isSpeakLoading = true;
                                });

                                var res = await flutterTts.speak(parse(singleContentData?.content ?? '').documentElement?.text ?? '');

                                setState(() {
                                  isPlayingText = res == 1;
                                  isSpeakLoading = false;
                                });
                              }
                            }
                          },
                          child: Container(
                            width: 55,
                            height: 52,
                            decoration: BoxDecoration(
                              color: green77(),
                              borderRadius: borderRadius(),
                            ),
                            child: isSpeakLoading
                                ? loading(color: Colors.white)
                                : Icon(
                                    isPlayingText ? Icons.pause : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                  ),
                          ),
                        )
                      ],
                    )
                  : Row(
                      // session
                      children: [
                        // join
                        Expanded(
                            child: button(
                                onTap: () async {
                                  if (!(singleContentData?.isFinished ?? false)) {
                                    if (singleContentData?.sessionApi == 'agora') {
                                      nextRoute(WebViewPage.pageName, arguments: ['${Constants.baseUrl}panel/webinars/session/agora/${singleContentData?.id ?? ''}', singleContentData?.title ?? '', true, LoadRequestMethod.get]);
                                    } else {
                                      String token = await AppData.getAccessToken();

                                      Map<String, String> headers = {
                                        "Authorization": "Bearer $token",
                                        "Content-Type": "application/json",
                                        'Accept': 'application/json',
                                        'x-api-key': Constants.apiKey,
                                        'x-locale': locator<AppLanguage>().currentLanguage.toLowerCase(),
                                      };

                                      launchUrlString(singleContentData?.link ?? '',
                                          webViewConfiguration: WebViewConfiguration(
                                            headers: headers,
                                          ),
                                          mode: LaunchMode.externalApplication);
                                    }
                                  }
                                },
                                width: getSize().width,
                                height: 52,
                                text: appText.join,
                                bgColor: (singleContentData?.isFinished ?? false) ? greyCF.withValues(alpha: .8) : green77(),
                                textColor: Colors.white)),

                        space(0, width: 16),

                        // join
                        Expanded(
                            child: button(
                          onTap: () {
                            try {
                              if (!(singleContentData?.isFinished ?? false)) {
                                DateTime start = DateTime(
                                  DateTime.fromMillisecondsSinceEpoch((singleContentData?.date ?? 0) * 1000, isUtc: true).year,
                                  DateTime.fromMillisecondsSinceEpoch((singleContentData?.date ?? 0) * 1000, isUtc: true).month,
                                  DateTime.fromMillisecondsSinceEpoch((singleContentData?.date ?? 0) * 1000, isUtc: true).day,
                                  DateTime.fromMillisecondsSinceEpoch((singleContentData?.date ?? 0) * 1000, isUtc: true).hour,
                                  DateTime.fromMillisecondsSinceEpoch((singleContentData?.date ?? 0) * 1000, isUtc: true).minute,
                                );
                                DateTime end = DateTime(
                                  DateTime.fromMillisecondsSinceEpoch((singleContentData?.date ?? 0) * 1000, isUtc: true).year,
                                  DateTime.fromMillisecondsSinceEpoch((singleContentData?.date ?? 0) * 1000, isUtc: true).month,
                                  DateTime.fromMillisecondsSinceEpoch((singleContentData?.date ?? 0) * 1000, isUtc: true).day,
                                  DateTime.fromMillisecondsSinceEpoch((singleContentData?.date ?? 0) * 1000, isUtc: true).hour,
                                  (DateTime.fromMillisecondsSinceEpoch((singleContentData?.date ?? 0) * 1000, isUtc: true).minute + (singleContentData?.duration ?? 0)),
                                );

                                final Event event = Event(
                                  title: singleContentData?.title ?? '',
                                  description: appText.webinar,
                                  startDate: start,
                                  endDate: end,
                                  iosParams: const IOSParams(),
                                  androidParams: const AndroidParams(),
                                );

                                Add2Calendar.addEvent2Cal(event);
                              }
                            } catch (_) {}
                          },
                          width: getSize().width,
                          height: 52,
                          text: appText.addToCalendar,
                          bgColor: Colors.white,
                          textColor: (singleContentData?.isFinished ?? false) ? greyCF : green77(),
                          borderColor: (singleContentData?.isFinished ?? false) ? greyCF.withValues(alpha: .8) : green77(),
                        )),
                      ],
                    ),
        ));
  }

  String buttonText(String storage, String fileType) {
    switch (storage) {
      case 'upload_archive':
        return appText.view;

      case 'upload':
        return appText.view;

      default:
        return appText.view;
    }
  }

  Widget youTubePlayerWidget() {
    if(isLoading) {
      return Container(
        decoration: BoxDecoration(
          color: greyFA,
        ),
        child: Center(child: loading()),
      );
    } else if (singleContentData?.storage == 'youtube') {
      if (_playerController == null) {
        return Container(
          decoration: BoxDecoration(
            color: greyFA,
          ),
          child: Center(child: loading()),
        );
      } else {
        return YoutubePlayerBuilder(
          player: YoutubePlayer(
            controller: _playerController!,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.blueAccent,
          ),
          builder: (context, player) {
            return  Scaffold(
              appBar: appbar(
                title: appText.courseDetails,
                rightIcon: AppAssets.shareSvg,
                onTapRightIcon: () {
                  debugPrint("$tag Single course id ========> ${courseId.toString()}");
                  debugPrint("$tag Single content ========> ${content?.toJson()}");
                  debugPrint("$tag Single Content Data =============> ${singleContentData!.toJson()}");

                  String link = "https://profitfromit.co.in/course/$courseId/lesson/${singleContentData!.id}";
                  if(Platform.isIOS) {
                    shareBlog(
                      context,
                      singleContentData!.title ?? '',
                      link,
                    );
                  } else {
                    String shareMsg = "${singleContentData!.title}\n\n$link";
                    Share.share(shareMsg ?? '');
                  }
                },
              ),
              body: isLoading
                  ? loading()
                  : Stack(
                children: [
                  // details
                  Positioned.fill(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: padding(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          space(20),
                          Text(
                            singleContentData?.title ?? '',
                            style: style16Bold(),
                          ),

                          if (isDripContent) ...{
                            space(20),
                            Container(
                              width: getSize().width,
                              padding: padding(vertical: 20, horizontal: 10),
                              decoration: BoxDecoration(borderRadius: borderRadius(), border: Border.all(color: greyE7)),
                              child: Column(
                                children: [
                                  SvgPicture.asset(AppAssets.accessDeniedSvg),
                                  Text(
                                    appText.accessDenied,
                                    style: style16Bold().copyWith(color: grey33),
                                  ),
                                  space(8),
                                  Text(
                                    appText.accessDeniedDesc,
                                    style: style14Regular().copyWith(color: greyA5),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          } else ...{
                            if ((singleContentData?.storage == 'upload' || singleContentData?.storage == 'external_link' || singleContentData?.storage == 's3') && videoFormats.contains(singleContentData?.fileType?.toLowerCase())) ...{
                              space(20),
                              CourseVideoPlayer(singleContentData?.file ?? '', '', Constants.contentRouteObserver),
                            },
                            if (singleContentData?.storage == 'vimeo' || singleContentData?.storage == 'youtube') ...{

                              player

                              // youTubePlayerWidget()

                              // PodVideoPlayerDev(
                              //   singleContentData?.file ?? '',
                              //   singleContentData?.storage ?? '',
                              //   Constants.contentRouteObserver
                              // )
                            },
                          },

                          space(20),

                          // info
                          Container(
                            padding: padding(),
                            width: getSize().width,
                            child: Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              runAlignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              runSpacing: 21,
                              children: [
                                SingleCourseWidget.courseStatus(
                                    appText.type,
                                    content?.type == 'file'
                                        ? singleContentData?.fileType?.toString().toUpperCase() ?? ''
                                        : content?.type == 'session'
                                        ? singleContentData?.sessionApi?.toString() ?? ''
                                        : appText.text_lesson,
                                    AppAssets.documentSvg,
                                    width: getSize().width * .38),

                                if (singleContentData?.date != null) ...{
                                  SingleCourseWidget.courseStatus(appText.startDate, timeStampToDate((singleContentData?.date ?? 0) * 1000).toString(), AppAssets.calendarSvg, width: getSize().width * .38),
                                },

                                if (singleContentData?.volume != null) ...{
                                  SingleCourseWidget.courseStatus(appText.volume, singleContentData?.volume ?? '', AppAssets.paperDownloadSvg, width: getSize().width * .38),
                                },

                                if (singleContentData?.createdAt != null) ...{
                                  SingleCourseWidget.courseStatus(appText.publishDate, timeStampToDate((singleContentData?.createdAt ?? 0) * 1000).toString(), AppAssets.calendarSvg, width: getSize().width * .38),
                                },

                                if (singleContentData?.duration != null) ...{
                                  SingleCourseWidget.courseStatus(appText.duration, '${(singleContentData?.duration ?? 0)} ${appText.min}', AppAssets.timeSvg, width: getSize().width * .38),
                                },

                                SingleCourseWidget.courseStatus(appText.downloadable, content?.downloadable == 1 ? appText.yes : appText.no, AppAssets.paperDownloadSvg, width: getSize().width * .38),

                                // SingleCourseWidget.courseStatus(
                                //   appText.type,
                                //   courseData.type ?? '',
                                //   AppAssets.moreSvg,
                                //   width: getSize().width * .38
                                // ),

                                // SingleCourseWidget.courseStatus(
                                //   appText.status,
                                //   courseData.status ?? '',
                                //   AppAssets.moreSvg,
                                //   width: getSize().width * .38
                                // ),
                              ],
                            ),
                          ),

                          if (content?.type == 'text_lesson') ...{
                            space(20),
                            HtmlWidget(
                              singleContentData?.content ?? '',
                              customStylesBuilder: (element) {
                                if (element.localName == 'img') {
                                  return {
                                    'max-width': '100%',
                                    'height': 'auto',
                                  };
                                }
                                return null;
                              },
                              // factoryBuilder: () => CustomWidgetFactory(),
                              // textStyle: style14Regular().copyWith(color: greyA5),
                              onErrorBuilder: (context, element, error) {
                                debugPrint("element ==============> $element");
                                debugPrint("error ==============> $error");
                              },
                            ),
                          } else ...{
                            space(20),
                            Text(
                              singleContentData?.description ?? '',
                              style: style14Regular().copyWith(color: greyA5),
                            ),
                          },

                          space(20),

                          if (!isDripContent) ...{
                            // toggle
                            SizedBox(
                              width: getSize().width,
                              child: switchButton(appText.iHaveReadThisLesson, content?.authHasRead ?? false, (value) {
                                setState(() {
                                  content?.authHasRead = value;
                                });

                                CourseService.toggle(
                                    courseId!,
                                    content!.type == 'text_lesson'
                                        ? 'text_lesson_id'
                                        : content!.type == 'file'
                                        ? 'file_id'
                                        : 'session_id',
                                    singleContentData!.id.toString(),
                                    value);
                              }),
                            ),

                            space(20),
                          },

                          if (PublicData.apiConfigData?['course_notes_status'] == '1') ...{
                            // add note
                            Row(
                              children: [
                                // add a note
                                Expanded(
                                    child: button(
                                        onTap: () async {
                                          if (note == null) {
                                            bool? res = await SingleCourseWidget.showAddNoteDialog(courseId!, singleContentData!.id!, text: note?.note);

                                            if (res ?? false) {
                                              getNote();
                                            }
                                          } else {
                                            SingleCourseWidget.viewNoteDialog(
                                              courseId!,
                                              singleContentData!.id!,
                                              note?.note ?? '',
                                                  () async {
                                                // onTapEdit
                                                backRoute();

                                                bool? res = await SingleCourseWidget.showAddNoteDialog(courseId!, singleContentData!.id!, text: note?.note);

                                                if (res ?? false) {
                                                  getNote();
                                                }
                                              },
                                                  () {
                                                // onTapAttachment
                                                backRoute();

                                                SingleCourseWidget.showNoteAttachmentDialog(() {
                                                  // onTapRemove
                                                }, () {
                                                  // onTapDownload
                                                  downloadSheet(note!.attachment!, note!.attachment!.split('/').last);
                                                }, note?.attachment != null // hasFileForDownload
                                                );
                                              },
                                              note?.attachment != null,
                                            );
                                          }
                                        },
                                        width: getSize().width,
                                        height: 52,
                                        text: note == null ? appText.addANote : appText.viewNote,
                                        bgColor: Colors.white,
                                        textColor: green77(),
                                        borderColor: green77(),
                                        raduis: 15)),

                                if (note != null) ...{
                                  space(0, width: 16),
                                  button(
                                      onTap: () {
                                        PersonalNoteService.delete(note!.id!);
                                        note = null;
                                        setState(() {});
                                      },
                                      width: 52,
                                      height: 52,
                                      text: '',
                                      bgColor: Colors.transparent,
                                      textColor: Colors.white,
                                      borderColor: red49,
                                      iconPath: AppAssets.delete2Svg,
                                      iconColor: red49,
                                      raduis: 20)
                                }
                              ],
                            ),
                          },

                          // attachments
                          if (singleContentData?.attachments?.isNotEmpty ?? false) ...{
                            SizedBox(
                              width: getSize().width,
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Row(
                                  children: [
                                    ...List.generate(singleContentData?.attachments?.length ?? 0, (index) {
                                      return horizontalChapterItem(
                                        green50,
                                        AppAssets.paperDownloadSvg,
                                        singleContentData?.attachments?[index].title ?? '',
                                        singleContentData?.attachments?[index].volume ?? '',
                                            () {
                                          downloadSheet('${Constants.baseUrl}files/${content?.id}/download', singleContentData?.attachments?[index].file?.split('/').last ?? '');
                                        },
                                      );
                                    })
                                  ],
                                ),
                              ),
                            )
                          },

                          if (contentListIndex < contentList.length - 1) ...{
                            button(
                              onTap: () {
                                checkNextVideo();
                              },
                              width: getSize().width,
                              height: 52,
                              text: appText.next,
                              bgColor: green77(),
                              textColor: Colors.white,
                              raduis: 15,
                            ),
                            space(20),
                          },

                          space(200),
                        ],
                      ),
                    ),
                  ),

                  // button
                  if (!isDripContent) ...{
                    if (content?.fileType == 'pdf') ...{
                      pageButton(),
                    } else if (content?.downloadable == 1 ||
                        (content?.type == 'file' &&
                            ([
                              'upload_archive',
                              'external_link',
                              'google_drive',
                              'iframe',
                              'secure_host',
                            ].contains(content?.storage ?? '')))) ...{
                      pageButton(
                          showViewButton: ([
                            'upload_archive',
                            'external_link',
                            'google_drive',
                            'iframe',
                            'secure_host',
                          ].contains(content?.storage ?? '')))
                    } else if (content?.type != 'file') ...{
                      pageButton(),
                    }
                  }
                ],
              ),
            );
          },);
      }
    } else {
      return  Scaffold(
        appBar: appbar(
          title: appText.courseDetails,
          rightIcon: AppAssets.shareSvg,
          onTapRightIcon: () {
            debugPrint("$tag Single course id ========> ${courseId.toString()}");
            debugPrint("$tag Single content ========> ${content?.toJson()}");
            debugPrint("$tag Single Content Data =============> ${singleContentData!.toJson()}");
            String link = "https://profitfromit.co.in/course/$courseId/lesson/${singleContentData!.id}";
            if(Platform.isIOS) {
              shareBlog(
                context,
                singleContentData!.title ?? '',
                link,
              );
            } else {
              String shareMsg = "${singleContentData!.title}\n\n$link";
              Share.share(shareMsg ?? '');
            }
          },
        ),
        body: isLoading
            ? loading()
            : Stack(
          children: [
            // details
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: padding(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    space(20),
                    Text(
                      singleContentData?.title ?? '',
                      style: style16Bold(),
                    ),

                    if (isDripContent) ...{
                      space(20),
                      Container(
                        width: getSize().width,
                        padding: padding(vertical: 20, horizontal: 10),
                        decoration: BoxDecoration(borderRadius: borderRadius(), border: Border.all(color: greyE7)),
                        child: Column(
                          children: [
                            SvgPicture.asset(AppAssets.accessDeniedSvg),
                            Text(
                              appText.accessDenied,
                              style: style16Bold().copyWith(color: grey33),
                            ),
                            space(8),
                            Text(
                              appText.accessDeniedDesc,
                              style: style14Regular().copyWith(color: greyA5),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    } else ...{
                      if ((singleContentData?.storage == 'upload' || singleContentData?.storage == 'external_link' || singleContentData?.storage == 's3') && videoFormats.contains(singleContentData?.fileType?.toLowerCase())) ...{
                        space(20),
                        CourseVideoPlayer(singleContentData?.file ?? '', '', Constants.contentRouteObserver),
                      },
                      if (singleContentData?.storage == 'vimeo') ...{
                              VimeoVideoPlayerWidget(
                                singleContentData?.file ?? '',
                              ),
                            },
                    },

                    space(20),
                    // info
                    Container(
                      padding: padding(),
                      width: getSize().width,
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        runAlignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        runSpacing: 21,
                        children: [
                          SingleCourseWidget.courseStatus(
                              appText.type,
                              content?.type == 'file'
                                  ? singleContentData?.fileType?.toString().toUpperCase() ?? ''
                                  : content?.type == 'session'
                                  ? singleContentData?.sessionApi?.toString() ?? ''
                                  : appText.text_lesson,
                              AppAssets.documentSvg,
                              width: getSize().width * .38),

                          if (singleContentData?.date != null) ...{
                            SingleCourseWidget.courseStatus(appText.startDate, timeStampToDate((singleContentData?.date ?? 0) * 1000).toString(), AppAssets.calendarSvg, width: getSize().width * .38),
                          },

                          if (singleContentData?.volume != null) ...{
                            SingleCourseWidget.courseStatus(appText.volume, singleContentData?.volume ?? '', AppAssets.paperDownloadSvg, width: getSize().width * .38),
                          },

                          if (singleContentData?.createdAt != null) ...{
                            SingleCourseWidget.courseStatus(appText.publishDate, timeStampToDate((singleContentData?.createdAt ?? 0) * 1000).toString(), AppAssets.calendarSvg, width: getSize().width * .38),
                          },

                          if (singleContentData?.duration != null) ...{
                            SingleCourseWidget.courseStatus(appText.duration, '${(singleContentData?.duration ?? 0)} ${appText.min}', AppAssets.timeSvg, width: getSize().width * .38),
                          },

                          SingleCourseWidget.courseStatus(appText.downloadable, content?.downloadable == 1 ? appText.yes : appText.no, AppAssets.paperDownloadSvg, width: getSize().width * .38),

                          // SingleCourseWidget.courseStatus(
                          //   appText.type,
                          //   courseData.type ?? '',
                          //   AppAssets.moreSvg,
                          //   width: getSize().width * .38
                          // ),

                          // SingleCourseWidget.courseStatus(
                          //   appText.status,
                          //   courseData.status ?? '',
                          //   AppAssets.moreSvg,
                          //   width: getSize().width * .38
                          // ),
                        ],
                      ),
                    ),

                    if (content?.type == 'text_lesson') ...{
                      space(20),
                      HtmlWidget(
                        singleContentData?.content ?? '',
                        customStylesBuilder: (element) {
                          if (element.localName == 'img') {
                            return {
                              'max-width': '100%',
                              'height': 'auto',
                            };
                          }
                          return null;
                        },
                        // textStyle: style14Regular().copyWith(color: greyA5),
                        onErrorBuilder: (context, element, error) {
                          debugPrint("element ==============> $element");
                          debugPrint("error ==============> $error");
                        },
                      ),
                    } else ...{
                      space(20),
                      Text(
                        singleContentData?.description ?? '',
                        style: style14Regular().copyWith(color: greyA5),
                      ),
                    },

                    space(20),

                    if (!isDripContent) ...{
                      // toggle
                      SizedBox(
                        width: getSize().width,
                        child: switchButton(appText.iHaveReadThisLesson, content?.authHasRead ?? false, (value) {
                          setState(() {
                            content?.authHasRead = value;
                          });

                          CourseService.toggle(
                              courseId!,
                              content!.type == 'text_lesson'
                                  ? 'text_lesson_id'
                                  : content!.type == 'file'
                                  ? 'file_id'
                                  : 'session_id',
                              singleContentData!.id.toString(),
                              value);
                        }),
                      ),

                      space(20),
                    },

                    if (PublicData.apiConfigData?['course_notes_status'] == '1') ...{
                      // add note
                      Row(
                        children: [
                          // add a note
                          Expanded(
                              child: button(
                                  onTap: () async {
                                    if (note == null) {
                                      bool? res = await SingleCourseWidget.showAddNoteDialog(courseId!, singleContentData!.id!, text: note?.note);

                                      if (res ?? false) {
                                        getNote();
                                      }
                                    } else {
                                      SingleCourseWidget.viewNoteDialog(
                                        courseId!,
                                        singleContentData!.id!,
                                        note?.note ?? '',
                                            () async {
                                          // onTapEdit
                                          backRoute();

                                          bool? res = await SingleCourseWidget.showAddNoteDialog(courseId!, singleContentData!.id!, text: note?.note);

                                          if (res ?? false) {
                                            getNote();
                                          }
                                        },
                                            () {
                                          // onTapAttachment
                                          backRoute();

                                          SingleCourseWidget.showNoteAttachmentDialog(() {
                                            // onTapRemove
                                          }, () {
                                            // onTapDownload
                                            downloadSheet(note!.attachment!, note!.attachment!.split('/').last);
                                          }, note?.attachment != null // hasFileForDownload
                                          );
                                        },
                                        note?.attachment != null,
                                      );
                                    }
                                  },
                                  width: getSize().width,
                                  height: 52,
                                  text: note == null ? appText.addANote : appText.viewNote,
                                  bgColor: Colors.white,
                                  textColor: green77(),
                                  borderColor: green77(),
                                  raduis: 15)),

                          if (note != null) ...{
                            space(0, width: 16),
                            button(
                                onTap: () {
                                  PersonalNoteService.delete(note!.id!);
                                  note = null;
                                  setState(() {});
                                },
                                width: 52,
                                height: 52,
                                text: '',
                                bgColor: Colors.transparent,
                                textColor: Colors.white,
                                borderColor: red49,
                                iconPath: AppAssets.delete2Svg,
                                iconColor: red49,
                                raduis: 20)
                          }
                        ],
                      ),
                    },

                    // attachments
                    if (singleContentData?.attachments?.isNotEmpty ?? false) ...{
                      SizedBox(
                        width: getSize().width,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              ...List.generate(singleContentData?.attachments?.length ?? 0, (index) {
                                return horizontalChapterItem(
                                  green50,
                                  AppAssets.paperDownloadSvg,
                                  singleContentData?.attachments?[index].title ?? '',
                                  singleContentData?.attachments?[index].volume ?? '',
                                      () {
                                    downloadSheet('${Constants.baseUrl}files/${content?.id}/download', singleContentData?.attachments?[index].file?.split('/').last ?? '');
                                  },
                                );
                              })
                            ],
                          ),
                        ),
                      )
                    },

                    if (contentListIndex < contentList.length - 1) ...{
                      button(
                        onTap: () {
                          checkNextVideo();
                        },
                        width: getSize().width,
                        height: 52,
                        text: appText.next,
                        bgColor: green77(),
                        textColor: Colors.white,
                        raduis: 15,
                      ),
                      space(20),
                    },

                    space(200),
                  ],
                ),
              ),
            ),

            // button
            if (!isDripContent) ...{
              if (content?.fileType == 'pdf') ...{
                pageButton(),
              } else if (content?.downloadable == 1 ||
                  (content?.type == 'file' &&
                      ([
                        'upload_archive',
                        'external_link',
                        'google_drive',
                        'iframe',
                        'secure_host',
                      ].contains(content?.storage ?? '')))) ...{
                pageButton(
                    showViewButton: ([
                      'upload_archive',
                      'external_link',
                      'google_drive',
                      'iframe',
                      'secure_host',
                    ].contains(content?.storage ?? '')))
              } else if (content?.type != 'file') ...{
                pageButton(),
              }
            }
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    if(_playerController != null) {
      _playerController!.dispose();
    }
    super.dispose();
  }

  @override
  void deactivate() {
    if(_playerController != null) {
      _playerController!.pause();
    }
    super.deactivate();
  }

  void checkNextVideo() {
    if (contentListIndex < contentList.length - 1) {
      setState(() {
        previousContentLink = contentList[contentListIndex].link;
        contentListIndex++;
        content = contentList[contentListIndex];
        courseId = contentList[contentListIndex].id;
      });

      Future.wait([getData(), getPreviousData(), getNote()]).then((value) {
        if (previousContentData != null) {
          if (singleContentData?.checkPreviousParts == 1 && (!(previousContentData?.authHasRead ?? true) || !(previousContentData?.passed ?? true) || (previousContentData?.assignmentStatus != 'passed'))) {
            isDripContent = true;
          }
        }

        if (singleContentData?.storage == 'youtube') {
          initYouTubePlayer();
        }
        setState(() {
          isLoading = false;
        });
      });
    } else {
      // You can also show a message or disable the button
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No more items')),
      );
    }
  }
}