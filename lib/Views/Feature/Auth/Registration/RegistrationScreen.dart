import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:notesave/Router/route_names.dart';
import 'package:notesave/Utils/AppSpacing/app_spacing.dart';

import '../../../../Controller/AuthController/AuthController.dart';
import '../../../../Utils/AppColor/app_colors.dart';
import '../../../../Utils/AppIcon/app_icon.dart';
import '../../../../Utils/floatingbar/floatingbar.dart';
import '../../../Base/AppText/appText.dart';
import '../../../Base/CustomTextfield/CustomTextfield.dart';
import '../../../Base/GridentButton/Appbutton.dart';
import '../../../Base/IOSTapEffect/iosTapEffect.dart';
import '../../../Base/OrDivider/ordivider.dart';
import '../../../Base/SocialButton/socialbutton.dart';

class Registrationscreen extends StatefulWidget {
  const Registrationscreen({super.key});

  @override
  State<Registrationscreen> createState() => _RegistrationscreenState();
}

class _RegistrationscreenState extends State<Registrationscreen> {

  final Authcontroller _signInController = Get.put(Authcontroller());


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: isDark ? AppColors.DarkThemeBackground : AppColors.White,
      body: SafeArea(
        top: false,
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? size.width * 0.15 : 18.0,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 600 : double.infinity,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.05),
                  _buildHeader(context, isDark, screenHeight, isTablet),
                  SizedBox(height: screenHeight * 0.05),
                  _buildEmailPasswordFields(),
                  SizedBox(height: screenHeight * 0.2),
                  _buildLoginButton(isTablet),
                  SizedBox(height: screenHeight * 0.03),
                  OrDivider(
                    text: "OR Log in with",
                    fontSize: isTablet ? 16 : 14,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(() => SocialButton(
                        isLoading: _signInController.googleLoading.value,
                        icon: AppIcons.google,
                        onTap:(){

                        },
                        isTablet: isTablet,
                      )),
                      SizedBox(width: isTablet ? 24 : 16),
                      Obx(() => SocialButton(
                        isLoading: _signInController.appleLoading.value,
                        icon: AppIcons.apple,
                        onTap: (){

                        },
                        isTablet: isTablet,
                      )),
                    ],
                  ),

                  SizedBox(height: screenHeight * 0.02),
                  _buildSignUpPrompt(context, isDark, isTablet),
                ],
              ),
            ),
          ),
        ),
      ),

    );
  }


  Widget _buildEmailPasswordFields() {
    return Column(
      children: [
        CustomTextField(
          controller: _signInController.nameController,
          hintText: "Enter name",
          prefixIcon: AppIcons.mailbox,
          prefixIconColor: AppColors.blue400,
          filColor: Colors.grey.withValues(alpha: 0.15),
        ),
        const SizedBox(height: AppSpacing.s16),
        CustomTextField(
          controller: _signInController.registeremailController,
          hintText: "Enter Email",
          prefixIcon: AppIcons.mailbox,
          prefixIconColor: AppColors.blue400,
          filColor: Colors.grey.withValues(alpha: 0.15),
        ),

        const SizedBox(height: AppSpacing.s16),

        CustomTextField(
          prefixIconColor: AppColors.blue400,
          controller: _signInController.passwordController,
          hintText: "Enter password",
          isPassword: true,
          prefixIcon: AppIcons.lock,
          filColor: Colors.grey.withValues(alpha: 0.15),
        ),
      ],
    );
  }

  // ==================== Login Button ====================
  Widget _buildLoginButton(bool isTablate) {
    return Obx(() => GradientButton(
      text: "Sign Up",
      height: isTablate ? 65 :52,
      isLoading: _signInController.isLoading.value,
      onTap: () async {
        HapticFeedback.lightImpact();
        if (_signInController.nameController.text.trim().isEmpty || _signInController.passwordController.text.trim().isEmpty) {
          FloatingErrorBar.show(context, message: "Please enter your name and password");
          return;
        }
        await _signInController.loginUser(
          context: context,
          name: _signInController.nameController.text.toString(),
          password: _signInController.passwordController.text.toString(),
        );
      },
    ),
    );
  }



  // ==================== Sign Up ====================
  Widget _buildSignUpPrompt(BuildContext context, bool isDark, bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppText(
          "Already have an account?",
          fontSize: isTablet ? 18 : 16,
          color: isDark ? AppColors.DarkThemeText : AppColors.Black,
          fontWeight: FontWeight.w500,
        ),
        IosTapEffect(
          onTap: (){
            context.goNamed(AppRouteName.login);
          },
          child: IntrinsicWidth(
            child: Column(
              children: [
                AppText(
                  " Sign In",
                  fontSize: isTablet ? 18 : 16,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                  fontWeight: FontWeight.bold,
                ),
                Container(
                  height: 1,
                  color: Theme.of(context).textTheme.titleLarge?.color ??
                      Colors.black,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==================== Header Section ====================
  Widget _buildHeader(
      BuildContext context,
      bool isDark,
      double screenHeight,
      bool isTablet,
      ) {
    return Column(
      children: [
        AppText("Create your account",
          fontSize: isTablet ? 35 : 28,
          color: isDark ? AppColors.DarkThemeText : AppColors.Black,
          fontWeight: FontWeight.bold,
        ),
        SizedBox(height: screenHeight * 0.02),
        AppText("Join us today and start saving your thoughts,\n ideas,and important notes in one secure\nand easy-to-use place.",
          fontSize: isTablet ? 18 : 16,
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: FontWeight.w500,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}