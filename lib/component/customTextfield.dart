import 'package:flutter/material.dart';

class CustomTextfield extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final Color? warna;
  final Color? warnaLabelText;
  final Color? warnaHintText;
  final Color? warnaInputText;
  final bool? sembunyikan;
  final String? labelText;


  const CustomTextfield({
    super.key,
    this.hintText,
    this.controller,
    this.warna,
    this.sembunyikan, 
    this.labelText, 
    this.warnaLabelText, 
    this.warnaHintText, this.warnaInputText
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: warnaInputText ?? const Color.fromARGB(255, 0, 0, 0)),
      obscureText: sembunyikan ?? false,
      decoration: InputDecoration(
        labelText: labelText ?? "LabelText",
        labelStyle: TextStyle(color: warnaLabelText ?? const Color.fromARGB(198, 0, 0, 0),fontWeight: FontWeight.bold),
        hintText: hintText ?? "HintText",
        hintStyle: TextStyle(color: warnaHintText ?? const Color.fromARGB(198, 0, 0, 0)),
        filled: true,
        fillColor:  warna ?? Color.fromARGB(255, 150, 150, 150),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(10))
        )
      ),
    );
  }
}