import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationController {
  static ReceivedAction? initialCallAction;

  // reuest permission
  static Future<void> requestPermission() async {
    AwesomeNotifications().shouldShowRationaleToRequest();
  }

  // init
  static Future<void> init() async {
    AwesomeNotifications().initialize(null, [
      NotificationChannel(
        //icon: 'resource://drawable/res_notification',
        channelKey: 'mytube',
        channelName: 'MyTube Media Player',
        channelDescription: 'MyTube Media Player',
        defaultPrivacy: NotificationPrivacy.Public,
        enableVibration: false,
        enableLights: false,
        playSound: false,
      )
    ], channelGroups: [
      NotificationChannelGroup(
          channelGroupKey: 'mytube', channelGroupName: 'MyTube Media Player')
    ]);
  }

  // show method to show notification with play/pause button
  static Future<void> show(
      String videoTitle, String channelName, String thubnail) async {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'mytube',
        title: videoTitle,
        body: channelName,
        category: NotificationCategory.Transport,
        notificationLayout: NotificationLayout.MediaPlayer,
        largeIcon: thubnail,
        autoDismissible: false,
        showWhen: false,
      ),
      actionButtons: [
        NotificationActionButton(
            key: 'PLAY/PAUSE',
            label: 'Play',
            actionType: ActionType.KeepOnTop,
            // le icone vanno nelle resources android
            icon: 'resource://drawable/res_ic_play',
            enabled: true,
            autoDismissible: false,
            showInCompactView: false),
        NotificationActionButton(
            key: 'STOP',
            label: 'Stop',
            actionType: ActionType.KeepOnTop,
            icon: 'resource://drawable/res_ic_stop',
            enabled: true,
            autoDismissible: false,
            showInCompactView: false),
      ],
    );

    AwesomeNotifications()
        .setListeners(onActionReceivedMethod: onActionReceived);
  }

  // cancel
  static Future<void> cancel() async {
    AwesomeNotifications().cancel(1);
  }

  static Future<void> onActionReceived(
      ReceivedAction receivedNotification) async {
    if (receivedNotification.buttonKeyPressed == 'PLAY/PAUSE') {
      log('PLAY/PAUSE button pressed');
    }
  }

  static Future<void> interceptInitialCallActionRequest() async {
    ReceivedAction? receivedAction =
        await AwesomeNotifications().getInitialNotificationAction();

    if (receivedAction?.channelKey == 'call_channel') {
      initialCallAction = receivedAction;
    }
  }
}
