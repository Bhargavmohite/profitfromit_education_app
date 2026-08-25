
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:webinar/app/pages/main_page/home_page/notification_page.dart';
import 'package:webinar/app/pages/main_page/main_page.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/data/app_data.dart';
import 'package:webinar/main.dart';

bool isFlutterLocalNotificationsInitialized = false;

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }

  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.high,
    playSound: true,
    showBadge: true,
    enableVibration: true,
  );

  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings(
    '@drawable/ic_notification'
  );
  DarwinInitializationSettings initializationSettingsDarwin = const DarwinInitializationSettings(
    defaultPresentAlert: true,
    defaultPresentSound: true,
    defaultPresentBadge: true,
    
    requestSoundPermission: true,
    requestBadgePermission: true,
  );

  InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,

    onDidReceiveNotificationResponse: (NotificationResponse details) {
      Map<String, dynamic> payload = jsonDecode(details.payload ?? '');
      debugPrint("payload ==========> $payload");

      if(payload.containsKey("notification_key") && payload["notification_key"] != null/* && payload["notification_key"] == "openCourse"*/) {
        debugPrint("initialMessage came inside notification_key");
        showCourseNotification = true;
        AppData.saveCourseNotification(payload);
        nextRoute(MainPage.pageName, isClearBackRoutes: true);
      } else {
        debugPrint("initialMessage came inside else notification");
        Future.delayed(const Duration(milliseconds: 150), () {
          Get.to(() => const NotificationPage());
        });
      }

    },
  );
  

  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);


  await Permission.notification.request();

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings _ = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true,badge: true,sound: true,);
  
  isFlutterLocalNotificationsInitialized = true;
}


late AndroidNotificationChannel channel;


void showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  
  AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
    channel.id,
    channel.name,
    channelDescription: channel.description,
    importance: Importance.high,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
    enableLights: true,
    icon: '@drawable/ic_notification',
  );
  
  const DarwinNotificationDetails darwinNotificationDetails =  DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );
  NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails, iOS: darwinNotificationDetails );

  
  if (notification != null) {
    if(Platform.isAndroid) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        notificationDetails,
        payload: jsonEncode(message.data),
      );
    }
  }
}

late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;