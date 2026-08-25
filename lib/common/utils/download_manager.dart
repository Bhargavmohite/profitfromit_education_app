import 'dart:io';

import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/common/enums/error_enum.dart';
import 'package:webinar/locator.dart';

import '../data/app_data.dart';
import '../data/app_language.dart';
import 'constants.dart';

class DownloadManager {
  static List<FileSystemEntity> files = [];

  static Future<void> download(String url, Function(int progress) onDownlaod, {CancelToken? cancelToken, String? name, Function? onLoadAtLocal, bool isOpen = true}) async {
    PermissionStatus res = await Permission.storage.request();
    PermissionStatus res2 = await Permission.photos.request();
    if (res.isGranted || res2.isGranted) {
      String directory = (await getApplicationSupportDirectory()).path;
      if (!(await findFile(directory, name ?? url.split('/').last, onLoadAtLocal: onLoadAtLocal))) {
        String token = await AppData.getAccessToken();
        Map<String, String> headers = {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          'x-api-key': Constants.apiKey,
          'x-locale': locator<AppLanguage>().currentLanguage.toLowerCase(),
        };

        try {
          await locator<Dio>().download(url, '$directory/${name ?? url.split('/').last}', onReceiveProgress: (count, total) {
            onDownlaod((count / total * 100).toInt());
          }, cancelToken: cancelToken, options: Options(followRedirects: true, headers: headers)).then((value) {
            if (value.statusCode == 200) {
              if (navigatorKey.currentContext!.mounted) {
                backRoute(arguments: '$directory/${name ?? url.split('/').last}');
              }

              if (isOpen) {
                OpenFile.open('$directory/${name ?? url.split('/').last}');
              }
            }
          });
        } on DioException catch (e) {
          showSnackBar(ErrorEnum.error, e.message);
        }
      }
    }
  }

  static Future<bool> findFile(String directory, String name, {Function? onLoadAtLocal, bool isOpen = true}) async {
    bool state = false;
    files = Directory(directory).listSync().toList();
    for (var i = 0; i < files.length; i++) {
      if (files[i].path.contains(name)) {
        if (onLoadAtLocal != null) {
          onLoadAtLocal();
        }
        if (isOpen) {
          OpenFile.open(files[i].path);
        }
        return true;
      }
    }
    return state;
  }
}


// import 'dart:io';
//
// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import 'package:open_file/open_file.dart';
// import 'package:path/path.dart' as path;
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:webinar/common/components.dart';
// import 'package:webinar/common/enums/error_enum.dart';
// import 'package:webinar/locator.dart';
//
// import '../data/app_data.dart';
// import '../data/app_language.dart';
// import 'constants.dart';
//
// class DownloadManager {
//   static Future<void> download(String url, Function(int progress) onDownload, {CancelToken? cancelToken, required String name, Function? onLoadAtLocal, bool isOpen = true}) async {
//     try {
//       /// =========================
//       /// ANDROID STORAGE PERMISSION
//       /// =========================
//       if (Platform.isAndroid) {
//         if (await Permission.storage.isDenied) {
//           await Permission.storage.request();
//         }
//         /// Android 11+
//         if (await Permission.manageExternalStorage.isDenied) {
//           await Permission.manageExternalStorage.request();
//         }
//       }
//       /// =========================
//       /// STORAGE DIRECTORY
//       /// =========================
//       late Directory directory;
//       if (Platform.isAndroid) {
//         /// Public Downloads Folder
//         directory = Directory("/storage/emulated/0/Download");
//       } else {
//         /// iOS Documents Folder
//         directory = await getApplicationDocumentsDirectory();
//       }
//       /// Create directory if not exists
//       if (!await directory.exists()) {
//         await directory.create(
//           recursive: true,
//         );
//       }
//       /// =========================
//       /// FILE NAME
//       /// =========================
//       String finalFileName = name.trim();
//       /// Add extension if missing
//       if (!finalFileName.contains(".")) {
//         final extension = _getExtensionFromUrl(url);
//         finalFileName = "$finalFileName$extension";
//       }
//       /// FILE PATH
//       final filePath = path.join(directory.path, finalFileName);
//       debugPrint("DOWNLOAD FILE PATH => $filePath");
//       /// =========================
//       /// CHECK LOCAL FILE
//       /// =========================
//       final file = File(filePath);
//       if (await file.exists()) {
//         debugPrint("FILE ALREADY EXISTS");
//         if (onLoadAtLocal != null) {
//           onLoadAtLocal();
//         }
//         if (isOpen) {
//           final openResult = await OpenFile.open(filePath);
//           debugPrint("OPEN RESULT => ${openResult.message}");
//         }
//         return;
//       }
//       /// =========================
//       /// AUTH TOKEN
//       /// =========================
//       final token = await AppData.getAccessToken();
//       /// =========================
//       /// HEADERS
//       /// =========================
//       final headers = {
//         "Authorization": "Bearer $token",
//         "Accept": "*/*",
//         "x-api-key": Constants.apiKey,
//         "x-locale": locator<AppLanguage>().currentLanguage.toLowerCase(),
//       };
//       /// =========================
//       /// DOWNLOAD FILE
//       /// =========================
//       final response = await locator<Dio>().download(
//         url,
//         filePath,
//         cancelToken: cancelToken,
//         options: Options(
//           headers: headers,
//           responseType: ResponseType.bytes,
//           followRedirects: true,
//           receiveTimeout: const Duration(minutes: 15),
//           sendTimeout: const Duration(minutes: 15),
//         ),
//         onReceiveProgress: (received, total) {
//           debugPrint("RECEIVED => $received");
//           debugPrint("TOTAL => $total");
//           /// Some APIs return -1
//           if (total > 0) {
//             final progress = ((received / total) * 100).toInt();
//             onDownload(progress);
//             debugPrint("PROGRESS => $progress%");
//           } else {
//             /// fallback
//             onDownload(0);
//           }
//         },
//       );
//       debugPrint("STATUS CODE => ${response.statusCode}");
//       /// =========================
//       /// VERIFY FILE
//       /// =========================
//       final downloadedFile = File(filePath);
//       if (await downloadedFile.exists()) {
//         debugPrint("FILE EXISTS => TRUE");
//         debugPrint("FILE SIZE => ${await downloadedFile.length()}");
//       }
//
//       /// =========================
//       /// SUCCESS
//       /// =========================
//       if (response.statusCode == 200) {
//         showSnackBar(ErrorEnum.success, "File downloaded successfully");
//         if (isOpen) {
//           final result = await OpenFile.open(filePath);
//           debugPrint("OPEN RESULT => ${result.message}");
//         }
//       } else {
//         showSnackBar(ErrorEnum.error, "Download failed");
//       }
//     } on DioException catch (e) {
//       debugPrint("DIO ERROR => ${e.message}");
//       debugPrint("DIO RESPONSE => ${e.response}");
//       showSnackBar(ErrorEnum.error, e.message ?? "Download failed");
//     } catch (e) {
//       debugPrint("DOWNLOAD ERROR => $e");
//       showSnackBar(ErrorEnum.error, e.toString());
//     }
//   }
//
//   /// =========================
//   /// FILE EXTENSION FALLBACK
//   /// =========================
//   static String _getExtensionFromUrl(String url) {
//     final lower = url.toLowerCase();
//     if (lower.contains(".pdf")) {
//       return ".pdf";
//     }
//     if (lower.contains(".png")) {
//       return ".png";
//     }
//     if (lower.contains(".jpg")) {
//       return ".jpg";
//     }
//     if (lower.contains(".jpeg")) {
//       return ".jpeg";
//     }
//     if (lower.contains(".doc")) {
//       return ".doc";
//     }
//     if (lower.contains(".docx")) {
//       return ".docx";
//     }
//     if (lower.contains(".xls")) {
//       return ".xls";
//     }
//     if (lower.contains(".xlsx")) {
//       return ".xlsx";
//     }
//     if (lower.contains(".ppt")) {
//       return ".ppt";
//     }
//     if (lower.contains(".pptx")) {
//       return ".pptx";
//     }
//     if (lower.contains(".zip")) {
//       return ".zip";
//     }
//     if (lower.contains(".mp4")) {
//       return ".mp4";
//     }
//     return ".file";
//   }
// }