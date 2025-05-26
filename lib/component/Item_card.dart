import 'package:flutter/material.dart';
import 'dart:ui';

class ItemCard extends StatefulWidget {
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final Widget? child;

  const ItemCard({
    super.key,
    this.height,
    this.width,
    this.child,
    this.backgroundColor,
  });

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Shadow luar
        Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
        // Blur + Warna Background
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  width: 1.5,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              child: widget.child,
            ),
          ),
        ),
      ],
    );
  }
}
