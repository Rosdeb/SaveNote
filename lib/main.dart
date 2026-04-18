import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:notesave/Router/app_router.dart';

import 'Controller/NetworkService/networkservice.dart';
import 'Services/Auth/Auth_Services.dart';
import 'Utils/TokenServices/token_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TokenService().init();
  await TokenService().init();
  await AuthService.init();
  Get.put(NetworkController(), permanent: true);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _router = MyAppRouter.instance.router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      title: 'NoteApp',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
    );
  }
}
