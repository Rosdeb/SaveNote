import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notesave/Controller/HomeController/homeController.dart';
import 'package:notesave/Models/Note/noteitem.dart';

import '../../../../Utils/AppColor/app_colors.dart';
import '../../../../Utils/floatingbar/floatingbar.dart';
import '../../../Base/CustomTextfield/CustomTextfield.dart';
import '../../../Base/GridentButton/Appbutton.dart';

class EditNoteScreen extends StatefulWidget {
  final NoteModel note;
  final int index;

  const EditNoteScreen({
    super.key,
    required this.note,
    required this.index,
  });

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  final HomeController controller = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note.title);
    descriptionController = TextEditingController(text: widget.note.description);
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _updateNote() {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      FloatingErrorBar.show(context, message: "Please enter title and description");
      return;
    }

    controller.editNote(
      context,
      id: widget.note.id,
      index: widget.index,
      title: title,
      description: description,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppColors.White,
      appBar: AppBar(
        backgroundColor: AppColors.White,
        title: const Text('Edit Note'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? size.width * 0.15 : 16,
        ),
        child: Column(
          children: [
            CustomTextField(
              controller: titleController,
              hintText: "Enter title",
              prefixIcon: Icons.title,
              filColor: Colors.grey.withValues(alpha: 0.15),
            ),

            const SizedBox(height: 16),

            CustomTextField(
              controller: descriptionController,
              hintText: "Enter description",
              prefixIcon: Icons.description,
              maxLines: 6,
              filColor: Colors.grey.withValues(alpha: 0.15),
            ),

            const SizedBox(height: 30),

            Obx(() => GradientButton(
              text: "Update Note",
              isLoading: controller.isSavingNote.value,
              onTap: _updateNote,
              height: isTablet ? 65 : 52,
            )),
          ],
        ),
      ),
    );
  }
}