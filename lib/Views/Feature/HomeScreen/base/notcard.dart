import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:go_router/go_router.dart';

import '../../../../Controller/HomeController/homeController.dart';
import '../../../../Models/Note/noteitem.dart';
import '../../../../Router/route_names.dart';
import '../../../../Utils/AppColor/app_colors.dart';
import '../../../Base/AppText/appText.dart';
import '../../../Base/IOSTapEffect/iosTapEffect.dart';

// ─── Note Card ─────────────────────────────────────────────────────────────

class NoteCard extends StatelessWidget {
  const NoteCard({
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
            Image.asset("assets/images/wirte.png",height: 25,width: 25,),
            const SizedBox(width: 12),
            _NoteCardContent(note: note),
            const SizedBox(width: 8),
            _EditButton(note: note, index: index),
            const SizedBox(width: 8),
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
      child: Image.asset("assets/images/edit.png",height: 18,width: 18,),
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
      final isThisNoteDeleting = controller.isDeletingNote.value && controller.deletingId.value == note.id;

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
        child: Image.asset("assets/images/delete (1).png",height: 20,width: 20,color: Colors.red,),
      );
    });
  }
}