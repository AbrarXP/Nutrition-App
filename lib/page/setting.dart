import 'package:flutter/material.dart';
import 'package:tugas_akhir/component/Item_card.dart';
import 'package:tugas_akhir/component/custom_button.dart';
import 'package:tugas_akhir/component/theme/theme.dart';
import 'package:tugas_akhir/component/video_player.dart';
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
      body: Stack(
        children: [
          CustomVideoPlayer("assets/img/homeBackground.mp4"),
          Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(187, 24, 10, 10)
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ItemCard(
                    backgroundColor: const Color.fromARGB(149, 81, 165, 255),
                    height:300,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 200,
                            width: double.infinity,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Text(
                                    "Saran dan kesan",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 50,
                                      fontFamily: "Clash Display",
                                    ),
                                  ),
                                  Text(
                                    "Kesan saya dalam mengikuti mata kuliah Teknologi dan Pemrograman Mobile ini sangat sulit dan cukup rumit untuk kami yang baru mempelajari bahasa dart, dan framework flutter yang baru mulai dipelajari pada semester 6 . Saya harapkan untuk kedepannya semoga dapat di sesuaikan lagi dengan kemampuan mahasiswa Informatika UPN Veteran Yogyakarta",
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontFamily: "Clash Display",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      
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
                  ),
                  
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}