import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

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
    navigateToCameraScreen();
  }


  void navigateToCameraScreen() async{
    await Future.delayed(const Duration(seconds: 3));
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
            const SizedBox(height: 20),
            Text('Mimic', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
