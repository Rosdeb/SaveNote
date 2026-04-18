  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
import 'package:get/get.dart';
  import 'package:get/get_core/src/get_main.dart';
  import 'package:get/get_instance/src/extension_instance.dart';
  import 'package:go_router/go_router.dart';
  import 'package:notesave/Utils/AppColor/app_colors.dart';
  import 'package:notesave/Utils/AppSpacing/app_spacing.dart';
  import 'package:notesave/Utils/Typography/app_typography.dart';
  import 'package:notesave/Views/Base/AppText/appText.dart';

  import '../../../Controller/NetworkService/networkservice.dart';
  import '../../../Controller/SplashController/splashController.dart';
import '../../../Router/route_names.dart';
  import '../../Base/CutomButton/Appbutton.dart';
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: SafeArea(
            child: Column(
              children: [
                //------ header image
                Image.asset("assets/images/note_save.png",),
                const SizedBox(height: AppSpacing.s16),
                const AppText("Welcome to Note Save",style: AppTypography.headlineH2, fontSize: 15,textAlign: TextAlign.center,),
                const SizedBox(height: AppSpacing.s16),
                const AppText("Capture ideas, write freely,\nand never lose a thought again.", fontSize: 16,textAlign: TextAlign.center,),

                const Spacer(),

                //------ buton
                Obx(()=>GradientButton(
                  text: "Get started",
                  isLoading: controller.isLoading.value,
                  height: isTablet ? 65 :52,
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    context.goNamed(AppRouteName.register);
                  },
                ),
                ),

                const SizedBox(height: AppSpacing.s16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AppText(
                      'Already have an account? ',
                      style: AppTypography.bodySmall
                    ),
                    GestureDetector(
                      onTap: () => context.goNamed(AppRouteName.login),
                      child: const AppText(
                        'Sign in',
                        style: AppTypography.displaySmall
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),
        ),
      );
    }
  }
