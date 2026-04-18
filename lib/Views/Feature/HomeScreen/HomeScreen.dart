import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:notesave/Router/route_names.dart';
import 'package:notesave/Utils/AppColor/app_colors.dart';
import 'package:notesave/Utils/AppSpacing/app_spacing.dart';
import 'package:notesave/Views/Base/AppText/appText.dart';
import '../../../Controller/HomeController/homeController.dart';
import '../../../Models/Note/noteitem.dart';
import '../../Base/IOSTapEffect/iosTapEffect.dart';
import 'base/Appdrawer.dart';
import 'base/Noteshimmer.dart';
import 'base/notcard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _spinController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700),);
  final HomeController controller = Get.put(HomeController());

  @override
  void initState() {
    super.initState();
    controller.fetchNotes();
    controller.loadUserData();
    controller.attachScrollListener();

    ever(controller.isLoadingNotes, (bool loading) {
      if (loading) {
        _spinController.repeat();
      } else {
        _spinController.stop();
        _spinController.reset();
      }
    });
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray0,
      appBar: _buildAppBar(),
      drawer: _HomeDrawer(controller: controller),
      floatingActionButton: AddNoteFab(context: context),
      body: _NoteListBody(controller: controller),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.gray0,
      centerTitle: true,
      elevation: 0,
      title: const AppText(
        'My Notes',
        fontWeight: FontWeight.w700,
        fontSize: 18,
        color: Color(0xFF1A1A2E),
      ),
      actions: [
         Obx(() => IosTapEffect(
          onTap: ()async {
            await controller.fetchNotes();
          },
          child: AnimatedRotation(
            turns: controller.isLoadingNotes.value ? 1 : 0,
            duration: const Duration(milliseconds: 600),
            child: RotationTransition(
              turns: _spinController,
              child: const Icon(Icons.refresh, color: Colors.black),
            ),
          ),
        )),
         const SizedBox(width: AppSpacing.s16,)
      ],
    );
  }
}

// ─── Drawer ────────────────────────────────────────────────────────────────

class _HomeDrawer extends StatelessWidget {
  const _HomeDrawer({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() => AppDrawer(
        name: controller.name.value,
        email: controller.email.value,
        image: controller.avatarUrl.value,
        isUploading: controller.isUploadingAvatar.value,
        onEditTap: controller.pickAndUploadAvatar,
        context: context,
      ),
    );
  }
}

// ─── FAB ───────────────────────────────────────────────────────────────────

class AddNoteFab extends StatelessWidget {
  const AddNoteFab({required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: AppColors.gray0,
      shape: const CircleBorder(),
      elevation: 3.5,
      onPressed: () => context.pushNamed(AppRouteName.createnoteScreen),
      child: const Icon(Icons.add, color: AppColors.blue500,size: 28,),
    );
  }
}

// ─── Note List Body ────────────────────────────────────────────────────────

class _NoteListBody extends StatelessWidget {
  const _NoteListBody({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingNotes.value) {
        return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: 6,
            itemBuilder: (_, __) => const NoteCardShimmer(),
        );
      }
      // Empty state
      if (controller.notesList.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sticky_note_2_outlined,
                size: 56,
                color: Colors.grey.shade300,
              ),
              const SizedBox(width: AppSpacing.s16,),
              AppText(
                'No notes yet',
                 fontSize: 16,
                 fontWeight: FontWeight.w600,
                 color: Colors.grey.shade400,

              ),
              const SizedBox(height: 6),
              AppText(
                'Tap + to create your first note',
                fontSize: 13,
                color: Colors.grey.shade400),
            ],
          ),
        );
      }
      return NoteList(controller: controller);
    });
  }
}


class NoteList extends StatelessWidget {
  const NoteList({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {

      final itemCount = controller.notesList.length + (controller.isLoadingMoreNotes.value ? 1 : 0);

      return ListView.builder(
        controller: controller.scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          //-----  Pagination
          if (index == controller.notesList.length) {
            return Obx(() => controller.isLoadingMoreNotes.value
                ? ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: 1,
              itemBuilder: (_, __) => const NoteCardShimmer(),
            ): const SizedBox.shrink());
          }
          final note = controller.notesList[index] as NoteModel;
          return NoteCard(
            note: note,
            index: index,
            controller: controller,
          );
        },
      );
    });
  }
}
