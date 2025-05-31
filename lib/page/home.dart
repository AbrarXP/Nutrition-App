import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tugas_akhir/component/Item_card.dart';
import 'package:tugas_akhir/component/customTextfield.dart';
import 'package:tugas_akhir/component/custom_button.dart';
import 'package:tugas_akhir/component/text/headerText.dart';
import 'package:tugas_akhir/component/theme/theme.dart';
import 'package:tugas_akhir/component/video_player.dart';
import 'package:tugas_akhir/model/foodModel.dart';
import 'package:timezone/timezone.dart' as timezone;
import 'package:tugas_akhir/preferenceService.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  TextEditingController ceritaMakananController = TextEditingController();
  int userID = 0;
  List<FoodData> foods = [];

  int bb = 0;
  int tb = 0 ;
  int usia = 0;
  String jenis_kelamin = "Laki-laki";

  int total_kalori = 0;
  int total_kolestrol = 0;
  int total_protein = 0;
  int total_sodium = 0;

  double kebutuhanKaloriHarian = 0;
  Color warnaBarProgress = Colors.white;

  double progress = 0;

  bool loaded = false;

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    load();
  }

  void load() async {
    final prefs = PreferenceService();
    int bbValue = await prefs.getBeratBadan();
    int tbValue = await prefs.getTinggiBadan();
    int usiaValue = await prefs.getUsia();
    String jenisKelaminValue = await prefs.getJenisKelamin();

    setState(() {
      bb = bbValue;
      tb = tbValue;
      usia = usiaValue;
      jenis_kelamin = jenisKelaminValue;
    });

    loaded = true;
  }

  void hitungKaloriHarian({
    required int bb, // berat badan
    required int tb, // tinggi badan
    required int usia,
    required String jenisKelamin,
    double faktorAktivitas = 1.375, // default ringan
  }) {
    double bmr = 0;

    if (jenisKelamin == "laki-laki") {
      bmr = 10 * bb + 6.25 * tb - 5 * usia + 5;
    } else {
      bmr = 10 * bb + 6.25 * tb - 5 * usia - 161;
    }

    setState(() {
      kebutuhanKaloriHarian = bmr * faktorAktivitas;
    });
  }

  void updateProgressBar(){
      setState(() {
      progress = total_kalori / kebutuhanKaloriHarian;
      progress = progress.clamp(0.0, 1.0); // biar gak lebih dari 100%

      if (total_kalori > kebutuhanKaloriHarian) {
        warnaBarProgress = Colors.red;
      } else if (progress > 0.6) {
        warnaBarProgress = const Color.fromARGB(255, 255, 208, 0);
      } else {
        warnaBarProgress = const Color.fromARGB(255, 255, 221, 0);
      }
    });
  }

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

  @override
  Widget build(BuildContext context) {

    hitungKaloriHarian(bb: bb, tb: tb, usia: usia, jenisKelamin: jenis_kelamin);
    updateProgressBar();

    return SafeArea(
      child: Scaffold(
        backgroundColor: theme.backgroundColor,
        body: Center(
          child: Stack(
            children: [
              CustomVideoPlayer("assets/img/homeBackground.mp4"),
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
                  SizedBox(height: MediaQuery.sizeOf(context).height *0.05,),
                  FormCerita(context),
                  SizedBox(height: 20,),
                  foods.length < 1 ? SizedBox() : TotalNutrisiCard(context),
                  SizedBox(height: 20,),
                  foods.length < 1 ? SizedBox() : FoodList(context)
                ],
              ),
            ),
          );
    }

  ItemCard TotalNutrisiCard(BuildContext context) {

    return ItemCard(
      backgroundColor: const Color.fromARGB(149, 81, 165, 255),
      height: 230,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(right: 30, left: 30, top: 10, bottom: 10),
        child: Column(
          children: [
            Text(
              "Nutrisi total", 
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
                fontFamily: "Clash Display"
              ),
            ),
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/img/kalori_icon.png",
                  width: 15,
                ),
                Text("Kalori total $total_kalori kkal",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontFamily: "Clash Display"
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/img/kolestrol_icon.png",
                  width: 15,
                ),
                Text("Kolestrol total $total_kolestrol mg",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontFamily: "Clash Display"
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/img/protein_icon.png",
                  width: 15,
                ),
                Text("Protein total $total_protein g",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontFamily: "Clash Display"
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/img/salt_icon.png",
                  width: 15,
                ),
                Text("Sodium total $total_sodium mg",
                overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontFamily: "Clash Display"
                  ),
                ),
              ],
            ),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Kalori yang anda butuhkan dalam sehari:",
                overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontFamily: "Clash Display"
                  ),
                )
              ],
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: const Color.fromARGB(255, 176, 176, 176),
                valueColor: AlwaysStoppedAnimation<Color>(warnaBarProgress),
                minHeight: 10,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(" $total_kalori/$kebutuhanKaloriHarian Kkal",
                overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontFamily: "Clash Display"
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  ItemCard FoodList(BuildContext context) {
    return ItemCard(
                backgroundColor: const Color.fromARGB(149, 81, 165, 255),
                height: MediaQuery.sizeOf(context).height * 0.5,
                child:Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ListView.builder(
                    itemCount: foods.length,
                    itemBuilder: (context, index){
                      final food = foods[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ItemCard(
                          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                          height: 200,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 12, bottom: 12, right: 10, left: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    food.photo?.highres != null
                                    ? Image.network(
                                        food.photo!.highres,
                                        width: 150,
                                        height: 150,
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
                                    SizedBox(width: 10,),
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
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text("Qty ", style: TextStyle(fontWeight: FontWeight.bold),),
                                                Text("& Unit", style: TextStyle(fontWeight: FontWeight.bold),),
                                              ],
                                            ),
                                            SizedBox(
                                              width:170 ,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text("${food.servingQty}", style: TextStyle(fontWeight: FontWeight.bold),),
                                                  Expanded(child: Text(food.servingUnit, overflow: TextOverflow.ellipsis))
                                                ],
                                              ),
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
                backgroundColor: const Color.fromARGB(149, 81, 165, 255),
                height: MediaQuery.sizeOf(context).height * 0.62,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: SingleChildScrollView(
                    child: SizedBox(
                      height:  MediaQuery.sizeOf(context).height * 0.5,
                      
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Habis makan apa nih?", 
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 48,
                              fontFamily: "Clash Display"
                            ),
                          ),
                          SizedBox(height: 10,),
                          Expanded(
                            child: Text("Silahkan beritahu kami tentang makanan yang kamu inginkan, dan akan kami menampilkan kandungan nutrisinya. contoh: \"Habis makan croissant, creme brule, dan lasagna kenyang banget nih\"",
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontFamily: "Clash Display"
                              ),
                            ),
                          ),
                          SizedBox(height: 30,),
                          CustomTextfield(
                            controller: ceritaMakananController,
                            warna: const Color.fromARGB(138, 226, 226, 226),
                            warnaInputText: Colors.white,
                            hintText: "Aku baru saja makan...",
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

                              total_kalori = 0;
                              total_kolestrol = 0;
                              total_protein = 0;
                              total_sodium = 0;
                      
                              if(ceritaMakananController.text.isEmpty){
                                _showSnackBar("Tidak boleh kosong !");
                                return;
                              }
                      
                              showLoadingModal(context);
                              await getNutritionixData(ceritaMakananController.text);
                              Navigator.pop(context);

                              // Hitung total nutrisi
                              for(final food in foods){
                                total_kalori += food.calories.toInt();
                                total_kolestrol += food.cholesterol.toInt();
                                total_protein += food.protein.toInt();
                                total_sodium += food.protein.toInt();
                              }
                              ceritaMakananController.clear();
                            },
                      
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
  }
}