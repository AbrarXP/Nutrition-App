import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:tugas_akhir/component/Item_card.dart';
import 'package:tugas_akhir/component/customTextfield.dart';
import 'package:tugas_akhir/component/custom_button.dart';
import 'package:tugas_akhir/component/text/headerText.dart';
import 'package:tugas_akhir/component/theme/theme.dart';
import 'package:tugas_akhir/component/video_player.dart';
import 'package:tugas_akhir/dashboard.dart';
import 'package:tugas_akhir/preferenceService.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  // Deklarasi variabel
  TextEditingController user = TextEditingController();
  TextEditingController pass = TextEditingController();

  final url = "http://192.168.0.101:5000/api/login";

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Color.fromARGB(255, 246, 143, 33),),
    );
  }

    void showLoadingModal(BuildContext context) {
      showDialog(
        barrierDismissible: false,
        context: context,
        barrierColor: Colors.black.withOpacity(0.3), // transparan gelap
        builder: (context) {
          return Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            ),
          );
        },
      );
    }


  Future<void> loginUser(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        
        final data = jsonDecode(response.body);

        final msg = data['msg'];
        final String username = data['user']['username'];
        final int userID = data['user']['userID'];
        final int bb = data['user']['bb'];
        final int tb = data['user']['tb'];
        final int usia = data['user']['usia'];
        final String jenisKelamin = data['user']['jenis_kelamin'];

        await PreferenceService().setLoginStatus(true);
        await PreferenceService().setUsername(username);
        await PreferenceService().setUserID(userID);
        await PreferenceService().setBeratBadan(bb);
        await PreferenceService().setTinggiBadan(tb);
        await PreferenceService().setUsia(usia);
        await PreferenceService().setJenisKelamin(jenisKelamin);

        Navigator.pop(context);
        _showSnackBar(msg);


        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
        );

      } else {
        _showSnackBar("Login gagal: ${response.body}");
        Navigator.pop(context);
      }
    } catch (e) {
      print("❌ Login error: $e");
      _showSnackBar("Terjadi kesalahan koneksi");
      Navigator.pop(context);
    }
  }
  

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: SafeArea(
        child: Center(
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomVideoPlayer("assets/img/loginBackground.mp4"),
              Container(
                height: MediaQuery.sizeOf(context).height,
                width: double.infinity,
                color: const Color.fromARGB(170, 0, 0, 0),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Headertext(kata: "login"),
                  SizedBox(height: 20,),
                  ItemCard(
                    backgroundColor: const Color.fromARGB(72, 242, 242, 242),
                    height: MediaQuery.sizeOf(context).height * 0.3,
                    width: MediaQuery.sizeOf(context).width * 0.7,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomTextfield(
                            controller: user,
                            warna: const Color.fromARGB(73, 226, 226, 226),
                            warnaInputText: Colors.white,
                            hintText: "Username",
                            warnaHintText: Colors.white,
                            labelText: "Username",
                            warnaLabelText: Colors.white,
                          ),
                          SizedBox(height: 10,),
                          CustomTextfield(  
                            controller: pass,                      
                            warna: const Color.fromARGB(72, 226, 226, 226),
                            warnaInputText: Colors.white,
                            hintText: "Password",
                            warnaHintText: Colors.white,
                            labelText: "Password",
                            warnaLabelText: Colors.white,
                          ),
                          SizedBox(height: 20,),
                          customButton(
                            title: "LOGIN",
                            warnaBackground: theme.LegendaryColor,
                            warnaText: Colors.white,
                            tebalFont: FontWeight.bold,
              
                            fungsiKetikaDitekan: () async{
                              showLoadingModal(context);
                              await loginUser(user.text, pass.text);
                            },
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}