import 'dart:io';
import 'dart:typed_data';

import 'package:face_editing_assignment/utility/utils.dart';
import 'package:face_editing_assignment/widget/custom_button.dart';
import 'package:face_editing_assignment/widget/draggable_circle_overlay.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as img;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

import 'constant/app_color.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({Key? key, required this.camera}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  Future<void>? _initializeControllerFuture;
  late List<CameraDescription> cameras;
  late int selectedCameraIndex;
  String? _takenImagePath;
  bool firstEyeOvalOverlay = false;
  bool secondEyeOvalOverlay = false;
  bool mouthOvalOverlay = false;
  bool takePictureAgain = false;

  WidgetsToImageController controller = WidgetsToImageController();
  Uint8List? bytes;

  @override
  void initState() {
    super.initState();

    _initializeCameras();
  }

  Future<void> _initializeCameras() async {
    cameras = await availableCameras();
    selectedCameraIndex = cameras.indexOf(widget.camera);
    _controller = CameraController(
      cameras[selectedCameraIndex],
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      String imagePath = image.path;
      if (_controller.description.lensDirection == CameraLensDirection.front) {
        // Load the image
        img.Image? originalImage =
            img.decodeImage(File(image.path).readAsBytesSync());

        // Flip the image horizontally
        img.Image flippedImage = img.flipHorizontal(originalImage!);

        // Save the flipped image to a file
        File flippedFile = File(image.path)
          ..writeAsBytesSync(img.encodeJpg(flippedImage));
        imagePath = flippedFile.path;
      }
      setState(() {
        _takenImagePath = imagePath;
      });
      await detectFaces(image.path);
    } catch (e) {
      print(e);
    }
  }

  Future<void> detectFaces(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final faceDetector = GoogleMlKit.vision.faceDetector();
    List<Face> faces = await faceDetector.processImage(inputImage);
    if (faces.isEmpty) {
      showCustomToast(context, "얼굴이 감지되지 않음");
      setState(() {
        // _takenImagePath=null;
        takePictureAgain = true;
      });
    } else if (faces.length > 1) {
      setState(() {
        // _takenImagePath=null;
        takePictureAgain = true;
        showCustomToast(context, "2개 이상의 얼굴이 감지되었어요!");
      });
    }
    faceDetector.close();
  }

  void _onSwitchCamera() {
    selectedCameraIndex =
        selectedCameraIndex < cameras.length - 1 ? selectedCameraIndex + 1 : 0;
    CameraDescription selectedCamera = cameras[selectedCameraIndex];
    _controller = CameraController(
      selectedCamera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }

  Widget _buildCameraPreview() {
    if (_takenImagePath != null) {
      return WidgetsToImage(
        controller: controller,
        child: Stack(
          children: [
            Image.file(File(_takenImagePath!)),
            firstEyeOvalOverlay
                ? DraggableEyeOverlay(
                    diameter: 40,
                    imageHeight: MediaQuery.of(context).size.height * 0.65)
                : Container(),
            secondEyeOvalOverlay
                ? DraggableEyeOverlay(
                    diameter: 40,
                    imageHeight: MediaQuery.of(context).size.height * 0.65)
                : Container(),
            mouthOvalOverlay
                ? DraggableEyeOverlay(
                    diameter: 56,
                    imageHeight: MediaQuery.of(context).size.height * 0.65)
                : Container(),
          ],
        ),
      );
    }

    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            _controller.value.isInitialized) {
          return CameraPreview(_controller);
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: bgColor,
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {},
              ),
            ],
            leading: _takenImagePath != null
                ? IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: _redirectToTakePicture,
                  )
                : Container(),
          ),
          body: Container(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                _buildCameraPreview(),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: (_takenImagePath == null)
                      ? _clickingCameraComponent()
                      : _cameraImageTakenComponent(),
                )
              ],
            ),
          )


          ),
    );
  }

  Widget _clickingCameraComponent() {
    return Container(
      color: bgColor,
      height: MediaQuery.of(context).size.height * 0.3,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Expanded(
              child: Center(
            child: GestureDetector(
              onTap: takePicture,
              child: Image.asset(
                "assets/camera_button.png",
                height: 64,
                width: 64,
              ),
            ),
          )),
          Expanded(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _openGallery,
                child: Image.asset(
                  "assets/gallery.png",
                  height: 24,
                  width: 24,
                ),
              ),
              GestureDetector(
                onTap: _onSwitchCamera,
                child: Image.asset(
                  "assets/orientation_camera.png",
                  height: 24,
                  width: 24,
                ),
              ),
            ],
          ))

          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //   children: [
          //     Image.asset("assets/camera_button.png",width: 64,height: 64,),
          //     FloatingActionButton(
          //       heroTag: 'switchCameraButton',
          //       onPressed: _onSwitchCamera,
          //       child: Icon(Icons.switch_camera),
          //     ),
          //   ],
          // ),
          //
          // CustomButton(
          //   btnTitle: '눈',
          // ),
          // CustomButton(
          //   btnTitle: '입',
          // ),
        ],
      ),
    );
  }

  Widget _cameraImageTakenComponent() {
    return Container(
      color: bgColor,
      height: MediaQuery.of(context).size.height * 0.3,
      padding: EdgeInsets.all(24.0),
      child: Column(
        children: [
          Expanded(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: _redirectToTakePicture,
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/back_btn.png",
                        height: 24,
                        width: 24,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        "다시찍기",
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: Colors.white),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                takePictureAgain
                    ? Container()
                    : Row(
                        children: [
                          CustomButton(
                            btnTitle: '눈',
                            textColor: Colors.black,
                            onTap: () {
                              setState(() {
                                firstEyeOvalOverlay = true;
                                secondEyeOvalOverlay = true;
                              });
                            },
                            textStyle: GoogleFonts.notoSans(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          takePictureAgain
                              ? Container()
                              : CustomButton(
                                  btnTitle: '입',
                                  onTap: () {
                                    setState(() {
                                      mouthOvalOverlay = true;
                                    });
                                  },
                                  textStyle: GoogleFonts.notoSans(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                ),
                        ],
                      ),
              ],
            ),
          ),
          takePictureAgain
              ? Container()
              : CustomButton(
                  btnTitle: '저장하기',
                  width: double.infinity,
                  height: 25,
                  backgroundColor: (firstEyeOvalOverlay && secondEyeOvalOverlay && mouthOvalOverlay)
                      ? const Color(0xFF7B8FF7)
                      : const Color(0xFFD3D3D3),
                  onTap: () async{
                    if (firstEyeOvalOverlay && secondEyeOvalOverlay && mouthOvalOverlay) {


                      final bytes = await controller.capture();
                      final result =
                      await ImageGallerySaver.saveImage(bytes!);
                      await Utils.saveImageToGallery(_takenImagePath!);
                      print(result);
                      showCustomToast(context,"성공적으로 저장되었습니다");
                    }else{
                      if(!firstEyeOvalOverlay && !mouthOvalOverlay) {
                        showCustomToast(context,"눈과 입을 선택하세요");
                      }

                      if(!firstEyeOvalOverlay){
                        showCustomToast(context,"눈 선택");
                      }
                      if(!mouthOvalOverlay){
                        showCustomToast(context,"입 선택");
                      }

                    }
                  },
                ),
        ],
      ),
    );
  }

  void showCustomToast(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 100.0, // Adjust the position as needed
        left: 80,
        right: 80,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 240,
            height: 70,
            // padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20.0), // Rounded corners
            ),
            child: Center(
              child: Text(
                message,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  void _redirectToTakePicture() {
    setState(() {
      _takenImagePath = null;
      takePictureAgain = false;
      firstEyeOvalOverlay = false;
      secondEyeOvalOverlay = false;
      mouthOvalOverlay = false;
    });
  }


  Future<bool> _onWillPop() async{
    if (_takenImagePath != null) {
      // Reset states
      setState(() {
        _takenImagePath = null;
        takePictureAgain = false;
        firstEyeOvalOverlay = false;
        secondEyeOvalOverlay = false;
        mouthOvalOverlay = false;
      });
      return false;
    }
    return true;
  }

  void _openGallery() async{
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {

        setState(() {
          _takenImagePath = image.path;
        });
        print("Image path: ${image.path}");
        await detectFaces(image.path);
      }
    } catch (e) {
      print("Failed to pick image: $e");
    }
  }



}
