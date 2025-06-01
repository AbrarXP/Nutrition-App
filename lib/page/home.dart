import 'dart:async';
import 'dart:convert';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:tugas_akhir/component/Item_card.dart';
import 'package:tugas_akhir/component/customTextfield.dart';
import 'package:tugas_akhir/component/custom_button.dart';
import 'package:tugas_akhir/component/theme/theme.dart';
import 'package:tugas_akhir/component/video_player.dart';
import 'package:tugas_akhir/model/foodModel.dart';
import 'package:tugas_akhir/model/placeModel.dart';
import 'package:tugas_akhir/preferenceService.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {

  // Google API Key
  final googleAPIKey = "AIzaSyCAbTqehKeUWRrQrAg0n8LGfVce5MEXqoE";

  TextEditingController ceritaMakananController = TextEditingController();
  int userID = 0;
  List<FoodData> foods = [];
  List<PlaceData> restaurants = [];

  // Variabel BMI
  int bb = 0;
  int tb = 0 ;
  int usia = 0;
  String jenis_kelamin = "Laki-laki";


  // Variabel total nutrisi
  int total_kalori = 0;
  int total_kolestrol = 0;
  int total_protein = 0;
  int total_sodium = 0;

  double kebutuhanKaloriHarian = 0;
  Color warnaBarProgress = const Color.fromARGB(255, 216, 216, 216);
  double progress = 0;

  bool loaded = false;
  bool RestaurantLoaded = false;

  String? place_url;

  // Variabel Controller Scroll Restaurant GridView
  final ScrollController _scrollController = ScrollController();
  late final Timer _timer;
  double _scrollPosition = 0;

  Timer? _autoScrollTimer;
  Timer? _userInteractionTimer;
  bool _autoScrolling = true;
  final Duration _delayBeforeAutoScroll = Duration(seconds: 2);
  final double _scrollSpeed = 200;

  // Variabel geolocator
  bool serviceEnabled = false;
  LocationPermission permission = LocationPermission.denied;

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    load();

    // Setting scroll
    setupScrollController();
    checkPermission();
    fetchPlace();

  }

  // Method ini dipanggil saat user berinteraksi scroll
  void _onUserInteraction() {
    if (_autoScrolling) {
      setState(() {
        _autoScrolling = false;
      });
    }

    // Reset timer setiap user interaksi
    _userInteractionTimer?.cancel();
    _userInteractionTimer = Timer(_delayBeforeAutoScroll, () {
      setState(() {
        _autoScrolling = true;
      });
    });
  }
  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _userInteractionTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> checkPermission() async{
    permission = await Geolocator.checkPermission();
  }

  void setupScrollController() {
  _autoScrollTimer = Timer.periodic(Duration(milliseconds: 10), (timer) {
    if (_autoScrolling && _scrollController.hasClients) {
      _scrollPosition += _scrollSpeed;

      if (_scrollPosition >= _scrollController.position.maxScrollExtent) {
        _scrollPosition = 0;
      }

      _scrollController.animateTo(
        _scrollPosition,
        duration: Duration(milliseconds: 3000),
        curve: Curves.fastOutSlowIn,
      );
    }
  });
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

  Future<void> fetchPlace() async {

    Position lokasiUser = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    String url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${lokasiUser.latitude},${lokasiUser.longitude}&radius=10020&type=restaurant&key=$googleAPIKey";
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(response.body);
        setState(() {
          restaurants = (data['results'] as List)
              .map<PlaceData>((item) => PlaceData.fromJson(item))
              .toList();
          _showSnackBar("Ditemukan ${restaurants.length} restoran di sekitar Anda.");
        });
        RestaurantLoaded = true;
      } else {
        print("❌ Gagal (${response.statusCode}): ${response.body}");
        _showSnackBar("Gagal mengambil data restoran.");
      }
    } catch (e) {
      print("❗ Error saat mengambil data restoran: $e");
      _showSnackBar("Terjadi kesalahan saat mengambil data restoran.");
    }
  }

  Future<void> fetchDetailPlace(String place_id) async {

    String url = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$place_id&key=$googleAPIKey";
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(response.body);
        setState(() {
          place_url = data['result']['url'];
        });
      } else {
        print("❌ Gagal (${response.statusCode}): ${response.body}");
        _showSnackBar("Gagal mengambil data restoran.");
      }
    } catch (e) {
      print("❗ Error saat mengambil data restoran: $e");
      _showSnackBar("Terjadi kesalahan saat mengambil data restoran.");
    }

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
              physics: ScrollPhysics(parent: BouncingScrollPhysics()),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: MediaQuery.sizeOf(context).height *0.05,),
                  FormCerita(context),
                  SizedBox(height: 20,),
                  listRestaurant(),
                  SizedBox(height: 20,),
                  foods.length < 1 ? SizedBox() : TotalNutrisiCard(context),
                  SizedBox(height: 20,),
                  foods.length < 1 ? SizedBox() : FoodList(context)
                ],
              ),
            ),
          );
    }

  ItemCard listRestaurant() {
    return ItemCard(
                  backgroundColor: const Color.fromARGB(149, 81, 165, 255),
                  height: 280,
                  width: MediaQuery.sizeOf(context).width,
                  child: permission == LocationPermission.denied ?
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off,
                        color: const Color.fromARGB(255, 246, 140, 33),
                        size: 43,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          
                          Text(
                            "  Izin lokasi anda di matikan",
                            style: TextStyle(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              fontSize: 15,
                              fontFamily: "Clash Display",
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      ElevatedButton.icon(
                        onPressed: () async{
                          permission = await Geolocator.requestPermission();
                          permission = await Geolocator.checkPermission();
                          
                        },
                        icon: Icon(Icons.settings),
                        label: Text("Izinkan Akses Lokasi"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 255, 153, 0),
                          foregroundColor: Colors.white,
                        ),
                      )
                    ],
                  )
                  :
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10, left: 10),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on_sharp,
                                color: const Color.fromARGB(255, 246, 140, 33),
                                size: 16,
                              ),
                              Text(
                                "  Restaurant di sekitar anda",
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 15,
                                  fontFamily: "Clash Display",
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(),
                        SizedBox(height: 10,),
                        RestaurantLoaded == false ? 
                        Center(child: Column(
                          children: [
                            SizedBox(height: 20,),
                            CircularProgressIndicator(),
                            SizedBox(height: 10,),
                            Text(
                                "Mencari restaurant..",
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 13,
                                  fontFamily: "Clash Display",
                                ),
                              ),
                          ],
                        ),)
                        :
                        SizedBox(
                          height: 160,
                          width: MediaQuery.sizeOf(context).width,
                          child: NotificationListener<ScrollNotification>(
                            onNotification: (scrollNotification) {
                              if (scrollNotification is ScrollStartNotification ||
                                  scrollNotification is ScrollUpdateNotification ||
                                  scrollNotification is ScrollEndNotification) {
                                _onUserInteraction();
                              }
                              return false; // lanjutkan event supaya scroll tetap jalan
                            },
                            child: GridView.builder(
                              controller: _scrollController,
                              scrollDirection: Axis.horizontal,
                              itemCount: 10,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1, // 2 baris
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                childAspectRatio: 1, // 1:1 bentuk kotak
                              ),
                              itemBuilder: (context, index) {
                                final restaurant = restaurants[index];
                                final photoUrl = 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=${restaurant.photos![0].photoReference}&key=$googleAPIKey';
                                return GestureDetector(
                                  onTap: ()async{
                                    showLoadingModal(context);
                                    fetchDetailPlace(restaurant.place_id!);
                                    final url = Uri.parse(place_url!);
                                    await launchUrl(url, mode: LaunchMode.platformDefault);
                                    Navigator.pop(context);
                                  },
                                  child: ItemCard(
                                    child: Column(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                                          child: Image.network(
                                            photoUrl,
                                            height: 100,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 51,
                                          child: SingleChildScrollView(
                                            child: Padding(
                                              padding: const EdgeInsets.only(top: 5, right: 2, left: 5, bottom: 5),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          "${restaurant.name}",
                                                          style: TextStyle(
                                                            color: const Color.fromARGB(255, 38, 38, 38),
                                                            fontSize:10,
                                                            fontWeight: FontWeight.bold,
                                                            fontFamily: "Clash Display",
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          "Price Level ${restaurant.priceLevel}",
                                                          style: TextStyle(
                                                            color: const Color.fromARGB(255, 0, 0, 0),
                                                            fontSize:10,
                                                            fontFamily: "Clash Display",
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
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
                            labelText: "Cari nutrisi makananmu",
                            warnaLabelText: Colors.white,
                          ),
                          SizedBox(height: 20,),
                          customButton(
                            title: "Cari",
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