import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:notesave/Router/route_names.dart';

import '../../../../Utils/AppColor/app_colors.dart';
import '../../../../Utils/AppSpacing/app_spacing.dart';
import '../../../../Utils/TokenServices/token_services.dart';
import '../../../Base/AppText/appText.dart';
import '../../../Base/IOSTapEffect/iosTapEffect.dart';


class AppDrawer extends StatelessWidget {
  final String name;
  final String email;
  final String image;
  final bool isUploading;
  final VoidCallback onEditTap;
  final BuildContext context;

  const AppDrawer({
    super.key,
    required this.name,
    required this.email,
    required this.image,
    required this.isUploading,
    required this.onEditTap,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.gray50,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
            color: AppColors.gray50,
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage:
                      image.isNotEmpty ? NetworkImage(image) : null,
                      child: image.isEmpty
                          ? const Icon(Icons.person, size: 30, color: Colors.white)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IosTapEffect(
                        onTap: onEditTap,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: isUploading
                              ? const SizedBox(
                            height: 14,
                            width: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Icon(
                            Icons.edit,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        name,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      const SizedBox(height: 4),
                      AppText(
                        email,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _drawerItem(
            icon: Icons.note,
            title: 'My Notes',
            onTap: () {
              Navigator.pop(context);
            },
          ),
          _drawerItem(
            icon: Icons.settings,
            title: 'Settings',
            onTap: () {},
          ),
          const Spacer(),
          _drawerItem(
            icon: Icons.logout,
            title: 'Logout',
            onTap: () async {
              await TokenService().clearAll();
              context.goNamed(AppRouteName.login);
            },
          ),
          const SizedBox(height: AppSpacing.s16),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
    );
  }
}