  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
  import 'package:get/get.dart';
  import 'package:get/get_core/src/get_main.dart';
  import 'package:get/get_instance/src/extension_instance.dart';
  import 'package:go_router/go_router.dart';
  import 'package:notesave/Utils/AppSpacing/app_spacing.dart';
  import 'package:notesave/Utils/Typography/app_typography.dart';
  import 'package:notesave/Views/Base/AppText/appText.dart';
import 'package:notesave/utils/AppColor/app_colors.dart';
  import '../../../Controller/SplashController/splashController.dart';
  import '../../../Router/route_names.dart';
  import '../../Base/GridentButton/Appbutton.dart';

  class SplashScreen extends StatefulWidget {
    const SplashScreen({super.key});

    @override
    State<SplashScreen> createState() => _SplashScreenState();
  }

  class _SplashScreenState extends State<SplashScreen>{
    late final SplashController controller;
    bool _navigated = false;

    @override
    void initState() {
      super.initState();
      controller = Get.put(SplashController());
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _routeFromSplash();
      });
    }

    Future<void> _routeFromSplash() async {
      if (_navigated) {
        return;
      }
      final routeName = await controller.resolveInitialRoute();
      if (!mounted || _navigated) {
        return;
      }
      _navigated = true;
      context.goNamed(routeName);
    }

    @override
    Widget build(BuildContext context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final size = MediaQuery.of(context).size;
      final screenHeight = size.height;
      final isTablet = size.width > 600;

      return Scaffold(
        backgroundColor: Color(0xFFD8D8D8),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                const SizedBox(height: AppSpacing.s36),
                Center(
                  child: Image.asset(
                    "assets/icons/Subtract.png",
                    height: 240,
                  ),
                ),
                const Spacer(),
                Obx(() => controller.isLoading.value
                    ? const SizedBox.shrink()
                    : GradientButton(
                  text: "Get started",
                  colors: [Color(0xFFADA7A7), Color(0xFFD8D8D8)],
                  height: isTablet ? 65 : 52,
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    context.goNamed(AppRouteName.register);
                  },
                ),),
                const SizedBox(height: AppSpacing.s16),
                Obx(() => controller.isLoading.value
                    ? const SizedBox.shrink()
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AppText('Already have an account? ', style: AppTypography.bodySmall),
                    GestureDetector(
                      onTap: () => context.goNamed(AppRouteName.login),
                      child: const AppText('Sign in', style: AppTypography.displaySmall),
                    ),
                  ],
                ),),

              ],
            ),
          ),
        ),
      );
    }
  }
