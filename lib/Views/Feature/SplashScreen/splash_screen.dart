import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notesave/Utils/AppColor/app_colors.dart';
import 'package:notesave/Utils/AppSpacing/app_spacing.dart';
import 'package:notesave/Utils/Typography/app_typography.dart';
import 'package:notesave/Views/Base/AppText/appText.dart';

import '../../../Router/route_names.dart';
import '../../Base/CutomButton/Appbutton.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>{


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
        child: SafeArea(
          child: Column(
            children: [
              Image.asset("assets/images/note_save.png",),
              const SizedBox(height: AppSpacing.s16),
              const AppText("Welcome to Note Save",style: AppTypography.headlineH2, fontSize: 15,textAlign: TextAlign.center,),
              const SizedBox(height: AppSpacing.s16),
              const AppText("Capture ideas, write freely,\nand never lose a thought again.", fontSize: 16,textAlign: TextAlign.center,),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: () => context.goNamed(AppRouteName.login),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text(
                    'Get started',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.gray500,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
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
