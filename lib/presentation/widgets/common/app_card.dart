import 'package:flutter/material.dart';

/// Uniform enterprise card container enforcing #E5E7EB borders and 16px radius.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.constraints,
    this.color = Colors.white,
    this.borderColor = const Color(0xFFE5E7EB),
    this.borderRadius = 16.0,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BoxConstraints? constraints;
  final Color color;
  final Color borderColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: constraints,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}
