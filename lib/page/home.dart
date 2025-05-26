import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tugas_akhir/component/Item_card.dart';
import 'package:tugas_akhir/component/customTextfield.dart';
import 'package:tugas_akhir/component/custom_button.dart';
import 'package:tugas_akhir/component/text/headerText.dart';
import 'package:tugas_akhir/component/theme/theme.dart';
import 'package:tugas_akhir/model/foodModel.dart';
import 'package:timezone/timezone.dart' as timezone;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  TextEditingController ceritaMakananController = TextEditingController();
  
  String selectedZone = 'WIB';
  final List<String> zones = ['WIB', 'WITA', 'WIT', 'LONDON'];

  List<FoodData> foods = [];

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Color.fromARGB(255, 246, 143, 33),),
    );
  }

  Future<void> getNutritionixData(String queryText) async {
    const String url = "https://trackapi.nutritionix.com/v2/natural/nutrients";

    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "x-app-id": "36eb23f6",
      "x-app-key": "11b43ad738c8b3472bfe2ff458bfda18",
      "x-remote-user-id": "0"
    };

    final Map<String, dynamic> body = {
      "query": queryText
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          foods = data['foods']
                .map<FoodData>((item) => FoodData.fromJson(item))
                .toList();

          _showSnackBar("Ketemu ${foods.length} makanan ");
        });

        print("✅ Sukses:\n$data");
      } else {
        print("❌ Gagal (${response.statusCode}): ${response.body}");
      _showSnackBar(response.body);

      }
    } catch (e) {
      print("❗ Error saat mengirim request: $e");
    }
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

  timezone.Location getTimeZone(String zone) {
    switch (zone) {
      case 'WITA':
        return timezone.getLocation('Asia/Makassar');
      case 'WIT':
        return timezone.getLocation('Asia/Jayapura');
      case 'LONDON':
        return timezone.getLocation('Europe/London');
      case 'WIB':
      default:
        return timezone.getLocation('Asia/Jakarta');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(

      child: Scaffold(
        backgroundColor: theme.backgroundColor,
        body: Center(
          child: Stack(
            children: [
              Image.network(
                "https://media1.tenor.com/m/e-9q6jJb9RUAAAAC/anime-lamen.gif",
                fit: BoxFit.fitHeight,
                height:MediaQuery.sizeOf(context).height,
                width: double.infinity,
              ),
              Container(
                height: MediaQuery.sizeOf(context).height,
                width: double.infinity,
                color: const Color.fromARGB(170, 0, 0, 0),
              ),
              mainBody(context)
            ],
          ),
        ),
      ),
    );
  }

  Padding mainBody(BuildContext context) {
    return Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: MediaQuery.sizeOf(context).height *0.25,),
                  FormCerita(context),
                  SizedBox(height: 20,),
                  foods.length < 1 ? SizedBox() : FoodList(context)
                ],
              ),
            ),
          );
  }

  ItemCard FoodList(BuildContext context) {
    return ItemCard(
                backgroundColor: const Color.fromARGB(68, 81, 165, 255),
                height: MediaQuery.sizeOf(context).height * 0.5,
                child:Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ListView.builder(
                    itemCount: foods.length,
                    itemBuilder: (context, index){
                      print("Jumlah makanan: ${foods.length}");
                  
                      final food = foods[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ItemCard(
                          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                          width: double.infinity,
                          height: 200,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                      child: food.photo?.highres != null
                                      ? Image.network(
                                          food.photo!.highres,
                                          width: 150,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              width: 150,
                                              height: 100,
                                              color: Colors.grey[300],
                                              child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                            );
                                          },
                                        )
                                      : Container(
                                          width: 150,
                                          height: 100,
                                          color: Colors.grey[300],
                                          child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                                        ),
                                    ),
                  
                                    Container(
                                      width: 150,
                                      height: 170,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                        color: const Color.fromARGB(0, 255, 255, 255),
                                      ),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text("${food.foodName.toUpperCase()}", style: TextStyle(fontWeight: FontWeight.bold),),
                                            Divider(thickness: 2, color: Colors.black,),
                                            SizedBox(height: 5,),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text("Qty", style: TextStyle(fontWeight: FontWeight.bold),),
                                                Text("Unit", style: TextStyle(fontWeight: FontWeight.bold),),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text("${food.servingQty}", style: TextStyle(fontWeight: FontWeight.bold),),
                                                Text("${food.servingUnit}")
                                              ],
                                            ),
                                            SizedBox(height: 20,),
                                            Text("Kandungan Nutrisi", style: TextStyle(fontWeight: FontWeight.bold),),
                                            SizedBox(height: 5,),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text("Kalori"),
                                                Text("${food.calories} kkal")
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text("Kolestrol"),
                                                Text("${food.cholesterol} mg")
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text("Protein"),
                                                Text("${food.protein} gr")
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text("Sodium"),
                                                Text("${food.protein} mg")
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              );
  }

  ItemCard FormCerita(BuildContext context) {
    return ItemCard(
                backgroundColor: const Color.fromARGB(68, 81, 165, 255),
                height: MediaQuery.sizeOf(context).height * 0.4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Habis makan apa nih?", 
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 50,
                          fontFamily: "Clash Display"
                        ),
                      ),
                      SizedBox(height: 30,),
                      CustomTextfield(
                        controller: ceritaMakananController,
                        warna: const Color.fromARGB(138, 226, 226, 226),
                        warnaInputText: Colors.white,
                        hintText: "Habis makan apa nih..",
                        warnaHintText: Colors.white,
                        labelText: "Cek nutrisi makanan",
                        warnaLabelText: Colors.white,
                      ),
                      SizedBox(height: 20,),
                      customButton(
                        title: "Lihat",
                        warnaBackground: const Color.fromARGB(186, 111, 246, 33),
                        warnaText: Colors.white,
                        tebalFont: FontWeight.bold,
                        fungsiKetikaDitekan: ()async {
                  
                          if(ceritaMakananController.text.isEmpty){
                            _showSnackBar("Tidak boleh kosong !");
                            return;
                          }
                  
                          showLoadingModal(context);
                          await getNutritionixData(ceritaMakananController.text);
                          Navigator.pop(context);
                        },
                  
                      )
                    ],
                  ),
                ),
              );
  }
}