import 'package:flutter/material.dart';

import '../constant/app_color.dart';

// class DraggableEyeOverlay extends StatefulWidget {
//   final double diameter;
//
//   const DraggableEyeOverlay({Key? key, required this.diameter}) : super(key: key);
//
//   @override
//   _DraggableEyeOverlayState createState() => _DraggableEyeOverlayState();
// }
//
// class _DraggableEyeOverlayState extends State<DraggableEyeOverlay> {
//   Offset position = Offset.zero;
//
//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       left: position.dx,
//       top: position.dy,
//       child: GestureDetector(
//         onPanUpdate: (details) {
//           setState(() {
//             position += details.delta;
//           });
//         },
//         child:  Container(
//           width: widget.diameter,
//           height: widget.diameter,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.all(Radius.circular(widget.diameter / 2)), // Elliptical shape
//             border: Border.all(color: Colors.red, width: 2),
//           ),
//         ),
//
//       ),
//     );
//   }
// }

class DraggableEyeOverlay extends StatefulWidget {
  final double diameter;
  final double imageHeight;

  const DraggableEyeOverlay({
    Key? key,
    required this.diameter,
    required this.imageHeight,
  }) : super(key: key);

  @override
  _DraggableEyeOverlayState createState() => _DraggableEyeOverlayState();
}

class _DraggableEyeOverlayState extends State<DraggableEyeOverlay> {
  Offset position = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            // Calculate the new position
            double newX = position.dx + details.delta.dx;
            double newY = position.dy + details.delta.dy;

            // Constrain the movement within the image boundaries
            newX = newX.clamp(0, screenSize.width  - widget.diameter);
            newY = newY.clamp(0, widget.imageHeight - widget.diameter);

            position = Offset(newX, newY);
          });
        },
        child: Container(
          height: widget.diameter/2,
          width: widget.diameter,
          // margin: EdgeInsets.only(top: 40, left: 40, right: 40),
          decoration: new BoxDecoration(
            color: greenEye.withOpacity(0.5),
            borderRadius: new BorderRadius.all(Radius.elliptical(widget.diameter, (widget.diameter/2)),
          ),
        ),
      ),
      )
    );
  }
}

