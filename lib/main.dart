import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:tugas_akhir/dashboard.dart';
import 'package:tugas_akhir/page/subpage/login.dart';
import 'package:tugas_akhir/preferenceService.dart';


void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();

  bool isLoggedIn = await PreferenceService().getLoginStatus();
  runApp(MyApp(isLogin: isLoggedIn,));
}

class MyApp extends StatelessWidget {
  final bool isLogin;
  const MyApp({super.key, required this.isLogin});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: isLogin ? MyHomePage() : LoginPage(),
    );
  }
}
