import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:tugas_akhir/component/text/customText.dart';
import 'package:tugas_akhir/component/theme/theme.dart';
import 'package:tugas_akhir/page/home.dart';
import 'package:tugas_akhir/page/profile.dart';
import 'package:tugas_akhir/page/setting.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  double lastX = 0, lastY = 0, lastZ = 0;
  int lastNotify = 0;
  final notif = FlutterLocalNotificationsPlugin();

  void initState() {
    super.initState();

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    notif.initialize(initializationSettings);

    _requestNotificationPermission();

    accelerometerEvents.listen((e) {
      double dx = (e.x - lastX).abs();
      double dy = (e.y - lastY).abs();
      double dz = (e.z - lastZ).abs();
      double delta = sqrt(dx*dx + dy*dy + dz*dz);

      if (delta > 1 && DateTime.now().millisecondsSinceEpoch - lastNotify > 2000) {
        notif.show(
          0,
          'Shake Detected!',
          'Ponsel kamu diguncangkan!',
          const NotificationDetails(
            android: AndroidNotificationDetails('id', 'shake'),
          ),
        );
        lastNotify = DateTime.now().millisecondsSinceEpoch;
      }

      // Update nilai terakhir setelah cek
      setState(() {
        lastX = e.x;
        lastY = e.y;
        lastZ = e.z;
      });
    });

  }

  void showManualNotification() {
    notif.show(
      1,
      'Manual Notification',
      'Ini notifikasi dari tombol manual',
      const NotificationDetails(
        android: AndroidNotificationDetails('id_manual', 'manual_channel'),
      ),
    );
  }

  Future<void> _requestNotificationPermission() async {
  if (await Permission.notification.isDenied ||
      await Permission.notification.isPermanentlyDenied) {
    await Permission.notification.request();
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: bottomNavbarNavigation(),
      body: halaman[indexNow],
    );
  }
  // Method bottomNavbarNavigation
  int indexNow = 1;

  void gantiHalaman(int index){
    setState(() {
      indexNow = index;
    });
  }

  final List<Widget> halaman =[
    ProfilePage(),
    HomePage(),
    SettingPage()
  ];

  Widget bottomNavbarNavigation(){
    return BottomNavigationBar(
      onTap: gantiHalaman,
      currentIndex: indexNow,
      backgroundColor: theme.LegendaryColor,
      selectedItemColor: theme.secondaryColor,
      unselectedItemColor: const Color.fromARGB(255, 187, 222, 247),
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.person), label : "Profile",),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home',),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings',),
      ]
    );
  }

}