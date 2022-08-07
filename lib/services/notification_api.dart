import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  NotificationService() {
    init();
  }
  static init() async {
    await _flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: IOSInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
        macOS: MacOSInitializationSettings(),
      ),
    );
  }

  static NotificationDetails _getNotificationDetails({required String bigTitle, required String bigBody}) {
    return NotificationDetails(
        android: AndroidNotificationDetails(
      'channel id',
      "channel name",
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      ticker: 'ticker',
      styleInformation: BigTextStyleInformation(
        bigBody,
        htmlFormatBigText: true,
        contentTitle: '<b>$bigTitle</b>',
        htmlFormatContentTitle: true,
        summaryText: '',
        htmlFormatSummaryText: true,
      ),
    ));
  }

//! -----------------------------  default alarms ----------------------------- //
  static Future showNotificationNow() async {
    await Future.delayed(Duration(seconds: 0));
    String title = 'تم اضافة عنصر جديد';
    String body = 'تم اضافة عنصر جديد الى قائمة العناصر , اضغت لرؤية العناصر الجديدة والتحقق منها';
    await _flutterLocalNotificationsPlugin.show(0, title, body, _getNotificationDetails(bigTitle: title, bigBody: body),
        payload: 'item x');
  }
}
