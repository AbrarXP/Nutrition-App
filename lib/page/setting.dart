import 'package:flutter/material.dart';
import 'package:tugas_akhir/component/custom_button.dart';
import 'package:tugas_akhir/component/theme/theme.dart';
import 'package:tugas_akhir/page/subpage/login.dart';
import 'package:tugas_akhir/preferenceService.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            customButton(
              title: "LOG OUT",
              warnaBackground: Colors.red,
              warnaText: Colors.white,
              tebalFont: FontWeight.bold,
              fungsiKetikaDitekan: () async{
                await PreferenceService().setLoginStatus(false);

                bool status = await PreferenceService().getLoginStatus();
                print("Status login sekarang: $status");

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (route) => false,
                );
              },
            )
          ],
        ),
      ),
    );
  }
}