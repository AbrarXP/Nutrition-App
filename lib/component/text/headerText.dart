import 'package:flutter/material.dart';
import 'package:tugas_akhir/component/theme/theme.dart';

class Headertext extends StatelessWidget {
  final String kata;
  final int? fontSize;
  const Headertext({super.key,required this.kata, this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Text(
      textAlign: TextAlign.justify,
      kata,
      style: TextStyle(
        fontFamily: 'Telma',
        fontWeight: FontWeight.w900,
        fontSize:55,
        color: Colors.white,
      ),
    );
  }
}