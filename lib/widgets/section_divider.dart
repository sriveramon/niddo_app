import 'package:flutter/material.dart';

class SectionDivider extends StatelessWidget {
  final double thickness;
  final Color? color;
  final double verticalPadding;

  const SectionDivider({
    super.key,
    this.thickness = 2.0,
    this.color,
    this.verticalPadding = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Divider(
        thickness: thickness,
        color: color ?? Colors.deepOrange.withOpacity(0.5),
      ),
    );
  }
}
