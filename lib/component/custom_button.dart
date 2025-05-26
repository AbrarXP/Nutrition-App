import 'package:flutter/material.dart';

class customButton extends StatelessWidget {
  final String? title;
  final VoidCallback? fungsiKetikaDitekan;
  final Color? warnaText;
  final Color? warnaBackground;
  final Color? warnaBorder;
  final FontWeight? tebalFont;

  const customButton({
    super.key,
    this.title,
    this.fungsiKetikaDitekan,
    this.warnaText,
    this.warnaBackground,
    this.warnaBorder,
    this.tebalFont,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: fungsiKetikaDitekan,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
            warnaBackground ?? const Color.fromARGB(255, 200, 24, 24)),
        side: MaterialStateProperty.all(
          BorderSide(
              color: warnaBorder ?? const Color.fromARGB(0, 0, 195, 255),
              width: 1.5),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      child: Text(
        title ?? "",
        style: TextStyle(
          color: warnaText ?? Colors.white,
          fontWeight: tebalFont ?? FontWeight.normal,
        ),
      ),
    );
  }
}
