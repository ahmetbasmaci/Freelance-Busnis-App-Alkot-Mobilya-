import 'package:alkot_mobilya/classes/app_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'pages/home_page.dart';
import 'pages/splash_page.dart';
import 'services/firebase_message_service.dart';
import 'services/notification_api.dart';

const String projectId = "alkot-mobilya";
const String apiKey = "AIzaSyAXBqOYlfjbLquqI3v7wiJX3q6PwQWQ5NU";
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(AppController());
  NotificationService();

  await Firebase.initializeApp();
  await FirebaseMessageService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: SplashPage(),
      // home: HomePage(),
    );
  }
}
