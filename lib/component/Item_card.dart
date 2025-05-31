import 'package:flutter/material.dart';

class ItemCard extends StatefulWidget {
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final Color? borderColor;
  final Widget? child;
  const ItemCard({
    super.key,
    this.height,
    this.width,
    this.backgroundColor,
    this.borderColor,
    this.child
  });

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          width: 1.5,
          color: widget.borderColor ?? Colors.grey.withOpacity(0.2),
        ),
      ),
      child:  widget.child,
    );
  }
}