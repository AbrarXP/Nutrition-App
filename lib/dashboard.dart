import 'dart:ui';

import 'package:flutter/material.dart';
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