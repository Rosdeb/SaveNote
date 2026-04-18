import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:notesave/Controller/HomeController/homeController.dart';

import '../../../../Utils/AppColor/app_colors.dart';
import '../../../../Utils/floatingbar/floatingbar.dart';
import '../../../Base/AppText/appText.dart';
import '../../../Base/CustomTextfield/CustomTextfield.dart';
import '../../../Base/GridentButton/Appbutton.dart';

class CreateNoteScreen extends StatefulWidget {
  const CreateNoteScreen({super.key});

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final HomeController controller = Get.find<HomeController>();

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    if (title.isEmpty || description.isEmpty) {
      FloatingErrorBar.show(context, message: "Please enter title and description",);
      return;
    }
    controller.createNote(context,title: title,description: description);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppColors.White,
      appBar: AppBar(
        backgroundColor: AppColors.White,
        title: const Text('Create Note'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? size.width * 0.15 : 16,
        ),
        child: Column(
          children: [
            /// Title Field (Reusable Component)
            CustomTextField(
              controller: titleController,
              hintText: "Enter title",
              prefixIcon: Icons.title,
              filColor: Colors.grey.withValues(alpha: 0.15),
            ),

            const SizedBox(height: 16),

            /// Description Field (Reusable Component)
            CustomTextField(
              controller: descriptionController,
              hintText: "Enter description",
              prefixIcon: Icons.description,
              maxLines: 6,
              filColor: Colors.grey.withValues(alpha: 0.15),
            ),

            const SizedBox(height: 30),

            /// Save Button (Reusable Gradient Button)
            Obx(()=>GradientButton(
              text: "Save Note",
              isLoading: controller.isSavingNote.value,
              onTap: _saveNote,
              height: isTablet ? 65 : 52,
            ),),

          ],
        ),
      ),
    );
  }
}