
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../IOSTapEffect/iosTapEffect.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final List<Color> colors;
  final double height;
  final double borderRadius;
  final bool isLoading;

  const GradientButton({
    super.key,
    required this.text,
    required this.onTap,
    this.colors = const [Color(0xFF4182CD),Color(0xFF05435F)],
    this.height = 52,
    this.borderRadius = 25,
    this.isLoading=false,
  });

  @override
  Widget build(BuildContext context) {
    return IosTapEffect(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: colors,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 60), // keep text centered
            isLoading?
                const SizedBox(
                  height: 24,
                  width: 24,
                  child:CupertinoActivityIndicator(
                    radius: 12,
                    color: Colors.white,
                  ),
                ):Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            /// Center Text


            ///----===--- Arrow Icon ---====---//
            isLoading ? const SizedBox(width: 42)
                :Padding(
              padding: const EdgeInsets.all(4.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 21,
                child: Icon(
                  Icons.arrow_forward,
                  color: colors.first,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
