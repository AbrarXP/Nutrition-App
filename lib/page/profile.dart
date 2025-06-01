import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:tugas_akhir/component/Item_card.dart';
import 'package:tugas_akhir/component/custom_button.dart';
import 'package:tugas_akhir/component/theme/theme.dart';
import 'package:tugas_akhir/component/video_player.dart';
import 'package:tugas_akhir/main.dart';
import 'package:tugas_akhir/preferenceService.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool loaded = false;

  String username = "Username belum di set";
  late int bb;
  late int tb;
  late int usia;
  late String jenis_kelamin;

  String kategori = "";
  double bmi = 0;
  Color warnaTextKategori = Colors.white;


  String BMI_icon_path = "assets/img/normal_person_icon.png";

  String selectedTimezone = "WIB";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadUsername();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Color.fromARGB(255, 246, 143, 33),),
    );
  }

  void hitungBMI() {
    double tinggiMeter = tb / 100; // ubah dari cm ke meter
    bmi = bb / (tinggiMeter * tinggiMeter);
    setState(() {
      if (bmi < 18.5) {
        kategori = "Kurus";
        BMI_icon_path = "assets/img/skinny_person_icon.png";
        warnaTextKategori = Colors.amber;
      } else if (bmi < 25) {
        kategori = "Normal";
        BMI_icon_path = "assets/img/normal_person_icon.png";
        warnaTextKategori = Colors.green;
      } else {
        kategori = "Obesitas";
        BMI_icon_path = "assets/img/obesity_person_icon.png";
        warnaTextKategori = Colors.red;
      }
    });
  }


  void loadUsername() async {
    final prefs = PreferenceService();
    String result = await prefs.getUsername();
    int bbValue = await prefs.getBeratBadan();
    int tbValue = await prefs.getTinggiBadan();
    int usiaValue = await prefs.getUsia();
    String jenisKelaminValue = await prefs.getJenisKelamin();

    setState(() {
      username = result;
      bb = bbValue;
      tb = tbValue;
      usia = usiaValue;
      jenis_kelamin = jenisKelaminValue;
    });

    hitungBMI();


    loaded = true;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: Stack(
        children: [
          CustomVideoPlayer("assets/img/profileBackground2.mp4"),
          Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(187, 24, 10, 10)
            ),
          ),
          mainBody(context)
          ]
      ),
    );
  }

  Padding mainBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: loaded == false ? 
      Center(child: CircularProgressIndicator()) 
      :
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          JamCard(),
          SizedBox(height: 10,),
          BMICard(context),
          SizedBox(height: 20,),
          customButton(
            title: "remind me",
            fungsiKetikaDitekan: (){},
          )
        ],
      ),
    );
  }

  DateTime convertToTimezone(DateTime utcTime, String timezone) {
    switch (timezone) {
      case 'WIB': return utcTime.add(Duration(hours: 7));
      case 'WITA': return utcTime.add(Duration(hours: 8));
      case 'WIT': return utcTime.add(Duration(hours: 9));
      case 'LONDON': return utcTime; // UTC == London time (tanpa daylight saving)
      default: return utcTime;
    }
  }

  String formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}";
  }



  ItemCard JamCard() {
    return ItemCard(
          backgroundColor: const Color.fromARGB(149, 81, 165, 255),
          height: 70,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.white, size: 15),
                    SizedBox(width: 10,),
                    StreamBuilder<DateTime>(
                      stream: Stream.periodic(Duration(seconds: 1), (_) => DateTime.now().toUtc()),
                      builder: (context, snapshot) {
                        final utcNow = snapshot.data ?? DateTime.now().toUtc();
                        final convertedTime = convertToTimezone(utcNow, selectedTimezone);
                        final formattedTime = formatTime(convertedTime);

                        return Text(
                          "$selectedTimezone, $formattedTime",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            fontFamily: "Clash Display",
                          ),
                        );
                      },
                    )

                  ],
                ),
                DropdownButton<String>(
                  menuWidth: 100,
                  dropdownColor: const Color.fromARGB(223, 246, 143, 33),
                  value: selectedTimezone,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontFamily: "Clash Display",
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'WIB', child: Text('WIB')),
                    DropdownMenuItem(value: 'WITA', child: Text('WITA')),
                    DropdownMenuItem(value: 'WIT', child: Text('WIT')),
                    DropdownMenuItem(value: 'LONDON', child: Text('LONDON')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedTimezone = value!;
                    });
                  },
                )
              ],
            ),
          ),
        );
  }

    ItemCard BMICard(BuildContext context) {

    return ItemCard(
                  backgroundColor: const Color.fromARGB(149, 81, 165, 255),
                  height: MediaQuery.sizeOf(context).height * 0.4,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.person, color: Colors.white, size: 18,),
                                Text("Hai, ${username}", 
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontFamily: "Clash Display"
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 25,
                              width: 80,
                              child: customButton(
                                title: "Edit",
                                tebalFont: FontWeight.bold,
                                warnaBackground: theme.LegendaryColor,
                                fungsiKetikaDitekan: () {
                                  setState(() {
                                    editDataForm(context);
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.monitor_weight, color: Colors.white, size: 15,),
                                SizedBox(width: 5,),
                                Text(
                                  "$bb kg",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontFamily: "Clash Display"
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.person, color: Colors.white, size: 15,),
                                Icon(Icons.height, color: Colors.white, size: 15,),
                                SizedBox(width: 5,),
                                Text(
                                  "$tb cm",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontFamily: "Clash Display"
                                  ),
                                ),
                              ],
                            ),
                            
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.cake, color: Colors.white, size: 15,),
                                SizedBox(width: 5,),
                                Text(
                                  "$usia tahun",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontFamily: "Clash Display"
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                jenis_kelamin == "Laki-laki" ?
                                Icon(Icons.male, color: Colors.white, size: 15,) : Icon(Icons.female, color: Colors.white, size: 15,),
                                SizedBox(width: 5,),
                                Text(
                                  "$jenis_kelamin",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontFamily: "Clash Display"
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 40,),
                         Text(
                          "BMI Score :  ${bmi.floor()}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 13,
                            fontFamily: "Clash Display"
                          ),
                        ),
                        Image.asset(
                          BMI_icon_path,
                          height: 90,
                        ),
                        Text(
                          "$kategori",
                          style: TextStyle(
                            color: warnaTextKategori,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            fontFamily: "Clash Display"
                          ),
                        ),
                      
                      ],
                    ),
                  ),
                );
  }

    Future<dynamic> editDataForm(BuildContext context) {
    final TextEditingController bbController = TextEditingController(text: bb.toString());
    final TextEditingController tbController = TextEditingController(text: tb.toString());
    final TextEditingController usiaController = TextEditingController(text: usia.toString());
    String selectedGender = jenis_kelamin;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(220, 255, 179, 0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.all(0),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Edit Data Diri", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: bbController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Berat Badan (kg)",
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    style: TextStyle(color: Colors.white),
                    controller: tbController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Tinggi Badan (cm)",
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: usiaController,
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Usia (tahun)",
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    dropdownColor: const Color.fromARGB(230, 30, 30, 30),
                    style: TextStyle(color: Colors.white),
                    value: selectedGender,
                    items: ["Laki-laki", "Perempuan"]
                        .map((gender) => DropdownMenuItem(
                              value: gender,
                              child: Text(gender),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        selectedGender = value;
                      }
                    },
                    decoration: InputDecoration(
                      labelText: "Jenis Kelamin",
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Batal", style: TextStyle(color: Colors.white)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.LegendaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () async {
                          final prefs = PreferenceService();
                          await prefs.setBeratBadan(int.tryParse(bbController.text) ?? bb);
                          await prefs.setTinggiBadan(int.tryParse(tbController.text) ?? tb);
                          await prefs.setUsia(int.tryParse(usiaController.text) ?? usia);
                          await prefs.setJenisKelamin(selectedGender);
                          loadUsername();
                          Navigator.pop(context);
                          _showSnackBar("Data berhasil diperbarui!");
                        },
                        child: Text("Simpan"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


}