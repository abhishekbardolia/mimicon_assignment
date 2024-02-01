import 'package:camera/camera.dart';
import 'package:face_editing_assignment/splashscreen.dart';
import 'package:flutter/material.dart';

import 'camera_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
    orElse: () => cameras.first, // Fallback to the first camera if a front camera is not available.
  );

  runApp(MyApp(camera: frontCamera));
}



class MyApp extends StatelessWidget {
  final CameraDescription camera;

  MyApp({Key? key, required this.camera}) : super(key: key);


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mimicon Assignment Abhishek',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreen(camera: camera),
    );
  }
}


