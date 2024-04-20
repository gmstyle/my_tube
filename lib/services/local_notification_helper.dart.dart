import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';

final _cancelDownloadController = StreamController<void>.broadcast();

@pragma('vm:entry-point')
Future<void> notificationResponse(
    NotificationResponse notificationResponse) async {
  if (notificationResponse.actionId == 'open_action') {
    final destinationDir = notificationResponse.payload;
    final path = destinationDir != null
        ? '/storage/emulated/0/Download/MyTube/$destinationDir'
        : '/storage/emulated/0/Download/MyTube';
    await OpenFile.open(path);
  } else if (notificationResponse.actionId == 'cancel_action') {
    // Se l'azione di annullamento viene attivata, invia un evento al controller
    _cancelDownloadController.add(null);
  }
}

class LocalNotificationHelper {
  LocalNotificationHelper();

  static const channelId = 'my_tube_downloads_channel';
  static const channelName = 'MyTube Downloads Channel';
  static const defaultIcon = 'ic_notification';

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(defaultIcon);

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: notificationResponse,
        onDidReceiveBackgroundNotificationResponse: notificationResponse);

    const AndroidNotificationChannel androidNotificationChannel =
        AndroidNotificationChannel(
      channelId,
      channelName,
      playSound: false,
    );

    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);

    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: false,
        );
  }

  static const DarwinNotificationDetails iOSNotificationDetails =
      DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: false,
  );

  static Future<void> showDownloadNotification(
      {required String title,
      required String body,
      required int progress,
      String? payload}) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(channelId, channelName,
            icon: defaultIcon,
            showProgress: true,
            onlyAlertOnce: true,
            maxProgress: 100,
            progress: progress,
            // se il download è in corso non è possibile cancellare la notifica
            ongoing: progress < 100,
            // se il download è completato la notifica viene cancellata al click
            autoCancel: progress == 100,
            actions: progress == 100
                ? [
                    const AndroidNotificationAction(
                        'open_action', 'Open download directory',
                        showsUserInterface: true),
                  ]
                : [
                    const AndroidNotificationAction(
                        'cancel_action', 'Cancel download',
                        showsUserInterface: true),
                  ]);

    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidNotificationDetails, iOS: iOSNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // Aggiungi un metodo per ottenere lo stream di annullamento
  static Stream<void> get onCancelDownload => _cancelDownloadController.stream;
}
