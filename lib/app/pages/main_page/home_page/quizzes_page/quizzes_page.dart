import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:webinar/app/models/content_model.dart';
import 'package:webinar/app/models/list_quiz_model.dart';
import 'package:webinar/app/models/note_model.dart';
import 'package:webinar/app/models/single_content_model.dart';
import 'package:webinar/app/pages/main_page/home_page/quizzes_page/quiz_info_page.dart';
import 'package:webinar/app/services/guest_service/course_service.dart';
import 'package:webinar/app/services/user_service/personal_note_service.dart';
import 'package:webinar/app/widgets/main_widget/quizzes_widget/quizzes_widget.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/common/utils/date_formater.dart';
import 'package:webinar/config/assets.dart';

import '../../../../../locator.dart';
import '../../../../models/quize_model.dart';
import '../../../../providers/user_provider.dart';
import '../../../../services/user_service/quiz_service.dart';

class QuizzesPage extends StatefulWidget {
  static const String pageName = '/quizzes';
  const QuizzesPage({super.key});

  @override
  State<QuizzesPage> createState() => _QuizzesPageState();
}

class _QuizzesPageState extends State<QuizzesPage> with TickerProviderStateMixin{

  late TabController tabController;

  List<QuizModel> myResults = [];
  bool isLoadingMyResults=false;

  List<Quiz> notParticipated = [];
  bool isLoadingNotParticipated=false;
  
  List<QuizModel> studentResults = [];
  bool isLoadingStudentResults=false;
  
  List<ListQuizModel> listQuiz = [];
  bool isLoadingListQuiz=false;

  String tag = "_QuizzesPageState";

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

  List<ContentItem> contentList = [];
  late int contentListIndex;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: locator<UserProvider>().profile?.roleName != 'user' ? 4 : 2, vsync: this);
    getData();
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
      debugPrint("$tag content ========> ${content?.toJson()}");
      debugPrint("$tag previousContentLink ========> $previousContentLink");

      Future.wait([getData2(), getPreviousData(), getNote()]).then((value) {
        if (previousContentData != null) {
          if (singleContentData?.checkPreviousParts == 1 && (!(previousContentData?.authHasRead ?? true) || !(previousContentData?.passed ?? true) || (previousContentData?.assignmentStatus != 'passed'))) {
            isDripContent = true;
          }
        }
        if(!mounted) return;
        setState(() {
          isLoading = false;
        });
      });
    });
  }

  getData() async {
    
    isLoadingMyResults = true;
    isLoadingNotParticipated = true;

    QuizService.getMyResults().then((value) {
      myResults = value;
      isLoadingMyResults = false;
      if(!mounted) return;
      setState(() {});
    });

    QuizService.getNotParticipated().then((value) {
      notParticipated = value;
      isLoadingNotParticipated = false;
      if(!mounted) return;
      setState(() {});
    });



    if(locator<UserProvider>().profile?.roleName != 'user'){

      isLoadingStudentResults = true;
      QuizService.getStudentResults().then((value) {
        studentResults = value;
        isLoadingStudentResults = false;
        setState(() {});
      });

      
      isLoadingListQuiz = true;
      QuizService.getList().then((value) {
        listQuiz = value;
        isLoadingListQuiz = false;
        setState(() {});
      });


    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    // AppData.getAccessToken().then((value) {
    //   print(value);
    // });

    return directionality(
      child: Scaffold(

        appBar: appbar(title: appText.quizzes),

        body: Column(
          children: [

            space(6),

            tabBar((p0) {}, tabController, [
              Tab(text: appText.myResults, height: 32),
              Tab(text: appText.notParticipated, height: 32),

              if(locator<UserProvider>().profile?.roleName != 'user')...{
                Tab(text: appText.studentResults, height: 32),
                Tab(text: appText.list, height: 32),
              }
            ]),

            space(6),

            Expanded(
              child: TabBarView(
                controller: tabController,
                physics: const BouncingScrollPhysics(),
                children: [

                  isLoadingMyResults
              ? loading()
              : myResults.isEmpty
                ? emptyState(AppAssets.bioEmptyStateSvg, appText.noResults, appText.youHaveNoQuizResults)
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: padding(),

                    child: Column(
                      children: [

                        space(12),

                        ...List.generate(myResults.length, (index) {
                          return QuizzesWidget.item(
                            myResults[index].quiz!, 
                            () async {
                              await nextRoute(QuizInfoPage.pageName, arguments: [myResults[index].quiz!, myResults[index].status, myResults[index].usergrade, 'MyResults']);

                              getData();
                            },
                            status: myResults[index].status,
                            userGrade: '${myResults[index].usergrade}/${myResults[index].quiz?.totalmark}'
                          );
                        }),
                      ],
                    ),
                  ),


                  isLoadingNotParticipated
                ? loading()
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: padding(),

                    child: Column(
                      children: [

                        space(12),

                        ...List.generate(notParticipated.length, (index) {
                          return QuizzesWidget.item(
                            notParticipated[index], 
                            () async {
                              await nextRoute(QuizInfoPage.pageName, arguments: [notParticipated[index], notParticipated[index].status, null, 'NotParticipated']);

                              getData();
                            }, 
                            isMyResult: false,
                            isShowQuestionCount: true,
                            isShowQuizTime: true
                          );
                        }),
                      ],
                    ),
                  ),


                  if(locator<UserProvider>().profile?.roleName != 'user')...{

                    isLoadingStudentResults
                ? loading()
                : studentResults.isEmpty
                  ? emptyState(AppAssets.bioEmptyStateSvg, appText.noStudentResults, appText.noStudentResultsDesc)
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: padding(),

                      child: Column(
                        children: [

                          space(12),

                          ...List.generate(studentResults.length, (index) {
                            return userCard(
                              studentResults[index].user?.avatar ?? '', 
                              studentResults[index].user?.fullName ?? '', 
                              studentResults[index].webinar?.title ?? '', 
                              timeStampToDate((studentResults[index].createdat ?? 0) * 1000), 
                              '', 
                              studentResults[index].status ?? '', 
                              () async {
                                await nextRoute(QuizInfoPage.pageName, arguments: [studentResults[index], studentResults[index].status, studentResults[index].usergrade, 'StudentResults']);

                                getData();
                              },
                              gradeStatus: studentResults[index].status,
                              userGrade: '${studentResults[index].usergrade}/${studentResults[index].quiz?.totalmark}'
                            );
                          }),
                        ],
                      ),
                    ),
                    
                    
                    isLoadingListQuiz
                ? loading()
                : listQuiz.isEmpty
                  ? const SizedBox.shrink() // emptyState(AppAssets.bioEmptyStateSvg, appText.noContentForShow, appText.noStudentResultsDesc)
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: padding(),

                      child: Column(
                        children: [

                          space(12),

                          ...List.generate(listQuiz.length, (index) {
                            return QuizzesWidget.listItem(
                              listQuiz[index], 
                              (){
                                nextRoute(
                                  QuizInfoPage.pageName, 
                                  arguments: [
                                    Quiz.fromJson(listQuiz[index].toJson())
                                      ..title = listQuiz[index].getTitle()
                                      ..questioncount = listQuiz[index].questionCount
                                      ..avrage = listQuiz[index].avrage
                                      ..studentcount = listQuiz[index].studentCount,
                                       
                                    listQuiz[index].status, 
                                    null, 
                                    'List'
                                  ]
                                );

                              }, 
                            );
                          }),
                        ],
                      ),
                    ),
                    

                  }
                ]
              )
            ),

          ],
        ),

      )
    );
  }

  void checkNextVideo() {
    if (contentListIndex < contentList.length - 1) {
      setState(() {
        previousContentLink = contentList[contentListIndex].link;
        contentListIndex++;
        content = contentList[contentListIndex];
        courseId = contentList[contentListIndex].id;
      });

      Future.wait([getData2(), getPreviousData(), getNote()]).then((value) {
        if (previousContentData != null) {
          if (singleContentData?.checkPreviousParts == 1 && (!(previousContentData?.authHasRead ?? true) || !(previousContentData?.passed ?? true) || (previousContentData?.assignmentStatus != 'passed'))) {
            isDripContent = true;
          }
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

  Future getNote() async {
    note = await PersonalNoteService.getNote(content!.id!);
    if(!mounted) return;
    setState(() {});
  }

  Future getData2() async {
    setState(() {
      isLoading = true;
    });
    singleContentData = await CourseService.getSingleContent(content?.link ?? '');

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
}