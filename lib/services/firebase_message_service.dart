// ignore_for_file: avoid_print

import 'package:alkot_mobilya/services/notification_api.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FirebaseMessageService {
  static init() async {
    await getToken(); //to can get messages events
    FirebaseMessaging.onBackgroundMessage(FirebaseMessageService.listenBackgroundMode);
    listenBackgroundModeOpenMessagee();
    listenForgroundMode();
    await listenTerminatedModeOpenMessage();
    await subscribe();
  }

  static const String serverToken =
      'AAAAAEsf2k0:APA91bHlcFAnrd4LdejmqGnx_IiHHukp_YQQysU9G-3e_qVkh-Th1XnXw_tk4zVbO4V426u8i4MvnoVNkahV-tf4Ck5fUZNYR8Sp6qT-n6zqRZn86uvHDp5ErEsW644K2aE-dLrltwQm';
  static const String _channelName = 'alkot_mobilya';
  static Future sentNotifiy() async {
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'title': 'تم اضافة عنصر جديد',
            'body': 'تم اضافة عنصر جديد الى قائمة العناصر , اضغت لرؤية العناصر الجديدة والتحقق منها',
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'shopName': 'shop number 1',
            'isClose': 'yes its close',
            // 'to': '/topic/$_channelName',
          },
         
          // 'to': '/topic/$_channelName',
          'to': '/topics/$_channelName',
        },
      ),
    );
  }

  static getToken() {
    return FirebaseMessaging.instance.getToken();
  }

  static Future listenTerminatedModeOpenMessage() async {
    var message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) {
      print('_-------------------- MESSAGE CLICK ON TERMENATED ----------------------');
      print(message.notification!.body);
      print('_-------------------- ! MESSAGE CLICK ON TERMENATED ! ----------------------');
    }
  }

  static void listenForgroundMode() {
    //get the message when the app in forground mode
    FirebaseMessaging.onMessage.listen((event) {
      print('_-------------------- MESSAGE  ON FORGROUND ----------------------');
      print(event.notification!.body);
      print('_-------------------- ! MESSAGE  ON FORGROUND ! ----------------------');

      NotificationService.showNotificationNow();
    });
  }

  static Future listenBackgroundMode(RemoteMessage message) async {
    //get the message when notivigation send in background mode
    print('_--------------------MESSAGE ON BACKGROUND----------------------');
    print(message.notification!.body);
    print('_-------------------- ! MESSAGE ON BACKGROUND ! ----------------------');
  }

  static void listenBackgroundModeOpenMessagee() {
    //get the message when click on notivigation in background mode
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      print('_--------------------MESSAGE OPENED ON BACKGROUND----------------------');
      print(event.notification!.body);
      print('_-------------------- ! MESSAGE OPENED ON BACKGROUND ! ----------------------');
    });
  }

  static Future subscribe() async {
    //to subscribe to a topic (like youtube channel) to can sent message to that all subscribers
    await FirebaseMessaging.instance.subscribeToTopic(_channelName);
  }

  static void unSubscribe() async {
    //to unSubscribe from a topic
    await FirebaseMessaging.instance.unsubscribeFromTopic(_channelName);

    /*
    ?inside sending the message inside body
    'to':'/topic/all',
    'to':'/topic/news',
     */
  }

  static void requistPersmitionIOS() async {
    //this method for ios users only to request persmission to send notification
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }
}
