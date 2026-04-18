import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:notesave/Controller/AuthController/AuthController.dart';
import 'package:notesave/Utils/floatingbar/floatingbar.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../../Utils/AppColor/app_colors.dart';
import '../../../Base/AppText/appText.dart';
import '../../../Base/GridentButton/Appbutton.dart';
import '../../../Base/IOSTapEffect/iosTapEffect.dart';


class VerifyScreen extends StatefulWidget {
  final String email;

  VerifyScreen({super.key, required this.email});


  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  TextEditingController pincode = TextEditingController();
  final Authcontroller controller = Get.find<Authcontroller>();

  @override
  void initState() {
    super.initState();
    controller.startTimer();
  }

  @override
  void dispose() {
    super.dispose();
    pincode.dispose();
    controller.timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: isDark ? AppColors.DarkThemeBackground : AppColors.White,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.DarkThemeBackground : AppColors.White,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            size: isTablet ? 24 : 21,
            color: isDark ? AppColors.DarkThemeText : AppColors.Black,
          ),
        ),
      ),
      body: SafeArea(
        child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? size.width * 0.15 : 20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isTablet ? 600 : double.infinity,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [

                      Align(
                        alignment: Alignment.center,
                        child: AppText(
                          "Verify OTP Now",
                          fontSize: isTablet ? 28 : 24,
                          color: isDark ? AppColors.DarkThemeText : AppColors.Black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: size.height * 0.01),
                      AppText(
                        "Onetime OTP has been sent to your registered email or phone number",
                        fontSize: isTablet ? 16 : 14,
                        color: isDark ? AppColors.DarkThemeText : AppColors.Black,
                        fontWeight: FontWeight.w500,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: size.height * 0.08),
                      SizedBox(
                        height: isTablet ? 90 : 80,
                        child: PinCodeEnter(context, isTablet,widget.email,pincode.text),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppText(
                            fontSize: isTablet ? 17 : 15,
                            "Didn't get the code?",
                            textAlign: TextAlign.center,
                            fontWeight: FontWeight.w400,
                            color: isDark ? AppColors.DarkThemeText : AppColors.Black,
                          ),
                          const SizedBox(width: 4),
                          Obx(
                                () => AppText(
                              fontSize: isTablet ? 17 : 15,
                              "${controller.start.value} sec",
                              textAlign: TextAlign.center,
                              fontWeight: FontWeight.w400,
                              color: AppColors.Red,
                            ),
                          ),
                          const Spacer(),
                          IntrinsicWidth(
                            child: Column(
                              children: [
                                IosTapEffect(
                                  onTap: () async {
                                    await controller.resendCode(context,widget.email);
                                  },
                                  child: AppText(
                                    "Resend",
                                    fontSize: isTablet ? 16 : 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.Red,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Container(
                                  height: 1,
                                  color: AppColors.Red,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.1),
                      Obx(() => GradientButton(
                          isLoading: controller.verifyLoading.value,
                          text: "Verify Code",
                          onTap: () async {
                            HapticFeedback.lightImpact();
                            if (controller.start.value == 0) {
                              FloatingErrorBar.show(context, message: "OTP expired. Please resend the code.");
                              return;
                            }
                            //----- verify -----//
                            await controller.verifyUser(context,widget.email, pincode.text);
                          },
                        )),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

    );
  }

  PinCodeTextField PinCodeEnter(BuildContext context, bool isTablet,String email , String code) {
    return PinCodeTextField(
      appContext: context,
      length: 6,
      enableActiveFill: true,
      showCursor: true,
      cursorColor: AppColors.Black,
      obscureText: false,
      textStyle: TextStyle(
        fontSize: isTablet ? 20 : 18,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).textTheme.headlineMedium?.color,
      ),
      controller: pincode,
      animationType: AnimationType.scale,
      keyboardType: TextInputType.number,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(12),
        borderWidth: 0,
        fieldHeight: isTablet ? 68 : 58,
        fieldWidth: isTablet ? 59 : 49,
        fieldOuterPadding: const EdgeInsets.symmetric(horizontal: 2),
        inactiveColor: AppColors.DarkGray,
        inactiveFillColor: AppColors.White,
        selectedFillColor: Colors.transparent,
        disabledColor: AppColors.DarkGray,
        activeFillColor: Colors.transparent,
        selectedColor: AppColors.DarkGray,
        activeColor: AppColors.blue400,
      ),
      hintCharacter: '-',
      animationDuration: const Duration(milliseconds: 100),
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      onChanged: (value) {
        // _controller.otpCode.value = value;
      },
        onCompleted: (value) async {
          if (value.length == 6) {
            await controller.verifyUser(context, widget.email, value);
          }
        }
    );
  }
}

const authOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Color(0xFF757575)),
  borderRadius: BorderRadius.all(Radius.circular(12)),
);