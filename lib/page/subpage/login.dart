import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:tugas_akhir/component/Item_card.dart';
import 'package:tugas_akhir/component/customTextfield.dart';
import 'package:tugas_akhir/component/custom_button.dart';
import 'package:tugas_akhir/component/text/headerText.dart';
import 'package:tugas_akhir/component/theme/theme.dart';
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

  final url = "http://192.168.0.110:5000/api/login";

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Color.fromARGB(255, 246, 143, 33),),
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

        await PreferenceService().setLoginStatus(true);

        _showSnackBar(msg);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
        );

      } else {
        _showSnackBar("Login gagal: ${response.body}");
      }
    } catch (e) {
      print("❌ Login error: $e");
      _showSnackBar("Terjadi kesalahan koneksi");
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
              Image.network(
                "https://media4.giphy.com/media/v1.Y2lkPTc5MGI3NjExb3hjMHgzYTVrZTNnY3V0em95a3BtdjI1MTUwMW9renZuMHppYnRuNiZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/tolaGqMj46lwxzTurd/giphy.gif",
                fit: BoxFit.fitHeight,
                height:MediaQuery.sizeOf(context).height,
                width: double.infinity,
              ),
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