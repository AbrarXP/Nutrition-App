import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String kata;
  const CustomText({super.key,required this.kata});

  @override
  Widget build(BuildContext context) {
    return Text(
      kata,
      style: TextStyle(
        
      ),
    );
  }
}