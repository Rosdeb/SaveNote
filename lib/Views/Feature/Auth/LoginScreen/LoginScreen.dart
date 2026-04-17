import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:notesave/Utils/SuccessBar/successbar.dart';
import 'package:notesave/Utils/floatingbar/floatingbar.dart';

import '../../../../Controller/AuthController/AuthController.dart';
import '../../../../Utils/AppColor/app_colors.dart';
import '../../../../Utils/AppIcon/app_icon.dart';
import '../../../Base/AppText/appText.dart';
import '../../../Base/CustomTextfield/CustomTextfield.dart';
import '../../../Base/GridentButton/Appbutton.dart';
import '../../../Base/IOSTapEffect/iosTapEffect.dart';
import '../../../Base/OrDivider/ordivider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
                  SizedBox(height: screenHeight * 0.08),
                  _buildHeader(context, isDark, screenHeight, isTablet),
                  SizedBox(height: screenHeight * 0.09),
                  _buildLoginForm(context, isDark, isTablet),
                  SizedBox(height: screenHeight * 0.04),
                  _buildLoginButton(isTablet),
                  SizedBox(height: screenHeight * 0.03),
                  OrDivider(
                    text: "OR Log in with",
                    fontSize: isTablet ? 16 : 14,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  _buildSocialLoginButtons(isTablet),
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

  // ==================== Login Form Section ====================
  Widget _buildLoginForm(BuildContext context, bool isDark, bool isTablet) {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Column(
        children: [
          _buildEmailPasswordFields(),
          const SizedBox(height: 14),
          Obx(() => _buildFooterRow(context, isDark, isTablet)),
        ],
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
          prefixIconColor: AppColors.Green,
          filColor: Colors.grey.withValues(alpha: 0.15),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          prefixIconColor: AppColors.Green,
          controller: _signInController.passwordController,
          hintText: "Enter password",
          isPassword: true,
          prefixIcon: AppIcons.lock,
          filColor: Colors.grey.withValues(alpha: 0.15),
        ),
      ],
    );
  }

  Widget _buildFooterRow(BuildContext context, bool isDark, bool isTablet) {
    if (_signInController.selectedIndex.value == 0) {
      return Row(
        children: [
          Obx(() => _buildCheckbox(context, _signInController.accepted.value)),
          AppText(
            "I agree to the",
            fontSize: isTablet ? 13 : 11,
            color: isDark ? AppColors.DarkThemeText : AppColors.Black,
            fontWeight: FontWeight.w400,
          ),
          const SizedBox(width: 4),
          _buildPrivacyPolicyLink(isTablet),
          const Spacer(),
          _buildForgotPasswordLink(isTablet),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildCheckbox(BuildContext context, bool value) {
    return Transform.scale(
      scale: 1.1,
      child: Checkbox(
        value: value,
        onChanged: _signInController.toggleAccepted,
        activeColor: AppColors.Green,
        checkColor: Colors.white,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        side: BorderSide(
          color: Theme.of(context).textTheme.titleSmall?.color ?? Colors.grey,
          width: 0,
        ),
      ),
    );
  }

  Widget _buildPrivacyPolicyLink(bool isTablet) {
    return IntrinsicWidth(
      child: Column(
        children: [
          IosTapEffect(
            onTap: (){
            },
            child: AppText(
              "Privacy Policy",
              fontSize: isTablet ? 13 : 11,
              color: AppColors.Green1,
              fontWeight: FontWeight.w400,
            ),
          ),
          Container(height: 0.5, color: AppColors.Black),
        ],
      ),
    );
  }

  Widget _buildForgotPasswordLink(bool isTablet) {
    return IosTapEffect(
      onTap: (){

      },
      child: AppText(
        "Forgot Password?",
        fontSize: isTablet ? 13 : 11,
        color: AppColors.Green1,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // ==================== Login Button ====================
  Widget _buildLoginButton(bool isTablate) {
    return Obx(() => GradientButton(
      text: "Log in",
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

  // ==================== Social Login Buttons ====================
  Widget _buildSocialLoginButtons(bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Obx(() => _buildSocialButton(
          isLoading: _signInController.googleLoading.value,
          icon: AppIcons.google,
          onTap:(){

          },
          isTablet: isTablet,
        )),
        SizedBox(width: isTablet ? 24 : 16),
        Obx(() => _buildSocialButton(
          isLoading: _signInController.appleLoading.value,
          icon: AppIcons.apple,
          onTap: (){

          },
          isTablet: isTablet,
        )),
      ],
    );
  }

  Widget _buildSocialButton({
    required bool isLoading,
    required String icon,
    required VoidCallback onTap,
    required bool isTablet,
  }) {
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

          },
          child: IntrinsicWidth(
            child: Column(
              children: [
                AppText(
                  " Sign Up",
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
        AppText(
          "Welcome back !",
          fontSize: isTablet ? 28 : 24,
          color: isDark ? AppColors.DarkThemeText : AppColors.Black,
          fontWeight: FontWeight.bold,
        ),
        SizedBox(height: screenHeight * 0.02),
        AppText(
          "Log in to continue managing your account and exploring new features.",
          fontSize: isTablet ? 18 : 16,
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: FontWeight.w500,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

}