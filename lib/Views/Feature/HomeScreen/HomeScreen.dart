import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:notesave/Router/route_names.dart';
import 'package:notesave/Utils/AppColor/app_colors.dart';
import 'package:notesave/Views/Base/AppText/appText.dart';
import '../../../Controller/HomeController/homeController.dart';
import '../../../Models/Note/noteitem.dart';
import '../../Base/IOSTapEffect/iosTapEffect.dart';
import 'base/Appdrawer.dart';
import 'base/Noteshimmer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use find() if already registered upstream; otherwise put().
    final HomeController controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: AppColors.gray0,
      appBar: _buildAppBar(),
      drawer: _HomeDrawer(controller: controller),
      floatingActionButton: _AddNoteFab(context: context),
      body: _NoteListBody(controller: controller),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.gray0,
      centerTitle: true,
      elevation: 0,
      title: const Text(
        'My Notes',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: Color(0xFF1A1A2E),
        ),
      ),
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

class _AddNoteFab extends StatelessWidget {
  const _AddNoteFab({required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: AppColors.gray0,
      shape: const CircleBorder(),
      onPressed: () => context.pushNamed(AppRouteName.createnoteScreen),
      child: const Icon(Icons.add, color: AppColors.blue500),
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
      // Initial loading
      if (controller.isLoadingNotes.value) {
        return _ShimmerList();
      }

      // Empty state
      if (controller.notesList.isEmpty) {
        return const _EmptyState();
      }

      return _NoteList(controller: controller);
    });
  }
}

// ─── Shimmer Placeholder ───────────────────────────────────────────────────

class _ShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: 6,
      itemBuilder: (_, __) => const NoteCardShimmer(),
    );
  }
}

// ─── Empty State ───────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.sticky_note_2_outlined,
            size: 56,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          AppText(
            'No notes yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 6),
          AppText(
            'Tap + to create your first note',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

// ─── Scrollable Note List ──────────────────────────────────────────────────

class _NoteList extends StatelessWidget {
  const _NoteList({required this.controller});

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
          // Pagination loader at the bottom
          if (index == controller.notesList.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CupertinoActivityIndicator()),
            );
          }

          final note = controller.notesList[index] as NoteModel;
          return _NoteCard(
            note: note,
            index: index,
            controller: controller,
          );
        },
      );
    });
  }
}

// ─── Note Card ─────────────────────────────────────────────────────────────

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.note,
    required this.index,
    required this.controller,
  });

  final NoteModel note;
  final int index;
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return IosTapEffect(
      onTap: () => context.pushNamed(
        AppRouteName.notedetails,
        extra: {
          'id': note.id ?? '',
          'title': note.title ?? '',
          'description': note.description ?? '',
        },
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.sticky_note_2_outlined,
              size: 20,
              color: AppColors.blue500,
            ),
            const SizedBox(width: 12),
            _NoteCardContent(note: note),
            const SizedBox(width: 8),
            _EditButton(note: note, index: index),
            const SizedBox(width: 4),
            _DeleteButton(note: note, index: index, controller: controller),
          ],
        ),
      ),
    );
  }
}

// ─── Note Card: Text Content ───────────────────────────────────────────────

class _NoteCardContent extends StatelessWidget {
  const _NoteCardContent({required this.note});

  final NoteModel note;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            note.title ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 4),
          AppText(
            note.description ?? '',
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
    );
  }
}

// ─── Note Card: Edit Button ────────────────────────────────────────────────

class _EditButton extends StatelessWidget {
  const _EditButton({required this.note, required this.index});

  final NoteModel note;
  final int index;

  @override
  Widget build(BuildContext context) {
    return IosTapEffect(
      onTap: () => context.pushNamed(
        AppRouteName.editScreen,
        extra: {'note': note, 'index': index},
      ),
      child: const Padding(
        padding: EdgeInsets.all(4),
        child: Icon(Icons.edit_outlined, size: 20, color: AppColors.blue500),
      ),
    );
  }
}

// ─── Note Card: Delete Button ──────────────────────────────────────────────

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({
    required this.note,
    required this.index,
    required this.controller,
  });

  final NoteModel note;
  final int index;
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isThisNoteDeleting =
          controller.isDeletingNote.value && controller.deletingId.value == note.id;

      if (isThisNoteDeleting) {
        return const SizedBox(
          width: 34,
          height: 34,
          child: Center(child: CupertinoActivityIndicator()),
        );
      }

      return IosTapEffect(
        onTap: () => controller.deleteNote(
          context,
          id: note.id ?? '',
          index: index,
        ),
        child: const Padding(
          padding: EdgeInsets.all(4),
          child: Icon(Icons.delete_outline, size: 20, color: Colors.red),
        ),
      );
    });
  }
}