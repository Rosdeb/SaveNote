import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:notesave/Router/route_names.dart';
import 'package:notesave/Utils/AppColor/app_colors.dart';
import 'package:notesave/Utils/AppSpacing/app_spacing.dart';
import 'package:notesave/Views/Base/AppText/appText.dart';
import '../../../Controller/HomeController/homeController.dart';
import '../../../Models/Note/noteitem.dart';
import '../../../Utils/TokenServices/token_services.dart';
import '../../../Utils/Typography/app_typography.dart';
import '../../Base/IOSTapEffect/iosTapEffect.dart';
import 'base/Appdrawer.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  String name = '';
  String email = '';
  String image = '';

  final List<Map<String, String>> notes = [
    {
      'title': 'Meeting Notes',
      'subtitle': 'Discuss project timeline and next tasks',
    },
    {'title': 'Shopping List', 'subtitle': 'Milk, Bread, Eggs, Butter'},
    {'title': 'Daily Ideas', 'subtitle': 'Build a better notes UI for the app'},
    {'title': 'Workout Plan', 'subtitle': 'Chest, Back, Legs, Cardio'},
  ];
  final Homecontroller controller = Get.put(Homecontroller());

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray0,
      appBar: AppBar(
        backgroundColor: AppColors.gray0,
        title: const Text('My Notes'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.gray0,
        onPressed: () {
          context.pushNamed(AppRouteName.createnoteScreen);
        },
        child: Icon(Icons.add, color: AppColors.blue500),
        shape: CircleBorder(),
      ),
      drawer: Obx(
        () => AppDrawer(
          name: controller.name.value,
          email: controller.email.value,
          image: controller.image.value,
          isUploading: controller.isUploadingImage.value,
          onEditTap: controller.pickAndUploadProfileImage,
          context: context,
        ),
      ),
      body: Obx(() {
        if (controller.notesList.isEmpty) {
          return const Center(child: Text('No notes found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.notesList.length,
          itemBuilder: (context, index) {
            final note = controller.notesList[index];

           return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // note icon
                   const Icon(
                      Icons.sticky_note_2_outlined,
                      size: 20,
                      color: AppColors.blue500,
                    ),


                  const SizedBox(width: 12),

                  // content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          note.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // edit button
                  IosTapEffect(
                    onTap: () => context.pushNamed(
                      AppRouteName.editScreen,
                      extra: {'note': note, 'index': index},
                    ),
                    child:  const Icon(Icons.edit_outlined, size: 20, color: AppColors.blue500),
                  ),

                  const SizedBox(width: 8),

                  // delete button
                  Obx(() =>
                  controller.isDeleting.value && controller.deletingId.value == note.id
                      ? const SizedBox(
                    width: 34,
                    height: 34,
                    child: Center(child: CupertinoActivityIndicator()),
                  )
                      : IosTapEffect(
                    onTap: () => controller.deleteNote(context, id: note.id, index: index),
                    child:  const Icon(Icons.delete, size: 20, color: Colors.red),
                  ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}

