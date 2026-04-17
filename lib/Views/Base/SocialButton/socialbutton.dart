import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../IOSTapEffect/iosTapEffect.dart';

class SocialButton extends StatelessWidget {
  final bool isLoading;
  final String icon;
  final VoidCallback onTap;
  final bool isTablet;

  const SocialButton({
    super.key,
    required this.isLoading,
    required this.icon,
    required this.onTap,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const CupertinoActivityIndicator();
    }

    final buttonSize = isTablet ? 60.0 : 50.0;

    return IosTapEffect(
      onTap: onTap,
      child: Container(
        height: buttonSize,
        width: buttonSize,
        padding: EdgeInsets.all(isTablet ? 12 : 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Color(0xffeeeeee),
              offset: Offset(0, 3),
              blurRadius: 5,
            ),
          ],
          borderRadius: BorderRadius.circular(100),
        ),
        child: SvgPicture.asset(icon),
      ),
    );
  }
}