import 'package:flutter/material.dart';

class FolderShape extends StatelessWidget {
  const FolderShape({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: FolderClipper(),
      child: Container(
        width: 80,
        height: 80,
        color: Colors.amber,
      ),
    );
  }
}

class FolderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    double width = size.width;
    double height = size.height;
    double tabHeight = height * 0.25;
    double tabWidth = width * 0.5;
    double radius = 10.0;

    path.moveTo(0, height - radius);

    path.arcToPoint(Offset(radius, height),
        radius: Radius.circular(radius), clockwise: false);

    path.lineTo(width - radius, height);

    path.arcToPoint(Offset(width, height - radius),
        radius: Radius.circular(radius), clockwise: false);

    path.lineTo(width, tabHeight + radius);

    path.arcToPoint(Offset(width - radius, tabHeight),
        radius: Radius.circular(radius), clockwise: false);

    path.lineTo(tabWidth + radius, tabHeight);

    path.arcToPoint(Offset(tabWidth, tabHeight - radius),
        radius: Radius.circular(radius), clockwise: false);

    path.lineTo(radius, 10);

    path.arcToPoint(Offset(0, radius),
        radius: Radius.circular(radius), clockwise: false);

    path.lineTo(0, height - radius);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
