import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  CustomButton({super.key,required this.btnTitle,this.width,this.height,this.backgroundColor,this.textColor,this.textStyle,required this.onTap});
  final String btnTitle;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final TextStyle? textStyle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed:onTap,
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor??Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Container(
        alignment: Alignment.center,
        width: width??30,
        height: height??50,
        child: Text(
          btnTitle,
          textAlign: TextAlign.center,
          style:  textStyle??GoogleFonts.inter(color: textColor??Colors.white),
        ),
      ),
    );
  }
}
