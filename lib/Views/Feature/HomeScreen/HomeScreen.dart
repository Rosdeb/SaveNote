import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notesave/Utils/AppColor/app_colors.dart';
import 'package:notesave/Utils/AppSpacing/app_spacing.dart';
import 'package:notesave/Views/Base/AppText/appText.dart';
import '../../../Utils/TokenServices/token_services.dart';
import '../../../Utils/Typography/app_typography.dart';

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
    {
      'title': 'Shopping List',
      'subtitle': 'Milk, Bread, Eggs, Butter',
    },
    {
      'title': 'Daily Ideas',
      'subtitle': 'Build a better notes UI for the app',
    },
    {
      'title': 'Workout Plan',
      'subtitle': 'Chest, Back, Legs, Cardio',
    },
  ];

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {

    final email = await TokenService().getEmail();
    final name = 'rosdeb Koch';

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
      floatingActionButton: FloatingActionButton(onPressed: (){},child: const Icon(Icons.add,color: AppColors.blue500,),shape: CircleBorder(),),
      drawer: AppDrawer(
        name: "rosdeb",
        email: "rosdeb@exaple.com",
        image: image,
      ),
      body: notes.isEmpty
          ? const Center(
        child: Text('No notes found'),
      ) : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.sticky_note_2_outlined),
              title: Text(note['title'] ?? ''),
              subtitle: Text(note['subtitle'] ?? ''),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  final String name;
  final String email;
  final String image;

  const AppDrawer({
    super.key,
    required this.name,
    required this.email,
    required this.image,
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
                // Profile Image
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
                      child: image.isEmpty
                          ? const Icon(Icons.person, size: 30, color: Colors.white)
                          : null,
                    ),

                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.edit, size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),


                const SizedBox(width: 10),

                // Name + Email
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
            },
          ),
          const SizedBox(height: AppSpacing.s16,)
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
