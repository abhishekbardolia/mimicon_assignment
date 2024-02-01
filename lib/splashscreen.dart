import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'camera_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key, required this.camera}) : super(key: key);
  final CameraDescription camera;
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  void requestPermissions() async {
    await Future.delayed(Duration(seconds: 3)); // Display the splash screen for a few seconds

    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.camera,
      Permission.microphone
    ].request();

    if (statuses[Permission.storage]!.isGranted && statuses[Permission.camera]!.isGranted) {
      navigateToCameraScreen();
    } else {
      print('Permissions not granted');
    }
  }

  void navigateToCameraScreen() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CameraScreen(camera: widget.camera,)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/logo.png', width: 100, height: 100),
            SizedBox(height: 20),
            Text('Mimicon', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
